import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum NotificationType { good, bad, defaultType }

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  static String routeName = 'notifi';
  static String routePath = '/notifi';

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  int? _expandedIndex;

  // Get colors based on theme
  Color get _primaryBackground => Theme.of(context).scaffoldBackgroundColor;
  Color get _secondaryText => Theme.of(context).colorScheme.onSurface;
  Color get _shadowColor {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return isDarkMode ? Colors.black.withOpacity(0.2) : Color(0xFFE0E3E7);
  }

  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Trash detected',
      'date': 'Mar 8, 2022',
      'details':
          'Your bin has detected new trash. The system has automatically categorized it as biodegradable waste.',
      'type': NotificationType.good,
    },
    {
      'title': 'Invalid trash detected',
      'date': 'Mar 8, 2022',
      'details':
          'Non-recyclable item detected in the recyclable bin. Please ensure proper waste segregation.',
      'type': NotificationType.bad,
    },
    {
      'title': 'Welcome to NutriBin',
      'date': 'Feb 13, 2022',
      'details':
          'Thank you for choosing NutriBin! Start your journey towards smarter waste management today.',
      'type': NotificationType.defaultType,
    },
  ];

  // Get colors based on notification type
  Color _getAccentColor(NotificationType type) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    switch (type) {
      case NotificationType.good:
        return Color(0xFF4CAF50);
      case NotificationType.bad:
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
      case NotificationType.good:
        return isDarkMode
            ? Color(0xFF1B5E20).withOpacity(0.3)
            : Color(0xFFE8F5E9);
      case NotificationType.bad:
        return isDarkMode
            ? Color(0xFFC62828).withOpacity(0.3)
            : Color(0xFFFFEBEE);
      case NotificationType.defaultType:
        return isDarkMode ? Colors.grey.shade800 : Color(0xFFF5F5F5);
    }
  }

  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.good:
        return Icons.check_circle_outline;
      case NotificationType.bad:
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
        body: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: _notifications.length,
          itemBuilder: (context, index) {
            final notification = _notifications[index];
            final isExpanded = _expandedIndex == index;
            final type = notification['type'] as NotificationType;

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
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            // Close if already expanded, otherwise open this one
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
                              child: Text(
                                notification['title']!,
                                style: GoogleFonts.inter(
                                  color: _secondaryText,
                                  fontSize: 16,
                                  fontWeight: isExpanded
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                12,
                                0,
                                8,
                                0,
                              ),
                              child: Text(
                                notification['date']!,
                                style: GoogleFonts.inter(
                                  color: _secondaryText,
                                  fontSize: 14,
                                ),
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
                            notification['details']!,
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
            );
          },
        ),
      ),
    );
  }
}
