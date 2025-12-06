// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Matcha';

  @override
  String get common_ok => 'OK';

  @override
  String get common_cancel => 'Hủy';

  @override
  String get common_save => 'Lưu';

  @override
  String get common_delete => 'Xóa';

  @override
  String get common_edit => 'Chỉnh sửa';

  @override
  String get common_close => 'Đóng';

  @override
  String get common_next => 'Tiếp theo';

  @override
  String get common_back => 'Quay lại';

  @override
  String get common_done => 'Hoàn tất';

  @override
  String get common_confirm => 'Xác nhận';

  @override
  String get common_skip => 'Bỏ qua';

  @override
  String get common_loading => 'Đang tải...';

  @override
  String get common_error => 'Đã có lỗi xảy ra';

  @override
  String get common_retry => 'Thử lại';

  @override
  String get common_yes => 'Có';

  @override
  String get common_no => 'Không';

  @override
  String get auth_login_title => 'Đăng nhập';

  @override
  String get auth_login_subtitle => 'Chào mừng bạn trở lại!';

  @override
  String get auth_login_email_hint => 'Email';

  @override
  String get auth_login_password_hint => 'Mật khẩu';

  @override
  String get auth_login_button => 'Đăng nhập';

  @override
  String get auth_login_with_google => 'Đăng nhập với Google';

  @override
  String get auth_login_or => 'HOẶC';

  @override
  String get auth_login_no_account => 'Chưa có tài khoản? ';

  @override
  String get auth_login_register => 'Đăng ký';

  @override
  String get auth_login_forgot_password => 'Quên mật khẩu?';

  @override
  String get auth_register_title => 'Tạo tài khoản';

  @override
  String get auth_register_subtitle => 'Bắt đầu hành trình tìm kiếm của bạn';

  @override
  String get auth_register_first_name => 'Tên';

  @override
  String get auth_register_last_name => 'Họ';

  @override
  String get auth_register_email => 'Email';

  @override
  String get auth_register_password => 'Mật khẩu';

  @override
  String get auth_register_confirm_password => 'Xác nhận mật khẩu';

  @override
  String get auth_register_dob => 'Ngày sinh';

  @override
  String get auth_register_button => 'Đăng ký';

  @override
  String get auth_register_with_google => 'Đăng ký với Google';

  @override
  String get auth_register_have_account => 'Đã có tài khoản? ';

  @override
  String get auth_register_login => 'Đăng nhập';

  @override
  String get auth_error_email_required => 'Vui lòng nhập email';

  @override
  String get auth_error_email_invalid => 'Email không hợp lệ';

  @override
  String get auth_error_password_required => 'Vui lòng nhập mật khẩu';

  @override
  String get auth_error_password_min_length =>
      'Mật khẩu phải có ít nhất 6 ký tự';

  @override
  String get auth_error_password_mismatch => 'Mật khẩu không khớp';

  @override
  String get auth_error_first_name_required => 'Vui lòng nhập tên';

  @override
  String get auth_error_first_name_min_length => 'Tên phải có ít nhất 2 ký tự';

  @override
  String get auth_error_first_name_whitespace =>
      'Tên không được chỉ chứa khoảng trắng';

  @override
  String get auth_error_last_name_required => 'Vui lòng nhập họ';

  @override
  String get auth_error_last_name_min_length => 'Họ phải có ít nhất 2 ký tự';

  @override
  String get auth_error_last_name_whitespace =>
      'Họ không được chỉ chứa khoảng trắng';

  @override
  String get auth_error_dob_required => 'Vui lòng chọn ngày sinh';

  @override
  String get profile_setup_title => 'Thiết lập hồ sơ';

  @override
  String profile_setup_step_of(int current, int total) {
    return 'Bước $current của $total';
  }

  @override
  String get profile_setup_gender_title => 'Giới tính của bạn?';

  @override
  String get profile_setup_gender_male => 'Nam';

  @override
  String get profile_setup_gender_female => 'Nữ';

  @override
  String get profile_setup_gender_non_binary => 'Phi nhị phân';

  @override
  String get profile_setup_gender_other => 'Khác';

  @override
  String get profile_setup_interests_title => 'Chọn sở thích của bạn';

  @override
  String get profile_setup_photos_title => 'Thêm ảnh của bạn';

  @override
  String get profile_setup_location_title => 'Thiết lập vị trí';

  @override
  String get profile_setup_location_subtitle =>
      'Chọn tỉnh/thành và thành phố bạn đang sinh sống. Không cần cấp quyền vị trí.';

  @override
  String get profile_setup_province => 'Tỉnh / Thành phố';

  @override
  String get profile_setup_city => 'Thành phố / Quận / Thị xã';

  @override
  String get profile_setup_address => 'Địa chỉ cụ thể (tuỳ chọn)';

  @override
  String get profile_setup_select_province_first => 'Chọn tỉnh/thành trước';

  @override
  String get profile_setup_complete => 'Hoàn tất thiết lập hồ sơ!';

  @override
  String get profile_setup_error_gender => 'Vui lòng chọn giới tính';

  @override
  String get profile_setup_error_photos => 'Vui lòng thêm ít nhất một ảnh';

  @override
  String get profile_setup_error_location =>
      'Vui lòng chọn tỉnh/thành và thành phố';

  @override
  String get profile_title => 'Hồ sơ của bạn';

  @override
  String get profile_about => 'Giới thiệu';

  @override
  String get profile_job => 'Công việc';

  @override
  String get profile_school => 'Trường học';

  @override
  String get profile_interests => 'Sở thích';

  @override
  String get profile_lifestyle => 'Phong cách sống';

  @override
  String get profile_edit_button => 'Chỉnh sửa hồ sơ';

  @override
  String get profile_edit_title => 'Chỉnh sửa hồ sơ';

  @override
  String get profile_edit_photos => 'Ảnh của bạn';

  @override
  String get profile_edit_info => 'Thông tin';

  @override
  String get profile_edit_bio => 'Giới thiệu bản thân';

  @override
  String get profile_edit_job => 'Công việc';

  @override
  String get profile_edit_school => 'Trường học';

  @override
  String get profile_edit_interests_title => 'Sở thích (tối đa 5)';

  @override
  String get profile_edit_lifestyle_title => 'Lifestyle (tối đa 5)';

  @override
  String get profile_edit_save_info => 'Lưu thông tin';

  @override
  String get profile_edit_save_photos => 'Lưu ảnh';

  @override
  String get discovery_title => 'Khám phá';

  @override
  String get discovery_no_users => 'Không có người dùng nào phù hợp';

  @override
  String get discovery_filter_button => 'Bộ lọc';

  @override
  String get discovery_complete_profile_title =>
      'Hoàn thiện hồ sơ để có đề xuất tốt hơn';

  @override
  String get discovery_complete_profile_subtitle =>
      'Thêm sở thích và lifestyle giúp hệ thống hiểu bạn hơn.';

  @override
  String get discovery_update_button => 'Cập nhật';

  @override
  String get discovery_filter_title => 'Bộ lọc tìm kiếm';

  @override
  String get discovery_filter_age => 'Độ tuổi';

  @override
  String get discovery_filter_distance => 'Khoảng cách (km)';

  @override
  String get discovery_filter_gender => 'Giới tính';

  @override
  String get discovery_filter_interests => 'Sở thích';

  @override
  String get discovery_filter_lifestyle => 'Lifestyle';

  @override
  String get discovery_filter_only_online => 'Chỉ hiển thị người online';

  @override
  String get discovery_filter_sort => 'Sắp xếp';

  @override
  String get discovery_filter_sort_best => 'Phù hợp nhất';

  @override
  String get discovery_filter_sort_newest => 'Mới nhất';

  @override
  String get discovery_filter_apply => 'Áp dụng';

  @override
  String get discovery_filter_reset => 'Đặt lại';

  @override
  String get matches_title => 'Tương thích';

  @override
  String get matches_no_matches => 'Chưa có tương thích nào';

  @override
  String get matches_start_conversation => 'Bắt đầu trò chuyện';

  @override
  String get chat_title => 'Tin nhắn';

  @override
  String get chat_no_messages => 'Chưa có tin nhắn nào';

  @override
  String get chat_type_message => 'Nhập tin nhắn...';

  @override
  String get chat_send => 'Gửi';

  @override
  String get settings_title => 'Cài đặt';

  @override
  String get settings_app_info => 'Thông tin ứng dụng';

  @override
  String get settings_version => 'Phiên bản';

  @override
  String get settings_server_status => 'Trạng thái server';

  @override
  String get settings_server_ok => 'Hoạt động bình thường';

  @override
  String get settings_server_error => 'Lỗi kết nối';

  @override
  String get settings_checking => 'Đang kiểm tra...';

  @override
  String get settings_language_ui => 'Ngôn ngữ & giao diện';

  @override
  String get settings_language => 'Ngôn ngữ';

  @override
  String get settings_language_vietnamese => 'Tiếng Việt';

  @override
  String get settings_language_english => 'English';

  @override
  String get settings_theme => 'Giao diện';

  @override
  String get settings_theme_subtitle =>
      'Chọn chế độ sáng/tối hoặc theo hệ thống';

  @override
  String get settings_theme_system => 'Theo hệ thống';

  @override
  String get settings_theme_light => 'Sáng';

  @override
  String get settings_theme_dark => 'Tối';

  @override
  String get settings_text_size => 'Kích thước chữ';

  @override
  String get settings_help_center => 'Trung tâm trợ giúp';

  @override
  String get settings_faq => 'FAQ';

  @override
  String get settings_contact_support => 'Liên hệ hỗ trợ';

  @override
  String get settings_report_bug => 'Báo cáo sự cố / Gửi phản hồi';

  @override
  String get settings_account => 'Tài khoản';

  @override
  String get settings_change_password => 'Đổi mật khẩu';

  @override
  String get settings_change_password_subtitle => 'Cập nhật mật khẩu của bạn';

  @override
  String get settings_current_password => 'Mật khẩu hiện tại';

  @override
  String get settings_new_password => 'Mật khẩu mới';

  @override
  String get settings_confirm_new_password => 'Xác nhận mật khẩu mới';

  @override
  String get settings_password_changed_success => 'Đổi mật khẩu thành công';

  @override
  String get settings_delete_account => 'Xóa tài khoản';

  @override
  String get settings_delete_account_warning => 'CẢNH BÁO';

  @override
  String get settings_delete_account_message =>
      'BẠN CÓ CHẮC MUỐN TIẾP TỤC? VIỆC XÓA TÀI KHOẢN SẼ KHÔNG THỂ KHÔI PHỤC.';

  @override
  String get settings_delete_account_password_hint =>
      'Nhập mật khẩu để xác nhận';

  @override
  String get settings_delete_permanently => 'Xóa vĩnh viễn';

  @override
  String get settings_account_deleted_success =>
      'Tài khoản đã được xóa thành công';

  @override
  String get settings_logout => 'Đăng xuất';

  @override
  String get settings_logout_confirm => 'Bạn có chắc muốn đăng xuất?';

  @override
  String get home_tab_discover => 'Discover';

  @override
  String get home_tab_matches => 'Matches';

  @override
  String get home_tab_messages => 'Messages';

  @override
  String get home_tab_profile => 'Profile';

  @override
  String get match_dialog_title => 'It\'s a Match!';

  @override
  String match_dialog_message(String name) {
    return 'Bạn và $name đã thích nhau!';
  }

  @override
  String get match_dialog_send_message => 'Gửi tin nhắn';

  @override
  String get match_dialog_keep_swiping => 'Tiếp tục tìm kiếm';

  @override
  String get onboarding_welcome => 'Chào mừng đến với Matcha';

  @override
  String get onboarding_subtitle => 'Tìm kiếm những kết nối ý nghĩa';

  @override
  String get onboarding_get_started => 'Bắt đầu';

  @override
  String get onboarding_login => 'Đã có tài khoản? Đăng nhập';

  @override
  String swipe_liked(String name) {
    return 'Bạn đã thích $name';
  }

  @override
  String swipe_superliked(String name) {
    return 'Bạn đã Super Like $name';
  }

  @override
  String swipe_passed(String name) {
    return 'Đã bỏ qua $name';
  }

  @override
  String get swipe_action_failed => 'Không thể gửi thao tác';

  @override
  String get swipe_match_title => 'It\'s a match!';

  @override
  String swipe_match_message(String name) {
    return 'Bạn và $name đã thích nhau. Hãy bắt đầu trò chuyện!';
  }

  @override
  String swipe_match_time(String time) {
    return 'Thời gian match: $time';
  }

  @override
  String get swipe_chat_now => 'Nhắn tin ngay';

  @override
  String get discovery_sort => 'Sắp xếp';

  @override
  String get discovery_sort_best_match => 'Phù hợp nhất';

  @override
  String get discovery_sort_newest => 'Mới nhất';

  @override
  String get discovery_load_error => 'Không thể tải danh sách người dùng';

  @override
  String get discovery_empty =>
      'Hiện chưa có gợi ý nào.\nHãy thử lại sau hoặc cập nhật bộ lọc.';

  @override
  String get discovery_reload => 'Tải lại';

  @override
  String get discovery_online_only => 'Chỉ hiển thị người đang online';

  @override
  String get discovery_filters_title => 'Bộ lọc đề xuất';

  @override
  String get discovery_filters_age_range => 'Độ tuổi mong muốn';

  @override
  String get discovery_filters_gender_show => 'Giới tính hiển thị';

  @override
  String get discovery_filters_lifestyle_match => 'Lifestyle phù hợp';

  @override
  String get discovery_filters_interests_common => 'Sở thích chung (tối đa 5)';

  @override
  String get discovery_filters_distance_max => 'Khoảng cách tối đa (km)';

  @override
  String get discovery_filters_no_distance_limit =>
      'Không giới hạn khoảng cách';

  @override
  String get discovery_filters_no_distance_subtitle =>
      'Hiển thị tất cả người dùng bất kể vị trí';

  @override
  String get discovery_filters_apply => 'Áp dụng bộ lọc';

  @override
  String get discovery_filters_gender_required =>
      'Chọn ít nhất một giới tính hiển thị';

  @override
  String get discovery_filters_interests_limit => 'Chỉ chọn tối đa 5 sở thích';

  @override
  String get discovery_filters_no_limit => 'Không giới hạn';

  @override
  String get matches_empty => 'Chưa có match nào';

  @override
  String get matches_load_error => 'Không thể tải danh sách match';

  @override
  String get matches_chat_error => 'Không thể mở chat';

  @override
  String get matches_unknown_user => 'Không xác định';

  @override
  String get chat_list_empty => 'Chưa có cuộc trò chuyện nào';

  @override
  String get chat_list_load_error => 'Không thể tải danh sách chat';

  @override
  String get chat_room_other_user_unknown => 'Người dùng không xác định';
}
