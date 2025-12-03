import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// Tên ứng dụng
  ///
  /// In vi, this message translates to:
  /// **'Matcha'**
  String get appTitle;

  /// No description provided for @common_ok.
  ///
  /// In vi, this message translates to:
  /// **'OK'**
  String get common_ok;

  /// No description provided for @common_cancel.
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get common_cancel;

  /// No description provided for @common_save.
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get common_save;

  /// No description provided for @common_delete.
  ///
  /// In vi, this message translates to:
  /// **'Xóa'**
  String get common_delete;

  /// No description provided for @common_edit.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa'**
  String get common_edit;

  /// No description provided for @common_close.
  ///
  /// In vi, this message translates to:
  /// **'Đóng'**
  String get common_close;

  /// No description provided for @common_next.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp theo'**
  String get common_next;

  /// No description provided for @common_back.
  ///
  /// In vi, this message translates to:
  /// **'Quay lại'**
  String get common_back;

  /// No description provided for @common_done.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn tất'**
  String get common_done;

  /// No description provided for @common_confirm.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận'**
  String get common_confirm;

  /// No description provided for @common_skip.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ qua'**
  String get common_skip;

  /// No description provided for @common_loading.
  ///
  /// In vi, this message translates to:
  /// **'Đang tải...'**
  String get common_loading;

  /// No description provided for @common_error.
  ///
  /// In vi, this message translates to:
  /// **'Đã có lỗi xảy ra'**
  String get common_error;

  /// No description provided for @common_retry.
  ///
  /// In vi, this message translates to:
  /// **'Thử lại'**
  String get common_retry;

  /// No description provided for @common_yes.
  ///
  /// In vi, this message translates to:
  /// **'Có'**
  String get common_yes;

  /// No description provided for @common_no.
  ///
  /// In vi, this message translates to:
  /// **'Không'**
  String get common_no;

  /// No description provided for @auth_login_title.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập'**
  String get auth_login_title;

  /// No description provided for @auth_login_subtitle.
  ///
  /// In vi, this message translates to:
  /// **'Chào mừng bạn trở lại!'**
  String get auth_login_subtitle;

  /// No description provided for @auth_login_email_hint.
  ///
  /// In vi, this message translates to:
  /// **'Email'**
  String get auth_login_email_hint;

  /// No description provided for @auth_login_password_hint.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu'**
  String get auth_login_password_hint;

  /// No description provided for @auth_login_button.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập'**
  String get auth_login_button;

  /// No description provided for @auth_login_with_google.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập với Google'**
  String get auth_login_with_google;

  /// No description provided for @auth_login_or.
  ///
  /// In vi, this message translates to:
  /// **'HOẶC'**
  String get auth_login_or;

  /// No description provided for @auth_login_no_account.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có tài khoản? '**
  String get auth_login_no_account;

  /// No description provided for @auth_login_register.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký'**
  String get auth_login_register;

  /// No description provided for @auth_login_forgot_password.
  ///
  /// In vi, this message translates to:
  /// **'Quên mật khẩu?'**
  String get auth_login_forgot_password;

  /// No description provided for @auth_register_title.
  ///
  /// In vi, this message translates to:
  /// **'Tạo tài khoản'**
  String get auth_register_title;

  /// No description provided for @auth_register_subtitle.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu hành trình tìm kiếm của bạn'**
  String get auth_register_subtitle;

  /// No description provided for @auth_register_first_name.
  ///
  /// In vi, this message translates to:
  /// **'Tên'**
  String get auth_register_first_name;

  /// No description provided for @auth_register_last_name.
  ///
  /// In vi, this message translates to:
  /// **'Họ'**
  String get auth_register_last_name;

  /// No description provided for @auth_register_email.
  ///
  /// In vi, this message translates to:
  /// **'Email'**
  String get auth_register_email;

  /// No description provided for @auth_register_password.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu'**
  String get auth_register_password;

  /// No description provided for @auth_register_confirm_password.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận mật khẩu'**
  String get auth_register_confirm_password;

  /// No description provided for @auth_register_dob.
  ///
  /// In vi, this message translates to:
  /// **'Ngày sinh'**
  String get auth_register_dob;

  /// No description provided for @auth_register_button.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký'**
  String get auth_register_button;

  /// No description provided for @auth_register_with_google.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký với Google'**
  String get auth_register_with_google;

  /// No description provided for @auth_register_have_account.
  ///
  /// In vi, this message translates to:
  /// **'Đã có tài khoản? '**
  String get auth_register_have_account;

  /// No description provided for @auth_register_login.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập'**
  String get auth_register_login;

  /// No description provided for @auth_error_email_required.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập email'**
  String get auth_error_email_required;

  /// No description provided for @auth_error_email_invalid.
  ///
  /// In vi, this message translates to:
  /// **'Email không hợp lệ'**
  String get auth_error_email_invalid;

  /// No description provided for @auth_error_password_required.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập mật khẩu'**
  String get auth_error_password_required;

  /// No description provided for @auth_error_password_min_length.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu phải có ít nhất 6 ký tự'**
  String get auth_error_password_min_length;

  /// No description provided for @auth_error_password_mismatch.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu không khớp'**
  String get auth_error_password_mismatch;

  /// No description provided for @auth_error_first_name_required.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập tên'**
  String get auth_error_first_name_required;

  /// No description provided for @auth_error_first_name_min_length.
  ///
  /// In vi, this message translates to:
  /// **'Tên phải có ít nhất 2 ký tự'**
  String get auth_error_first_name_min_length;

  /// No description provided for @auth_error_first_name_whitespace.
  ///
  /// In vi, this message translates to:
  /// **'Tên không được chỉ chứa khoảng trắng'**
  String get auth_error_first_name_whitespace;

  /// No description provided for @auth_error_last_name_required.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập họ'**
  String get auth_error_last_name_required;

  /// No description provided for @auth_error_last_name_min_length.
  ///
  /// In vi, this message translates to:
  /// **'Họ phải có ít nhất 2 ký tự'**
  String get auth_error_last_name_min_length;

  /// No description provided for @auth_error_last_name_whitespace.
  ///
  /// In vi, this message translates to:
  /// **'Họ không được chỉ chứa khoảng trắng'**
  String get auth_error_last_name_whitespace;

  /// No description provided for @auth_error_dob_required.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng chọn ngày sinh'**
  String get auth_error_dob_required;

  /// No description provided for @profile_setup_title.
  ///
  /// In vi, this message translates to:
  /// **'Thiết lập hồ sơ'**
  String get profile_setup_title;

  /// No description provided for @profile_setup_step_of.
  ///
  /// In vi, this message translates to:
  /// **'Bước {current} của {total}'**
  String profile_setup_step_of(int current, int total);

  /// No description provided for @profile_setup_gender_title.
  ///
  /// In vi, this message translates to:
  /// **'Giới tính của bạn?'**
  String get profile_setup_gender_title;

  /// No description provided for @profile_setup_gender_male.
  ///
  /// In vi, this message translates to:
  /// **'Nam'**
  String get profile_setup_gender_male;

  /// No description provided for @profile_setup_gender_female.
  ///
  /// In vi, this message translates to:
  /// **'Nữ'**
  String get profile_setup_gender_female;

  /// No description provided for @profile_setup_gender_non_binary.
  ///
  /// In vi, this message translates to:
  /// **'Phi nhị phân'**
  String get profile_setup_gender_non_binary;

  /// No description provided for @profile_setup_gender_other.
  ///
  /// In vi, this message translates to:
  /// **'Khác'**
  String get profile_setup_gender_other;

  /// No description provided for @profile_setup_interests_title.
  ///
  /// In vi, this message translates to:
  /// **'Chọn sở thích của bạn'**
  String get profile_setup_interests_title;

  /// No description provided for @profile_setup_photos_title.
  ///
  /// In vi, this message translates to:
  /// **'Thêm ảnh của bạn'**
  String get profile_setup_photos_title;

  /// No description provided for @profile_setup_location_title.
  ///
  /// In vi, this message translates to:
  /// **'Thiết lập vị trí'**
  String get profile_setup_location_title;

  /// No description provided for @profile_setup_location_subtitle.
  ///
  /// In vi, this message translates to:
  /// **'Chọn tỉnh/thành và thành phố bạn đang sinh sống. Không cần cấp quyền vị trí.'**
  String get profile_setup_location_subtitle;

  /// No description provided for @profile_setup_province.
  ///
  /// In vi, this message translates to:
  /// **'Tỉnh / Thành phố'**
  String get profile_setup_province;

  /// No description provided for @profile_setup_city.
  ///
  /// In vi, this message translates to:
  /// **'Thành phố / Quận / Thị xã'**
  String get profile_setup_city;

  /// No description provided for @profile_setup_address.
  ///
  /// In vi, this message translates to:
  /// **'Địa chỉ cụ thể (tuỳ chọn)'**
  String get profile_setup_address;

  /// No description provided for @profile_setup_select_province_first.
  ///
  /// In vi, this message translates to:
  /// **'Chọn tỉnh/thành trước'**
  String get profile_setup_select_province_first;

  /// No description provided for @profile_setup_complete.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn tất thiết lập hồ sơ!'**
  String get profile_setup_complete;

  /// No description provided for @profile_setup_error_gender.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng chọn giới tính'**
  String get profile_setup_error_gender;

  /// No description provided for @profile_setup_error_photos.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng thêm ít nhất một ảnh'**
  String get profile_setup_error_photos;

  /// No description provided for @profile_setup_error_location.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng chọn tỉnh/thành và thành phố'**
  String get profile_setup_error_location;

  /// No description provided for @profile_title.
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ của bạn'**
  String get profile_title;

  /// No description provided for @profile_about.
  ///
  /// In vi, this message translates to:
  /// **'Giới thiệu'**
  String get profile_about;

  /// No description provided for @profile_job.
  ///
  /// In vi, this message translates to:
  /// **'Công việc'**
  String get profile_job;

  /// No description provided for @profile_school.
  ///
  /// In vi, this message translates to:
  /// **'Trường học'**
  String get profile_school;

  /// No description provided for @profile_interests.
  ///
  /// In vi, this message translates to:
  /// **'Sở thích'**
  String get profile_interests;

  /// No description provided for @profile_lifestyle.
  ///
  /// In vi, this message translates to:
  /// **'Phong cách sống'**
  String get profile_lifestyle;

  /// No description provided for @profile_edit_button.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa hồ sơ'**
  String get profile_edit_button;

  /// No description provided for @profile_edit_title.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa hồ sơ'**
  String get profile_edit_title;

  /// No description provided for @profile_edit_photos.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh của bạn'**
  String get profile_edit_photos;

  /// No description provided for @profile_edit_info.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin'**
  String get profile_edit_info;

  /// No description provided for @profile_edit_bio.
  ///
  /// In vi, this message translates to:
  /// **'Giới thiệu bản thân'**
  String get profile_edit_bio;

  /// No description provided for @profile_edit_job.
  ///
  /// In vi, this message translates to:
  /// **'Công việc'**
  String get profile_edit_job;

  /// No description provided for @profile_edit_school.
  ///
  /// In vi, this message translates to:
  /// **'Trường học'**
  String get profile_edit_school;

  /// No description provided for @profile_edit_interests_title.
  ///
  /// In vi, this message translates to:
  /// **'Sở thích (tối đa 5)'**
  String get profile_edit_interests_title;

  /// No description provided for @profile_edit_lifestyle_title.
  ///
  /// In vi, this message translates to:
  /// **'Lifestyle (tối đa 5)'**
  String get profile_edit_lifestyle_title;

  /// No description provided for @profile_edit_save_info.
  ///
  /// In vi, this message translates to:
  /// **'Lưu thông tin'**
  String get profile_edit_save_info;

  /// No description provided for @profile_edit_save_photos.
  ///
  /// In vi, this message translates to:
  /// **'Lưu ảnh'**
  String get profile_edit_save_photos;

  /// No description provided for @discovery_title.
  ///
  /// In vi, this message translates to:
  /// **'Khám phá'**
  String get discovery_title;

  /// No description provided for @discovery_no_users.
  ///
  /// In vi, this message translates to:
  /// **'Không có người dùng nào phù hợp'**
  String get discovery_no_users;

  /// No description provided for @discovery_filter_button.
  ///
  /// In vi, this message translates to:
  /// **'Bộ lọc'**
  String get discovery_filter_button;

  /// No description provided for @discovery_complete_profile_title.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn thiện hồ sơ để có đề xuất tốt hơn'**
  String get discovery_complete_profile_title;

  /// No description provided for @discovery_complete_profile_subtitle.
  ///
  /// In vi, this message translates to:
  /// **'Thêm sở thích và lifestyle giúp hệ thống hiểu bạn hơn.'**
  String get discovery_complete_profile_subtitle;

  /// No description provided for @discovery_update_button.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật'**
  String get discovery_update_button;

  /// No description provided for @discovery_filter_title.
  ///
  /// In vi, this message translates to:
  /// **'Bộ lọc tìm kiếm'**
  String get discovery_filter_title;

  /// No description provided for @discovery_filter_age.
  ///
  /// In vi, this message translates to:
  /// **'Độ tuổi'**
  String get discovery_filter_age;

  /// No description provided for @discovery_filter_distance.
  ///
  /// In vi, this message translates to:
  /// **'Khoảng cách (km)'**
  String get discovery_filter_distance;

  /// No description provided for @discovery_filter_gender.
  ///
  /// In vi, this message translates to:
  /// **'Giới tính'**
  String get discovery_filter_gender;

  /// No description provided for @discovery_filter_interests.
  ///
  /// In vi, this message translates to:
  /// **'Sở thích'**
  String get discovery_filter_interests;

  /// No description provided for @discovery_filter_lifestyle.
  ///
  /// In vi, this message translates to:
  /// **'Lifestyle'**
  String get discovery_filter_lifestyle;

  /// No description provided for @discovery_filter_only_online.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ hiển thị người online'**
  String get discovery_filter_only_online;

  /// No description provided for @discovery_filter_sort.
  ///
  /// In vi, this message translates to:
  /// **'Sắp xếp'**
  String get discovery_filter_sort;

  /// No description provided for @discovery_filter_sort_best.
  ///
  /// In vi, this message translates to:
  /// **'Phù hợp nhất'**
  String get discovery_filter_sort_best;

  /// No description provided for @discovery_filter_sort_newest.
  ///
  /// In vi, this message translates to:
  /// **'Mới nhất'**
  String get discovery_filter_sort_newest;

  /// No description provided for @discovery_filter_apply.
  ///
  /// In vi, this message translates to:
  /// **'Áp dụng'**
  String get discovery_filter_apply;

  /// No description provided for @discovery_filter_reset.
  ///
  /// In vi, this message translates to:
  /// **'Đặt lại'**
  String get discovery_filter_reset;

  /// No description provided for @matches_title.
  ///
  /// In vi, this message translates to:
  /// **'Tương thích'**
  String get matches_title;

  /// No description provided for @matches_no_matches.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có tương thích nào'**
  String get matches_no_matches;

  /// No description provided for @matches_start_conversation.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu trò chuyện'**
  String get matches_start_conversation;

  /// No description provided for @chat_title.
  ///
  /// In vi, this message translates to:
  /// **'Tin nhắn'**
  String get chat_title;

  /// No description provided for @chat_no_messages.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có tin nhắn nào'**
  String get chat_no_messages;

  /// No description provided for @chat_type_message.
  ///
  /// In vi, this message translates to:
  /// **'Nhập tin nhắn...'**
  String get chat_type_message;

  /// No description provided for @chat_send.
  ///
  /// In vi, this message translates to:
  /// **'Gửi'**
  String get chat_send;

  /// No description provided for @settings_title.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get settings_title;

  /// No description provided for @settings_app_info.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin ứng dụng'**
  String get settings_app_info;

  /// No description provided for @settings_version.
  ///
  /// In vi, this message translates to:
  /// **'Phiên bản'**
  String get settings_version;

  /// No description provided for @settings_server_status.
  ///
  /// In vi, this message translates to:
  /// **'Trạng thái server'**
  String get settings_server_status;

  /// No description provided for @settings_server_ok.
  ///
  /// In vi, this message translates to:
  /// **'Hoạt động bình thường'**
  String get settings_server_ok;

  /// No description provided for @settings_server_error.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi kết nối'**
  String get settings_server_error;

  /// No description provided for @settings_checking.
  ///
  /// In vi, this message translates to:
  /// **'Đang kiểm tra...'**
  String get settings_checking;

  /// No description provided for @settings_language_ui.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ & giao diện'**
  String get settings_language_ui;

  /// No description provided for @settings_language.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ'**
  String get settings_language;

  /// No description provided for @settings_language_vietnamese.
  ///
  /// In vi, this message translates to:
  /// **'Tiếng Việt'**
  String get settings_language_vietnamese;

  /// No description provided for @settings_language_english.
  ///
  /// In vi, this message translates to:
  /// **'English'**
  String get settings_language_english;

  /// No description provided for @settings_theme.
  ///
  /// In vi, this message translates to:
  /// **'Giao diện'**
  String get settings_theme;

  /// No description provided for @settings_theme_subtitle.
  ///
  /// In vi, this message translates to:
  /// **'Chọn chế độ sáng/tối hoặc theo hệ thống'**
  String get settings_theme_subtitle;

  /// No description provided for @settings_theme_system.
  ///
  /// In vi, this message translates to:
  /// **'Theo hệ thống'**
  String get settings_theme_system;

  /// No description provided for @settings_theme_light.
  ///
  /// In vi, this message translates to:
  /// **'Sáng'**
  String get settings_theme_light;

  /// No description provided for @settings_theme_dark.
  ///
  /// In vi, this message translates to:
  /// **'Tối'**
  String get settings_theme_dark;

  /// No description provided for @settings_text_size.
  ///
  /// In vi, this message translates to:
  /// **'Kích thước chữ'**
  String get settings_text_size;

  /// No description provided for @settings_help_center.
  ///
  /// In vi, this message translates to:
  /// **'Trung tâm trợ giúp'**
  String get settings_help_center;

  /// No description provided for @settings_faq.
  ///
  /// In vi, this message translates to:
  /// **'FAQ'**
  String get settings_faq;

  /// No description provided for @settings_contact_support.
  ///
  /// In vi, this message translates to:
  /// **'Liên hệ hỗ trợ'**
  String get settings_contact_support;

  /// No description provided for @settings_report_bug.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo sự cố / Gửi phản hồi'**
  String get settings_report_bug;

  /// No description provided for @settings_account.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản'**
  String get settings_account;

  /// No description provided for @settings_logout.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất'**
  String get settings_logout;

  /// No description provided for @settings_logout_confirm.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc muốn đăng xuất?'**
  String get settings_logout_confirm;

  /// No description provided for @home_tab_discover.
  ///
  /// In vi, this message translates to:
  /// **'Discover'**
  String get home_tab_discover;

  /// No description provided for @home_tab_matches.
  ///
  /// In vi, this message translates to:
  /// **'Matches'**
  String get home_tab_matches;

  /// No description provided for @home_tab_messages.
  ///
  /// In vi, this message translates to:
  /// **'Messages'**
  String get home_tab_messages;

  /// No description provided for @home_tab_profile.
  ///
  /// In vi, this message translates to:
  /// **'Profile'**
  String get home_tab_profile;

  /// No description provided for @match_dialog_title.
  ///
  /// In vi, this message translates to:
  /// **'It\'s a Match!'**
  String get match_dialog_title;

  /// No description provided for @match_dialog_message.
  ///
  /// In vi, this message translates to:
  /// **'Bạn và {name} đã thích nhau!'**
  String match_dialog_message(String name);

  /// No description provided for @match_dialog_send_message.
  ///
  /// In vi, this message translates to:
  /// **'Gửi tin nhắn'**
  String get match_dialog_send_message;

  /// No description provided for @match_dialog_keep_swiping.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục tìm kiếm'**
  String get match_dialog_keep_swiping;

  /// No description provided for @onboarding_welcome.
  ///
  /// In vi, this message translates to:
  /// **'Chào mừng đến với Matcha'**
  String get onboarding_welcome;

  /// No description provided for @onboarding_subtitle.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm những kết nối ý nghĩa'**
  String get onboarding_subtitle;

  /// No description provided for @onboarding_get_started.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu'**
  String get onboarding_get_started;

  /// No description provided for @onboarding_login.
  ///
  /// In vi, this message translates to:
  /// **'Đã có tài khoản? Đăng nhập'**
  String get onboarding_login;

  /// No description provided for @swipe_liked.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đã thích {name}'**
  String swipe_liked(String name);

  /// No description provided for @swipe_superliked.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đã Super Like {name}'**
  String swipe_superliked(String name);

  /// No description provided for @swipe_passed.
  ///
  /// In vi, this message translates to:
  /// **'Đã bỏ qua {name}'**
  String swipe_passed(String name);

  /// No description provided for @swipe_action_failed.
  ///
  /// In vi, this message translates to:
  /// **'Không thể gửi thao tác'**
  String get swipe_action_failed;

  /// No description provided for @swipe_match_title.
  ///
  /// In vi, this message translates to:
  /// **'It\'s a match!'**
  String get swipe_match_title;

  /// No description provided for @swipe_match_message.
  ///
  /// In vi, this message translates to:
  /// **'Bạn và {name} đã thích nhau. Hãy bắt đầu trò chuyện!'**
  String swipe_match_message(String name);

  /// No description provided for @swipe_match_time.
  ///
  /// In vi, this message translates to:
  /// **'Thời gian match: {time}'**
  String swipe_match_time(String time);

  /// No description provided for @swipe_chat_now.
  ///
  /// In vi, this message translates to:
  /// **'Nhắn tin ngay'**
  String get swipe_chat_now;

  /// No description provided for @discovery_sort.
  ///
  /// In vi, this message translates to:
  /// **'Sắp xếp'**
  String get discovery_sort;

  /// No description provided for @discovery_sort_best_match.
  ///
  /// In vi, this message translates to:
  /// **'Phù hợp nhất'**
  String get discovery_sort_best_match;

  /// No description provided for @discovery_sort_newest.
  ///
  /// In vi, this message translates to:
  /// **'Mới nhất'**
  String get discovery_sort_newest;

  /// No description provided for @discovery_load_error.
  ///
  /// In vi, this message translates to:
  /// **'Không thể tải danh sách người dùng'**
  String get discovery_load_error;

  /// No description provided for @discovery_empty.
  ///
  /// In vi, this message translates to:
  /// **'Hiện chưa có gợi ý nào.\nHãy thử lại sau hoặc cập nhật bộ lọc.'**
  String get discovery_empty;

  /// No description provided for @discovery_reload.
  ///
  /// In vi, this message translates to:
  /// **'Tải lại'**
  String get discovery_reload;

  /// No description provided for @discovery_online_only.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ hiển thị người đang online'**
  String get discovery_online_only;

  /// No description provided for @discovery_filters_title.
  ///
  /// In vi, this message translates to:
  /// **'Bộ lọc đề xuất'**
  String get discovery_filters_title;

  /// No description provided for @discovery_filters_age_range.
  ///
  /// In vi, this message translates to:
  /// **'Độ tuổi mong muốn'**
  String get discovery_filters_age_range;

  /// No description provided for @discovery_filters_gender_show.
  ///
  /// In vi, this message translates to:
  /// **'Giới tính hiển thị'**
  String get discovery_filters_gender_show;

  /// No description provided for @discovery_filters_lifestyle_match.
  ///
  /// In vi, this message translates to:
  /// **'Lifestyle phù hợp'**
  String get discovery_filters_lifestyle_match;

  /// No description provided for @discovery_filters_interests_common.
  ///
  /// In vi, this message translates to:
  /// **'Sở thích chung (tối đa 5)'**
  String get discovery_filters_interests_common;

  /// No description provided for @discovery_filters_distance_max.
  ///
  /// In vi, this message translates to:
  /// **'Khoảng cách tối đa (km)'**
  String get discovery_filters_distance_max;

  /// No description provided for @discovery_filters_no_distance_limit.
  ///
  /// In vi, this message translates to:
  /// **'Không giới hạn khoảng cách'**
  String get discovery_filters_no_distance_limit;

  /// No description provided for @discovery_filters_no_distance_subtitle.
  ///
  /// In vi, this message translates to:
  /// **'Hiển thị tất cả người dùng bất kể vị trí'**
  String get discovery_filters_no_distance_subtitle;

  /// No description provided for @discovery_filters_apply.
  ///
  /// In vi, this message translates to:
  /// **'Áp dụng bộ lọc'**
  String get discovery_filters_apply;

  /// No description provided for @discovery_filters_gender_required.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ít nhất một giới tính hiển thị'**
  String get discovery_filters_gender_required;

  /// No description provided for @discovery_filters_interests_limit.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ chọn tối đa 5 sở thích'**
  String get discovery_filters_interests_limit;

  /// No description provided for @discovery_filters_no_limit.
  ///
  /// In vi, this message translates to:
  /// **'Không giới hạn'**
  String get discovery_filters_no_limit;

  /// No description provided for @matches_empty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có match nào'**
  String get matches_empty;

  /// No description provided for @matches_load_error.
  ///
  /// In vi, this message translates to:
  /// **'Không thể tải danh sách match'**
  String get matches_load_error;

  /// No description provided for @matches_chat_error.
  ///
  /// In vi, this message translates to:
  /// **'Không thể mở chat'**
  String get matches_chat_error;

  /// No description provided for @matches_unknown_user.
  ///
  /// In vi, this message translates to:
  /// **'Không xác định'**
  String get matches_unknown_user;

  /// No description provided for @chat_list_empty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có cuộc trò chuyện nào'**
  String get chat_list_empty;

  /// No description provided for @chat_list_load_error.
  ///
  /// In vi, this message translates to:
  /// **'Không thể tải danh sách chat'**
  String get chat_list_load_error;

  /// No description provided for @chat_room_other_user_unknown.
  ///
  /// In vi, this message translates to:
  /// **'Người dùng không xác định'**
  String get chat_room_other_user_unknown;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
