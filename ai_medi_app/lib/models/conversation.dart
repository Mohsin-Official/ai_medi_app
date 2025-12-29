import 'package:ai_medi_app/models/message.dart';

class Conversation {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime lastUpdate;
  final List<Message> messages;
  final Map<String, dynamic> userContext;

  Conversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.lastUpdate,
    required this.messages,
    required this.userContext,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': title,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastUpdate': lastUpdate.millisecondsSinceEpoch,
      'messages': messages.map((m) => m.toJason()).toList(),
      'userContext': userContext,
    };
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      title: json['title'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      lastUpdate: DateTime.fromMillisecondsSinceEpoch(json['lastUpdate']),
      messages: (json['messages'] as List)
          .map((m) => Message.fromJson(m))
          .toList(),
      userContext: Map<String, dynamic>.from(json['userContext']),
    );
  }

  Conversation copyWith({
    String? tilte,
    DateTime? lastUpdate,
    List<Message>? messages,
    Map<String, dynamic>? userContext,
  }) {
    return Conversation(
      id: id,
      title: title,
      createdAt: createdAt,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      messages: messages ?? this.messages,
      userContext: userContext ?? this.userContext,
    );
  }
}
