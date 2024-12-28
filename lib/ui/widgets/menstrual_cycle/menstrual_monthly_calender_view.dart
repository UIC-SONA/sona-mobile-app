import 'package:flutter/material.dart';
import 'package:menstrual_cycle_widget/menstrual_cycle_widget.dart';
import 'package:menstrual_cycle_widget/ui/calender_view/calender_view.dart' hide getInformationView;
import 'package:menstrual_cycle_widget/ui/calender_view/scroll_to_index.dart';
import 'package:sona/ui/widgets/menstrual_cycle/calendar_cell.dart';
import 'package:sona/ui/widgets/menstrual_cycle/calendar_date_formatter.dart';

class MyMenstrualCycleMonthlyCalenderView extends StatefulWidget {
  final Color themeColor;
  final Color? daySelectedColor;
  final bool hideInfoView;
  final bool isShowCloseIcon;
  final Function? onDataChanged;
  final CalenderDateFormatter formatter;
  final Color todayColor;

  const MyMenstrualCycleMonthlyCalenderView({
    super.key,
    this.themeColor = Colors.black,
    this.daySelectedColor,
    this.isShowCloseIcon = false,
    this.onDataChanged,
    this.hideInfoView = false,
    required this.formatter,
    required this.todayColor,
  });

  @override
  State<MyMenstrualCycleMonthlyCalenderView> createState() => _MyMenstrualCycleMonthlyCalenderViewState();
}

class _MyMenstrualCycleMonthlyCalenderViewState extends State<MyMenstrualCycleMonthlyCalenderView> {
  final _instance = MenstrualCycleWidget.instance!;

  @override
  Widget build(BuildContext context) {
    return CalenderMonthlyView(
      themeColor: widget.themeColor,
      selectedColor: (widget.daySelectedColor != null) ? widget.daySelectedColor! : Colors.grey,
      cycleLength: _instance.getCycleLength(),
      periodLength: _instance.getPeriodDuration(),
      isFromCalender: widget.isShowCloseIcon,
      onDataChanged: (value) {
        widget.onDataChanged!.call(value);
      },
      hideInfoView: widget.hideInfoView,
      formatter: widget.formatter,
      todayColor: widget.todayColor,
    );
  }
}

class CalenderMonthlyView extends StatefulWidget {
  final ValueChanged<DateTime>? onDateSelected;
  final Color selectedColor;
  final Color todayColor;
  final DateTime? initialDate;
  final List<String> weekTitles;
  final double? borderRadius;
  final Function? onDataChanged;
  final int cycleLength;
  final Color themeColor;
  final int periodLength;
  final bool isFromCalender;
  final bool hideInfoView;
  final CalenderDateFormatter formatter;

  const CalenderMonthlyView({
    super.key,
    this.onDateSelected,
    required this.themeColor,
    required this.selectedColor,
    required this.todayColor,
    this.initialDate,
    this.weekTitles = CalenderDateUtils.weekTitles,
    this.onDataChanged,
    this.borderRadius = 20,
    this.cycleLength = defaultCycleLength,
    this.periodLength = defaultPeriodDuration,
    this.isFromCalender = true,
    this.hideInfoView = false,
    required this.formatter,
  });

  @override
  State<CalenderMonthlyView> createState() => _CalenderMonthlyViewState();
}

class _CalenderMonthlyViewState extends State<CalenderMonthlyView> {
  DateTime _selectedDate = DateTime.now();
  List<List<DateTime>> monthWidgets = [];
  List<String> monthTitle = [];
  bool isEditMode = false;
  List<DateTime> selectedPeriodsDate = [];
  bool isChangedData = false;

  List<String> futurePeriodDays = [];
  List<String> futureOvulationDays = [];
  List<String>? pastAllPeriodsDays = [];

  final _instance = MenstrualCycleWidget.instance!;

  int pastMonthCount = 3;
  int nextMonthCount = 3;
  int nextMonthIncrementCount = 3;
  int pastMonthDecrementCount = 3;

  late AutoScrollController controller;
  bool isInitialScroll = true;

  CalenderDateFormatter get formatter => widget.formatter;

  @override
  void initState() {
    super.initState();
    controller = AutoScrollController(
      viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: Axis.vertical,
    );
    init();
    _selectedDate = widget.initialDate ?? DateTime.now();
    generateMonthData(true);
  }

  init() async {
    await _instance.calculateLastPeriodDate();
    pastAllPeriodsDays = _instance.pastAllPeriodDays;
    futurePeriodDays = await initFuturePeriodDay();
    futureOvulationDays = await initFutureOvulationDay();
  }

  DateTime getDateTimeFromMonthsAgo(int monthsAgo) {
    final now = DateTime.now();
    int year = now.year;
    int month = now.month;

    month -= monthsAgo;
    while (month <= 0) {
      month += 12;
      year -= 1;
    }

    // Return the calculated date
    return DateTime(year, month);
  }

  void generateMonthData(bool isConsiderFutureDate) async {
    monthWidgets.clear();
    monthTitle.clear();

    for (int index = pastMonthCount; index > 0; index--) {
      DateTime currentMonth = getDateTimeFromMonthsAgo(index);
      monthTitle.add(formatter.formatMonthYear(currentMonth));
      monthWidgets.add(monthCalendarBuilder(currentMonth, isConsiderFutureDate));
    }
    monthTitle.add(formatter.formatMonthYear(_selectedDate));
    monthWidgets.add(monthCalendarBuilder(_selectedDate, isConsiderFutureDate));

    if (isConsiderFutureDate) {
      DateTime nextMonth = CalenderDateUtils.nextMonth(_selectedDate);
      for (int index = 0; index < nextMonthCount; index++) {
        monthTitle.add(formatter.formatMonthYear(nextMonth));
        monthWidgets.add(monthCalendarBuilder(nextMonth, isConsiderFutureDate));
        nextMonth = CalenderDateUtils.nextMonth(nextMonth);
      }
    }

    if (isInitialScroll) {
      await controller.scrollToIndex(3, preferPosition: AutoScrollPosition.begin);
      isInitialScroll = false;
    }
  }

  List<DateTime> _daysInMonth(DateTime month) {
    var first = CalenderDateUtils.firstDayOfMonth(month);
    var daysBefore = first.weekday;
    var firstToDisplay = first.subtract(Duration(days: daysBefore));
    var last = CalenderDateUtils.lastDayOfMonth(month);

    var daysAfter = 7 - last.weekday;

    if (daysAfter == 0) {
      daysAfter = 7;
    }

    var lastToDisplay = last.add(const Duration(days: 1));
    return CalenderDateUtils.daysInRange(firstToDisplay, lastToDisplay).toList();
  }

  void previousMonth() {
    _selectedDate = CalenderDateUtils.previousMonth(_selectedDate);
  }

  void nextMonth() {
    _selectedDate = CalenderDateUtils.nextMonth(_selectedDate);
  }

  titleCalendarBuilder() {
    List<Widget> dayWidgets = [];

    for (var day in formatter.weekTitles) {
      dayWidgets.add(
        Container(
          alignment: Alignment.center,
          child: Text(
            day,
            style: TextStyle(color: widget.themeColor, fontWeight: FontWeight.w800, fontSize: 11),
          ),
        ),
      );
    }

    return dayWidgets;
  }

  monthCalendarBuilder(DateTime selectedDate, bool isConsiderFutureDate) {
    List<DateTime> dayWidgets = [];
    List<DateTime>? calendarDays = _daysInMonth(selectedDate);
    for (var day in calendarDays) {
      day = CalenderDateUtils.getDay(day);
      if (day.hour > 0) {
        day = day.toLocal();
        day = day.subtract(Duration(hours: day.hour));
      }
      bool isBeforeCurrentDate = day.isBefore(DateTime.now());
      if (isBeforeCurrentDate) {
        dayWidgets.add(day);
      } else if (isConsiderFutureDate) {
        dayWidgets.add(day);
      }
    }
    return dayWidgets;
  }

  void _launchDateSelectionCallback(DateTime day) {
    if (!isEditMode) {
      if (widget.onDateSelected != null) {
        widget.onDateSelected!(day);
      }
    }
  }

  void dateSelectionCallBack(DateTime day, bool isChecked) {
    int index = selectedPeriodsDate.indexOf(day);
    if (index > -1) {
      if (!isChecked) {
        selectedPeriodsDate.removeAt(index);
      }
    } else {
      if (isChecked) {
        selectedPeriodsDate.add(day);
      }
    }
  }

  saveSelectedPeriodDate() async {
    final dbHelper = MenstrualCycleDbHelper.instance;
    final instance = MenstrualCycleWidget.instance!;
    String encryptedUserid = instance.getCustomerId();

    selectedPeriodsDate.sort((a, b) => a.compareTo(b));
    if (selectedPeriodsDate.isNotEmpty) {
      DateTime lastPeriodDate = selectedPeriodsDate[0].add(const Duration(days: -1));
      await dbHelper.clearPeriodLogAfterSpecificDate(encryptedUserid, CalenderDateUtils.dateDayFormat(lastPeriodDate));
      await dbHelper.insertPeriodLog(selectedPeriodsDate);
    } else {
      await dbHelper.clearPeriodLog(encryptedUserid);
    }
    isChangedData = true;
    widget.onDataChanged!.call(isChangedData);
    isEditMode = false;
    generateMonthData(true);

    pastAllPeriodsDays = await instance.calculateLastPeriodDate();
    futurePeriodDays = await initFuturePeriodDay();
    futureOvulationDays = await initFutureOvulationDay();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) {
          return;
        }
        if (context.mounted) {
          Navigator.pop(context, isChangedData);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isFromCalender)
                IconButton(
                  onPressed: () => Navigator.pop(context, isChangedData),
                  iconSize: 25.0,
                  padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                  icon: Icon(
                    Icons.close,
                    color: widget.themeColor,
                  ),
                ),
              if (!widget.hideInfoView) ...[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: getInformationView(widget.selectedColor, widget.themeColor),
                ),
                Divider(color: widget.themeColor),
              ],
              GridView.count(
                childAspectRatio: 1.5,
                primary: false,
                shrinkWrap: true,
                crossAxisCount: 7,
                padding: const EdgeInsets.only(bottom: 0.0),
                children: titleCalendarBuilder(),
              ),
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification notification) {
                    if (notification is ScrollUpdateNotification || notification is ScrollEndNotification) {
                      if (notification.metrics.pixels < 10) {
                        printMenstrualCycleLogs('Reached top');
                        //
                        pastMonthCount = pastMonthCount + 1;
                        DateTime currantMonth = getDateTimeFromMonthsAgo(pastMonthCount);
                        monthTitle.insert(0, CalenderDateUtils.monthYear.format(currantMonth));
                        monthWidgets.insert(0, monthCalendarBuilder(currantMonth, false));

                        setState(() {});
                      } else if (notification.metrics.pixels + 100 > notification.metrics.maxScrollExtent && !isEditMode) {
                        printMenstrualCycleLogs('Reached bottom');
                        if (nextMonthCount <= futureMonthCount) {
                          DateTime nextMonth = DateTime.now();
                          for (int index = 0; index <= nextMonthCount; index++) {
                            nextMonth = CalenderDateUtils.nextMonth(nextMonth);
                          }
                          for (int index = nextMonthCount; index < nextMonthCount + nextMonthIncrementCount; index++) {
                            monthTitle.add(CalenderDateUtils.monthYear.format(nextMonth));
                            monthWidgets.add(monthCalendarBuilder(nextMonth, true));
                            nextMonth = CalenderDateUtils.nextMonth(nextMonth);
                          }
                          nextMonthCount = nextMonthCount + nextMonthIncrementCount;

                          setState(() {});
                        }
                      }
                    }
                    return true;
                  },
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    controller: controller,
                    padding: const EdgeInsets.all(8),
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: monthWidgets.length,
                    itemBuilder: (BuildContext context, int index) {
                      bool monthStarted = false;
                      return AutoScrollTag(
                        key: ValueKey(index),
                        controller: controller,
                        index: index,
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            Text(
                              monthTitle[index],
                              style: TextStyle(color: widget.themeColor, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            GridView.count(
                              primary: false,
                              shrinkWrap: true,
                              crossAxisCount: 7,
                              padding: const EdgeInsets.only(bottom: 0.0),
                              children: List.generate(monthWidgets[index].length, (childIndex) {
                                final day = CalenderDateUtils.getDay(monthWidgets[index][childIndex]);

                                if (CalenderDateUtils.isFirstDayOfMonth(day)) monthStarted = true;

                                if (!monthStarted) return const SizedBox();

                                final dateStyle = TextStyle(color: widget.themeColor, fontWeight: FontWeight.normal);
                                final dayDate = monthWidgets[index][childIndex];
                                final now = DateTime.now();

                                if (isEditMode) {
                                  return EditCalendarCell(
                                    day: day,
                                    multipleDateSelectionCallBack: (value) => dateSelectionCallBack(dayDate, value),
                                    dateStyles: dateStyle,
                                    previousPeriodDate: _instance.getPreviousPeriodDay(),
                                    pastAllPeriodsDays: pastAllPeriodsDays,
                                    periodDuration: widget.periodLength,
                                  );
                                }

                                final isToday = CalenderDateUtils.isSameDay(now, day);
                                return CustomizedCalendarCell(
                                  day: day,
                                  onTapDay: (dayType) => _launchDateSelectionCallback(dayDate),
                                  themeColor: widget.themeColor,
                                  selectedColor: widget.selectedColor,
                                  todayColor: widget.todayColor,
                                  dayTextStyle: dateStyle,
                                  //PERIOD CONFIFURATION
                                  previousPeriodDate: _instance.getPreviousPeriodDay(),
                                  periodDuration: _instance.getPeriodDuration(),
                                  cycleLength: _instance.getCycleLength(),
                                  //PERIOD LOGS
                                  pastAllPeriodsDays: pastAllPeriodsDays ?? [],
                                  futurePeriodDays: futurePeriodDays,
                                  futureOvulationDays: futureOvulationDays,
                                  // STATES
                                  isSelected: CalenderDateUtils.isSameDay(_selectedDate, day),
                                  isToday: isToday,
                                );
                              }),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (isEditMode)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    children: [
                      Divider(color: widget.themeColor),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: saveSelectedPeriodDate,
                            child: const Text(
                              'Guardar',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              setState(() {
                                isEditMode = false;
                                generateMonthData(true);
                              });
                            },
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10)
                    ],
                  ),
                )
              else
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (isEditMode) {
                            isEditMode = false;
                          } else {
                            generateMonthData(false);
                            isEditMode = true;
                          }
                        });
                      },
                      child: const Text(
                        "Editar fechas del periodo",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
