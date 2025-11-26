import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/providers/user_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ của bạn'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/profile/edit'),
          ),
        ],
      ),
      body: profileAsync.when(
        data: (user) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(userProfileProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (user.primaryPhoto != null)
                AspectRatio(
                  aspectRatio: 3 / 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      imageUrl: user.primaryPhoto!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: Colors.grey.shade200),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.broken_image, size: 48),
                    ),
                  ),
                )
              else
                Container(
                  height: 200,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey.shade200,
                  ),
                  child: const Icon(Icons.person, size: 64),
                ),
              const SizedBox(height: 16),
              Text(
                '${user.fullName}, ${user.age}',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (user.location?.city != null && user.location?.province != null)
                Text(
                  '${user.location!.city}, ${user.location!.province}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              const SizedBox(height: 16),
              if ((user.bio ?? '').isNotEmpty) ...[
                const Text(
                  'Giới thiệu',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(user.bio!),
                const SizedBox(height: 12),
              ],
              if ((user.job ?? '').isNotEmpty) ...[
                const Text(
                  'Công việc',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(user.job!),
                const SizedBox(height: 12),
              ],
              if ((user.school ?? '').isNotEmpty) ...[
                const Text(
                  'Trường học',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(user.school!),
                const SizedBox(height: 12),
              ],
              if (user.interests.isNotEmpty) ...[
                const Text(
                  'Sở thích',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: user.interests
                      .map((interest) => Chip(label: Text(interest)))
                      .toList(),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.push('/profile/edit'),
                icon: const Icon(Icons.edit),
                label: const Text('Chỉnh sửa hồ sơ'),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text('Không thể tải hồ sơ: $error', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ref.refresh(userProfileProvider),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

