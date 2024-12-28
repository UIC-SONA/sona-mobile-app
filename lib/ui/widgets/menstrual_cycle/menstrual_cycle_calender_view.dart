import 'package:flutter/material.dart';
import 'package:menstrual_cycle_widget/menstrual_cycle_widget.dart';
import 'package:menstrual_cycle_widget/ui/calender_view/calender_view.dart';
import 'package:sona/ui/widgets/menstrual_cycle/calendar_date_formatter.dart';
import 'package:sona/ui/widgets/menstrual_cycle/calendar_cell.dart';
import 'package:sona/ui/widgets/menstrual_cycle/menstrual_monthly_calender_view.dart';

class CalendarRefersher {
  void Function()? refresh;

  void refreshCalendar() {
    refresh?.call();
  }
}

class MyMenstrualCycleCalenderView extends StatefulWidget {
  final Color daySelectedColor;
  final Color themeColor;
  final Color backgroundColor;
  final String logPeriodText;
  final bool hideInfoView;
  final bool hideBottomBar;
  final bool hideLogPeriodButton;
  final bool isExpanded;
  final void Function(DateTime, DayType?)? onDateSelected;
  final VoidCallback? onDataChanged;
  final CalendarRefersher? refresher;

  const MyMenstrualCycleCalenderView({
    super.key,
    this.daySelectedColor = Colors.grey,
    this.themeColor = Colors.black,
    this.backgroundColor = Colors.white,
    this.logPeriodText = Strings.logPeriodLabel,
    this.hideInfoView = false,
    this.hideBottomBar = false,
    this.hideLogPeriodButton = false,
    this.isExpanded = false,
    this.onDateSelected,
    this.onDataChanged,
    this.refresher,
  });

  @override
  State<MyMenstrualCycleCalenderView> createState() => _MyMenstrualCycleCalenderViewState();
}

class _MyMenstrualCycleCalenderViewState extends State<MyMenstrualCycleCalenderView> {
  List<DateTime>? selectedMonthsDays;
  List<DateTime>? selectedWeekDays;
  DateTime _selectedDateTime = DateTime.now();
  String? currentMonth;
  bool isExpanded = false;
  String displayMonth = "";
  String today = "";
  bool isExpandable = true;

  DateTime get selectedDateTime => _selectedDateTime;
  final _instance = MenstrualCycleWidget.instance!;

  List<String> futurePeriodDays = [];
  List<String> futureOvulationDays = [];
  List<String>? pastAllPeriodsDays = [];

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

    _selectedDateTime = DateTime.now();
    selectedMonthsDays = _daysInMonth(selectedDateTime);
    selectedWeekDays = CalenderDateUtils.daysInRange(_firstDayOfWeek(selectedDateTime), _lastDayOfWeek(selectedDateTime)).toList();

    init();

    if (widget.refresher != null) {
      widget.refresher!.refresh = init;
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.refresher != null) {
      widget.refresher!.refresh = null;
    }
  }

  init() async {
    await _instance.calculateLastPeriodDate();
    pastAllPeriodsDays = _instance.pastAllPeriodDays;
    futurePeriodDays = await initFuturePeriodDay();
    futureOvulationDays = await initFutureOvulationDay();
    setState(() {});
  }

  Widget calendarGridView() {
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
          children: calendarBuilder(),
        ),
      ]),
    );
  }

  List<Widget> calendarBuilder() {
    List<Widget> calendarGridItems = [];
    List<DateTime>? calendarDays = isExpanded ? selectedMonthsDays : selectedWeekDays;

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
      day = CalenderDateUtils.getDay(day);
      day = _normalizeDay(day);

      if (day.hour > 0) {
        day = day.toLocal();
        day = day.subtract(Duration(hours: day.hour));
      }

      if (monthStarted && day.day == 01) {
        monthEnded = true;
      }

      if (CalenderDateUtils.isFirstDayOfMonth(day)) {
        monthStarted = true;
      }

      //
      bool isToday = CalenderDateUtils.isSameDay(now, day);
      calendarGridItems.add(CustomizedCalendarCell(
        day: day,
        onTapDay: (dayType) => handleSelectedDateCallback(day, dayType),
        themeColor: widget.themeColor,
        selectedColor: widget.daySelectedColor,
        todayColor: widget.themeColor,
        dayTextStyle: isToday ? const TextStyle(color: Colors.white, fontWeight: FontWeight.bold) : configureDateStyle(monthStarted, monthEnded),
        //PERIOD CONFIFURATION
        previousPeriodDate: _instance.getPreviousPeriodDay(),
        periodDuration: _instance.getPeriodDuration(),
        cycleLength: _instance.getCycleLength(),
        //PERIOD LOGS
        pastAllPeriodsDays: pastAllPeriodsDays ?? [],
        futurePeriodDays: futurePeriodDays,
        futureOvulationDays: futureOvulationDays,
        // STATES
        isSelected: CalenderDateUtils.isSameDay(_selectedDateTime, day),
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
                    onPressed: _onTapLogPeriod,
                    child: Text(
                      widget.logPeriodText,
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
          ExpansionCrossFade(
            collapsed: calendarGridView(),
            expanded: calendarGridView(),
            isExpanded: isExpanded,
          ),
          const SizedBox(height: 15),
          if (!widget.hideInfoView) getInformationView(widget.daySelectedColor, widget.themeColor),
          const SizedBox(height: 10),
          if (!widget.hideBottomBar) bottomView(),
        ],
      ),
    );
  }

  void resetToToday() {
    _selectedDateTime = DateTime.now();
    var firstDayOfCurrentWeek = _firstDayOfWeek(selectedDateTime);
    var lastDayOfCurrentWeek = _lastDayOfWeek(selectedDateTime);

    setState(() {
      selectedWeekDays = CalenderDateUtils.daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek).toList();
      selectedMonthsDays = _daysInMonth(selectedDateTime);
      var monthFormat = formatter.formatDayMonth(selectedDateTime);

      displayMonth = "${monthFormat[0].toUpperCase()}${monthFormat.substring(1)}";
      var todayFormat = formatter.formatDay(selectedDateTime);

      today = todayFormat;
    });

    // _launchDateSelectionCallback(selectedDateTime);
  }

  void nextMonth() {
    setState(() {
      _selectedDateTime = CalenderDateUtils.nextMonth(selectedDateTime);
      var firstDateOfNewMonth = CalenderDateUtils.firstDayOfMonth(selectedDateTime);
      var lastDateOfNewMonth = CalenderDateUtils.lastDayOfMonth(selectedDateTime);
      updateSelectedRange(firstDateOfNewMonth, lastDateOfNewMonth);
      selectedMonthsDays = _daysInMonth(selectedDateTime);
      var monthFormat = formatter.formatMonthYear(selectedDateTime);
      displayMonth = "${monthFormat[0].toUpperCase()}${monthFormat.substring(1)}";
    });
  }

  void previousMonth() {
    setState(() {
      _selectedDateTime = CalenderDateUtils.previousMonth(selectedDateTime);
      var firstDateOfNewMonth = CalenderDateUtils.firstDayOfMonth(selectedDateTime);
      var lastDateOfNewMonth = CalenderDateUtils.lastDayOfMonth(selectedDateTime);
      updateSelectedRange(firstDateOfNewMonth, lastDateOfNewMonth);
      selectedMonthsDays = _daysInMonth(selectedDateTime);
      var monthFormat = formatter.formatMonthYear(selectedDateTime);

      displayMonth = "${monthFormat[0].toUpperCase()}${monthFormat.substring(1)}";
    });
    // _launchDateSelectionCallback(selectedDateTime);
  }

  void nextWeek() {
    setState(() {
      _selectedDateTime = CalenderDateUtils.nextWeek(selectedDateTime);
      var firstDayOfCurrentWeek = _firstDayOfWeek(selectedDateTime);
      var lastDayOfCurrentWeek = _lastDayOfWeek(selectedDateTime);
      updateSelectedRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek);
      selectedWeekDays = CalenderDateUtils.daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek).toList();
      var monthFormat = formatter.formatMonthYear(selectedDateTime);

      displayMonth = "${monthFormat[0].toUpperCase()}${monthFormat.substring(1)}";
    });
    // _launchDateSelectionCallback(selectedDateTime);
  }

  void previousWeek() {
    setState(() {
      _selectedDateTime = CalenderDateUtils.previousWeek(selectedDateTime);
      var firstDayOfCurrentWeek = _firstDayOfWeek(selectedDateTime);
      var lastDayOfCurrentWeek = _lastDayOfWeek(selectedDateTime);
      updateSelectedRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek);
      selectedWeekDays = CalenderDateUtils.daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek).toList();
      var monthFormat = formatter.formatMonthYear(selectedDateTime);

      displayMonth = "${monthFormat[0].toUpperCase()}${monthFormat.substring(1)}";
    });
    //  _launchDateSelectionCallback(selectedDateTime);
  }

  void updateSelectedRange(DateTime start, DateTime end) {}

  void _onTapLogPeriod() async {
    final dataChanged = await Navigator.of(context).push<bool>(MaterialPageRoute(
      builder: (context) => MyMenstrualCycleMonthlyCalenderView(
        themeColor: widget.themeColor,
        hideInfoView: widget.hideInfoView,
        isShowCloseIcon: true,
        onDataChanged: (value) {},
        formatter: formatter,
        todayColor: widget.themeColor,
        daySelectedColor: widget.daySelectedColor,
      ),
    ));

    if (dataChanged != null && dataChanged) {
      init();
      if (widget.onDataChanged != null) {
        widget.onDataChanged!();
      }
    }
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

  void handleSelectedDateCallback(DateTime day, DayType? dayType) {
    var firstDayOfCurrentWeek = _firstDayOfWeek(day);
    var lastDayOfCurrentWeek = _lastDayOfWeek(day);
    if (selectedDateTime.month > day.month) {
      previousMonth();
    }
    if (selectedDateTime.month < day.month) {
      nextMonth();
    }
    setState(() {
      _selectedDateTime = day;
      selectedWeekDays = CalenderDateUtils.daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek).toList();
      selectedMonthsDays = _daysInMonth(day);
    });
    _launchDateSelectionCallback(day, dayType);
  }

  void _launchDateSelectionCallback(DateTime day, [DayType? dayType]) {
    if (widget.onDateSelected != null) {
      widget.onDateSelected!(day, dayType);
    }
  }

  _firstDayOfWeek(DateTime date) {
    var day = DateTime.utc(selectedDateTime.year, selectedDateTime.month, selectedDateTime.day, 12);
    return day.subtract(Duration(days: day.weekday));
  }

  _lastDayOfWeek(DateTime date) {
    return _firstDayOfWeek(date).add(const Duration(days: 7));
  }

  List<DateTime> _daysInMonth(DateTime month) {
    var first = CalenderDateUtils.firstDayOfMonth(month);
    var daysBefore = first.weekday;
    var firstToDisplay = first.subtract(Duration(days: daysBefore));
    var last = CalenderDateUtils.lastDayOfMonth(month);

    var daysAfter = 7 - last.weekday;

    // If the last day is sunday (7) the entire week must be rendered
    if (daysAfter == 0) {
      daysAfter = 7;
    }

    var lastToDisplay = last.add(Duration(days: daysAfter));
    return CalenderDateUtils.daysInRange(firstToDisplay, lastToDisplay).toList();
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
