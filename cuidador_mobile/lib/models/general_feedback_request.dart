class GeneralFeedbackRequest {
  final int? generalFeeling;
  final String? text;

  GeneralFeedbackRequest({
    this.generalFeeling,
    this.text,
  });

  Map<String, dynamic> toJson() {
    return {
      'generalFeeling': generalFeeling,
      'text': text,
    };
  }
}