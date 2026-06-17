class ChatMessageModel {
  final String text;
  final String? option1;
  final String? option2;
  final String? option3;
  final bool isUser;
  final DateTime timestamp;

  ChatMessageModel({
    this.text = '',
    this.option1,
    this.option2,
    this.option3,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'option1': option1,
        'option2': option2,
        'option3': option3,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) => ChatMessageModel(
        text: json['text'] ?? '',
        option1: json['option1'],
        option2: json['option2'],
        option3: json['option3'],
        isUser: json['isUser'] ?? false,
        timestamp: json['timestamp'] != null
            ? DateTime.parse(json['timestamp'])
            : DateTime.now(),
      );
}
