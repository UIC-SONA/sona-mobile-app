import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:menstrual_cycle_widget/menstrual_cycle_widget.dart';

class CustomizedCalendarCell extends StatefulWidget {
  final Function(DayType?)? onTapDay;
  final DateTime day;
  final bool isSelected;
  final bool isToday;
  final TextStyle? dayTextStyle;
  final Color selectedColor;
  final Color todayColor;

  // PERIOD CONFIGURATION
  final String previousPeriodDate;
  final int cycleLength;
  final int periodDuration;

  // PERIOD LOGS
  final List<String> pastAllPeriodsDays;
  final List<String> futurePeriodDays;
  final List<String> futureOvulationDays;
  final Color themeColor;

  const CustomizedCalendarCell({
    super.key,
    required this.themeColor,
    this.onTapDay,
    required this.day,
    this.dayTextStyle,
    required this.selectedColor,
    required this.todayColor,
    this.pastAllPeriodsDays = const <String>[],
    this.previousPeriodDate = "",
    this.futurePeriodDays = const <String>[],
    this.periodDuration = defaultPeriodDuration,
    this.cycleLength = defaultCycleLength,
    this.futureOvulationDays = const <String>[],
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

  DayType? getDayType() {
    if (checkIsPastPeriodDay()) {
      return DayType.period;
    }
    if (checkIsFuturePeriodDay()) {
      return DayType.periodPrediction;
    }
    if (checkIsFutureOvulationDay() || checkIsOvulationDay()) {
      return DayType.ovulationPrediction;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    DayType? dayType = getDayType();
    //CalendarCell

    return InkWell(
      onTap: widget.onTapDay != null
          ? () {
              widget.onTapDay!(dayType);
            }
          : null,
      child: Column(
        children: [
          Container(
            height: 30,
            width: 30,
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
          if (dayType != null)
            SizedBox(
              height: 15,
              child: _buildDayTypeWidget(dayType),
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

  Widget _buildDayTypeWidget(DayType dayType) {
    final config = defaultDayTypeWidgetConfigurer(dayType);
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Icon(
        config.icon,
        size: 16,
        color: config.iconColor,
      ),
    );
  }

  bool checkIsFuturePeriodDay() {
    bool isMatchDate = false;
    if (widget.previousPeriodDate.isNotEmpty) {
      String currentDate = defaultDateFormat.format(widget.day);
      int index = widget.futurePeriodDays.indexOf(currentDate);
      if (index != -1) {
        isMatchDate = true;
      }
    }
    return isMatchDate;
  }



  bool checkIsPastPeriodDay() {
    bool isPeriodDay = false;
    if (widget.previousPeriodDate.isNotEmpty) {
      String currentDate = defaultDateFormat.format(widget.day);
      List<String> periodDays = widget.pastAllPeriodsDays;
      for (int index = 0; index < periodDays.length; index++) {
        if (periodDays[index] == currentDate) {
          isPeriodDay = true;
          break;
        }
      }
    }
    return isPeriodDay;
  }

  bool checkIsPeriodDay() {
    bool isPeriodDay = false;
    if (widget.previousPeriodDate.isNotEmpty) {
      final lastPeriodDate = DateFormat("yyyy-MM-dd").parse(widget.previousPeriodDate).add(const Duration(days: -1));
      final endPeriodDate = DateFormat("yyyy-MM-dd").parse(widget.previousPeriodDate).add(Duration(days: widget.periodDuration));
      final inDays = lastPeriodDate.difference(DateTime.now()).inDays;
      final startPeriodDate = DateTime.parse(widget.previousPeriodDate);
      final isCurrentDateBtnPeriodsDays = (startPeriodDate.isBefore(widget.day) && endPeriodDate.isAfter(widget.day));

      var isValidPeriodDayCount = false; // Check is valid day count of period date
      if (inDays > 0 && inDays <= widget.periodDuration) {
        isValidPeriodDayCount = true;
      } else if (inDays < 0 && inDays >= -widget.periodDuration) {
        isValidPeriodDayCount = true;
      }
      if (!isCurrentDateBtnPeriodsDays) {
        isPeriodDay = false;
      } else if (!isValidPeriodDayCount) {
        isPeriodDay = false;
      } else {
        final isBefore = widget.day.isBefore(endPeriodDate);
        final isAfter = widget.day.isAfter(lastPeriodDate);

        if (isBefore && isAfter) {
          isPeriodDay = true;
        }
      }
    }
    return isPeriodDay;
  }

  bool checkIsFutureOvulationDay() {
    bool isMatchDate = false;
    if (widget.futureOvulationDays.isNotEmpty) {
      String currentDate = defaultDateFormat.format(widget.day);
      int index = widget.futureOvulationDays.indexOf(currentDate);
      if (index != -1) {
        isMatchDate = true;
      }
    }
    return isMatchDate;
  }

  bool checkIsOvulationDay() {
    bool isOvlDay = false;

    if (widget.previousPeriodDate.isNotEmpty) {
      DateTime ovulationDay = DateFormat("yyyy-MM-dd").parse(widget.previousPeriodDate).add(Duration(days: widget.cycleLength)).subtract(const Duration(days: 14));
      if (widget.day.compareTo(ovulationDay) == 0) {
        isOvlDay = true;
      }
    }
    return isOvlDay;
  }
}

Widget getInformationView(Color daySelectedColor, Color themeColor) {
  const double fontSize = 13;
  const double iconSize = 13;

  Widget buildRow(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: iconSize,
          color: color,
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(fontSize: fontSize),
        ),
      ],
    );
  }

  return Padding(
    padding: const EdgeInsets.only(left: 5, right: 5),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildRow(Icons.water_drop_sharp, defaultMenstruationColor, "Período"),
        const SizedBox(height: 5),
        buildRow(Icons.favorite_border, defaultOvulationColor, "Predicción de ovulación"),
        const SizedBox(height: 5),
        buildRow(Icons.water_drop_outlined, defaultMenstruationColor, "Predicción de periodo"),
        const SizedBox(height: 5),
        buildRow(Icons.circle, daySelectedColor, "Día seleccionado"),
        const SizedBox(height: 5),
        buildRow(Icons.circle, themeColor, "Hoy"),
      ],
    ),
  );
}

enum DayType {
  period,
  periodPrediction,
  ovulationPrediction,
}

class DayTypeWidgetConfiguration {
  final Color iconColor;
  final IconData icon;
  final Color onIconColor;
  final String text;

  const DayTypeWidgetConfiguration({
    required this.iconColor,
    required this.icon,
    required this.onIconColor,
    required this.text,
  });
}

typedef DayTypeWidgetConfigurer = DayTypeWidgetConfiguration Function(DayType dayType);

DayTypeWidgetConfiguration defaultDayTypeWidgetConfigurer(DayType dayType) {
  switch (dayType) {
    case DayType.period:
      return const DayTypeWidgetConfiguration(
        iconColor: defaultMenstruationColor,
        icon: Icons.water_drop_sharp,
        onIconColor: defaultMenstruationColor,
        text: "Período",
      );
    case DayType.periodPrediction:
      return const DayTypeWidgetConfiguration(
        iconColor: defaultMenstruationColor,
        icon: Icons.water_drop_outlined,
        onIconColor: defaultMenstruationColor,
        text: "Predicción de periodo",
      );
    case DayType.ovulationPrediction:
      return const DayTypeWidgetConfiguration(
        iconColor: defaultOvulationColor,
        icon: Icons.favorite_border,
        onIconColor: defaultOvulationColor,
        text: "Predicción de ovulación",
      );
  }
}

class EditCalendarCell extends StatefulWidget {
  final DateTime day;
  final TextStyle? dateStyles;
  final String? previousPeriodDate;
  final List<String>? pastAllPeriodsDays;
  final int periodDuration;
  final Function(bool) multipleDateSelectionCallBack;

  const EditCalendarCell({
    super.key,
    required this.day,
    this.dateStyles,
    this.pastAllPeriodsDays = const <String>[],
    this.periodDuration = defaultPeriodDuration,
    required this.multipleDateSelectionCallBack,
    this.previousPeriodDate = "",
  });

  @override
  State<EditCalendarCell> createState() => _EditCalendarCellState();
}

class _EditCalendarCellState extends State<EditCalendarCell> {
  var isChecked = false;
  var isChanged = false;

  Widget editModeView({
    bool isPeriodDay = false,
    bool isPastPeriodDay = false,
  }) {
    if ((isPeriodDay || isPastPeriodDay) && !isChanged) {
      isChecked = true;
      widget.multipleDateSelectionCallBack.call(true);
    }
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
                widget.multipleDateSelectionCallBack.call(value);
                isChanged = true;
                setState(() => isChecked = value);
              }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPeriodDay = checkIsPeriodDay();
    final isPastPeriodDay = checkIsPastPeriodDay();
    return editModeView(
      isPeriodDay: isPeriodDay,
      isPastPeriodDay: isPastPeriodDay,
    );
  }

  bool checkIsPastPeriodDay() {
    bool isPeriodDay = false;
    if (widget.previousPeriodDate!.isNotEmpty) {
      String currentDate = defaultDateFormat.format(widget.day);
      List<String> periodDays = widget.pastAllPeriodsDays!;
      for (int index = 0; index < periodDays.length; index++) {
        if (periodDays[index] == currentDate) {
          isPeriodDay = true;
          break;
        }
      }
    }
    return isPeriodDay;
  }

  bool checkIsPeriodDay() {
    bool isPeriodDay = false;
    if (widget.previousPeriodDate!.isNotEmpty) {
      final lastPeriodDate = DateFormat("yyyy-MM-dd").parse(widget.previousPeriodDate!).add(const Duration(days: -1));
      final endPeriodDate = DateFormat("yyyy-MM-dd").parse(widget.previousPeriodDate!).add(Duration(days: widget.periodDuration));
      final inDays = lastPeriodDate.difference(DateTime.now()).inDays;
      final startPeriodDate = DateTime.parse(widget.previousPeriodDate!);

      final isCurrentDateBtnPeriodsDays = (startPeriodDate.isBefore(widget.day) && endPeriodDate.isAfter(widget.day));

      var isValidPeriodDayCount = false; // Check is valid day count of period date
      if (inDays > 0 && inDays <= widget.periodDuration) {
        isValidPeriodDayCount = true;
      } else if (inDays < 0 && inDays >= -widget.periodDuration) {
        isValidPeriodDayCount = true;
      }
      if (!isCurrentDateBtnPeriodsDays) {
        isPeriodDay = false;
      } else if (!isValidPeriodDayCount) {
        isPeriodDay = false;
      } else {
        if (widget.day.isBefore(DateTime.now())) {
          isPeriodDay = false;
        }
      }
    }
    return isPeriodDay;
  }
}
