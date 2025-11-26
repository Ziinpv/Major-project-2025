import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

import 'edit_profile_controller.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  late final TextEditingController _bioController;
  late final TextEditingController _jobController;
  late final TextEditingController _schoolController;
  ProviderSubscription<EditProfileState>? _stateSub;

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController();
    _jobController = TextEditingController();
    _schoolController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(editProfileProvider.notifier).load();
    });

    _stateSub = ref.listenManual<EditProfileState>(
      editProfileProvider,
      (previous, next) {
        if (previous?.bio != next.bio && _bioController.text != next.bio) {
          _bioController.text = next.bio;
        }
        if (previous?.job != next.job && _jobController.text != next.job) {
          _jobController.text = next.job;
        }
        if (previous?.school != next.school && _schoolController.text != next.school) {
          _schoolController.text = next.school;
        }
      },
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _stateSub?.close();
    _bioController.dispose();
    _jobController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.remove_red_eye_outlined),
            tooltip: 'Xem thử',
            onPressed: () => _openPreview(state),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(editProfileProvider.notifier).load(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSectionTitle('Ảnh của bạn'),
                  const SizedBox(height: 8),
                  _buildPhotosGrid(state),
                  const SizedBox(height: 12),
                  if (state.photos.length < 6)
                    OutlinedButton.icon(
                      onPressed: state.uploadingPhoto ? null : _pickPhoto,
                      icon: state.uploadingPhoto
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add_a_photo),
                      label: const Text('Thêm ảnh'),
                    ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: state.savingPhotos
                        ? null
                        : () async {
                            try {
                              await ref.read(editProfileProvider.notifier).savePhotos();
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Đã lưu ảnh thành công')),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Không thể lưu ảnh: $e')),
                              );
                            }
                          },
                    child: state.savingPhotos
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Lưu ảnh'),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Giới thiệu'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _bioController,
                    maxLength: 300,
                    maxLines: 4,
                    onChanged: (value) =>
                        ref.read(editProfileProvider.notifier).updateBio(value),
                    decoration: const InputDecoration(
                      hintText: 'Chia sẻ đôi chút về bạn...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _jobController,
                    onChanged: (value) =>
                        ref.read(editProfileProvider.notifier).updateJob(value),
                    decoration: const InputDecoration(
                      labelText: 'Công việc',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _schoolController,
                    onChanged: (value) =>
                        ref.read(editProfileProvider.notifier).updateSchool(value),
                    decoration: const InputDecoration(
                      labelText: 'Trường học',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Sở thích (tối đa 5)'),
                  const SizedBox(height: 8),
                  _buildInterests(state),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Lifestyle (tối đa 5)'),
                  const SizedBox(height: 8),
                  _buildLifestyle(state),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: state.savingInfo
                        ? null
                        : () async {
                            try {
                              await ref.read(editProfileProvider.notifier).saveInfo();
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Đã lưu thông tin')),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Không thể lưu thông tin: $e')),
                              );
                            }
                          },
                    child: state.savingInfo
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Lưu thông tin'),
                  ),
                  const SizedBox(height: 32),
                  OutlinedButton.icon(
                    onPressed: () => _openPreview(state),
                    icon: const Icon(Icons.remove_red_eye),
                    label: const Text('Xem trước'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildPhotosGrid(EditProfileState state) {
    if (state.photos.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Center(
          child: Text('Chưa có ảnh nào. Hãy thêm ảnh để mọi người biết về bạn hơn!'),
        ),
      );
    }

    return ReorderableGridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      onReorder: (oldIndex, newIndex) {
        ref.read(editProfileProvider.notifier).reorderPhotos(oldIndex, newIndex);
      },
      children: [
        for (final photo in state.photos)
          _PhotoTile(
            key: ValueKey(photo.id ?? photo.url),
            photo: photo,
            onRemove: () => ref.read(editProfileProvider.notifier).removePhoto(photo),
          ),
      ],
    );
  }

  Widget _buildInterests(EditProfileState state) {
    if (state.interestsCatalog.isEmpty) {
      return const Text('Không thể tải danh sách sở thích.');
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: state.interestsCatalog.map((option) {
        final isSelected = state.selectedInterests.contains(option.id);
        return FilterChip(
          label: Text(option.label),
          selected: isSelected,
          onSelected: (_) {
            try {
              ref.read(editProfileProvider.notifier).toggleInterest(option.id);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.toString())),
              );
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildLifestyle(EditProfileState state) {
    if (state.lifestyleCatalog.isEmpty) {
      return const Text('Không thể tải danh sách lifestyle.');
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: state.lifestyleCatalog.map((option) {
        final isSelected = state.selectedLifestyle.contains(option.id);
        return FilterChip(
          label: Text(option.label),
          selected: isSelected,
          onSelected: (_) {
            try {
              ref.read(editProfileProvider.notifier).toggleLifestyle(option.id);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.toString())),
              );
            }
          },
        );
      }).toList(),
    );
  }

  Future<void> _pickPhoto() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1280);
    if (file == null) return;
    try {
      await ref.read(editProfileProvider.notifier).addPhotoFromFile(file.path);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã thêm ảnh mới')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể thêm ảnh: $e')),
      );
    }
  }

  Future<void> _openPreview(EditProfileState state) async {
    final data = ref.read(editProfileProvider.notifier).buildPreviewData();
    if (data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng tải hồ sơ trước khi xem trước')),
      );
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ProfilePreviewCard(data: data),
          ),
        );
      },
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    super.key,
    required this.photo,
    required this.onRemove,
  });

  final EditablePhoto photo;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: photo.url,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  Container(color: Colors.grey.shade200),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.broken_image),
              ),
            ),
          ),
        ),
        if (photo.isPrimary)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Ảnh chính',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        Positioned(
          top: 4,
          right: 4,
          child: IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Colors.black54,
              padding: EdgeInsets.zero,
            ),
            icon: const Icon(Icons.close, color: Colors.white, size: 18),
            onPressed: onRemove,
          ),
        ),
      ],
    );
  }
}

class ProfilePreviewCard extends StatelessWidget {
  const ProfilePreviewCard({super.key, required this.data});

  final ProfilePreviewData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned.fill(
              child: data.photoUrl != null
                  ? CachedNetworkImage(
                      imageUrl: data.photoUrl!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.person, size: 80),
                    ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${data.name}, ${data.age}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (data.bio != null && data.bio!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        data.bio!,
                        style: const TextStyle(color: Colors.white70),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (data.job != null && data.job!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        data.job!,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                    if (data.school != null && data.school!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        data.school!,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                    if (data.location?.city != null &&
                        data.location?.province != null &&
                        data.location!.city!.isNotEmpty &&
                        data.location!.province!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${data.location!.city}, ${data.location!.province}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                    if (data.interests.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: data.interests
                            .take(4)
                            .map(
                              (interest) => Chip(
                                label: Text(interest),
                                backgroundColor: Colors.white.withOpacity(0.3),
                                labelStyle: const TextStyle(color: Colors.white),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    if (data.lifestyle.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: data.lifestyle
                            .take(4)
                            .map(
                              (item) => Chip(
                                label: Text(item),
                                backgroundColor: Colors.black.withOpacity(0.4),
                                labelStyle: const TextStyle(color: Colors.white),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

