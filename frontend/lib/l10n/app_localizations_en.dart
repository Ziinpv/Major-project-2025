// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Matcha';

  @override
  String get common_ok => 'OK';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_save => 'Save';

  @override
  String get common_delete => 'Delete';

  @override
  String get common_edit => 'Edit';

  @override
  String get common_close => 'Close';

  @override
  String get common_next => 'Next';

  @override
  String get common_back => 'Back';

  @override
  String get common_done => 'Done';

  @override
  String get common_confirm => 'Confirm';

  @override
  String get common_skip => 'Skip';

  @override
  String get common_loading => 'Loading...';

  @override
  String get common_error => 'An error occurred';

  @override
  String get common_retry => 'Retry';

  @override
  String get common_yes => 'Yes';

  @override
  String get common_no => 'No';

  @override
  String get auth_login_title => 'Login';

  @override
  String get auth_login_subtitle => 'Welcome back!';

  @override
  String get auth_login_email_hint => 'Email';

  @override
  String get auth_login_password_hint => 'Password';

  @override
  String get auth_login_button => 'Login';

  @override
  String get auth_login_with_google => 'Login with Google';

  @override
  String get auth_login_or => 'OR';

  @override
  String get auth_login_no_account => 'Don\'t have an account? ';

  @override
  String get auth_login_register => 'Register';

  @override
  String get auth_login_forgot_password => 'Forgot password?';

  @override
  String get auth_register_title => 'Create Account';

  @override
  String get auth_register_subtitle => 'Start your journey';

  @override
  String get auth_register_first_name => 'First Name';

  @override
  String get auth_register_last_name => 'Last Name';

  @override
  String get auth_register_email => 'Email';

  @override
  String get auth_register_password => 'Password';

  @override
  String get auth_register_confirm_password => 'Confirm Password';

  @override
  String get auth_register_dob => 'Date of Birth';

  @override
  String get auth_register_button => 'Register';

  @override
  String get auth_register_with_google => 'Register with Google';

  @override
  String get auth_register_have_account => 'Already have an account? ';

  @override
  String get auth_register_login => 'Login';

  @override
  String get auth_error_email_required => 'Please enter email';

  @override
  String get auth_error_email_invalid => 'Invalid email';

  @override
  String get auth_error_password_required => 'Please enter password';

  @override
  String get auth_error_password_min_length =>
      'Password must be at least 6 characters';

  @override
  String get auth_error_password_mismatch => 'Passwords do not match';

  @override
  String get auth_error_first_name_required => 'Please enter first name';

  @override
  String get auth_error_first_name_min_length =>
      'First name must be at least 2 characters';

  @override
  String get auth_error_first_name_whitespace =>
      'First name cannot contain only whitespace';

  @override
  String get auth_error_last_name_required => 'Please enter last name';

  @override
  String get auth_error_last_name_min_length =>
      'Last name must be at least 2 characters';

  @override
  String get auth_error_last_name_whitespace =>
      'Last name cannot contain only whitespace';

  @override
  String get auth_error_dob_required => 'Please select date of birth';

  @override
  String get profile_setup_title => 'Profile Setup';

  @override
  String profile_setup_step_of(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get profile_setup_gender_title => 'Your gender?';

  @override
  String get profile_setup_gender_male => 'Male';

  @override
  String get profile_setup_gender_female => 'Female';

  @override
  String get profile_setup_gender_non_binary => 'Non-binary';

  @override
  String get profile_setup_gender_other => 'Other';

  @override
  String get profile_setup_interests_title => 'Choose your interests';

  @override
  String get profile_setup_photos_title => 'Add your photos';

  @override
  String get profile_setup_location_title => 'Set your location';

  @override
  String get profile_setup_location_subtitle =>
      'Select your province and city. No location permission needed.';

  @override
  String get profile_setup_province => 'Province / City';

  @override
  String get profile_setup_city => 'City / District / Town';

  @override
  String get profile_setup_address => 'Specific address (optional)';

  @override
  String get profile_setup_select_province_first => 'Select province first';

  @override
  String get profile_setup_complete => 'Profile setup completed!';

  @override
  String get profile_setup_error_gender => 'Please select gender';

  @override
  String get profile_setup_error_photos => 'Please add at least one photo';

  @override
  String get profile_setup_error_location => 'Please select province and city';

  @override
  String get profile_title => 'Your Profile';

  @override
  String get profile_about => 'About';

  @override
  String get profile_job => 'Job';

  @override
  String get profile_school => 'School';

  @override
  String get profile_interests => 'Interests';

  @override
  String get profile_edit_button => 'Edit Profile';

  @override
  String get profile_edit_title => 'Edit Profile';

  @override
  String get profile_edit_photos => 'Your Photos';

  @override
  String get profile_edit_info => 'Information';

  @override
  String get profile_edit_bio => 'About yourself';

  @override
  String get profile_edit_job => 'Job';

  @override
  String get profile_edit_school => 'School';

  @override
  String get profile_edit_interests_title => 'Interests (max 5)';

  @override
  String get profile_edit_lifestyle_title => 'Lifestyle (max 5)';

  @override
  String get profile_edit_save_info => 'Save Information';

  @override
  String get profile_edit_save_photos => 'Save Photos';

  @override
  String get discovery_title => 'Discover';

  @override
  String get discovery_no_users => 'No matching users';

  @override
  String get discovery_filter_button => 'Filters';

  @override
  String get discovery_complete_profile_title =>
      'Complete your profile for better suggestions';

  @override
  String get discovery_complete_profile_subtitle =>
      'Add interests and lifestyle to help the system understand you better.';

  @override
  String get discovery_update_button => 'Update';

  @override
  String get discovery_filter_title => 'Search Filters';

  @override
  String get discovery_filter_age => 'Age';

  @override
  String get discovery_filter_distance => 'Distance (km)';

  @override
  String get discovery_filter_gender => 'Gender';

  @override
  String get discovery_filter_interests => 'Interests';

  @override
  String get discovery_filter_lifestyle => 'Lifestyle';

  @override
  String get discovery_filter_only_online => 'Only show online users';

  @override
  String get discovery_filter_sort => 'Sort by';

  @override
  String get discovery_filter_sort_best => 'Best Match';

  @override
  String get discovery_filter_sort_newest => 'Newest';

  @override
  String get discovery_filter_apply => 'Apply';

  @override
  String get discovery_filter_reset => 'Reset';

  @override
  String get matches_title => 'Matches';

  @override
  String get matches_no_matches => 'No matches yet';

  @override
  String get matches_start_conversation => 'Start conversation';

  @override
  String get chat_title => 'Messages';

  @override
  String get chat_no_messages => 'No messages yet';

  @override
  String get chat_type_message => 'Type a message...';

  @override
  String get chat_send => 'Send';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_app_info => 'App Information';

  @override
  String get settings_version => 'Version';

  @override
  String get settings_server_status => 'Server Status';

  @override
  String get settings_server_ok => 'Operating normally';

  @override
  String get settings_server_error => 'Connection error';

  @override
  String get settings_checking => 'Checking...';

  @override
  String get settings_language_ui => 'Language & Interface';

  @override
  String get settings_language => 'Language';

  @override
  String get settings_language_vietnamese => 'Tiếng Việt';

  @override
  String get settings_language_english => 'English';

  @override
  String get settings_theme => 'Theme';

  @override
  String get settings_theme_subtitle =>
      'Choose light/dark mode or follow system';

  @override
  String get settings_theme_system => 'System';

  @override
  String get settings_theme_light => 'Light';

  @override
  String get settings_theme_dark => 'Dark';

  @override
  String get settings_text_size => 'Text Size';

  @override
  String get settings_help_center => 'Help Center';

  @override
  String get settings_faq => 'FAQ';

  @override
  String get settings_contact_support => 'Contact Support';

  @override
  String get settings_report_bug => 'Report Bug / Send Feedback';

  @override
  String get settings_account => 'Account';

  @override
  String get settings_logout => 'Logout';

  @override
  String get settings_logout_confirm => 'Are you sure you want to logout?';

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
    return 'You and $name liked each other!';
  }

  @override
  String get match_dialog_send_message => 'Send Message';

  @override
  String get match_dialog_keep_swiping => 'Keep Swiping';

  @override
  String get onboarding_welcome => 'Welcome to Matcha';

  @override
  String get onboarding_subtitle => 'Find meaningful connections';

  @override
  String get onboarding_get_started => 'Get Started';

  @override
  String get onboarding_login => 'Already have an account? Login';
}
