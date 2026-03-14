import 'package:flutter_test/flutter_test.dart';
import 'package:yetimatch/config/app_config.dart';

void main() {
  group('AppConfig', () {
    test('privacyPolicyUrl and supportUrl are set', () {
      expect(AppConfig.privacyPolicyUrl, contains('daddoodev.pro'));
      expect(AppConfig.supportUrl, contains('support@daddoodev.pro'));
    });

    test('apiKey is a string (compile-time or init)', () {
      expect(AppConfig.apiKey, isA<String>());
    });
  });
}
