import 'package:flutter/widgets.dart';
import 'package:windwisher/features/auth/presentation/onboarding/community_guidelines_dialog.dart';
import 'package:windwisher/features/auth/presentation/onboarding/data_sources_licenses_dialog.dart';
import 'package:windwisher/features/auth/presentation/onboarding/legal_notice_dialog.dart';
import 'package:windwisher/features/auth/presentation/onboarding/privacy_policy_dialog.dart';
import 'package:windwisher/features/auth/presentation/onboarding/terms_and_conditions_dialog.dart';
import 'package:windwisher/features/auth/presentation/onboarding/weather_safety_disclaimer_dialog.dart';

class LegalSettingsLauncher {
  const LegalSettingsLauncher._();

  static void showTerms(BuildContext context) {
    TermsAndConditionsDialog.showReadOnly(context);
  }

  static void showPrivacy(BuildContext context) {
    PrivacyPolicyDialog.show(context);
  }

  static void showLegalNotice(BuildContext context) {
    LegalNoticeDialog.show(context);
  }

  static void showWeatherSafetyDisclaimer(BuildContext context) {
    WeatherSafetyDisclaimerDialog.show(context);
  }

  static void showCommunityGuidelines(BuildContext context) {
    CommunityGuidelinesDialog.show(context);
  }

  static void showDataSourcesLicenses(BuildContext context) {
    DataSourcesLicensesDialog.show(context);
  }
}
