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
  int _displayLimit = 20;
  static const int _loadMoreIncrement = 20;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }


  Color get _primaryBackground => Theme.of(context).scaffoldBackgroundColor;
  Color get _cardColor =>
      Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor;
  Color get _onSurface => Theme.of(context).colorScheme.onSurface;
  Color get _subText =>
      Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  Color get _shadowColor =>
      _isDark ? Colors.black.withOpacity(0.2) : const Color(0xFFE0E3E7);

  static const Color _errorColor = Color(0xFFF44336);
  static const Color _successColor = Color(0xFF4CAF50);
  static const Color _warningColor = Color(0xFFFF9800);


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

  String _formatDate(String isoDate) {
    try {
      return DateFormat('MMM d, yyyy').format(DateTime.parse(isoDate));
    } catch (_) {
      return isoDate;
    }
  }

  String _formatTime(String isoDate) {
    try {
      return DateFormat('h:mm a').format(DateTime.parse(isoDate));
    } catch (_) {
      return '';
    }
  }

  Color _accentColor(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return _successColor;
      case NotificationType.error:
        return _errorColor;
      case NotificationType.defaultType:
        return _isDark ? Colors.grey.shade400 : const Color(0xFF616161);
    }
  }

  Color _expandedBg(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return _isDark
            ? const Color(0xFF1B5E20).withOpacity(0.3)
            : const Color(0xFFE8F5E9);
      case NotificationType.error:
        return _isDark
            ? const Color(0xFFC62828).withOpacity(0.3)
            : const Color(0xFFFFEBEE);
      case NotificationType.defaultType:
        return _isDark ? Colors.grey.shade800 : const Color(0xFFF5F5F5);
    }
  }

  IconData _icon(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Icons.check_circle_outline;
      case NotificationType.error:
        return Icons.error_outline;
      case NotificationType.defaultType:
        return Icons.info_outline;
    }
  }

  List<Map<String, dynamic>> get _displayedNotifications =>
      notifications.take(_displayLimit).toList();

  bool get _hasMore => notifications.length > _displayLimit;

  void _loadMore() {
    setState(() {
      _displayLimit = (_displayLimit + _loadMoreIncrement).clamp(
        0,
        notifications.length,
      );
    });
  }

  void _handleReportError(String errorTitle) {
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
                color: _isDark ? Colors.white : Theme.of(context).primaryColor,
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
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: _primaryBackground,
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : notifications.isEmpty
            ? Center(
                child: Text(
                  'No notifications',
                  style: GoogleFonts.inter(
                    color: _onSurface.withOpacity(0.6),
                    fontSize: 16,
                  ),
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: _displayedNotifications.length,
                      itemBuilder: (context, index) => _buildItem(index),
                    ),
                  ),
                  if (_hasMore) _buildLoadMoreButton(),
                ],
              ),
      ),
    );
  }

  Widget _buildItem(int index) {
    final notification = _displayedNotifications[index];
    final isExpanded = _expandedIndex == index;
    final type = _parseType(notification['type'] ?? 'default');
    final isResolved = notification['resolved'] ?? false;
    final isUnresolvedError = type == NotificationType.error && !isResolved;
    final accent = _accentColor(type);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isExpanded ? _expandedBg(type) : _primaryBackground,
        boxShadow: [
          BoxShadow(
            blurRadius: 0,
            color: _shadowColor,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Opacity(
        opacity: isResolved ? 0.6 : 1.0,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () =>
                    setState(() => _expandedIndex = isExpanded ? null : index),
                child: Row(
                  children: [
                    // Accent bar
                    Container(
                      width: 4,
                      height: 50,
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Type icon
                    Icon(_icon(type), color: accent, size: 24),
                    const SizedBox(width: 8),
                    // Title + subheader
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notification['header'] ?? '',
                                  style: GoogleFonts.inter(
                                    color: _onSurface,
                                    fontSize: 16,
                                    fontWeight: isExpanded
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (isResolved) _resolvedBadge(),
                            ],
                          ),
                          if ((notification['subheader'] ?? '')
                              .toString()
                              .isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                notification['subheader']!,
                                style: GoogleFonts.inter(
                                  color: _onSurface.withOpacity(0.6),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Date/time
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        12,
                        0,
                        8,
                        0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatDate(notification['date'] ?? ''),
                            style: GoogleFonts.inter(
                              color: _onSurface,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _formatTime(notification['date'] ?? ''),
                            style: GoogleFonts.inter(
                              color: _onSurface.withOpacity(0.6),
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
                      color: _onSurface,
                      size: 24,
                    ),
                  ],
                ),
              ),

              // ── Expandable content ───────────────────────────────────────
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 200),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(44, 12, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _cardColor,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: accent.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          notification['description'] ??
                              'No additional details available.',
                          style: GoogleFonts.inter(
                            color: _onSurface,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),

                      // Tip + Report button — only for unresolved errors
                      if (isUnresolvedError) ...[
                        const SizedBox(height: 12),
                        // Tip box
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _isDark
                                ? _warningColor.withOpacity(0.1)
                                : const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _warningColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: _warningColor,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tip:',
                                      style: GoogleFonts.inter(
                                        color: _warningColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Try restarting the device twice before filing a report. '
                                      'This often resolves temporary sensor and connection issues.',
                                      style: GoogleFonts.inter(
                                        color: _onSurface,
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
                            onPressed: () => _handleReportError(
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
                              backgroundColor: _errorColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resolvedBadge() {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _successColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Resolved',
        style: GoogleFonts.inter(
          color: _successColor,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _primaryBackground,
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            color: _shadowColor,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _loadMore,
        icon: const Icon(Icons.expand_more, size: 20),
        label: Text(
          'Load More (${notifications.length - _displayLimit} remaining)',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
      ),
    );
  }

  void fetchNotifications() async {
    setState(() => isLoading = true);
    try {
      final response = await MachineService.fetchNotifications(
        machineId: widget.machineId,
      );
      if (response['ok'] == true && response['data'] != null) {
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
      setState(() => isLoading = false);
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
