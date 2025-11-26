const userService = require('../user.service');
const { DEFAULT_PREFERENCES, LIFESTYLE_OPTIONS } = require('../../utils/constants');

describe('UserService.parseDiscoveryFilters', () => {
  it('sanitizes and normalizes discovery filter params', () => {
    const filters = userService.parseDiscoveryFilters({
      ageMin: '25',
      ageMax: '40',
      distance: '30',
      lifestyle: `${LIFESTYLE_OPTIONS[0]},unknown`,
      interests: ['music', 'invalid', 'travel'],
      sort: 'newest',
      onlyOnline: 'true',
      showMe: ['male', 'invalid'],
      limit: '120'
    });

    expect(filters.ageMin).toBe(25);
    expect(filters.ageMax).toBe(40);
    expect(filters.maxDistance).toBe(30);
    expect(filters.lifestyle).toHaveLength(1);
    expect(filters.interests).toEqual(expect.arrayContaining(['music', 'travel']));
    expect(filters.sort).toBe('newest');
    expect(filters.onlyOnline).toBe(true);
    expect(filters.showMe).toEqual(['male']);
    expect(filters.limit).toBeLessThanOrEqual(100);
  });

  it('falls back to defaults when filters missing', () => {
    const filters = userService.parseDiscoveryFilters({});

    expect(filters.ageMin).toBeUndefined();
    expect(filters.ageMax).toBeUndefined();
    expect(filters.maxDistance).toBeUndefined();
    expect(filters.sort).toBeDefined();
    expect(filters.sort).toBe('best');
    expect(filters.limit).toBeUndefined();
  });
});

