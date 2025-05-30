import 'package:flutter/material.dart';
import 'package:sona/ui/widgets/menstrual_cycle/menstrual_cycle.dart';

class CustomizedCalendarCell extends StatefulWidget {
  final VoidCallback? onTapDay;
  final DateTime day;
  final CycleDayType? dayType;
  final bool isSelected;
  final bool isToday;
  final TextStyle? dayTextStyle;
  final Color selectedColor;
  final Color todayColor;
  final Color themeColor;

  const CustomizedCalendarCell({
    super.key,
    required this.themeColor,
    this.onTapDay,
    this.dayType,
    required this.day,
    this.dayTextStyle,
    required this.selectedColor,
    required this.todayColor,
    this.isSelected = false,
    this.isToday = false,
  });

  @override
  State<CustomizedCalendarCell> createState() => _CustomizedCalendarCellState();
}

class _CustomizedCalendarCellState extends State<CustomizedCalendarCell> {
  bool isChanged = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTapDay,
      child: Column(
        children: [
          Container(
            height: 25,
            width: 25,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _resolverColor(),
            ),
            child: Center(
              child: Text(
                '${widget.day.day}',
                style: widget.dayTextStyle,
              ),
            ),
          ),
          if (widget.dayType != null)
            SizedBox(
              height: 10,
              child: _buildDayTypeWidget(widget.dayType!),
            ),
        ],
      ),
    );
  }

  Color _resolverColor() {
    if (widget.isSelected) {
      return widget.selectedColor;
    }
    if (widget.isToday) {
      return widget.todayColor;
    }
    return Colors.transparent;
  }

  Widget _buildDayTypeWidget(CycleDayType dayType) {
    final config = defaultDayTypeWidgetConfigurer(dayType);
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Icon(
        config.icon,
        size: 12,
        color: config.iconColor,
      ),
    );
  }
}

class EditCalendarCell extends StatefulWidget {
  final DateTime day;
  final TextStyle? dateStyles;
  final bool initialChecked;
  final Function(bool) onChecked;

  const EditCalendarCell({
    super.key,
    required this.day,
    this.dateStyles,
    this.initialChecked = false,
    required this.onChecked,
  });

  @override
  State<EditCalendarCell> createState() => _EditCalendarCellState();
}

class _EditCalendarCellState extends State<EditCalendarCell> {
  var isChecked = false;

  @override
  void initState() {
    super.initState();
    isChecked = widget.initialChecked;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(
            '${widget.day.day}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
        ),
        Expanded(
          child: Checkbox(
            value: isChecked,
            activeColor: isChecked ? defaultMenstruationColor : Colors.black,
            onChanged: (value) {
              if (value == null) return;
              widget.onChecked.call(value);
              setState(() => isChecked = value);
            },
          ),
        ),
      ],
    );
  }
}
