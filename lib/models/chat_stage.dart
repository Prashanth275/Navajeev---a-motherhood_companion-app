class ChatContext {
  final String stage; // pregnant | postpartum
  final int? trimester;
  final int? babyAgeMonths;

  ChatContext({
    required this.stage,
    this.trimester,
    this.babyAgeMonths,
  });

  String toPromptPrefix() {
    if (stage == 'pregnant') {
      return 'User is pregnant${trimester != null ? ", Trimester $trimester" : ""}.';
    }

    return 'User is postpartum${babyAgeMonths != null ? ", baby age $babyAgeMonths months" : ""}.';
  }
}
