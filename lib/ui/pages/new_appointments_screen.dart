import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/domain/models/models.dart';
import 'package:sona/domain/services/services.dart';
import 'package:sona/shared/crud.dart';
import 'package:sona/ui/utils/dialogs.dart';
import 'package:sona/ui/utils/helpers/user_service_widget_helper.dart';
import 'package:sona/ui/widgets/search_dropdown.dart';
import 'package:sona/ui/widgets/professional_botton_sheet.dart';
import 'package:sona/ui/widgets/sona_scaffold.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart' hide Appointment, AppointmentType;
import 'package:intl/intl.dart';

@RoutePage()
class NewAppointmentScreen extends StatefulWidget {
  const NewAppointmentScreen({super.key});

  @override
  State<NewAppointmentScreen> createState() => _NewAppointmentScreenState();
}

class _NewAppointmentScreenState extends State<NewAppointmentScreen> with UserServiceWidgetHelper {
  //
  final appointmentService = injector.get<AppointmentService>();
  final professionalScheduleService = injector.get<ProfessionalScheduleService>();
  @override
  final userService = injector.get<UserService>();

  final int pageSize = 20;

  final calendarController = CalendarController();
  final schedulers = ValueNotifier<List<ProfessionalSchedule>>([]);

  List<Authority> _authorities = professionalAuthorities;
  List<AppoimentRange> _appointments = [];
  User? _selectedProfessional;
  DateTimeRange? _visibleRange;

  void _openFilterSettings() {
    showProfessionalAuthoritiesSelector(
      context: context,
      onSelected: (authorities) {
        setState(() => _authorities = authorities);
      },
    );
  }

  Future<List<User>> _onSearch(String search, int page) async {
    final users = await userService.page(PageQuery(
      search: search,
      page: page - 1,
      size: pageSize,
      query: 'authorities=in=(${_authorities.map((e) => e.authority).join(",")})',
    ));
    return users.content;
  }

  Future<void> _loadData() async {
    if (_selectedProfessional == null || _visibleRange == null) return;
    final from = _visibleRange!.start;
    final to = _visibleRange!.end;

    final results = await Future.wait([
      professionalScheduleService.professionalSchedules(_selectedProfessional!, from, to),
      appointmentService.professionalAppointmentsRanges(_selectedProfessional!, from, to),
    ]);

    schedulers.value = results[0] as List<ProfessionalSchedule>;
    _appointments = results[1] as List<AppoimentRange>;
  }

  void _setSelectedProfessional(User? user) {
    setState(() => _selectedProfessional = user);
    _loadData();
  }

  void _onScheduleTapped(ProfessionalSchedule schedule) {
    if (schedule.date.isBefore(DateTime.now())) return;
    _showModalBottomAppoinmentSelector(schedule);
  }

  @override
  Widget build(BuildContext context) {
    return SonaScaffold(
      actionButton: SonaActionButton.home(),
      body: Column(
        children: [
          _buildSearchProfessional(),
          const SizedBox(height: 10),
          Expanded(
            child: _selectedProfessional != null
                ? SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildProfessionDetails(_selectedProfessional!),
                        const SizedBox(height: 10),
                        _buildCalendar(_selectedProfessional!),
                      ],
                    ),
                  )
                : _buildEmptyState(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchProfessional() {
    return SearchDropdown(
      hideOnEmpty: true,
      pageSize: pageSize,
      onSearch: _onSearch,
      onSelected: _setSelectedProfessional,
      dependencies: [_authorities],
      itemBuilder: (context, user, isSelected) {
        return ListTile(
          title: Text(user.fullName),
          subtitle: Text("@${user.username}"),
          leading: buildUserAvatar(user),
        );
      },
      inputDecoration: InputDecoration(
        hintText: 'Buscar profesional',
        suffixIcon: IconButton(
          onPressed: _openFilterSettings,
          icon: const Icon(Icons.filter_alt_rounded),
        ),
      ),
      dropdownDecoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      displayMapper: (User item) => item.fullName,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 100,
            color: Colors.grey,
          ),
          const SizedBox(height: 10),
          Text(
            'Seleccione un profesional para ver su horario de atención',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(User professional) {
    return Card(
      child: SizedBox(
        height: 600,
        child: ValueListenableBuilder<List<ProfessionalSchedule>>(
          valueListenable: schedulers,
          builder: (context, schedules, _) {
            return SfCalendar(
              view: CalendarView.month,
              allowedViews: [
                CalendarView.day,
                CalendarView.week,
                CalendarView.month,
              ],
              dataSource: ProfessionalScheduleDataSources(schedules),
              viewHeaderStyle: ViewHeaderStyle(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              ),
              onViewChanged: _onCalendarViewChanged,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              controller: calendarController,
              headerHeight: 50,
              viewHeaderHeight: 50,
              initialDisplayDate: DateTime.now(),
              onTap: _onCalendarTapped,
              monthViewSettings: MonthViewSettings(
                navigationDirection: MonthNavigationDirection.horizontal,
                showAgenda: true,
                agendaViewHeight: 230,
              ),
            );
          },
        ),
      ),
    );
  }

  void _onCalendarViewChanged(ViewChangedDetails details) {
    if (details.visibleDates.isNotEmpty) {
      final firstDate = details.visibleDates.first;
      final lastDate = details.visibleDates.last;
      _visibleRange = DateTimeRange(start: firstDate, end: lastDate);
      _loadData();
    }
  }

  void _onCalendarTapped(CalendarTapDetails details) {
    if ((calendarController.view == CalendarView.week || calendarController.view == CalendarView.month) && details.targetElement == CalendarElement.viewHeader) {
      calendarController.view = CalendarView.day;
    }
    if (details.targetElement == CalendarElement.appointment) {
      final appointment = details.appointments!.first as ProfessionalSchedule;
      _onScheduleTapped(appointment);
    }
  }

  void _showModalBottomAppoinmentSelector(ProfessionalSchedule schedule) {
    final minDate = schedule.date.add(Duration(hours: schedule.fromHour));
    final maxDate = schedule.date.add(Duration(hours: schedule.toHour)).subtract(Duration(milliseconds: 1));

    final selectedDate = ValueNotifier<DateTime?>(null);
    final appointmentType = ValueNotifier<AppointmentType>(AppointmentType.presential);

    final controller = CalendarController();

    controller.addPropertyChangedListener((property) {
      if (property == 'selectedDate') {
        selectedDate.value = controller.selectedDate;
      }
    });

    void onTap(CalendarTapDetails details) {
      if (details.targetElement == CalendarElement.calendarCell) {
        controller.selectedDate = details.date;
        return;
      }

      if (details.targetElement == CalendarElement.appointment) {
        controller.selectedDate = null;
        return;
      }
    }

    String getPeriod(DateTime date) => date.hour < 12 ? 'AM' : 'PM';

    void showConfirmationDialog() async {
      final date = selectedDate.value!;
      final confirmText = ''
          '¿Desea confirmar la ${appointmentType.value == AppointmentType.presential ? 'cita presencial' : 'cita virtual'} '
          'cita para el día ${DateFormat('dd/MM/yyyy').format(date)} a las ${date.hour} ${getPeriod(date)} con el profesional '
          '${schedule.professional.fullName}?'
          '';

      final isConfirmed = await showConfirmDialog(
        context,
        title: 'Confirmar cita',
        message: confirmText,
      );
      if (!mounted || !isConfirmed) return;
      showLoadingDialog(context);

      try {
        final result = await appointmentService.program(
          date: date,
          hour: date.hour,
          type: appointmentType.value,
          professional: schedule.professional,
        );
        _appointments.add(result.range);
        if (!mounted) return;
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        showSnackBarSuccess(context, 'Cita programada correctamente');
      } catch (e) {
        if (!mounted) return;
        Navigator.of(context).pop();
        await showAlertErrorDialog(context, error: e);
        rethrow;
      }
    }

    showModalBottomSheet(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      isScrollControlled: true,
      context: context,
      builder: (context) {
        final primaryColor = Theme.of(context).colorScheme.primary;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Seleccione una hora dentro del horario de atención del profesional',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              Text(
                'Horario de atención: ${schedule.fromHour}:${getPeriod(minDate)} - ${schedule.toHour}:${getPeriod(maxDate)}',
                textAlign: TextAlign.start,
              ),
              Divider(
                color: Colors.grey,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        'Las citas duran una hora, seleccione la hora de inicio de la cita dentro del horario de atención del profesional',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: SfCalendar(
                          showTodayButton: false,
                          view: CalendarView.timelineDay,
                          dataSource: AppointmentRangeDataSource(_appointments),
                          minDate: minDate,
                          maxDate: maxDate,
                          onTap: onTap,
                          timeSlotViewSettings: TimeSlotViewSettings(
                            timeInterval: Duration(hours: 1),
                            timelineAppointmentHeight: double.infinity,
                          ),
                          appointmentBuilder: (context, details) {
                            return Container(
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Center(
                                child: RotatedBox(
                                  quarterTurns: 3,
                                  child: Text(
                                    'Reservado',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      ValueListenableBuilder<AppointmentType>(
                        valueListenable: appointmentType,
                        builder: (context, type, _) {
                          Widget listTile(AppointmentType type, String title) {
                            return RadioListTile<AppointmentType>(
                              title: Text(title),
                              value: type,
                              contentPadding: const EdgeInsets.all(0),
                              dense: true,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            );
                          }
                          return RadioGroup<AppointmentType>(
                            groupValue: appointmentType.value,
                            onChanged: (value) => appointmentType.value = value!,
                            child: Column(
                              children: [
                                listTile(AppointmentType.presential, 'Presencial'),
                                listTile(AppointmentType.virtual, 'Virtual'),
                              ],
                            ),
                          );
                        },
                      ),
                      ValueListenableBuilder<DateTime?>(
                        valueListenable: selectedDate,
                        builder: (context, date, _) {
                          return Column(
                            children: [
                              const SizedBox(height: 10),
                              Text(
                                date != null ? 'Horario seleccionado: ${date.hour} ${getPeriod(date)} a ${date.hour + 1} ${getPeriod(date)}' : 'Seleccione una hora',
                                textAlign: TextAlign.start,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              ElevatedButton(
                                onPressed: date != null ? showConfirmationDialog : null,
                                child: const Text('Reservar cita'),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfessionDetails(User professional) {
    final isMedicalProfessional = professional.authorities.contains(Authority.medicalProfessional);
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  buildUserAvatar(professional),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        professional.fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '@${professional.username}',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Tooltip(
                message: isMedicalProfessional ? 'Profesional médico' : 'Profesional',
                child: Icon(
                  isMedicalProfessional ? Icons.medical_services : Icons.person,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class ProfessionalScheduleDataSources extends CalendarDataSource {
  //
  final DateTime now = DateTime.now();

  ProfessionalScheduleDataSources(List<ProfessionalSchedule> source) {
    appointments = source;
  }

  @override
  List<ProfessionalSchedule> get appointments => super.appointments as List<ProfessionalSchedule>;

  @override
  DateTime getStartTime(int index) {
    final appointment = appointments[index];
    return appointment.date.add(Duration(hours: appointment.fromHour));
  }

  @override
  DateTime getEndTime(int index) {
    final appointment = appointments[index];
    return appointment.date.add(Duration(hours: appointment.toHour));
  }

  @override
  String getSubject(int index) {
    final appointment = appointments[index];
    if (now.isAfter(appointment.date)) return "Horario pasado";
    return "Horario de atención";
  }

  @override
  Color getColor(int index) {
    if (now.isAfter(appointments[index].date)) return Colors.grey;
    return Colors.blue;
  }
}

class AppointmentRangeDataSource extends CalendarDataSource {
  //
  AppointmentRangeDataSource(List<AppoimentRange> source) {
    appointments = source;
  }

  @override
  List<AppoimentRange> get appointments => super.appointments as List<AppoimentRange>;

  @override
  DateTime getStartTime(int index) {
    return appointments[index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments[index].to;
  }
}
