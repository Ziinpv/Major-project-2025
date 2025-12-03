import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/localization_extension.dart';
import '../../../data/models/chat_room_model.dart';
import '../../../data/models/discovery_filters.dart';
import '../../../data/models/filter_option.dart';
import '../../../data/models/match_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/discovery_filters_provider.dart';
import '../../../data/providers/user_provider.dart';
import '../../../data/repositories/swipe_repository.dart';
import '../../widgets/swipe_card.dart';

class DiscoveryScreen extends ConsumerStatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  ConsumerState<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends ConsumerState<DiscoveryScreen> {
  final PageController _pageController = PageController();
  final SwipeRepository _swipeRepository = SwipeRepository();
  List<UserModel> _users = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isSwiping = false;
  ProviderSubscription<DiscoveryFilters>? _filtersSubscription;
  DiscoveryFilters _currentFilters = const DiscoveryFilters();

  @override
  void initState() {
    super.initState();
    _currentFilters = ref.read(discoveryFiltersProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _filtersSubscription = ref.listenManual<DiscoveryFilters>(
        discoveryFiltersProvider,
        (previous, next) {
          if (previous?.toStorageString() == next.toStorageString()) return;
          _currentFilters = next;
          _loadUsers();
        },
        fireImmediately: false,
      );
      _loadUsers();
    });
  }

  @override
  void dispose() {
    _filtersSubscription?.close();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(userRepositoryProvider);
      final users = await repository.getDiscovery(_currentFilters);

      if (!mounted) return;
      setState(() {
        _users = users;
        _isLoading = false;
        _currentIndex = 0;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _handleSwipe(String action) async {
    if (_users.isEmpty || _isSwiping) return;
    final user = _users[_currentIndex];

    setState(() {
      _isSwiping = true;
    });

    try {
      final result = await _swipeRepository.swipe(userId: user.id, action: action);

      if (!mounted) return;
      if (result['isMatch'] == true) {
        MatchModel? match;
        ChatRoomModel? chatRoom;
        try {
          if (result['match'] != null) {
            match = MatchModel.fromJson(Map<String, dynamic>.from(result['match'] as Map));
          }
          if (result['chatRoom'] != null) {
            chatRoom = ChatRoomModel.fromJson(Map<String, dynamic>.from(result['chatRoom'] as Map));
          }
        } catch (e) {
          debugPrint('Failed to parse match/chatRoom: $e');
        }
        await _showMatchDialog(user, match: match, chatRoom: chatRoom);
      } else {
        final l10n = context.l10n;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              action == 'like'
                  ? l10n.swipe_liked(user.firstName)
                  : action == 'superlike'
                      ? l10n.swipe_superliked(user.firstName)
                      : l10n.swipe_passed(user.firstName),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      setState(() {
        _users.removeAt(_currentIndex);
        if (_users.isEmpty) {
          _currentIndex = 0;
        } else if (_currentIndex >= _users.length) {
          _currentIndex = _users.length - 1;
        }
      });

      if (_users.isEmpty) {
        _loadUsers();
      }
    } catch (e) {
      if (!mounted) return;
      final l10n = context.l10n;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.swipe_action_failed}: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSwiping = false;
        });
      }
    }
  }

  Future<void> _showMatchDialog(
    UserModel user, {
    MatchModel? match,
    ChatRoomModel? chatRoom,
  }) async {
    final l10n = context.l10n;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.swipe_match_title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.swipe_match_message(user.firstName)),
            if (match?.matchedAt != null) ...[
              const SizedBox(height: 8),
              Text(
                l10n.swipe_match_time(match!.matchedAt.toString()),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
        actions: [
          if (chatRoom != null) ...[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.push('/chat/${chatRoom.id}', extra: chatRoom);
              },
              child: Text(l10n.swipe_chat_now),
            ),
          ],
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.common_close),
          ),
        ],
      ),
    );
  }

  Future<void> _openFilterSheet() async {
    final interests = await ref.read(interestOptionsProvider.future);
    final lifestyles = await ref.read(lifestyleOptionsProvider.future);

    if (!mounted) return;
    final result = await showModalBottomSheet<DiscoveryFilters>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DiscoveryFiltersSheet(
        initialFilters: _currentFilters,
        interestOptions: interests,
        lifestyleOptions: lifestyles,
      ),
    );

    if (result != null) {
      await ref.read(discoveryFiltersProvider.notifier).updateFilters(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final filters = ref.watch(discoveryFiltersProvider);
    final profile = ref.watch(userProfileProvider).maybeWhen(
          data: (user) => user,
          orElse: () => null,
        );
    final showProfileReminder = _shouldShowProfileReminder(profile);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.discovery_title)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  '${l10n.discovery_load_error}.\n$_errorMessage',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadUsers,
                  child: Text(l10n.common_retry),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_users.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.discovery_title),
          actions: [
            _buildSortMenu(filters),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _openFilterSheet,
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadUsers,
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  l10n.discovery_empty,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _loadUsers,
                  child: Text(l10n.discovery_reload),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.discovery_title),
        actions: [
          _buildSortMenu(filters),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _openFilterSheet,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(top: showProfileReminder ? 90 : 0),
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return SwipeCard(
                    user: user,
                    onSwipeLeft: () => _handleSwipe('pass'),
                    onSwipeRight: () => _handleSwipe('like'),
                    onSwipeUp: () => _handleSwipe('superlike'),
                  );
                },
              ),
            ),
          ),
          if (showProfileReminder)
            Positioned(
              top: 10,
              left: 16,
              right: 16,
              child: _buildProfileReminderBanner(),
            ),
          if (filters.onlyOnline)
            Positioned(
              top: showProfileReminder ? 100 : 16,
              right: 16,
              child: Chip(
                avatar: const Icon(Icons.bolt, color: Colors.green, size: 18),
                label: Text(l10n.discovery_online_only),
              ),
            ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.close,
                  color: Colors.red,
                  onTap: _isSwiping ? null : () => _handleSwipe('pass'),
                ),
                _buildActionButton(
                  icon: Icons.star,
                  color: Colors.blue,
                  onTap: _isSwiping ? null : () => _handleSwipe('superlike'),
                ),
                _buildActionButton(
                  icon: Icons.favorite,
                  color: Colors.pink,
                  onTap: _isSwiping ? null : () => _handleSwipe('like'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortMenu(DiscoveryFilters filters) {
    final l10n = context.l10n;
    final sortLabel = filters.sort == 'newest' ? l10n.discovery_sort_newest : l10n.discovery_sort_best_match;
    return PopupMenuButton<String>(
      tooltip: l10n.discovery_sort,
      initialValue: filters.sort,
      onSelected: (value) async {
        await ref.read(discoveryFiltersProvider.notifier).setSort(value);
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'best',
          child: Text(l10n.discovery_sort_best_match),
        ),
        PopupMenuItem(
          value: 'newest',
          child: Text(l10n.discovery_sort_newest),
        ),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sort),
          const SizedBox(width: 4),
          Text(sortLabel),
        ],
      ),
    );
  }

  bool _shouldShowProfileReminder(UserModel? profile) {
    if (profile == null) return false;
    final missingInterests = profile.interests.isEmpty;
    final missingLifestyle = profile.lifestyle.isEmpty;
    return missingInterests || missingLifestyle;
  }

  Widget _buildProfileReminderBanner() {
    final l10n = context.l10n;
    return Card(
      color: Colors.orange.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.tips_and_updates, color: Colors.deepOrange),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.discovery_complete_profile_title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.discovery_complete_profile_subtitle,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => context.push('/profile/edit'),
              child: Text(l10n.discovery_update_button),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: onTap == null ? Colors.grey.shade200 : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: onTap == null ? Colors.grey : color,
          size: 30,
        ),
      ),
    );
  }

}

class DiscoveryFiltersSheet extends StatefulWidget {
  final DiscoveryFilters initialFilters;
  final List<FilterOption> interestOptions;
  final List<FilterOption> lifestyleOptions;

  const DiscoveryFiltersSheet({
    super.key,
    required this.initialFilters,
    required this.interestOptions,
    required this.lifestyleOptions,
  });

  @override
  State<DiscoveryFiltersSheet> createState() => _DiscoveryFiltersSheetState();
}

class _DiscoveryFiltersSheetState extends State<DiscoveryFiltersSheet> {
  late RangeValues _ageRange;
  late double _distance;
  late bool _noDistanceLimit;
  late Set<String> _showMe;
  late Set<String> _selectedLifestyles;
  late Set<String> _selectedInterests;
  late bool _onlyOnline;

  @override
  void initState() {
    super.initState();
    _ageRange = RangeValues(
      widget.initialFilters.ageMin.toDouble(),
      widget.initialFilters.ageMax.toDouble(),
    );
    _distance = widget.initialFilters.distance.toDouble();
    _noDistanceLimit = widget.initialFilters.noDistanceLimit;
    _showMe = widget.initialFilters.showMe.toSet();
    if (_showMe.isEmpty) {
      _showMe = {'male', 'female'};
    }
    _selectedLifestyles = widget.initialFilters.lifestyle.toSet();
    _selectedInterests = widget.initialFilters.interests.toSet();
    _onlyOnline = widget.initialFilters.onlyOnline;
  }

  void _reset() {
    setState(() {
      _ageRange = const RangeValues(18, 35);
      _distance = 50;
      _noDistanceLimit = false;
      _showMe = {'male', 'female'};
      _selectedLifestyles.clear();
      _selectedInterests.clear();
      _onlyOnline = false;
    });
  }

  void _toggleInterest(String id, bool selected) {
    setState(() {
      if (selected) {
        if (_selectedInterests.length >= 5) {
          final l10n = context.l10n;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.discovery_filters_interests_limit)),
          );
          return;
        }
        _selectedInterests.add(id);
      } else {
        _selectedInterests.remove(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final genderOptions = {
      'male': l10n.profile_setup_gender_male,
      'female': l10n.profile_setup_gender_female,
      'non-binary': l10n.profile_setup_gender_non_binary,
      'other': l10n.profile_setup_gender_other,
    };

    return FractionallySizedBox(
      heightFactor: 0.92,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.discovery_filters_title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: _reset,
                  child: Text(l10n.discovery_filter_reset),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(l10n.discovery_filters_age_range),
            RangeSlider(
              values: _ageRange,
              min: 18,
              max: 60,
              divisions: 42,
              labels: RangeLabels(
                '${_ageRange.start.round()}',
                '${_ageRange.end.round()}',
              ),
              onChanged: (values) => setState(() => _ageRange = values),
            ),
            const SizedBox(height: 16),
            Text(l10n.discovery_filters_gender_show),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: genderOptions.entries.map((entry) {
                final isSelected = _showMe.contains(entry.key);
                return FilterChip(
                  label: Text(entry.value),
                  selected: isSelected,
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        _showMe.add(entry.key);
                      } else if (_showMe.length > 1) {
                        _showMe.remove(entry.key);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(l10n.discovery_filters_lifestyle_match),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: widget.lifestyleOptions.map((option) {
                final isSelected = _selectedLifestyles.contains(option.id);
                return FilterChip(
                  label: Text(option.label),
                  selected: isSelected,
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        _selectedLifestyles.add(option.id);
                      } else {
                        _selectedLifestyles.remove(option.id);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(l10n.discovery_filters_interests_common),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: widget.interestOptions.map((option) {
                final isSelected = _selectedInterests.contains(option.id);
                return FilterChip(
                  label: Text(option.label),
                  selected: isSelected,
                  onSelected: (value) => _toggleInterest(option.id, value),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(l10n.discovery_filters_distance_max),
            Slider(
              value: _distance,
              min: 5,
              max: 200,
              divisions: 39,
              label: _noDistanceLimit ? l10n.discovery_filters_no_limit : '${_distance.round()} km',
              onChanged: _noDistanceLimit ? null : (value) => setState(() => _distance = value),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.discovery_filters_no_distance_limit),
              subtitle: Text(l10n.discovery_filters_no_distance_subtitle),
              value: _noDistanceLimit,
              onChanged: (value) => setState(() => _noDistanceLimit = value),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.discovery_online_only),
              value: _onlyOnline,
              onChanged: (value) => setState(() => _onlyOnline = value),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_showMe.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.discovery_filters_gender_required)),
                    );
                    return;
                  }
                  Navigator.of(context).pop(
                    widget.initialFilters.copyWith(
                      ageMin: _ageRange.start.round(),
                      ageMax: _ageRange.end.round(),
                      distance: _distance.round(),
                      noDistanceLimit: _noDistanceLimit,
                      lifestyle: _selectedLifestyles.toList(),
                      interests: _selectedInterests.toList(),
                      showMe: _showMe.toList(),
                      onlyOnline: _onlyOnline,
                    ),
                  );
                },
                child: Text(l10n.discovery_filters_apply),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

