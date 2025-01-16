import 'package:flutter/material.dart';
import 'package:sona/ui/utils/date_time.dart' as dtu;
import 'package:sona/ui/widgets/menstrual_cycle/calendar_date_tools.dart';
import 'package:sona/ui/widgets/menstrual_cycle/calendar_cell.dart';
import 'package:sona/ui/widgets/menstrual_cycle/menstrual_cycle.dart';
import 'package:sona/ui/widgets/menstrual_cycle/menstrual_cycle_calendar_editable_view.dart';
import 'package:sona/ui/widgets/simple_gesture_detector.dart';

class MenstrualCycleCalendarView extends StatefulWidget {
  // THEMING
  final Color daySelectedColor;
  final Color themeColor;
  final Color backgroundColor;
  final String editPeriodText;
  final bool hideInfoView;
  final bool hideBottomBar;
  final bool hideLogPeriodButton;
  final bool isExpanded;

  // CALLBACKS AND REFRESHER
  final PeriodCalculatorController controller;
  final void Function(DateTime, CycleDayType?)? onDateSelected;
  final VoidCallback? onDataChanged;

  const MenstrualCycleCalendarView({
    super.key,
    required this.controller,
    this.daySelectedColor = Colors.grey,
    this.themeColor = Colors.black,
    this.backgroundColor = Colors.white,
    this.editPeriodText = "EDIT",
    this.hideInfoView = false,
    this.hideBottomBar = false,
    this.hideLogPeriodButton = false,
    this.isExpanded = false,
    this.onDateSelected,
    this.onDataChanged,
  });

  @override
  State<MenstrualCycleCalendarView> createState() => _MenstrualCycleCalendarViewState();
}

class _MenstrualCycleCalendarViewState extends State<MenstrualCycleCalendarView> {
  List<DateTime>? selectedMonthsDays;
  List<DateTime>? selectedWeekDays;
  DateTime selectedDateTime = DateTime.now();
  String? currentMonth;
  bool isExpanded = false;
  String displayMonth = "";
  String today = "";
  bool isExpandable = true;
  CalenderDateFormatter? _formatter;

  CalenderDateFormatter get formatter {
    return _formatter ??= CalenderDateFormatter(Localizations.localeOf(context));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _formatter = CalenderDateFormatter(Localizations.localeOf(context));
  }

  @override
  void initState() {
    super.initState();
    selectedDateTime = DateTime.now();
    selectedMonthsDays = _daysInMonth(selectedDateTime);
    selectedWeekDays = dtu.daysInRange(_firstDayOfWeek(selectedDateTime), _lastDayOfWeek(selectedDateTime)).toList();
  }

  Widget calendarGridView(PerdiodCalculatorResult result) {
    return SimpleGestureDetector(
      onSwipeUp: _onSwipeUp,
      onSwipeDown: _onSwipeDown,
      onSwipeLeft: _onSwipeLeft,
      onSwipeRight: _onSwipeRight,
      swipeConfig: const SimpleSwipeConfig(
        verticalThreshold: 10.0,
        horizontalThreshold: 40.0,
        swipeDetectionMoment: SwipeDetectionMoment.onUpdate,
      ),
      child: Column(children: [
        GridView.count(
          primary: false,
          shrinkWrap: true,
          crossAxisCount: 7,
          padding: const EdgeInsets.only(bottom: 0.0),
          children: calendarBuilder(result),
        ),
      ]),
    );
  }

  List<Widget> calendarBuilder(PerdiodCalculatorResult result) {
    List<Widget> calendarGridItems = [];
    List<DateTime>? calendarDays = selectedMonthsDays;

    for (var day in formatter.weekTitles) {
      calendarGridItems.add(
        Container(
          alignment: Alignment.center,
          child: Text(
            day,
            style: TextStyle(color: widget.themeColor, fontWeight: FontWeight.w800, fontSize: 11),
          ),
        ),
      );
    }

    bool monthStarted = false;
    bool monthEnded = false;

    var now = DateTime.now();

    for (var day in calendarDays!) {
      day = dtu.getDay(day);
      day = _normalizeDay(day);

      if (day.hour > 0) {
        day = day.toLocal();
        day = day.subtract(Duration(hours: day.hour));
      }

      if (monthStarted && day.day == 1) {
        monthEnded = true;
      }

      if (dtu.isFirstDayOfMonth(day)) {
        monthStarted = true;
      }

      CycleDayType? dayType = result.getCycleDayType(day);
      //
      bool isToday = dtu.isSameDay(now, day);
      calendarGridItems.add(CustomizedCalendarCell(
        dayType: dayType,
        day: day,
        onTapDay: () => handleSelectedDateCallback(day, dayType),
        themeColor: widget.themeColor,
        selectedColor: widget.daySelectedColor,
        todayColor: widget.themeColor,
        dayTextStyle: isToday ? const TextStyle(color: Colors.white, fontWeight: FontWeight.bold) : configureDateStyle(monthStarted, monthEnded),
        isSelected: dtu.isSameDay(selectedDateTime, day),
        isToday: isToday,
      ));
    }
    return calendarGridItems;
  }

  DateTime _normalizeDay(DateTime day) {
    if (day.hour > 0) {
      day = day.toLocal();
      day = day.subtract(Duration(hours: day.hour));
    }
    return day;
  }

  TextStyle configureDateStyle(monthStarted, monthEnded) {
    TextStyle normalTextStyle = TextStyle(color: widget.themeColor, fontWeight: FontWeight.normal);

    if (isExpanded) {
      final TextStyle body1StyleDisabled = normalTextStyle.copyWith(color: Colors.grey);
      return monthStarted && !monthEnded ? normalTextStyle : body1StyleDisabled;
    }

    return normalTextStyle;
  }

  Widget bottomView() {
    if (isExpandable) {
      return GestureDetector(
        onTap: toggleExpanded,
        child: Container(
          height: 40,
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              if (!widget.hideLogPeriodButton)
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: OutlinedButton(
                    onPressed: _onTapEditPeriod,
                    child: Text(
                      widget.editPeriodText,
                      style: TextStyle(color: widget.themeColor, fontSize: 11),
                    ),
                  ),
                ),
              IconButton(
                onPressed: toggleExpanded,
                iconSize: 25.0,
                padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                icon: Icon(isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: widget.themeColor),
              ),
            ],
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext buildContext) {
    //
    var monthFormat = formatter.formatDayMonth(selectedDateTime);
    var todayFormat = formatter.formatDay(selectedDateTime);
    //
    displayMonth = "${monthFormat[0].toUpperCase()}${monthFormat.substring(1)}";
    today = todayFormat;

    return Card(
      color: widget.backgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: resetToToday,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: widget.themeColor,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          today,
                          style: TextStyle(color: widget.themeColor, fontSize: 10.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 50),
                child: Text(
                  displayMonth,
                  style: TextStyle(color: widget.themeColor, fontSize: 15.0, fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: isExpanded ? previousMonth : previousWeek,
                    icon: Icon(
                      Icons.chevron_left,
                      color: widget.themeColor,
                    ),
                  ),
                  IconButton(
                    onPressed: isExpanded ? nextMonth : nextWeek,
                    icon: Icon(
                      Icons.chevron_right,
                      color: widget.themeColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          ValueListenableBuilder(
            valueListenable: widget.controller,
            builder: (context, value, child) {
              return _ExpansionCrossFade(
                collapsed: calendarGridView(value),
                expanded: Column(
                  children: [
                    calendarGridView(value),
                    const SizedBox(height: 15),
                    if (!widget.hideInfoView) getInformationView(widget.daySelectedColor, widget.themeColor),
                    const SizedBox(height: 10),
                  ],
                ),
                isExpanded: isExpanded,
              );
            },
          ),
          if (!widget.hideBottomBar) bottomView(),
        ],
      ),
    );
  }

  void resetToToday() {
    selectedDateTime = DateTime.now();
    var firstDayOfCurrentWeek = _firstDayOfWeek(selectedDateTime);
    var lastDayOfCurrentWeek = _lastDayOfWeek(selectedDateTime);

    setState(() {
      selectedWeekDays = dtu.daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek).toList();
      selectedMonthsDays = _daysInMonth(selectedDateTime);
      var monthFormat = formatter.formatDayMonth(selectedDateTime);

      displayMonth = "${monthFormat[0].toUpperCase()}${monthFormat.substring(1)}";
      today = formatter.formatDay(selectedDateTime);
    });
  }

  void nextMonth() {
    setState(() {
      selectedDateTime = dtu.nextMonth(selectedDateTime);
      var firstDateOfNewMonth = dtu.firstDayOfMonth(selectedDateTime);
      var lastDateOfNewMonth = dtu.lastDayOfMonth(selectedDateTime);
      updateSelectedRange(firstDateOfNewMonth, lastDateOfNewMonth);
      selectedMonthsDays = _daysInMonth(selectedDateTime);
      var monthFormat = formatter.formatMonthYear(selectedDateTime);
      displayMonth = "${monthFormat[0].toUpperCase()}${monthFormat.substring(1)}";
    });
  }

  void previousMonth() {
    setState(() {
      selectedDateTime = dtu.previousMonth(selectedDateTime);
      var firstDateOfNewMonth = dtu.firstDayOfMonth(selectedDateTime);
      var lastDateOfNewMonth = dtu.lastDayOfMonth(selectedDateTime);
      updateSelectedRange(firstDateOfNewMonth, lastDateOfNewMonth);
      selectedMonthsDays = _daysInMonth(selectedDateTime);
      var monthFormat = formatter.formatMonthYear(selectedDateTime);

      displayMonth = "${monthFormat[0].toUpperCase()}${monthFormat.substring(1)}";
    });
    // _launchDateSelectionCallback(selectedDateTime);
  }

  void nextWeek() {
    setState(() {
      selectedDateTime = dtu.nextWeek(selectedDateTime);
      var firstDayOfCurrentWeek = _firstDayOfWeek(selectedDateTime);
      var lastDayOfCurrentWeek = _lastDayOfWeek(selectedDateTime);
      updateSelectedRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek);
      selectedWeekDays = dtu.daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek).toList();
      var monthFormat = formatter.formatMonthYear(selectedDateTime);

      displayMonth = "${monthFormat[0].toUpperCase()}${monthFormat.substring(1)}";
    });
  }

  void previousWeek() {
    setState(() {
      selectedDateTime = dtu.previousWeek(selectedDateTime);
      var firstDayOfCurrentWeek = _firstDayOfWeek(selectedDateTime);
      var lastDayOfCurrentWeek = _lastDayOfWeek(selectedDateTime);
      updateSelectedRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek);
      selectedWeekDays = dtu.daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek).toList();
      var monthFormat = formatter.formatMonthYear(selectedDateTime);

      displayMonth = "${monthFormat[0].toUpperCase()}${monthFormat.substring(1)}";
    });
  }

  void updateSelectedRange(DateTime start, DateTime end) {}

  void _onTapEditPeriod() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MenstrualCycleCalendarEditableView(
          controller: widget.controller,
          themeColor: widget.themeColor,
          hideInfoView: widget.hideInfoView,
          isShowCloseIcon: true,
          onDataChanged: widget.onDataChanged,
          formatter: formatter,
          todayColor: widget.themeColor,
          daySelectedColor: widget.daySelectedColor,
        ),
      ),
    );
  }

  void _onSwipeUp() {
    if (isExpanded) toggleExpanded();
  }

  void _onSwipeDown() {
    if (!isExpanded) toggleExpanded();
  }

  void _onSwipeRight() {
    if (isExpanded) {
      previousMonth();
    } else {
      previousWeek();
    }
  }

  void _onSwipeLeft() {
    if (isExpanded) {
      nextMonth();
    } else {
      nextWeek();
    }
  }

  void toggleExpanded() {
    if (isExpandable) {
      setState(() => isExpanded = !isExpanded);
    }
  }

  void handleSelectedDateCallback(DateTime day, CycleDayType? dayType) {
    var firstDayOfCurrentWeek = _firstDayOfWeek(day);
    var lastDayOfCurrentWeek = _lastDayOfWeek(day);
    if (selectedDateTime.month > day.month) {
      previousMonth();
    }
    if (selectedDateTime.month < day.month) {
      nextMonth();
    }
    setState(() {
      selectedDateTime = day;
      selectedWeekDays = dtu.daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek).toList();
      selectedMonthsDays = _daysInMonth(day);
    });
    _launchDateSelectionCallback(day, dayType);
  }

  void _launchDateSelectionCallback(DateTime day, [CycleDayType? dayType]) {
    if (widget.onDateSelected != null) {
      widget.onDateSelected!(day, dayType);
    }
  }

  DateTime _firstDayOfWeek(DateTime date) {
    var day = DateTime.utc(selectedDateTime.year, selectedDateTime.month, selectedDateTime.day, 12);
    return day.subtract(Duration(days: day.weekday));
  }

  DateTime _lastDayOfWeek(DateTime date) {
    return _firstDayOfWeek(date).add(const Duration(days: 7));
  }

  List<DateTime> _daysInMonth(DateTime month) {
    var first = dtu.firstDayOfMonth(month);
    var daysBefore = first.weekday;
    var firstToDisplay = first.subtract(Duration(days: daysBefore));
    var last = dtu.lastDayOfMonth(month);

    var daysAfter = 7 - last.weekday;

    // If the last day is sunday (7) the entire week must be rendered
    if (daysAfter == 0) {
      daysAfter = 7;
    }

    var lastToDisplay = last.add(Duration(days: daysAfter));
    return dtu.daysInRange(firstToDisplay, lastToDisplay).toList();
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

class _ExpansionCrossFade extends StatelessWidget {
  final Widget? collapsed;
  final Widget? expanded;
  final bool? isExpanded;

  const _ExpansionCrossFade({
    this.collapsed,
    this.expanded,
    this.isExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: collapsed!,
      secondChild: expanded!,
      reverseDuration: const Duration(milliseconds: 1000),
      firstCurve: const Interval(0.0, 1.0, curve: Curves.fastOutSlowIn),
      secondCurve: const Interval(0.0, 1.0, curve: Curves.fastOutSlowIn),
      sizeCurve: Curves.decelerate,
      crossFadeState: isExpanded! ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 1000),
    );
  }
}
