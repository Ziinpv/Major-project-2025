require('dotenv').config();
const mongoose = require('mongoose');
const User = require('../models/User');
const Swipe = require('../models/Swipe');
const Match = require('../models/Match');
const ChatRoom = require('../models/ChatRoom');
const Message = require('../models/Message');

const baseUsers = [
  {
    email: 'anh.nguyen@example.com',
    firstName: 'Anh',
    lastName: 'Nguyễn',
    dateOfBirth: new Date('1995-03-12'),
    gender: 'female',
    interestedIn: ['male'],
    bio: 'Food blogger tại Hà Nội, mê cà phê cold brew ☕',
    photos: [
      { url: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=800&q=60', isPrimary: true, order: 0 }
    ],
    location: {
      province: 'Hà Nội',
      city: 'Quận Hoàn Kiếm',
      country: 'Vietnam'
    },
    interests: ['cooking', 'photography', 'yoga', 'travel'],
    isProfileComplete: true,
    preferences: {
      ageRange: { min: 26, max: 35 },
      maxDistance: 30,
      showMe: ['male']
    }
  },
  {
    email: 'minh.tran@example.com',
    firstName: 'Minh',
    lastName: 'Trần',
    dateOfBirth: new Date('1992-07-05'),
    gender: 'male',
    interestedIn: ['female'],
    bio: 'Designer thích chạy bộ quanh hồ Tây 🏃‍♂️',
    photos: [
      { url: 'https://images.unsplash.com/photo-1521119989659-a83eee488004?auto=format&fit=crop&w=800&q=60', isPrimary: true, order: 0 }
    ],
    location: {
      province: 'Hà Nội',
      city: 'Quận Tây Hồ',
      country: 'Vietnam'
    },
    interests: ['fitness',  'reading', 'music'],
    isProfileComplete: true,
    preferences: {
      ageRange: { min: 24, max: 32 },
      maxDistance: 25,
      showMe: ['female']
    }
  },
  {
    email: 'thu.le@example.com',
    firstName: 'Thu',
    lastName: 'Lê',
    dateOfBirth: new Date('1998-11-21'),
    gender: 'female',
    interestedIn: ['male', 'non-binary'],
    bio: 'Sinh viên ngành truyền thông tại TP.HCM 🎓',
    photos: [
      { url: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=800&q=60', isPrimary: true, order: 0 }
    ],
    location: {
      province: 'TP. Hồ Chí Minh',
      city: 'Quận 1',
      country: 'Vietnam'
    },
    interests: [ 'movies', 'music', 'coffee'],
    isProfileComplete: true,
    preferences: {
      ageRange: { min: 23, max: 32 },
      maxDistance: 20,
      showMe: ['male', 'non-binary']
    }
  },
  {
    email: 'son.pham@example.com',
    firstName: 'Sơn',
    lastName: 'Phạm',
    dateOfBirth: new Date('1990-01-18'),
    gender: 'male',
    interestedIn: ['female'],
    bio: 'Kỹ sư phần mềm, thích trekking và nhiếp ảnh',
    photos: [
      { url: 'https://images.unsplash.com/photo-1502767089025-6572583495b0?auto=format&fit=crop&w=800&q=60', isPrimary: true, order: 0 }
    ],
    location: {
      province: 'TP. Hồ Chí Minh',
      city: 'Quận Bình Thạnh',
      country: 'Vietnam'
    },
    interests: ['startups', 'sports', 'photography', 'music'],
    isProfileComplete: true,
    preferences: {
      ageRange: { min: 24, max: 33 },
      maxDistance: 30,
      showMe: ['female']
    }
  },
  {
    email: 'my.ngo@example.com',
    firstName: 'My',
    lastName: 'Ngô',
    dateOfBirth: new Date('1994-09-09'),
    gender: 'female',
    interestedIn: ['male', 'female'],
    bio: 'Product manager yêu mèo và startup 🐱',
    photos: [
      { url: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=800&q=60', isPrimary: true, order: 0 }
    ],
    location: {
      province: 'Đà Nẵng',
      city: 'Quận Hải Châu',
      country: 'Vietnam'
    },
    interests: ['startups', 'yoga', 'cooking', 'gaming'],
    isProfileComplete: true,
    preferences: {
      ageRange: { min: 26, max: 36 },
      maxDistance: 40,
      showMe: ['male', 'female']
    }
  },
  {
    email: 'tuan.vo@example.com',
    firstName: 'Tuấn',
    lastName: 'Võ',
    dateOfBirth: new Date('1991-12-02'),
    gender: 'male',
    interestedIn: ['female'],
    bio: 'Giảng viên guitar, thích cafe acoustic cuối tuần ☕🎸',
    photos: [
      { url: 'https://images.unsplash.com/photo-1504593811423-6dd665756598?auto=format&fit=crop&w=800&q=60', isPrimary: true, order: 0 }
    ],
    location: {
      province: 'Đà Nẵng',
      city: 'Quận Sơn Trà',
      country: 'Vietnam'
    },
    interests: ['music', 'coffee', 'travel', 'pets'],
    isProfileComplete: true,
    preferences: {
      ageRange: { min: 24, max: 32 },
      maxDistance: 35,
      showMe: ['female']
    }
  },
  {
    email: 'linh.phan@example.com',
    firstName: 'Linh',
    lastName: 'Phan',
    dateOfBirth: new Date('1996-04-27'),
    gender: 'non-binary',
    interestedIn: ['male', 'female', 'non-binary'],
    bio: 'Illustrator làm việc remote từ Đà Lạt ☁️',
    photos: [
      { url: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=800&q=60', isPrimary: true, order: 0 }
    ],
    location: {
      province: 'Lâm Đồng',
      city: 'Thành phố Đà Lạt',
      country: 'Vietnam'
    },
    interests: [ 'reading', 'travel', 'cooking'],
    isProfileComplete: true,
    preferences: {
      ageRange: { min: 25, max: 35 },
      maxDistance: 100,
      showMe: ['male', 'female', 'non-binary']
    }
  },
  {
    email: 'quang.do@example.com',
    firstName: 'Quang',
    lastName: 'Đỗ',
    dateOfBirth: new Date('1989-06-30'),
    gender: 'male',
    interestedIn: ['female'],
    bio: 'Founder một quán craft beer nhỏ ở Nha Trang 🍺',
    photos: [
      { url: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=800&q=60', isPrimary: true, order: 0 }
    ],
    location: {
      province: 'Khánh Hòa',
      city: 'Thành phố Nha Trang',
      country: 'Vietnam'
    },
    interests: ['coffee', 'travel', 'sports', 'music'],
    isProfileComplete: true,
    preferences: {
      ageRange: { min: 25, max: 34 },
      maxDistance: 50,
      showMe: ['female']
    }
  },
  {
    email: 'hanh.bui@example.com',
    firstName: 'Hạnh',
    lastName: 'Bùi',
    dateOfBirth: new Date('1997-02-14'),
    gender: 'female',
    interestedIn: ['male'],
    bio: 'Nhân viên marketing thích trekking Fansipan',
    photos: [
      { url: 'https://images.unsplash.com/photo-1523287562758-66c7fc58967f?auto=format&fit=crop&w=800&q=60', isPrimary: true, order: 0 }
    ],
    location: {
      province: 'Lào Cai',
      city: 'Thành phố Lào Cai',
      country: 'Vietnam'
    },
    interests: ['sports', 'reading', 'music', 'cooking'],
    isProfileComplete: true,
    preferences: {
      ageRange: { min: 26, max: 36 },
      maxDistance: 60,
      showMe: ['male']
    }
  },
  {
    email: 'bao.nguyen@example.com',
    firstName: 'Bảo',
    lastName: 'Nguyễn',
    dateOfBirth: new Date('1993-10-08'),
    gender: 'male',
    interestedIn: ['female', 'non-binary'],
    bio: 'Nhà sản xuất âm nhạc indie, mê analog synth',
    photos: [
      { url: 'https://images.unsplash.com/photo-1504593811423-6dd665756598?auto=format&fit=crop&w=800&q=60', isPrimary: true, order: 0 }
    ],
    location: {
      province: 'Hà Nội',
      city: 'Quận Cầu Giấy',
      country: 'Vietnam'
    },
    interests: ['music', 'travel', 'fitness', 'cooking'],
    isProfileComplete: true,
    preferences: {
      ageRange: { min: 24, max: 34 },
      maxDistance: 30,
      showMe: ['female', 'non-binary']
    }
  }
];

const filterTestUsers = [
  {
    email: 'lan.pham.filter@example.com',
    firstName: 'Lan',
    lastName: 'Phạm',
    dateOfBirth: new Date('1993-02-11'),
    gender: 'female',
    interestedIn: ['male'],
    bio: 'Marketing manager mê chạy trail và cà phê specialty.',
    photos: [
      { url: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=800&q=60', isPrimary: true, order: 0 }
    ],
    location: {
      province: 'Hà Nội',
      city: 'Quận Cầu Giấy',
      country: 'Vietnam',
      coordinates: [105.7906, 21.0333]
    },
    interests: ['fitness', 'travel', 'coffee'],
    lifestyle: ['fitness', 'early-bird', 'career-focused'],
    job: 'Marketing Manager',
    school: 'FTU',
    isProfileComplete: true,
    preferences: {
      ageRange: { min: 27, max: 35 },
      maxDistance: 25,
      lifestyle: ['fitness'],
      showMe: ['male'],
      onlyShowOnline: false
    }
  },
  {
    email: 'quoc.le.filter@example.com',
    firstName: 'Quốc',
    lastName: 'Lê',
    dateOfBirth: new Date('1990-06-08'),
    gender: 'male',
    interestedIn: ['female'],
    bio: 'Kỹ sư AI thích leo núi Fansipan và đọc sci-fi.',
    photos: [
      { url: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=800&q=60', isPrimary: true, order: 0 }
    ],
    location: {
      province: 'Lào Cai',
      city: 'Sa Pa',
      country: 'Vietnam',
      coordinates: [103.8440, 22.3400]
    },
    interests: ['sports', 'reading', 'travel', 'photography'],
    lifestyle: ['hiking', 'minimalist', 'early-bird'],
    job: 'AI Engineer',
    school: 'ĐH Bách Khoa',
    isProfileComplete: true,
    preferences: {
      ageRange: { min: 26, max: 34 },
      maxDistance: 80,
      lifestyle: ['hiking'],
      showMe: ['female'],
      onlyShowOnline: false
    }
  },
  {
    email: 'mai.dang.filter@example.com',
    firstName: 'Mai',
    lastName: 'Đặng',
    dateOfBirth: new Date('1995-09-19'),
    gender: 'female',
    interestedIn: ['male', 'female'],
    bio: 'Product designer sống tối giản, thích workshop nghệ thuật.',
    photos: [
      { url: 'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?auto=format&fit=crop&w=800&q=60', isPrimary: true, order: 0 }
    ],
    location: {
      province: 'Đà Nẵng',
      city: 'Quận Hải Châu',
      country: 'Vietnam',
      coordinates: [108.2208, 16.0678]
    },
    interests: [ 'coffee', 'movies', 'travel'],
    lifestyle: ['minimalist', 'night-owl', 'career-focused'],
    job: 'Product Designer',
    school: 'ĐH Kiến Trúc',
    isProfileComplete: true,
    preferences: {
      ageRange: { min: 25, max: 34 },
      maxDistance: 40,
      lifestyle: ['minimalist'],
      showMe: ['male', 'female'],
      onlyShowOnline: false
    }
  },
  {
    email: 'bao.tran.filter@example.com',
    firstName: 'Bảo',
    lastName: 'Trần',
    dateOfBirth: new Date('1988-12-01'),
    gender: 'male',
    interestedIn: ['female'],
    bio: 'Founder quán cà phê acoustic, mê jazz và thú cưng.',
    photos: [
      { url: 'https://images.unsplash.com/photo-1502767089025-6572583495b0?auto=format&fit=crop&w=800&q=60', isPrimary: true, order: 0 }
    ],
    location: {
      province: 'TP. Hồ Chí Minh',
      city: 'Quận 3',
      country: 'Vietnam',
      coordinates: [106.6822, 10.7847]
    },
    interests: ['music', 'coffee', 'pets', 'travel'],
    lifestyle: ['nightlife', 'pet-lover', 'night-owl'],
    job: 'Cafe Owner',
    school: 'ĐH Văn Lang',
    isProfileComplete: true,
    preferences: {
      ageRange: { min: 24, max: 33 },
      maxDistance: 30,
      lifestyle: ['pet-lover'],
      showMe: ['female'],
      onlyShowOnline: true
    }
  },
  {
    email: 'thuong.ngo.filter@example.com',
    firstName: 'Thương',
    lastName: 'Ngô',
    dateOfBirth: new Date('1994-04-04'),
    gender: 'female',
    interestedIn: ['male'],
    bio: 'Chuyên gia dữ liệu thích yoga bình minh và ăn chay.',
    photos: [
      { url: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=800&q=60', isPrimary: true, order: 0 }
    ],
    location: {
      province: 'Đà Lạt',
      city: 'Thành phố Đà Lạt',
      country: 'Vietnam',
      coordinates: [108.4419, 11.9404]
    },
    interests: ['yoga', 'reading', 'cooking', 'travel'],
    lifestyle: ['vegan', 'early-bird', 'spiritual'],
    job: 'Data Scientist',
    school: 'ĐH Đà Lạt',
    isProfileComplete: true,
    preferences: {
      ageRange: { min: 26, max: 36 },
      maxDistance: 60,
      lifestyle: ['vegan', 'spiritual'],
      showMe: ['male'],
      onlyShowOnline: false
    }
  },
  {
    email: 'thanh.vo.filter@example.com',
    firstName: 'Thành',
    lastName: 'Võ',
    dateOfBirth: new Date('1991-03-16'),
    gender: 'male',
    interestedIn: ['female', 'non-binary'],
    bio: 'Digital nomad yêu surf và làm podcast.',
    photos: [
      { url: 'https://images.unsplash.com/photo-1504593811423-6dd665756598?auto=format&fit=crop&w=800&q=60', isPrimary: true, order: 0 }
    ],
    location: {
      province: 'Khánh Hòa',
      city: 'Nha Trang',
      country: 'Vietnam',
      coordinates: [109.1967, 12.2388]
    },
    interests: ['travel', 'music', 'photography', 'fitness'],
    lifestyle: ['traveling', 'night-owl', 'minimalist'],
    job: 'Content Creator',
    school: 'ĐH Nha Trang',
    isProfileComplete: true,
    preferences: {
      ageRange: { min: 24, max: 34 },
      maxDistance: 100,
      lifestyle: ['traveling'],
      showMe: ['female', 'non-binary'],
      onlyShowOnline: false
    }
  },
  {
    email: 'kim.chi.filter@example.com',
    firstName: 'Kim Chi',
    lastName: 'Nguyễn',
    dateOfBirth: new Date('1997-01-28'),
    gender: 'female',
    interestedIn: ['male'],
    bio: 'Bác sĩ thú y yêu mèo, thích trekking nhẹ cuối tuần.',
    photos: [
      { url: 'https://images.unsplash.com/photo-1523287562758-66c7fc58967f?auto=format&fit=crop&w=800&q=60', isPrimary: true, order: 0 }
    ],
    location: {
      province: 'Quảng Ninh',
      city: 'Hạ Long',
      country: 'Vietnam',
      coordinates: [107.0460, 20.9716]
    },
    interests: ['pets', 'travel', 'sports', 'coffee'],
    lifestyle: ['pet-lover', 'family-oriented', 'hiking'],
    job: 'Veterinarian',
    school: 'HV Nông Nghiệp',
    isProfileComplete: true,
    preferences: {
      ageRange: { min: 25, max: 33 },
      maxDistance: 70,
      lifestyle: ['pet-lover'],
      showMe: ['male'],
      onlyShowOnline: false
    }
  },
  {
    email: 'linh.ha.filter@example.com',
    firstName: 'Linh',
    lastName: 'Hà',
    dateOfBirth: new Date('1999-05-05'),
    gender: 'non-binary',
    interestedIn: ['male', 'female', 'non-binary'],
    bio: 'Illustrator thích camping và nhạc indie.',
    photos: [
      { url: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=800&q=60', isPrimary: true, order: 0 }
    ],
    location: {
      province: 'Gia Lai',
      city: 'Pleiku',
      country: 'Vietnam',
      coordinates: [108.0145, 13.9712]
    },
    interests: [ 'travel', 'music', 'photography'],
    lifestyle: ['spiritual', 'minimalist', 'traveling'],
    job: 'Illustrator',
    school: 'ĐH Mỹ Thuật',
    isProfileComplete: true,
    preferences: {
      ageRange: { min: 23, max: 34 },
      maxDistance: 120,
      lifestyle: ['traveling'],
      showMe: ['male', 'female', 'non-binary'],
      onlyShowOnline: false
    }
  },
  {
    email: 'vuong.nguyen.filter@example.com',
    firstName: 'Vương',
    lastName: 'Nguyễn',
    dateOfBirth: new Date('1987-07-27'),
    gender: 'male',
    interestedIn: ['female'],
    bio: 'Giám đốc sản phẩm, mê golf và khởi nghiệp.',
    photos: [
      { url: 'https://images.unsplash.com/photo-1504593811423-6dd665756598?auto=format&fit=crop&w=800&q=60', isPrimary: true, order: 0 }
    ],
    location: {
      province: 'Bình Dương',
      city: 'Thủ Dầu Một',
      country: 'Vietnam',
      coordinates: [106.6500, 10.9800]
    },
    interests: ['startups', 'travel', 'fitness', 'coffee'],
    lifestyle: ['career-focused', 'fitness', 'nightlife'],
    job: 'Product Director',
    school: 'RMIT Việt Nam',
    isProfileComplete: true,
    preferences: {
      ageRange: { min: 25, max: 32 },
      maxDistance: 60,
      lifestyle: ['career-focused'],
      showMe: ['female'],
      onlyShowOnline: true
    }
  },
  {
    email: 'ngoc.phan.filter@example.com',
    firstName: 'Ngọc',
    lastName: 'Phan',
    dateOfBirth: new Date('1996-10-13'),
    gender: 'female',
    interestedIn: ['male'],
    bio: 'Giáo viên yoga sống healthy, thích nấu ăn chay.',
    photos: [
      { url: 'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?auto=format&fit=crop&w=800&q=60', isPrimary: true, order: 0 }
    ],
    location: {
      province: 'Khánh Hòa',
      city: 'Cam Ranh',
      country: 'Vietnam',
      coordinates: [109.1597, 11.9214]
    },
    interests: ['yoga', 'cooking', 'travel', 'reading'],
    lifestyle: ['vegan', 'early-bird', 'fitness'],
    job: 'Yoga Instructor',
    school: 'Yoga Alliance',
    isProfileComplete: true,
    preferences: {
      ageRange: { min: 27, max: 36 },
      maxDistance: 80,
      lifestyle: ['vegan', 'fitness'],
      showMe: ['male'],
      onlyShowOnline: false
    }
  },
  {
    email: 'thien.vu.filter@example.com',
    firstName: 'Thiên',
    lastName: 'Vũ',
    dateOfBirth: new Date('1992-02-22'),
    gender: 'male',
    interestedIn: ['female'],
    bio: 'Nhà làm phim documentary thích thức khuya viết kịch bản.',
    photos: [
      { url: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?auto=format&fit=crop&w=800&q=60', isPrimary: true, order: 0 }
    ],
    location: {
      province: 'TP. Hồ Chí Minh',
      city: 'Quận Phú Nhuận',
      country: 'Vietnam',
      coordinates: [106.6777, 10.7971]
    },
    interests: ['movies', 'photography', 'travel', 'coffee'],
    lifestyle: ['night-owl', 'minimalist', 'traveling'],
    job: 'Filmmaker',
    school: 'ĐH Sân Khấu Điện Ảnh',
    isProfileComplete: true,
    preferences: {
      ageRange: { min: 23, max: 31 },
      maxDistance: 35,
      lifestyle: ['night-owl'],
      showMe: ['female'],
      onlyShowOnline: false
    }
  },
  {
    email: 'yen.dang.filter@example.com',
    firstName: 'Yến',
    lastName: 'Đặng',
    dateOfBirth: new Date('1990-11-02'),
    gender: 'female',
    interestedIn: ['male'],
    bio: 'Chuyên gia nhân sự hướng nội, thích đọc sách và trồng cây.',
    photos: [
      { url: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=800&q=60', isPrimary: true, order: 0 }
    ],
    location: {
      province: 'Huế',
      city: 'Thành phố Huế',
      country: 'Vietnam',
      coordinates: [107.5780, 16.4637]
    },
    interests: ['reading', 'cooking', 'travel', 'yoga'],
    lifestyle: ['family-oriented', 'early-bird', 'minimalist'],
    job: 'HR Business Partner',
    school: 'ĐH Kinh Tế Huế',
    isProfileComplete: true,
    preferences: {
      ageRange: { min: 30, max: 40 },
      maxDistance: 45,
      lifestyle: ['family-oriented'],
      showMe: ['male'],
      onlyShowOnline: false
    }
  },
  {
    email: 'tu.kieu.filter@example.com',
    firstName: 'Tú',
    lastName: 'Kiều',
    dateOfBirth: new Date('1998-08-18'),
    gender: 'male',
    interestedIn: ['female'],
    bio: 'Barista kiêm DJ, yêu nightlife và khám phá quán mới.',
    photos: [
      { url: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=800&q=60', isPrimary: true, order: 0 }
    ],
    location: {
      province: 'TP. Hồ Chí Minh',
      city: 'Quận 10',
      country: 'Vietnam',
      coordinates: [106.6672, 10.7753]
    },
    interests: ['music', 'coffee', 'dancing', 'travel'],
    lifestyle: ['nightlife', 'night-owl', 'traveling'],
    job: 'Barista & DJ',
    school: 'Học viện Âm nhạc',
    isProfileComplete: true,
    preferences: {
      ageRange: { min: 22, max: 30 },
      maxDistance: 20,
      lifestyle: ['nightlife'],
      showMe: ['female'],
      onlyShowOnline: true
    }
  },
  {
    email: 'huong.trinh.filter@example.com',
    firstName: 'Hương',
    lastName: 'Trịnh',
    dateOfBirth: new Date('1989-03-09'),
    gender: 'female',
    interestedIn: ['male', 'female'],
    bio: 'Coach thiền giúp mọi người cân bằng cuộc sống.',
    photos: [
      { url: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=800&q=60', isPrimary: true, order: 0 }
    ],
    location: {
      province: 'Bình Thuận',
      city: 'Phan Thiết',
      country: 'Vietnam',
      coordinates: [108.1000, 10.9333]
    },
    interests: ['yoga', 'travel', 'reading', 'music'],
    lifestyle: ['spiritual', 'minimalist', 'early-bird'],
    job: 'Mindfulness Coach',
    school: 'UCLA Extension',
    isProfileComplete: true,
    preferences: {
      ageRange: { min: 30, max: 42 },
      maxDistance: 90,
      lifestyle: ['spiritual'],
      showMe: ['male', 'female'],
      onlyShowOnline: false
    }
  },
  {
    email: 'phuc.nguyen.filter@example.com',
    firstName: 'Phúc',
    lastName: 'Nguyễn',
    dateOfBirth: new Date('1994-12-30'),
    gender: 'male',
    interestedIn: ['female'],
    bio: 'Fullstack dev, mê gaming và gym buổi tối.',
    photos: [
      { url: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=800&q=60', isPrimary: true, order: 0 }
    ],
    location: {
      province: 'Cần Thơ',
      city: 'Ninh Kiều',
      country: 'Vietnam',
      coordinates: [105.7689, 10.0452]
    },
    interests: ['gaming', 'fitness', 'coffee', 'movies'],
    lifestyle: ['night-owl', 'fitness', 'minimalist'],
    job: 'Software Engineer',
    school: 'ĐH Cần Thơ',
    isProfileComplete: true,
    preferences: {
      ageRange: { min: 24, max: 32 },
      maxDistance: 70,
      lifestyle: ['fitness'],
      showMe: ['female'],
      onlyShowOnline: false
    }
  }
];

const seedDatabase = async () => {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    // Clear existing data (optional - comment out in production)
    // await User.deleteMany({});
    // await Swipe.deleteMany({});
    // await Match.deleteMany({});
    // await ChatRoom.deleteMany({});
    // await Message.deleteMany({});

    const allSeedUsers = [...baseUsers, ...filterTestUsers];

    // Remove existing users with the same emails to avoid duplicate key errors
    const emailsToDelete = allSeedUsers.map(user => user.email);
    const deleteResult = await User.deleteMany({ email: { $in: emailsToDelete } });
    console.log(`🧹 Removed ${deleteResult.deletedCount} existing users with seed emails`);

    const createdUsers = await User.insertMany(allSeedUsers);
    console.log('✅ Seeded users:', createdUsers.length);

    console.log('\n🎉 Seeding completed successfully!');
    console.log('\nVietnam Test Users:');
    createdUsers.forEach(user => {
      console.log(`- ${user.firstName} ${user.lastName}: ${user.email} (${user.location?.city}, ${user.location?.province})`);
    });

    process.exit(0);
  } catch (error) {
    console.error('❌ Seeding error:', error);
    process.exit(1);
  }
};

seedDatabase();

