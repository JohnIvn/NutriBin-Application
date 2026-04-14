class SupportMessage {
  final String id;
  final String ticketId;
  final String senderId;
  final String message;
  final String senderType;
  final DateTime createdAt;

  SupportMessage({
    required this.id,
    required this.ticketId,
    required this.senderId,
    required this.message,
    required this.senderType,
    required this.createdAt,
  });

  factory SupportMessage.fromJson(Map<String, dynamic> json) {
    return SupportMessage(
      id: json['message_id'] ?? json['id'] ?? '',
      ticketId: json['ticket_id'] ?? '',
      senderId: json['sender_id'] ?? '',
      message: json['message'] ?? '',
      senderType: json['sender_type'] ?? 'customer',
      createdAt: DateTime.parse(
        json['date_created'] ??
            json['createdAt'] ??
            DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message_id': id,
      'ticket_id': ticketId,
      'sender_id': senderId,
      'message': message,
      'sender_type': senderType,
      'date_created': createdAt.toIso8601String(),
    };
  }
}
