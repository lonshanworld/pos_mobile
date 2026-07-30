import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportDateRangeDialog extends StatefulWidget {
  final DateTimeRange initialRange;

  const ReportDateRangeDialog({super.key, required this.initialRange});

  @override
  State<ReportDateRangeDialog> createState() => _ReportDateRangeDialogState();
}

class _ReportDateRangeDialogState extends State<ReportDateRangeDialog> {
  late DateTime _startDate;
  late DateTime _endDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  final DateFormat _dateFormat = DateFormat('dd-MMM-yyyy');

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialRange.start;
    _endDate = widget.initialRange.end;
    _startTime = TimeOfDay.fromDateTime(widget.initialRange.start);
    _endTime = TimeOfDay.fromDateTime(widget.initialRange.end);
  }

  Future<void> _pickDate({required bool isStart}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    setState(() {
      if (isStart) {
        _startDate = date;
      } else {
        _endDate = date;
      }
    });
  }

  Future<void> _pickTime({required bool isStart}) async {
    final time = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (time == null || !mounted) return;
    setState(() {
      if (isStart) {
        _startTime = time;
      } else {
        _endTime = time;
      }
    });
  }

  DateTime _combine(DateTime date, TimeOfDay time) =>
      DateTime(date.year, date.month, date.day, time.hour, time.minute);

  @override
  Widget build(BuildContext context) {
    final start = _combine(_startDate, _startTime);
    final end = _combine(_endDate, _endTime);
    final timeFormat = DateFormat('HH:mm');

    return AlertDialog(
      title: const Text('Export date and time range'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RangeRow(
            label: 'From',
            dateText: _dateFormat.format(_startDate),
            timeText: timeFormat.format(start),
            onDateTap: () => _pickDate(isStart: true),
            onTimeTap: () => _pickTime(isStart: true),
          ),
          const SizedBox(height: 12),
          _RangeRow(
            label: 'To',
            dateText: _dateFormat.format(_endDate),
            timeText: timeFormat.format(end),
            onDateTap: () => _pickDate(isStart: false),
            onTimeTap: () => _pickTime(isStart: false),
          ),
          if (!end.isAfter(start))
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'The end must be after the start.',
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: end.isAfter(start)
              ? () => Navigator.of(
                  context,
                ).pop(DateTimeRange(start: start, end: end))
              : null,
          child: const Text('Export'),
        ),
      ],
    );
  }
}

class _RangeRow extends StatelessWidget {
  final String label;
  final String dateText;
  final String timeText;
  final VoidCallback onDateTap;
  final VoidCallback onTimeTap;

  const _RangeRow({
    required this.label,
    required this.dateText,
    required this.timeText,
    required this.onDateTap,
    required this.onTimeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 42, child: Text(label)),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onDateTap,
            icon: const Icon(Icons.calendar_today_outlined, size: 16),
            label: Text(dateText),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton(onPressed: onTimeTap, child: Text(timeText)),
      ],
    );
  }
}
