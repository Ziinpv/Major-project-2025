import 'package:flutter/material.dart';

import 'discovery_filters.dart';

class DiscoveryFilterSheet extends StatefulWidget {
  final DiscoveryFilters initialFilters;
  final List<FilterOption> interestOptions;
  final List<FilterOption> lifestyleOptions;

  const DiscoveryFilterSheet({
    super.key,
    required this.initialFilters,
    required this.interestOptions,
    required this.lifestyleOptions,
  });

  @override
  State<DiscoveryFilterSheet> createState() => _DiscoveryFilterSheetState();
}

class _DiscoveryFilterSheetState extends State<DiscoveryFilterSheet> {
  late RangeValues _ageRange;
  late double _distance;
  late Set<String> _selectedShowMe;
  late Set<String> _selectedLifestyle;
  late Set<String> _selectedInterests;
  late bool _onlyOnline;
  late String _sort;

  static const _genderOptions = {
    'male': 'Nam',
    'female': 'Nữ',
    'non-binary': 'Phi nhị nguyên',
    'other': 'Khác',
  };

  static const _sortOptions = {
    'best': 'Gợi ý tốt nhất',
    'newest': 'Người mới',
  };

  @override
  void initState() {
    super.initState();
    _ageRange = RangeValues(
      widget.initialFilters.ageMin.toDouble(),
      widget.initialFilters.ageMax.toDouble(),
    );
    _distance = widget.initialFilters.distance.toDouble();
    _selectedShowMe = widget.initialFilters.showMe.toSet();
    _selectedLifestyle = widget.initialFilters.lifestyle.toSet();
    _selectedInterests = widget.initialFilters.interests.toSet();
    _onlyOnline = widget.initialFilters.onlyOnline;
    _sort = widget.initialFilters.sort;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Bộ lọc nâng cao',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      final defaults = DiscoveryFilters.defaults();
                      _ageRange = RangeValues(
                        defaults.ageMin.toDouble(),
                        defaults.ageMax.toDouble(),
                      );
                      _distance = defaults.distance.toDouble();
                      _selectedShowMe = defaults.showMe.toSet();
                      _selectedLifestyle = defaults.lifestyle.toSet();
                      _selectedInterests = defaults.interests.toSet();
                      _onlyOnline = defaults.onlyOnline;
                      _sort = defaults.sort;
                    });
                  },
                  child: const Text('Đặt lại'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('Độ tuổi mong muốn'),
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
            const SizedBox(height: 12),
            _buildSectionTitle('Khoảng cách tối đa (${_distance.round()} km)'),
            Slider(
              value: _distance,
              min: 5,
              max: 200,
              divisions: 39,
              onChanged: (value) => setState(() => _distance = value),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('Muốn gặp'),
            Wrap(
              spacing: 8,
              children: _genderOptions.entries.map((entry) {
                final selected = _selectedShowMe.contains(entry.key);
                return FilterChip(
                  label: Text(entry.value),
                  selected: selected,
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        _selectedShowMe.add(entry.key);
                      } else {
                        _selectedShowMe.remove(entry.key);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('Phong cách sống'),
            _buildOptionsWrap(
              options: widget.lifestyleOptions,
              selected: _selectedLifestyle,
              maxSelection: 5,
              onSelectionChanged: (id) => _toggleSelection(_selectedLifestyle, id, max: 5),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('Sở thích chung'),
            _buildOptionsWrap(
              options: widget.interestOptions,
              selected: _selectedInterests,
              maxSelection: 5,
              onSelectionChanged: (id) => _toggleSelection(_selectedInterests, id, max: 5),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Chỉ hiện người đang online'),
              value: _onlyOnline,
              onChanged: (value) => setState(() => _onlyOnline = value),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('Sắp xếp kết quả'),
            DropdownButton<String>(
              value: _sort,
              isExpanded: true,
              items: _sortOptions.entries
                  .map((entry) => DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _sort = value);
                }
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleApply,
                icon: const Icon(Icons.check),
                label: const Text('Áp dụng'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildOptionsWrap({
    required List<FilterOption> options,
    required Set<String> selected,
    required void Function(String id) onSelectionChanged,
    int? maxSelection,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selected.contains(option.id);
        return FilterChip(
          label: Text(option.label),
          selected: isSelected,
          onSelected: (_) => onSelectionChanged(option.id),
        );
      }).toList(),
    );
  }

  void _toggleSelection(Set<String> target, String id, {int? max}) {
    setState(() {
      if (target.contains(id)) {
        target.remove(id);
        return;
      }

      if (max != null && target.length >= max) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chỉ chọn tối đa $max mục.')),
        );
        return;
      }

      target.add(id);
    });
  }

  void _handleApply() {
    final filters = widget.initialFilters.copyWith(
      ageMin: _ageRange.start.round(),
      ageMax: _ageRange.end.round(),
      distance: _distance.round(),
      lifestyle: _selectedLifestyle.toList(),
      interests: _selectedInterests.toList(),
      showMe: _selectedShowMe.toList(),
      onlyOnline: _onlyOnline,
      sort: _sort,
    );
    Navigator.of(context).pop(filters);
  }
}

