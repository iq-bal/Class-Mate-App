import 'package:flutter/material.dart';
import 'package:classmate/models/notification/notification_model.dart';

class NotificationFilters extends StatefulWidget {
  final NotificationType? selectedType;
  final bool? isRead;
  final NotificationPriority? selectedPriority;
  final Function(NotificationType?) onTypeChanged;
  final Function(bool?) onReadStatusChanged;
  final Function(NotificationPriority?) onPriorityChanged;
  final VoidCallback onClearFilters;

  const NotificationFilters({
    super.key,
    this.selectedType,
    this.isRead,
    this.selectedPriority,
    required this.onTypeChanged,
    required this.onReadStatusChanged,
    required this.onPriorityChanged,
    required this.onClearFilters,
  });

  @override
  State<NotificationFilters> createState() => _NotificationFiltersState();
}

class _NotificationFiltersState extends State<NotificationFilters> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters = widget.selectedType != null ||
        widget.isRead != null ||
        widget.selectedPriority != null;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Filter Header
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  if (hasActiveFilters) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Active',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[800],
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (hasActiveFilters)
                    TextButton(
                      onPressed: widget.onClearFilters,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Clear',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
          
          // Filter Content
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Read Status Filter
                  _buildFilterSection(
                    title: 'Read Status',
                    child: Wrap(
                      spacing: 8,
                      children: [
                        _buildChip(
                          label: 'All',
                          isSelected: widget.isRead == null,
                          onTap: () => widget.onReadStatusChanged(null),
                        ),
                        _buildChip(
                          label: 'Unread',
                          isSelected: widget.isRead == false,
                          onTap: () => widget.onReadStatusChanged(false),
                        ),
                        _buildChip(
                          label: 'Read',
                          isSelected: widget.isRead == true,
                          onTap: () => widget.onReadStatusChanged(true),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Type Filter
                  _buildFilterSection(
                    title: 'Type',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildChip(
                          label: 'All',
                          isSelected: widget.selectedType == null,
                          onTap: () => widget.onTypeChanged(null),
                        ),
                        ...NotificationType.values.map(
                          (type) => _buildChip(
                            label: _getTypeDisplayName(type),
                            isSelected: widget.selectedType == type,
                            onTap: () => widget.onTypeChanged(type),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Priority Filter
                  _buildFilterSection(
                    title: 'Priority',
                    child: Wrap(
                      spacing: 8,
                      children: [
                        _buildChip(
                          label: 'All',
                          isSelected: widget.selectedPriority == null,
                          onTap: () => widget.onPriorityChanged(null),
                        ),
                        ...NotificationPriority.values.map(
                          (priority) => _buildChip(
                            label: _getPriorityDisplayName(priority),
                            isSelected: widget.selectedPriority == priority,
                            onTap: () => widget.onPriorityChanged(priority),
                            color: _getPriorityColor(priority),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? Colors.blue[600])
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? (color ?? Colors.blue[600]!)
                : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? Colors.white
                : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  String _getTypeDisplayName(NotificationType type) {
    switch (type) {
      case NotificationType.taskAssigned:
        return 'Task Assigned';
      case NotificationType.taskUpdated:
        return 'Task Updated';
      case NotificationType.taskDueReminder:
        return 'Due Reminder';
      case NotificationType.courseReschedule:
        return 'Reschedule';
      case NotificationType.assignmentGraded:
        return 'Graded';
      case NotificationType.classCancelled:
        return 'Cancelled';
      case NotificationType.announcement:
        return 'Announcement';
      case NotificationType.systemUpdate:
        return 'System';
    }
  }

  String _getPriorityDisplayName(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return 'Low';
      case NotificationPriority.normal:
        return 'Normal';
      case NotificationPriority.high:
        return 'High';
      case NotificationPriority.urgent:
        return 'Urgent';
    }
  }

  Color _getPriorityColor(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Colors.green[600]!;
      case NotificationPriority.normal:
        return Colors.blue[600]!;
      case NotificationPriority.high:
        return Colors.orange[600]!;
      case NotificationPriority.urgent:
        return Colors.red[600]!;
    }
  }
}