// Danh sách 63 tỉnh/thành Việt Nam với toạ độ trung tâm (lng, lat)
// Lưu ý: đây là toạ độ tương đối, đủ chính xác cho mục đích "tìm quanh đây".

const VIETNAM_PROVINCE_COORDINATES = {
  'Hà Nội': [105.83416, 21.02776],
  'TP. Hồ Chí Minh': [106.66017, 10.76262],
  'Hải Phòng': [106.68809, 20.84491],
  'Đà Nẵng': [108.22083, 16.06778],
  'Cần Thơ': [105.783, 10.04516],
  'Hà Giang': [104.987, 22.82333],
  'Cao Bằng': [106.252, 22.66667],
  'Lào Cai': [103.973, 22.48556],
  'Sơn La': [104.00694, 21.3256],
  'Lai Châu': [103.273, 22.39643],
  'Yên Bái': [104.872, 21.705],
  'Tuyên Quang': [105.218, 21.81944],
  'Lạng Sơn': [106.757, 21.84694],
  'Quảng Ninh': [107.10278, 20.97139],
  'Bắc Giang': [106.199, 21.27307],
  'Phú Thọ': [105.225, 21.32278],
  'Vĩnh Phúc': [105.60498, 21.30891],
  'Bắc Ninh': [106.05111, 21.18608],
  'Hải Dương': [106.31667, 20.93972],
  'Hưng Yên': [106.06667, 20.64636],
  'Hà Nam': [105.91221, 20.54111],
  'Nam Định': [106.162, 20.42028],
  'Thái Bình': [106.33667, 20.45],
  'Ninh Bình': [105.975, 20.25389],
  'Thanh Hóa': [105.776, 19.8075],
  'Nghệ An': [105.693, 18.67333],
  'Hà Tĩnh': [105.905, 18.34278],
  'Quảng Bình': [106.6, 17.48333],
  'Quảng Trị': [107.1, 16.81625],
  'Thừa Thiên Huế': [107.59546, 16.46371],
  'Quảng Nam': [108.196, 15.57364],
  'Quảng Ngãi': [108.80144, 15.12199],
  'Bình Định': [109.219, 13.77648],
  'Phú Yên': [109.219, 13.09546],
  'Khánh Hòa': [109.19675, 12.23879],
  'Ninh Thuận': [108.98625, 11.56732],
  'Bình Thuận': [108.10208, 10.98046],
  'Kon Tum': [107.998, 14.35451],
  'Gia Lai': [108.014, 13.98333],
  'Đắk Lắk': [108.03775, 12.66747],
  'Đắk Nông': [107.69074, 12.00417],
  'Lâm Đồng': [108.438, 11.94042],
  'Bình Phước': [106.91667, 11.75],
  'Tây Ninh': [106.119, 11.31],
  'Bình Dương': [106.65, 10.98],
  'Đồng Nai': [106.822, 10.94527],
  'Bà Rịa - Vũng Tàu': [107.08426, 10.41138],
  'Long An': [106.16667, 10.53333],
  'Tiền Giang': [106.365, 10.35264],
  'Bến Tre': [106.375, 10.24147],
  'Trà Vinh': [106.345, 9.93472],
  'Vĩnh Long': [105.97, 10.25369],
  'Đồng Tháp': [105.63294, 10.45737],
  'An Giang': [105.43518, 10.37594],
  'Kiên Giang': [105.196, 10.01245],
  'Hậu Giang': [105.641, 9.78333],
  'Sóc Trăng': [105.97194, 9.60333],
  'Bạc Liêu': [105.725, 9.29414],
  'Cà Mau': [105.15242, 9.17694],
  'Bắc Kạn': [105.840, 22.147],
  'Điện Biên': [103.016, 21.386],
  'Hòa Bình': [105.3376, 20.81717],
  'Quảng Nam (Tam Kỳ)': [108.488, 15.573],
  'Quảng Ngãi (TP Quảng Ngãi)': [108.810, 15.120],
};

// Chuẩn hoá chuỗi: lower-case, bỏ dấu, loại bỏ tiền tố "tỉnh", "tp", "thành phố"
function normalizeName(name) {
  if (!name) return '';
  let s = String(name).trim().toLowerCase();

  // Bỏ dấu tiếng Việt
  s = s
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '');

  // Loại bỏ tiền tố thường gặp
  s = s.replace(/^tp\.\s*/g, '');
  s = s.replace(/^thanh pho\s*/g, '');
  s = s.replace(/^tinh\s*/g, '');

  // Loại bỏ khoảng trắng thừa
  s = s.replace(/\s+/g, ' ').trim();
  return s;
}

const NORMALIZED_INDEX = Object.entries(VIETNAM_PROVINCE_COORDINATES).map(
  ([name, coords]) => ({
    name,
    norm: normalizeName(name),
    coords,
  })
);

function getCoordinates(provinceName) {
  if (!provinceName) return null;
  const query = normalizeName(provinceName);
  if (!query) return null;

  // 1. Khớp chính xác sau khi normalize
  let found = NORMALIZED_INDEX.find((item) => item.norm === query);
  if (found) return found.coords;

  // 2. Khớp tương đối (query chứa name hoặc ngược lại)
  found = NORMALIZED_INDEX.find(
    (item) =>
      item.norm.includes(query) ||
      query.includes(item.norm)
  );
  return found ? found.coords : null;
}

module.exports = {
  VIETNAM_PROVINCE_COORDINATES,
  getCoordinates,
};


