import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/user_model.dart';
import 'user_profile_detail_modal.dart';

class SwipeCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final VoidCallback? onSwipeUp;

  const SwipeCard({
    super.key,
    required this.user,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onSwipeUp,
  });

  void _showProfileDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UserProfileDetailModal(user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showProfileDetail(context),
      onPanUpdate: (details) {
        // Handle swipe gestures
        if (details.delta.dx > 10) {
          onSwipeRight?.call();
        } else if (details.delta.dx < -10) {
          onSwipeLeft?.call();
        } else if (details.delta.dy < -10) {
          onSwipeUp?.call();
        }
      },
      child: Container(
        margin: const EdgeInsets.all(16),
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
            fit: StackFit.expand,
            children: [
              // Photo
              if (user.primaryPhoto != null)
                CachedNetworkImage(
                  imageUrl: user.primaryPhoto!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                )
              else
                Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.person, size: 100),
                ),
              // Gradient overlay (ở trên để tên dễ đọc)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Gradient overlay (ở dưới để vị trí dễ đọc)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.5),
                      ],
                    ),
                  ),
                ),
              ),
              // Match score badge (góc trên phải)
              if (user.matchScore != null)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE91E63).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${user.matchScore!.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              // Tên user (góc trên trái)
              Positioned(
                top: 16,
                left: 16,
                right: 80, // Tránh che bởi match score badge
                child: Text(
                  '${user.firstName}${user.lastName != null && user.lastName!.isNotEmpty ? ' ${user.lastName}' : ''}, ${user.age}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Vị trí và khoảng cách (góc dưới trái, tách riêng)
              Positioned(
                bottom: 100, // Tránh che bởi các nút action
                left: 16,
                right: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vị trí
                    if (user.location?.city != null || user.location?.province != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              [
                                user.location?.city,
                                user.location?.province,
                              ].where((e) => e != null && e.isNotEmpty).join(', '),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                shadows: [
                                  Shadow(
                                    color: Colors.black54,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    // Khoảng cách (xuống dòng riêng)
                    if (user.distanceKm != null) ...[
                      if (user.location?.city != null || user.location?.province != null)
                        const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.straighten,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${user.distanceKm!.toStringAsFixed(1)} km',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

