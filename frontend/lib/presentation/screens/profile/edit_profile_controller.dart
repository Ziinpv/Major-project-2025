import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/api_service.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/user_provider.dart';
import '../../../data/repositories/user_repository.dart';

class EditablePhoto {
  final String? id;
  final String url;
  final int order;
  final bool isPrimary;

  const EditablePhoto({
    this.id,
    required this.url,
    required this.order,
    required this.isPrimary,
  });

  EditablePhoto copyWith({
    String? id,
    String? url,
    int? order,
    bool? isPrimary,
  }) {
    return EditablePhoto(
      id: id ?? this.id,
      url: url ?? this.url,
      order: order ?? this.order,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }
}

class SelectableOption {
  final String id;
  final String label;

  SelectableOption({required this.id, required this.label});

  factory SelectableOption.fromJson(Map<String, dynamic> json) {
    return SelectableOption(
      id: json['id'] as String,
      label: json['label'] as String,
    );
  }
}

class EditProfileState {
  final bool isLoading;
  final bool savingPhotos;
  final bool savingInfo;
  final bool uploadingPhoto;
  final List<EditablePhoto> photos;
  final Set<String> removedPhotoIds;
  final List<SelectableOption> interestsCatalog;
  final List<SelectableOption> lifestyleCatalog;
  final List<String> selectedInterests;
  final List<String> selectedLifestyle;
  final String bio;
  final String job;
  final String school;
  final UserModel? profile;
  final String? error;

  const EditProfileState({
    this.isLoading = true,
    this.savingPhotos = false,
    this.savingInfo = false,
    this.uploadingPhoto = false,
    this.photos = const [],
    this.removedPhotoIds = const <String>{},
    this.interestsCatalog = const [],
    this.lifestyleCatalog = const [],
    this.selectedInterests = const [],
    this.selectedLifestyle = const [],
    this.bio = '',
    this.job = '',
    this.school = '',
    this.profile,
    this.error,
  });

  EditProfileState copyWith({
    bool? isLoading,
    bool? savingPhotos,
    bool? savingInfo,
    bool? uploadingPhoto,
    List<EditablePhoto>? photos,
    Set<String>? removedPhotoIds,
    List<SelectableOption>? interestsCatalog,
    List<SelectableOption>? lifestyleCatalog,
    List<String>? selectedInterests,
    List<String>? selectedLifestyle,
    String? bio,
    String? job,
    String? school,
    UserModel? profile,
    String? error,
  }) {
    return EditProfileState(
      isLoading: isLoading ?? this.isLoading,
      savingPhotos: savingPhotos ?? this.savingPhotos,
      savingInfo: savingInfo ?? this.savingInfo,
      uploadingPhoto: uploadingPhoto ?? this.uploadingPhoto,
      photos: photos ?? this.photos,
      removedPhotoIds: removedPhotoIds ?? this.removedPhotoIds,
      interestsCatalog: interestsCatalog ?? this.interestsCatalog,
      lifestyleCatalog: lifestyleCatalog ?? this.lifestyleCatalog,
      selectedInterests: selectedInterests ?? this.selectedInterests,
      selectedLifestyle: selectedLifestyle ?? this.selectedLifestyle,
      bio: bio ?? this.bio,
      job: job ?? this.job,
      school: school ?? this.school,
      profile: profile ?? this.profile,
      error: error,
    );
  }
}

class EditProfileNotifier extends StateNotifier<EditProfileState> {
  EditProfileNotifier(this._ref)
      : _userRepository = _ref.read(userRepositoryProvider),
        super(const EditProfileState());

  final Ref _ref;
  final UserRepository _userRepository;
  final ApiService _api = ApiService();

  Future<void> load() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final interestsFuture = state.interestsCatalog.isEmpty
          ? _loadInterestsCatalog()
          : Future.value(state.interestsCatalog);
      final lifestyleFuture = state.lifestyleCatalog.isEmpty
          ? _loadLifestyleCatalog()
          : Future.value(state.lifestyleCatalog);

      final interests = await interestsFuture;
      final lifestyles = await lifestyleFuture;

      final profile = await _userRepository.getProfile();
      state = state.copyWith(
        isLoading: false,
        interestsCatalog: interests,
        lifestyleCatalog: lifestyles,
        profile: profile,
        photos: _mapPhotos(profile.photos),
        selectedInterests: List<String>.from(profile.interests),
        selectedLifestyle: List<String>.from(profile.lifestyle),
        bio: profile.bio ?? '',
        job: profile.job ?? '',
        school: profile.school ?? '',
        removedPhotoIds: {},
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<List<SelectableOption>> _loadInterestsCatalog() async {
    final data = await rootBundle.loadString('assets/data/interests.json');
    final raw = json.decode(data) as List;
    return raw.map((item) => SelectableOption.fromJson(item)).toList();
  }

  Future<List<SelectableOption>> _loadLifestyleCatalog() async {
    final data = await rootBundle.loadString('assets/data/lifestyles.json');
    final raw = json.decode(data) as List;
    return raw.map((item) => SelectableOption.fromJson(item)).toList();
  }

  List<EditablePhoto> _mapPhotos(List<PhotoModel> photos) {
    return photos
        .map(
          (photo) => EditablePhoto(
            id: photo.id,
            url: photo.url,
            order: photo.order,
            isPrimary: photo.isPrimary,
          ),
        )
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  void reorderPhotos(int oldIndex, int newIndex) {
    final list = List<EditablePhoto>.from(state.photos);
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    state = state.copyWith(photos: _normalizePhotos(list));
  }

  void removePhoto(EditablePhoto photo) {
    final list = List<EditablePhoto>.from(state.photos)..remove(photo);
    final removed = Set<String>.from(state.removedPhotoIds);
    if (photo.id != null) {
      removed.add(photo.id!);
    }
    state = state.copyWith(
      photos: _normalizePhotos(list),
      removedPhotoIds: removed,
    );
  }

  void addPhotoFromUrl(String url) {
    if (state.photos.length >= 6) return;
    final list = List<EditablePhoto>.from(state.photos)
      ..add(
        EditablePhoto(
          url: url,
          id: null,
          order: state.photos.length,
          isPrimary: false,
        ),
      );
    state = state.copyWith(photos: _normalizePhotos(list));
  }

  List<EditablePhoto> _normalizePhotos(List<EditablePhoto> items) {
    final normalized = <EditablePhoto>[];
    for (var i = 0; i < items.length; i++) {
      normalized.add(
        items[i].copyWith(
          order: i,
          isPrimary: i == 0,
        ),
      );
    }
    return normalized;
  }

  Future<String> uploadPhoto(String filePath) async {
    final response = await _api.uploadFile('/upload/image', filePath, fieldName: 'image');
    final url = response.data['data']?['url'] as String?;
    if (url == null) {
      throw Exception('Không thể lấy URL ảnh sau khi upload');
    }
    return url;
  }

  Future<void> addPhotoFromFile(String filePath) async {
    try {
      state = state.copyWith(uploadingPhoto: true);
      final url = await uploadPhoto(filePath);
      addPhotoFromUrl(url);
    } finally {
      state = state.copyWith(uploadingPhoto: false);
    }
  }

  Future<void> savePhotos() async {
    if (state.photos.isEmpty) {
      throw Exception('Vui lòng thêm ít nhất một ảnh');
    }

    try {
      state = state.copyWith(savingPhotos: true);

      final payloadPhotos = state.photos
          .map((photo) => {
                if (photo.id != null) 'id': photo.id,
                'url': photo.url,
                'order': photo.order,
                'isPrimary': photo.isPrimary,
              })
          .toList();

      final updatedUser = await _userRepository.updateProfilePhotos(
        photos: payloadPhotos,
        removedPhotoIds: state.removedPhotoIds.toList(),
      );

      state = state.copyWith(
        savingPhotos: false,
        photos: _mapPhotos(updatedUser.photos),
        removedPhotoIds: {},
        profile: updatedUser,
      );
      _ref.read(authProvider.notifier).updateUserLocally(updatedUser);
      _ref.invalidate(userProfileProvider);
    } catch (e) {
      state = state.copyWith(savingPhotos: false);
      rethrow;
    }
  }

  void updateBio(String value) {
    state = state.copyWith(bio: value);
  }

  void updateJob(String value) {
    state = state.copyWith(job: value);
  }

  void updateSchool(String value) {
    state = state.copyWith(school: value);
  }

  void toggleInterest(String id) {
    final selected = List<String>.from(state.selectedInterests);
    if (selected.contains(id)) {
      selected.remove(id);
    } else {
      if (selected.length >= 5) {
        throw Exception('Bạn chỉ có thể chọn tối đa 5 sở thích');
      }
      selected.add(id);
    }
    state = state.copyWith(selectedInterests: selected);
  }

  void toggleLifestyle(String id) {
    final selected = List<String>.from(state.selectedLifestyle);
    if (selected.contains(id)) {
      selected.remove(id);
    } else {
      if (selected.length >= 5) {
        throw Exception('Bạn chỉ có thể chọn tối đa 5 lifestyle');
      }
      selected.add(id);
    }
    state = state.copyWith(selectedLifestyle: selected);
  }

  Future<void> saveInfo() async {
    try {
      state = state.copyWith(savingInfo: true);
      final payload = {
        'bio': state.bio,
        'job': state.job,
        'school': state.school,
        'interests': state.selectedInterests,
        'lifestyle': state.selectedLifestyle,
      };
      final updatedUser = await _userRepository.updateProfile(payload);
      state = state.copyWith(
        savingInfo: false,
        profile: updatedUser,
        photos: _mapPhotos(updatedUser.photos),
      );
      _ref.read(authProvider.notifier).updateUserLocally(updatedUser);
      _ref.invalidate(userProfileProvider);
    } catch (e) {
      state = state.copyWith(savingInfo: false);
      rethrow;
    }
  }

  ProfilePreviewData? buildPreviewData() {
    final profile = state.profile;
    if (profile == null) return null;
    final primaryPhoto = state.photos.isNotEmpty ? state.photos.first.url : null;
    final interestLabels = state.selectedInterests.map((id) {
      final option =
          state.interestsCatalog.firstWhere((opt) => opt.id == id, orElse: () => SelectableOption(id: id, label: id));
      return option.label;
    }).toList();
    final lifestyleLabels = state.selectedLifestyle.map((id) {
      final option = state.lifestyleCatalog
          .firstWhere((opt) => opt.id == id, orElse: () => SelectableOption(id: id, label: id));
      return option.label;
    }).toList();
    return ProfilePreviewData(
      name: profile.fullName,
      age: profile.age,
      bio: state.bio,
      job: state.job,
      school: state.school,
      interests: interestLabels,
      lifestyle: lifestyleLabels,
      location: profile.location,
      photoUrl: primaryPhoto,
    );
  }
}

class ProfilePreviewData {
  final String name;
  final int age;
  final String? bio;
  final String? job;
  final String? school;
  final List<String> interests;
  final List<String> lifestyle;
  final LocationModel? location;
  final String? photoUrl;

  ProfilePreviewData({
    required this.name,
    required this.age,
    required this.bio,
    required this.job,
    required this.school,
    required this.interests,
    required this.lifestyle,
    required this.location,
    required this.photoUrl,
  });
}

final editProfileProvider =
    StateNotifierProvider<EditProfileNotifier, EditProfileState>((ref) {
  return EditProfileNotifier(ref);
});

