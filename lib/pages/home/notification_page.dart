import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutribin_application/services/machine_service.dart';
import 'package:intl/intl.dart';

enum NotificationType { success, error, defaultType }

class NotificationPage extends StatefulWidget {
  final String machineId;
  const NotificationPage({super.key, required this.machineId});

  static String routeName = 'notifi';
  static String routePath = '/notifi';

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  int? _expandedIndex;
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  // Get colors based on theme
  Color get _primaryBackground => Theme.of(context).scaffoldBackgroundColor;
  Color get _secondaryText => Theme.of(context).colorScheme.onSurface;
  Color get _shadowColor {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return isDarkMode ? Colors.black.withOpacity(0.2) : Color(0xFFE0E3E7);
  }

  // Parse notification type from string
  NotificationType _parseType(String type) {
    switch (type.toLowerCase()) {
      case 'success':
        return NotificationType.success;
      case 'error':
        return NotificationType.error;
      default:
        return NotificationType.defaultType;
    }
  }

  // Format date from ISO string
  String _formatDate(String isoDate) {
    try {
      final DateTime dateTime = DateTime.parse(isoDate);
      final DateFormat formatter = DateFormat('MMM d, yyyy');
      return formatter.format(dateTime);
    } catch (e) {
      return isoDate;
    }
  }

  // Format time from ISO string
  String _formatTime(String isoDate) {
    try {
      final DateTime dateTime = DateTime.parse(isoDate);
      final DateFormat formatter = DateFormat('h:mm a');
      return formatter.format(dateTime);
    } catch (e) {
      return '';
    }
  }

  // Get colors based on notification type
  Color _getAccentColor(NotificationType type) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    switch (type) {
      case NotificationType.success:
        return Color(0xFF4CAF50);
      case NotificationType.error:
        return Color(0xFFF44336);
      case NotificationType.defaultType:
        return isDarkMode
            ? Colors.grey.shade400
            : Color.fromARGB(156, 26, 23, 23);
    }
  }

  Color _getBackgroundColor(NotificationType type, bool isExpanded) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (!isExpanded) {
      return isDarkMode ? Theme.of(context).cardColor : _primaryBackground;
    }

    switch (type) {
      case NotificationType.success:
        return isDarkMode
            ? Color(0xFF1B5E20).withOpacity(0.3)
            : Color(0xFFE8F5E9);
      case NotificationType.error:
        return isDarkMode
            ? Color(0xFFC62828).withOpacity(0.3)
            : Color(0xFFFFEBEE);
      case NotificationType.defaultType:
        return isDarkMode ? Colors.grey.shade800 : Color(0xFFF5F5F5);
    }
  }

  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Icons.check_circle_outline;
      case NotificationType.error:
        return Icons.error_outline;
      case NotificationType.defaultType:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: _primaryBackground,
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : notifications.isEmpty
            ? Center(
                child: Text(
                  'No notifications',
                  style: GoogleFonts.inter(
                    color: _secondaryText.withOpacity(0.6),
                    fontSize: 16,
                  ),
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  final isExpanded = _expandedIndex == index;
                  final type = _parseType(notification['type'] ?? 'default');
                  final isResolved = notification['resolved'] ?? false;

                  return Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 1),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _getBackgroundColor(type, isExpanded),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 0,
                            color: _shadowColor,
                            offset: Offset(0.0, 1),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(0),
                        shape: BoxShape.rectangle,
                      ),
                      child: Opacity(
                        opacity: isResolved ? 0.6 : 1.0,
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _expandedIndex = isExpanded ? null : index;
                                  });
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: _getAccentColor(type),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                        12,
                                        0,
                                        8,
                                        0,
                                      ),
                                      child: Icon(
                                        _getIcon(type),
                                        color: _getAccentColor(type),
                                        size: 24,
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  notification['header'] ?? '',
                                                  style: GoogleFonts.inter(
                                                    color: _secondaryText,
                                                    fontSize: 16,
                                                    fontWeight: isExpanded
                                                        ? FontWeight.w600
                                                        : FontWeight.normal,
                                                  ),
                                                ),
                                              ),
                                              if (isResolved)
                                                Container(
                                                  margin: EdgeInsets.only(
                                                    left: 8,
                                                  ),
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green
                                                        .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    'Resolved',
                                                    style: GoogleFonts.inter(
                                                      color: Colors.green,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          if (notification['subheader'] !=
                                                  null &&
                                              notification['subheader']
                                                  .toString()
                                                  .isNotEmpty)
                                            Padding(
                                              padding: EdgeInsets.only(top: 2),
                                              child: Text(
                                                notification['subheader']!,
                                                style: GoogleFonts.inter(
                                                  color: _secondaryText
                                                      .withOpacity(0.6),
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                        12,
                                        0,
                                        8,
                                        0,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            _formatDate(
                                              notification['date'] ?? '',
                                            ),
                                            style: GoogleFonts.inter(
                                              color: _secondaryText,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            _formatTime(
                                              notification['date'] ?? '',
                                            ),
                                            style: GoogleFonts.inter(
                                              color: _secondaryText.withOpacity(
                                                0.6,
                                              ),
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      isExpanded
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: _secondaryText,
                                      size: 24,
                                    ),
                                  ],
                                ),
                              ),
                              AnimatedCrossFade(
                                firstChild: SizedBox.shrink(),
                                secondChild: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                    44,
                                    12,
                                    16,
                                    8,
                                  ),
                                  child: Text(
                                    notification['description'] ?? '',
                                    style: GoogleFonts.inter(
                                      color: _secondaryText.withOpacity(0.7),
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                                crossFadeState: isExpanded
                                    ? CrossFadeState.showSecond
                                    : CrossFadeState.showFirst,
                                duration: Duration(milliseconds: 200),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  void fetchNotifications() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await MachineService.fetchNotifications(
        machineId: widget.machineId,
      );
      print("RESPONSE: ${response.toString()}");

      if (response['ok'] == true && response['data'] != null) {
        print("NOTIFICATIONS: ${response['data']}");
        setState(() {
          notifications = List<Map<String, dynamic>>.from(response['data']);
          isLoading = false;
        });
      } else {
        setState(() {
          notifications = [];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
    }
  }
}
