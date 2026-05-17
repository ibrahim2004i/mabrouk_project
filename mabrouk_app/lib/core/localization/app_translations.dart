import 'package:get/get.dart';
import 'languages/ar_jo.dart';
import 'languages/en_us.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'ar': arJo,
        'en': enUs,
      };
}
