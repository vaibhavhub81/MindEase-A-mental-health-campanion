class ChatbotSafety {
  static final List<String> _crisisWords = [
    'suicide',
    'kill myself',
    'hate myself',
    'hurt myself',
    'end my life',
    'self harm'
  ];

  static bool detectCrisis(String text) {
    final t = text.toLowerCase();
    for (final w in _crisisWords) {
      if (t.contains(w)) return true;
    }
    return false;
  }

  static String get crisisMessage =>
      "I'm really sorry you're feeling this way. If you're in immediate danger, please call local emergency services. If not, please consider contacting a crisis helpline.";
}
