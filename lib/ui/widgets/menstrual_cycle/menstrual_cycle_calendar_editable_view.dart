import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sona/ui/widgets/menstrual_cycle/calendar_cell.dart';
import 'package:sona/ui/widgets/menstrual_cycle/calendar_date_tools.dart';
import 'package:sona/ui/widgets/menstrual_cycle/menstrual_cycle.dart';
import 'package:sona/ui/widgets/menstrual_cycle/menstrual_cycle_calender_view.dart';
import 'package:sona/ui/widgets/scroll_to_index.dart';
import 'package:sona/ui/utils/date_time.dart' as dtu;

class MenstrualCycleCalendarEditableView extends StatefulWidget {
  final PeriodCalculatorController controller;
  final Color daySelectedColor;
  final Color todayColor;
  final DateTime? initialDate;
  final double? borderRadius;
  final Function? onDataChanged;
  final Color themeColor;
  final bool isShowCloseIcon;
  final CalenderDateFormatter formatter;

  const MenstrualCycleCalendarEditableView({
    super.key,
    required this.controller,
    required this.themeColor,
    required this.daySelectedColor,
    required this.todayColor,
    this.initialDate,
    this.onDataChanged,
    this.borderRadius = 20,
    this.isShowCloseIcon = true,
    required this.formatter,
  });

  @override
  State<MenstrualCycleCalendarEditableView> createState() => _MenstrualCycleCalendarEditableViewState();
}

class _MenstrualCycleCalendarEditableViewState extends State<MenstrualCycleCalendarEditableView> {
  late List<DateTime> selectedPeriodsDate;
  DateTime selectedDate = DateTime.now();
  List<List<DateTime>> monthWidgets = [];
  List<String> monthTitle = [];
  bool isEditMode = false;

  List<String> futurePeriodDays = [];
  List<String> futureOvulationDays = [];
  List<String>? pastAllPeriodsDays = [];

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
    selectedPeriodsDate = List.from(widget.controller.pastPeriodDays);

    controller = AutoScrollController(
      viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: Axis.vertical,
    );
    selectedDate = widget.initialDate ?? DateTime.now();
    generateMonthData(true);
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

    for (var index = pastMonthCount; index > 0; index--) {
      var currentMonth = getDateTimeFromMonthsAgo(index);
      monthTitle.add(formatter.formatMonthYear(currentMonth));
      monthWidgets.add(monthCalendarBuilder(currentMonth, isConsiderFutureDate));
    }
    monthTitle.add(formatter.formatMonthYear(selectedDate));
    monthWidgets.add(monthCalendarBuilder(selectedDate, isConsiderFutureDate));

    if (isConsiderFutureDate) {
      var nextMonth = dtu.nextMonth(selectedDate);
      for (var index = 0; index < nextMonthCount; index++) {
        monthTitle.add(formatter.formatMonthYear(nextMonth));
        monthWidgets.add(monthCalendarBuilder(nextMonth, isConsiderFutureDate));
        nextMonth = dtu.nextMonth(nextMonth);
      }
    }

    if (isInitialScroll) {
      await controller.scrollToIndex(3, preferPosition: AutoScrollPosition.begin);
      isInitialScroll = false;
    }
  }

  List<DateTime> _daysInMonth(DateTime month) {
    var first = dtu.firstDayOfMonth(month);
    var daysBefore = first.weekday;
    var firstToDisplay = first.subtract(Duration(days: daysBefore));
    var last = dtu.lastDayOfMonth(month);

    var daysAfter = 7 - last.weekday;

    if (daysAfter == 0) {
      daysAfter = 7;
    }

    var lastToDisplay = last.add(const Duration(days: 1));
    return dtu.daysInRange(firstToDisplay, lastToDisplay).toList();
  }

  void previousMonth() {
    selectedDate = dtu.previousMonth(selectedDate);
  }

  void nextMonth() {
    selectedDate = dtu.nextMonth(selectedDate);
  }

  titleCalendarBuilder() {
    List<Widget> dayWidgets = [];

    for (var day in formatter.weekTitles) {
      dayWidgets.add(
        Container(
          alignment: Alignment.center,
          child: Text(
            day,
            style: TextStyle(
              color: widget.themeColor,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
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
      day = dtu.getDay(day);
      if (day.hour > 0) {
        day = day.toLocal();
        day = day.subtract(Duration(hours: day.hour));
      }
      var isBeforeCurrentDate = day.isBefore(DateTime.now());
      if (isBeforeCurrentDate) {
        dayWidgets.add(day);
      } else if (isConsiderFutureDate) {
        dayWidgets.add(day);
      }
    }
    return dayWidgets;
  }

  void dateSelectionCallBack(DateTime day, bool isChecked) {
    var index = selectedPeriodsDate.indexWhere((element) => dtu.isSameDay(element, day));
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
    if (dataHasChanged()) {
      widget.controller.pastPeriodDays = List.from(selectedPeriodsDate);
      widget.onDataChanged?.call();
    } else {
      if (kDebugMode) {
        print("Data has not changed");
      }
    }

    setState(() {
      isEditMode = false;
      generateMonthData(true);
    });
  }

  bool dataHasChanged() {
    if (kDebugMode) {
      print("Selected Periods Date: ${selectedPeriodsDate.length}");
      print("Past Period Days: ${widget.controller.pastPeriodDays.length}");
    }
    if (selectedPeriodsDate.length != widget.controller.pastPeriodDays.length) {
      return true;
    }
    for (var index = 0; index < selectedPeriodsDate.length; index++) {
      if (!dtu.isSameDay(selectedPeriodsDate[index], widget.controller.pastPeriodDays[index])) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.isShowCloseIcon)
              IconButton(
                onPressed: () => Navigator.pop(context),
                iconSize: 25.0,
                padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                icon: Icon(
                  Icons.close,
                  color: widget.themeColor,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: getInformationView(widget.daySelectedColor, widget.themeColor),
            ),
            Divider(color: widget.themeColor),
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
                      pastMonthCount = pastMonthCount + 1;
                      DateTime currantMonth = getDateTimeFromMonthsAgo(pastMonthCount);
                      monthTitle.insert(0, formatter.formatMonthYear(currantMonth));
                      monthWidgets.insert(0, monthCalendarBuilder(currantMonth, false));

                      setState(() {});
                    } else if (notification.metrics.pixels + 100 > notification.metrics.maxScrollExtent && !isEditMode) {
                      if (nextMonthCount <= widget.controller.futureMonthCount) {
                        DateTime nextMonth = DateTime.now();
                        for (int index = 0; index <= nextMonthCount; index++) {
                          nextMonth = dtu.nextMonth(nextMonth);
                        }
                        for (int index = nextMonthCount; index < nextMonthCount + nextMonthIncrementCount; index++) {
                          monthTitle.add(formatter.formatMonthYear(nextMonth));
                          monthWidgets.add(monthCalendarBuilder(nextMonth, true));
                          nextMonth = dtu.nextMonth(nextMonth);
                        }
                        nextMonthCount = nextMonthCount + nextMonthIncrementCount;
                        setState(() {});
                      }
                    }
                  }
                  return true;
                },
                child: ValueListenableBuilder(
                  valueListenable: widget.controller,
                  builder: (context, value, child) {
                    return ListView.builder(
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
                                  final day = dtu.getDay(monthWidgets[index][childIndex]);

                                  if (dtu.isFirstDayOfMonth(day)) monthStarted = true;

                                  if (!monthStarted) return const SizedBox();

                                  final dateStyle = TextStyle(color: widget.themeColor, fontWeight: FontWeight.normal);
                                  final dayDate = monthWidgets[index][childIndex];
                                  final now = DateTime.now();

                                  final dayType = value.getCycleDayType(dayDate);

                                  if (isEditMode) {
                                    return EditCalendarCell(
                                      day: day,
                                      initialChecked: dayType == CycleDayType.period,
                                      onChecked: (value) => dateSelectionCallBack(dayDate, value),
                                      dateStyles: dateStyle,
                                    );
                                  }

                                  final isToday = dtu.isSameDay(now, day);
                                  return CustomizedCalendarCell(
                                    dayType: dayType,
                                    day: day,
                                    themeColor: widget.themeColor,
                                    selectedColor: widget.daySelectedColor,
                                    todayColor: widget.todayColor,
                                    dayTextStyle: dateStyle,
                                    isSelected: dtu.isSameDay(selectedDate, day),
                                    isToday: isToday,
                                  );
                                }),
                              ),
                            ],
                          ),
                        );
                      },
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
    );
  }
}
