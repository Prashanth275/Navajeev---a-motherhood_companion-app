class ChatContext {
  final String stage;         // 'pregnancy' | 'postpartum'
  final int? trimester;       // 1, 2, or 3 (pregnancy only)
  final int? babyAgeMonths;   // postpartum only
  final String? babyName;     // personalises responses
  final String? feedingType;  // 'breastfeeding' | 'formula' | 'mixed'
  final String? deliveryType; // 'normal' | 'caesarean'

  ChatContext({
    required this.stage,
    this.trimester,
    this.babyAgeMonths,
    this.babyName,
    this.feedingType,
    this.deliveryType,
  });

  // -------------------------------------------------------
  // Builds the context prefix injected into every question.
  // This is what makes the chatbot context-aware.
  // -------------------------------------------------------
  String toPromptPrefix() {
    if (stage == 'pregnancy') {
      final trimStr = trimester != null ? ', Trimester $trimester' : '';
      return 'The user is pregnant$trimStr.';
    }

    // Postpartum
    final parts = <String>[];
    if (babyAgeMonths != null) parts.add('baby is $babyAgeMonths months old');
    if (babyName != null)      parts.add("baby's name is $babyName");
    if (feedingType != null)   parts.add('feeding method is $feedingType');
    if (deliveryType != null)  parts.add('delivery was $deliveryType');

    final detail = parts.isNotEmpty ? ' (${parts.join(', ')})' : '';
    return 'The user is postpartum$detail.';
  }

  // Which FAQ list to show in the chat UI
  bool get isPregnancy => stage == 'pregnancy';
}
