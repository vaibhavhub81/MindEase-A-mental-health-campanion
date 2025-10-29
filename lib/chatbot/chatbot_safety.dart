import 'package:url_launcher/url_launcher.dart';

class Helpline {
  final String country;
  final String number;
  Helpline(this.country, this.number);
}

class ChatbotSafety {
  static const crisisKeywords = [
    "suicide", "kill myself", "end my life", "die", "hopeless",
    "can't go on", "want to disappear", "panic attack"
  ];

  static const crisisMessage = "It looks like you may be in crisis. Reach out immediately!";

  static final List<Helpline> helplines = [
    Helpline("India 🇮🇳", "tel:919820466726"),
    Helpline("USA 🇺🇸", "tel:988"),
    Helpline("UK 🇬🇧", "tel:116123"),
  ];

  static bool detectCrisis(String text) {
    final lower = text.toLowerCase();
    return crisisKeywords.any((k) => lower.contains(k));
  }

  static Future<void> callHelpline(String number) async {
    final uri = Uri.parse(number);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}
