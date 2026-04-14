class SupportTicket {
  final String id;
  final String customerId;
  final String subject;
  final String description;
  final String priority;
  final String status;
  final DateTime createdAt;
  final DateTime? lastUpdated;

  SupportTicket({
    required this.id,
    required this.customerId,
    required this.subject,
    required this.description,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.lastUpdated,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['ticket_id'] ?? json['id'] ?? '',
      customerId: json['customer_id'] ?? '',
      subject: json['subject'] ?? '',
      description: json['description'] ?? '',
      priority: json['priority'] ?? 'medium',
      status: json['status'] ?? 'open',
      createdAt: DateTime.parse(
        json['date_created'] ??
            json['createdAt'] ??
            DateTime.now().toIso8601String(),
      ),
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticket_id': id,
      'customer_id': customerId,
      'subject': subject,
      'description': description,
      'priority': priority,
      'status': status,
      'date_created': createdAt.toIso8601String(),
      'last_updated': lastUpdated?.toIso8601String(),
    };
  }
}
