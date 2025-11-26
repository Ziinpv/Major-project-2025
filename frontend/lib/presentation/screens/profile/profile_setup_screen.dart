import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../core/services/api_service.dart';
import '../../../data/providers/auth_provider.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  final TextEditingController _addressController = TextEditingController();
  int _currentPage = 0;

  // Form fields
  String? _selectedGender;
  final List<String> _selectedInterests = [];
  String? _bio;
  final List<XFile> _photos = [];
  bool _isLoading = false;

  // Location data
  final List<Map<String, dynamic>> _provinceCityData = [];
  bool _isLocationDataLoading = true;
  String? _locationDataError;
  String? _selectedProvince;
  String? _selectedCity;

  final List<String> _genders = ['male', 'female', 'non-binary', 'other'];
  final List<String> _interestOptions = [
    'photography',
    'travel',
    'coffee',
    'hiking',
    'music',
    'coding',
    'reading',
    'cooking',
    'sports',
    'art',
  ];

  @override
  void initState() {
    super.initState();
    _loadProvinceCityData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadProvinceCityData() async {
    if (mounted) {
      setState(() {
        _isLocationDataLoading = true;
        _locationDataError = null;
      });
    }

    try {
      final jsonString = await rootBundle.loadString('assets/data/vn_locations.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final parsed = jsonList.map((item) {
        return {
          'province': item['province'] as String,
          'cities': List<String>.from(item['cities'] as List),
        };
      }).toList();

      if (!mounted) return;
      setState(() {
        _provinceCityData
          ..clear()
          ..addAll(parsed);
        _isLocationDataLoading = false;
        _locationDataError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLocationDataLoading = false;
        _locationDataError = 'Không thể tải dữ liệu tỉnh/thành: $e';
      });
    }
  }

  List<String> _citiesForProvince(String province) {
    final match = _provinceCityData.firstWhere(
      (element) => element['province'] == province,
      orElse: () => {'cities': <String>[]},
    );
    final cities = match['cities'];
    if (cities is List) {
      return cities.cast<String>();
    }
    return [];
  }

  void _onProvinceChanged(String? province) {
    setState(() {
      _selectedProvince = province;
      _selectedCity = null;
    });
  }

  void _onCityChanged(String? city) {
    setState(() {
      _selectedCity = city;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _photos.add(image);
      });
    }
  }

  // Location is now selected manually via dropdowns, so no GPS methods are required.

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitProfile();
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _submitProfile() async {
    // Validate required fields
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn giới tính')),
      );
      _pageController.jumpToPage(0);
      return;
    }

    if (_photos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng thêm ít nhất một ảnh')),
      );
      _pageController.jumpToPage(2);
      return;
    }

    if (_selectedProvince == null || _selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn tỉnh/thành và thành phố')),
      );
      _pageController.jumpToPage(3);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final api = ApiService();
      final userRepo = UserRepository();

      // Upload photos
      final List<String> photoUrls = [];
      for (int i = 0; i < _photos.length; i++) {
        try {
          final response = await api.uploadFile(
            '/upload/image',
            _photos[i].path,
            fieldName: 'image', // Backend expects 'image' field name
          );
          if (response.statusCode == 200 || response.statusCode == 201) {
            final url = response.data['data']?['url'];
            if (url != null) {
              photoUrls.add(url);
              print('Successfully uploaded photo $i: $url');
            } else {
              print('Warning: No URL in response for photo $i: ${response.data}');
            }
          } else {
            print('Error uploading photo $i: Status ${response.statusCode}, Data: ${response.data}');
          }
        } catch (e) {
          print('Error uploading photo $i: $e');
          // Continue with other photos even if one fails
        }
      }

      if (photoUrls.isEmpty) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể upload ảnh. Vui lòng thử lại.'),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      final cleanedAddress = _addressController.text.trim();

      // Cập nhật ảnh profile (sử dụng endpoint chuyên biệt)
      final photosPayload = photoUrls.asMap().entries.map((e) => {
            'url': e.value,
            'isPrimary': e.key == 0,
            'order': e.key,
          }).toList();
      await userRepo.updateProfilePhotos(photos: photosPayload);

      // Cập nhật các field text cơ bản
      final profileData = <String, dynamic>{
        'gender': _selectedGender,
        'interests': _selectedInterests,
        if (_bio != null && _bio!.isNotEmpty) 'bio': _bio,
      };

      await userRepo.updateProfile(profileData);

      // Cập nhật location
      await userRepo.updateLocation(
        province: _selectedProvince!,
        city: _selectedCity!,
        address: cleanedAddress.isNotEmpty ? cleanedAddress : null,
        country: 'Vietnam',
      );

      // Refresh user profile
      await ref.read(authProvider.notifier).refreshUser();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hoàn tất thiết lập hồ sơ!')),
        );
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Step ${_currentPage + 1} of 4'),
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousPage,
              )
            : null,
      ),
      body: Form(
        key: _formKey,
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) => setState(() => _currentPage = index),
          children: [
            _buildGenderPage(),
            _buildInterestsPage(),
            _buildPhotosPage(),
            _buildLocationPage(),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _nextPage,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE91E63),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(_currentPage == 3 ? 'Hoàn tất' : 'Tiếp theo'),
        ),
      ),
    );
  }

  Widget _buildGenderPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Giới tính của bạn?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          ..._genders.map((gender) => RadioListTile<String>(
                title: Text(gender[0].toUpperCase() + gender.substring(1)),
                value: gender,
                groupValue: _selectedGender,
                onChanged: (value) => setState(() => _selectedGender = value),
              )),
        ],
      ),
    );
  }

  Widget _buildInterestsPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chọn sở thích của bạn',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _interestOptions.map((interest) {
              final isSelected = _selectedInterests.contains(interest);
              return FilterChip(
                label: Text(interest),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedInterests.add(interest);
                    } else {
                      _selectedInterests.remove(interest);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thêm ảnh của bạn',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _photos.length + 1,
              itemBuilder: (context, index) {
                if (index == _photos.length) {
                  return GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add_photo_alternate, size: 48),
                    ),
                  );
                }
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(_photos[index].path),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          setState(() => _photos.removeAt(index));
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationPage() {
    if (_isLocationDataLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_locationDataError != null) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thiết lập vị trí',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              _locationDataError!,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProvinceCityData,
              child: const Text('Thử tải lại dữ liệu'),
            )
          ],
        ),
      );
    }

    final provinces = _provinceCityData.map((e) => e['province'] as String).toList();
    final cities = _selectedProvince == null ? <String>[] : _citiesForProvince(_selectedProvince!);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thiết lập vị trí',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Chọn tỉnh/thành và thành phố bạn đang sinh sống. Không cần cấp quyền vị trí.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Tỉnh / Thành phố',
              border: OutlineInputBorder(),
            ),
            isExpanded: true,
            initialValue: _selectedProvince,
            items: provinces
                .map((province) => DropdownMenuItem(
                      value: province,
                      child: Text(province),
                    ))
                .toList(),
            onChanged: _onProvinceChanged,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Thành phố / Quận / Thị xã',
              border: OutlineInputBorder(),
            ),
            isExpanded: true,
            initialValue: _selectedCity,
            items: cities
                .map((city) => DropdownMenuItem(
                      value: city,
                      child: Text(city),
                    ))
                .toList(),
            onChanged: _selectedProvince == null ? null : _onCityChanged,
            disabledHint: const Text('Chọn tỉnh/thành trước'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Địa chỉ cụ thể (tuỳ chọn)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          if (_selectedProvince != null && _selectedCity != null)
            Card(
              child: ListTile(
                leading: const Icon(Icons.location_on),
                title: Text('$_selectedCity, $_selectedProvince'),
                subtitle: Text(
                  (_addressController.text.trim().isNotEmpty
                      ? _addressController.text.trim()
                      : 'Việt Nam'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

