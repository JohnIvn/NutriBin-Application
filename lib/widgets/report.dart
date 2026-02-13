import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MachineErrorReportCard extends StatefulWidget {
  final List<Map<String, dynamic>> notifications;
  
  const MachineErrorReportCard({
    super.key,
    required this.notifications,
  });

  @override
  State<MachineErrorReportCard> createState() => _MachineErrorReportCardState();
}

class _MachineErrorReportCardState extends State<MachineErrorReportCard> {
  // Track which error is expanded (only one at a time)
  int? _expandedIndex;

  // Format date from ISO string
  String _formatDate(String isoDate) {
    try {
      final DateTime dateTime = DateTime.parse(isoDate);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        final formatter = DateFormat('MMM d, yyyy');
        return formatter.format(dateTime);
      }
    } catch (e) {
      return isoDate;
    }
  }

  // Get organized notifications: unresolved errors first, then resolved
  List<Map<String, dynamic>> get _organizedNotifications {
    final unresolved = widget.notifications.where((n) {
      final resolved = n['resolved'] ?? false;
      return !resolved;
    }).toList();

    final resolved = widget.notifications.where((n) {
      final isResolved = n['resolved'] ?? false;
      return isResolved;
    }).toList();

    return [...unresolved, ...resolved];
  }

  void _handleReportError(String errorTitle) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Report Error',
          style: GoogleFonts.interTight(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Error report for "$errorTitle" has been submitted to the maintenance team.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.inter(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If no notifications, return empty container
    if (widget.notifications.isEmpty) {
      return const SizedBox.shrink();
    }

    final organizedNotifications = _organizedNotifications;

    // --- DYNAMIC COLORS ---
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final subTextColor =
        Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;
    final dividerColor = isDarkMode
        ? Colors.white.withOpacity(0.1)
        : const Color(0xFFE0E3E7);
    final errorColor = const Color(0xFFF44336);
    final successColor = const Color(0xFF4CAF50);
    final warningColor = const Color(0xFFFF9800);
    final shadowColor = isDarkMode
        ? Colors.black.withOpacity(0.3)
        : const Color(0x33000000);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: cardColor,
          boxShadow: [
            BoxShadow(
              blurRadius: 3,
              color: shadowColor,
              offset: const Offset(0, 1),
            ),
          ],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.notifications_active_outlined,
                            color: errorColor,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Machine Notifications',
                            style: GoogleFonts.interTight(
                              color: textColor,
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Recent system alerts and status updates',
                        style: GoogleFonts.inter(
                          color: subTextColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: organizedNotifications.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 1, thickness: 1, color: dividerColor),
                itemBuilder: (context, index) {
                  final notification = organizedNotifications[index];
                  final isExpanded = _expandedIndex == index;
                  final isResolved = notification['resolved'] ?? false;
                  final type = notification['type']?.toString().toLowerCase() ?? 'default';
                  final isError = type == 'error';

                  // Determine color based on type
                  Color accentColor;
                  if (isError) {
                    accentColor = errorColor;
                  } else if (type == 'success') {
                    accentColor = successColor;
                  } else {
                    accentColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
                  }

                  Color expandedBgColor;
                  if (isError) {
                    expandedBgColor = isDarkMode
                        ? errorColor.withOpacity(0.1)
                        : const Color(0xFFFFEBEE);
                  } else if (type == 'success') {
                    expandedBgColor = isDarkMode
                        ? successColor.withOpacity(0.1)
                        : const Color(0xFFE8F5E9);
                  } else {
                    expandedBgColor = isDarkMode
                        ? Colors.grey.shade800
                        : const Color(0xFFF5F5F5);
                  }

                  final tipBgColor = isDarkMode
                      ? warningColor.withOpacity(0.1)
                      : const Color(0xFFFFF3E0);

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isExpanded ? expandedBgColor : cardColor,
                    ),
                    child: Opacity(
                      opacity: isResolved ? 0.6 : 1.0,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _expandedIndex = isExpanded ? null : index;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 24,
                                alignment: Alignment.topCenter,
                                padding: const EdgeInsets.only(top: 12),
                                child: Container(
                                  width: 4,
                                  height: isExpanded ? (isError && !isResolved ? 230 : 130) : 76,
                                  decoration: BoxDecoration(
                                    color: accentColor,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    8,
                                    12,
                                    16,
                                    12,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    notification['header'] ?? 'Notification',
                                                    style: GoogleFonts.inter(
                                                      color: textColor,
                                                      fontSize: 14,
                                                      fontWeight: isExpanded
                                                          ? FontWeight.w600
                                                          : FontWeight.normal,
                                                    ),
                                                  ),
                                                ),
                                                if (isResolved)
                                                  Container(
                                                    margin: const EdgeInsets.only(left: 8),
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: successColor.withOpacity(0.2),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Text(
                                                      'Resolved',
                                                      style: GoogleFonts.inter(
                                                        color: successColor,
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            isExpanded
                                                ? Icons.keyboard_arrow_up
                                                : Icons.keyboard_arrow_down,
                                            color: subTextColor,
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                      if (notification['subheader'] != null &&
                                          notification['subheader'].toString().isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(
                                            notification['subheader']!,
                                            style: GoogleFonts.inter(
                                              color: subTextColor,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.access_time,
                                              size: 14,
                                              color: subTextColor,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              _formatDate(notification['date'] ?? ''),
                                              style: GoogleFonts.inter(
                                                color: subTextColor,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      AnimatedCrossFade(
                                        firstChild: const SizedBox.shrink(),
                                        secondChild: Padding(
                                          padding: const EdgeInsets.only(top: 12),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: cardColor,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  border: Border.all(
                                                    color: accentColor.withOpacity(0.3),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Text(
                                                  notification['description'] ??
                                                      'No additional details available.',
                                                  style: GoogleFonts.inter(
                                                    color: textColor,
                                                    fontSize: 13,
                                                    height: 1.5,
                                                  ),
                                                ),
                                              ),
                                              // Only show tip and report button for unresolved errors
                                              if (isError && !isResolved) ...[
                                                const SizedBox(height: 12),
                                                // Tip container
                                                Container(
                                                  padding: const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: tipBgColor,
                                                    borderRadius:
                                                        BorderRadius.circular(6),
                                                    border: Border.all(
                                                      color: warningColor
                                                          .withOpacity(0.3),
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      Icon(
                                                        Icons.lightbulb_outline,
                                                        color: warningColor,
                                                        size: 18,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              'Tip:',
                                                              style:
                                                                  GoogleFonts.inter(
                                                                    color:
                                                                        warningColor,
                                                                    fontSize: 12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                            ),
                                                            const SizedBox(
                                                              height: 4,
                                                            ),
                                                            Text(
                                                              'Try restarting the device twice before filing a report. This often resolves temporary sensor and connection issues.',
                                                              style:
                                                                  GoogleFonts.inter(
                                                                    color:
                                                                        textColor,
                                                                    fontSize: 12,
                                                                    height: 1.4,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                // Report button
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: ElevatedButton.icon(
                                                    onPressed: () =>
                                                        _handleReportError(
                                                          notification['header'] ?? 'Error',
                                                        ),
                                                    icon: const Icon(
                                                      Icons.report_problem_outlined,
                                                      size: 18,
                                                    ),
                                                    label: Text(
                                                      'Report This Error',
                                                      style: GoogleFonts.inter(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: errorColor,
                                                      foregroundColor: Colors.white,
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 12,
                                                          ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      elevation: 0,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        crossFadeState: isExpanded
                                            ? CrossFadeState.showSecond
                                            : CrossFadeState.showFirst,
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
          ],
        ),
      ),
    );
  }
}