import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/domain/models/models.dart';
import 'package:sona/domain/services/services.dart';
import 'package:sona/shared/crud.dart';
import 'package:sona/shared/schemas/direction.dart';
import 'package:sona/ui/utils/dialogs.dart';
import 'package:sona/ui/utils/paging.dart';
import 'package:sona/ui/widgets/sona_scaffold.dart';
import 'package:intl/intl.dart';

@RoutePage()
class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  final _appointmentService = injector.get<AppointmentService>();
  late final _pagingController = PagingRequestController<Appointment>(_loadPageAppointments);

  @override
  void initState() {
    super.initState();
  }

  Future<List<Appointment>> _loadPageAppointments(int page) async {
    final result = await _appointmentService.appoiments(PageQuery(
      page: page,
      sort: [
        Sort('date', Direction.desc),
        Sort('hour', Direction.desc),
      ],
    ));
    return result.content;
  }

  @override
  Widget build(BuildContext context) {
    return SonaScaffold(
      actionButton: SonaActionButton.home(),
      body: RefreshIndicator(
        onRefresh: () => Future.sync(_pagingController.refresh),
        child: PagingListener(
          controller: _pagingController,
          builder: (context, state, fetchNextPage) => PagedListView<int, Appointment>(
            state: state,
            fetchNextPage: fetchNextPage,
            builderDelegate: PagedChildBuilderDelegate<Appointment>(
              noItemsFoundIndicatorBuilder: (context) => const Center(child: Text('No tienes citas.')),
              itemBuilder: (context, appointment, index) => AppointmentListItem(appointment: appointment),
            ),
          ),
        ),
      ),
    );
  }
}

class AppointmentListItem extends StatefulWidget {
  final Appointment appointment;

  const AppointmentListItem({
    super.key,
    required this.appointment,
  });

  @override
  State<AppointmentListItem> createState() => _AppointmentListItemState();
}

class _AppointmentListItemState extends State<AppointmentListItem> {
  final now = DateTime.now();
  final appointmentService = injector.get<AppointmentService>();

  late bool canceled;
  late String? cancellationReason;

  @override
  void initState() {
    super.initState();
    canceled = widget.appointment.canceled;
    cancellationReason = widget.appointment.cancellationReason;
  }

  Future<void> _showCancelAppointmentDialog() async {
    final result = await showConfirmDialog(
      context,
      title: 'Cancelar cita',
      message: '¿Estás seguro de que deseas cancelar esta cita?',
      confirmText: "Sí, cancelar",
      cancelText: 'No, mantener',
    );

    if (result != true || !mounted) return;

    final reason = await showInputDialog(
      context,
      title: 'Motivo de cancelación',
      message: 'Por favor, ingresa el motivo de la cancelación.',
      minLines: 5,
    );

    if (reason == null || !mounted) return;

    showLoadingDialog(context);
    try {
      await appointmentService.cancel(
        appointment: widget.appointment,
        reason: reason,
      );

      if (mounted) {
        Navigator.of(context).pop();
        setState(() {
          canceled = true;
          cancellationReason = reason;
        });
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      showAlertErrorDialog(
        context,
        title: 'Error al cancelar cita',
        error: e,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);

    return Card(
      child: InkWell(
        onTap: () {
          // Aquí puedes navegar al detalle de la cita
          // Navigator.pushNamed(context, '/appointment-detail', arguments: appointment);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('d \'de\' MMMM \'de\' y', locale.toLanguageTag()).format(widget.appointment.date),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  _buildStatusChip(),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    widget.appointment.type == AppointmentType.virtual ? Icons.videocam_outlined : Icons.person_outline,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.appointment.hour.toString().padLeft(2, '0')}:00 ${widget.appointment.hour < 12 ? 'AM' : 'PM'}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.appointment.professional.fullName,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
              if (canceled && cancellationReason != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Motivo de cancelación: $cancellationReason',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    final isPast = widget.appointment.date.isBefore(now);
    Widget container(String text, Color color) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    if (isPast) {
      return container('Pasada', Colors.grey.shade400);
    }

    if (canceled) {
      return container('Cancelada', Colors.red.shade700);
    }

    return Row(
      children: [
        container('Confirmada', Colors.green.shade700),
        const SizedBox(width: 8),
        SizedBox(
          height: 25,
          width: 25,
          child: PopupMenuButton(
            padding: EdgeInsets.zero,
            menuPadding: EdgeInsets.zero,
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  value: 'cancel',
                  child: Text('Cancelar cita'),
                ),
              ];
            },
            onSelected: (value) {
              if (value == 'cancel') {
                _showCancelAppointmentDialog();
              }
            },
          ),
        ),
      ],
    );
  }
}
