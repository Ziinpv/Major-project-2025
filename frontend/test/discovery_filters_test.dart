import 'package:flutter_test/flutter_test.dart';
import 'package:matcha/data/models/discovery_filters.dart';

void main() {
  group('DiscoveryFilters', () {
    test('serializes and deserializes correctly', () {
      const filters = DiscoveryFilters(
        ageMin: 25,
        ageMax: 32,
        distance: 80,
        lifestyle: ['fitness', 'nightlife'],
        interests: ['music', 'travel'],
        showMe: ['female'],
        onlyOnline: true,
        sort: 'newest',
      );

      final encoded = filters.toStorageString();
      final restored = DiscoveryFilters.fromStorageString(encoded);

      expect(restored.ageMin, filters.ageMin);
      expect(restored.ageMax, filters.ageMax);
      expect(restored.distance, filters.distance);
      expect(restored.lifestyle, filters.lifestyle);
      expect(restored.interests, filters.interests);
      expect(restored.showMe, filters.showMe);
      expect(restored.onlyOnline, filters.onlyOnline);
      expect(restored.sort, filters.sort);
    });

    test('handles invalid storage string with defaults', () {
      final restored = DiscoveryFilters.fromStorageString('invalid-json');
      expect(restored.ageMin, greaterThanOrEqualTo(18));
      expect(restored.showMe, isNotEmpty);
    });
  });
}

