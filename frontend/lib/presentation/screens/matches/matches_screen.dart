import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/match_model.dart';
import '../../../data/providers/match_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/chat_provider.dart';

class MatchesScreen extends ConsumerStatefulWidget {
  const MatchesScreen({super.key});

  @override
  ConsumerState<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends ConsumerState<MatchesScreen> {
  String? _openingMatchId;

  Future<void> _navigateToChat(MatchModel match) async {
    final chatRepo = ref.read(chatRepositoryProvider);
    setState(() {
      _openingMatchId = match.id;
    });
    try {
      final chatRoom = await chatRepo.getChatRoomByMatch(match.id);
      if (!mounted) return;
      context.push('/chat/${chatRoom.id}', extra: chatRoom);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể mở chat: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _openingMatchId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final matchesAsync = ref.watch(matchesProvider);
    final currentUserId = ref.watch(authProvider).user?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(matchesProvider),
          ),
        ],
      ),
      body: matchesAsync.when(
        data: (matches) {
          if (matches.isEmpty) {
            return const Center(child: Text('Chưa có match nào.'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(matchesProvider);
              await ref.read(matchesProvider.future);
            },
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final match = matches[index];
                final otherUser = currentUserId != null
                    ? match.getOtherUser(currentUserId)
                    : match.users.isNotEmpty
                        ? match.users.first
                        : null;
                final isOpening = _openingMatchId == match.id;
                return GestureDetector(
                  onTap: otherUser == null || isOpening
                      ? null
                      : () => _navigateToChat(match),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius:
                                const BorderRadius.vertical(top: Radius.circular(16)),
                            child: otherUser?.primaryPhoto != null
                                ? Stack(
                                    children: [
                                      Positioned.fill(
                                        child: CachedNetworkImage(
                                          imageUrl: otherUser!.primaryPhoto!,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              const Center(child: CircularProgressIndicator()),
                                        ),
                                      ),
                                      if (isOpening)
                                        const Positioned.fill(
                                          child: ColoredBox(
                                            color: Colors.black38,
                                            child: Center(
                                              child: CircularProgressIndicator(color: Colors.white),
                                            ),
                                          ),
                                        ),
                                    ],
                                  )
                                : const Icon(Icons.person, size: 60),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            otherUser?.fullName ?? 'Không xác định',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 8),
              Text('Không thể tải danh sách match.\n$error', textAlign: TextAlign.center),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.refresh(matchesProvider),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

