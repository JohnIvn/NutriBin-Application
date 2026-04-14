import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:nutribin_application/models/support_ticket.dart';
import 'package:nutribin_application/models/support_message.dart';
import 'package:nutribin_application/utils/response_handler.dart';

final String restUser = dotenv.env["RAILWAY_USER"].toString();

class SupportService {
  /// Create a new support ticket
  static Future<Map<String, dynamic>> createTicket({
    required String customerId,
    required String subject,
    required String description,
    String priority = 'medium',
  }) async {
    try {
      final url = Uri.parse("$restUser/support/tickets");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'customerId': customerId,
          'subject': subject,
          'description': description,
          'priority': priority,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'ok': true, 'data': SupportTicket.fromJson(data)};
      } else {
        return Error.errorResponse('Failed to create support ticket');
      }
    } catch (e) {
      return Error.errorResponse('Error creating ticket: ${e.toString()}');
    }
  }

  /// Get all tickets for a customer
  static Future<Map<String, dynamic>> getTickets({
    required String customerId,
  }) async {
    try {
      final url = Uri.parse("$restUser/support/tickets/customer/$customerId");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final tickets = data
            .map((ticket) => SupportTicket.fromJson(ticket))
            .toList();
        return {'ok': true, 'data': tickets};
      } else {
        return Error.errorResponse('Failed to fetch tickets');
      }
    } catch (e) {
      return Error.errorResponse('Error fetching tickets: ${e.toString()}');
    }
  }

  /// Get a specific ticket by ID
  static Future<Map<String, dynamic>> getTicketById({
    required String ticketId,
    required String customerId,
  }) async {
    try {
      final url = Uri.parse(
        "$restUser/support/tickets/$ticketId/customer/$customerId",
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'ok': true, 'data': SupportTicket.fromJson(data)};
      } else {
        return Error.errorResponse('Ticket not found');
      }
    } catch (e) {
      return Error.errorResponse('Error fetching ticket: ${e.toString()}');
    }
  }

  /// Add a message to a support ticket
  static Future<Map<String, dynamic>> addMessage({
    required String ticketId,
    required String senderId,
    required String message,
  }) async {
    try {
      final url = Uri.parse("$restUser/support/tickets/$ticketId/messages");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'senderId': senderId, 'message': message}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'ok': true, 'data': SupportMessage.fromJson(data)};
      } else {
        return Error.errorResponse('Failed to send message');
      }
    } catch (e) {
      return Error.errorResponse('Error sending message: ${e.toString()}');
    }
  }

  /// Get all messages for a ticket
  static Future<Map<String, dynamic>> getMessages({
    required String ticketId,
    required String customerId,
  }) async {
    try {
      final url = Uri.parse(
        "$restUser/support/tickets/$ticketId/messages/customer/$customerId",
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final messages = data
            .map((message) => SupportMessage.fromJson(message))
            .toList();
        return {'ok': true, 'data': messages};
      } else {
        return Error.errorResponse('Failed to fetch messages');
      }
    } catch (e) {
      return Error.errorResponse('Error fetching messages: ${e.toString()}');
    }
  }
}
