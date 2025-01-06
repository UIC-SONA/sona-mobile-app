import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/domain/models/models.dart';
import 'package:sona/domain/services/services.dart';
import 'package:sona/shared/crud.dart';
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
  final _pagingController = PagingQueryController<Appointment>(firstPage: 0);

  @override
  void initState() {
    super.initState();
    _pagingController.configurePageRequestListener(_loadPageAppointments);
  }

  Future<List<Appointment>> _loadPageAppointments(int page) async {
    final result = await _appointmentService.appoiments(PageQuery(
      page: page,
    ));
    return result.content;
  }

  @override
  Widget build(BuildContext context) {
    return SonaScaffold(
      actionButton: SonaActionButton.home(),
      body: RefreshIndicator(
        onRefresh: () => Future.sync(_pagingController.refresh),
        child: PagedListView<int, Appointment>(
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<Appointment>(
            noItemsFoundIndicatorBuilder: (context) => const Center(child: Text('No se encontraron tips.')),
            itemBuilder: (context, appointment, index) => AppointmentListItem(
              appointment: appointment,
            ),
          ),
        ),
      ),
    );
  }
}

class AppointmentListItem extends StatelessWidget {
  final Appointment appointment;

  const AppointmentListItem({
    super.key,
    required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
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
                    DateFormat('dd/MM/yyyy').format(appointment.date),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  _buildStatusChip(),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    appointment.type == AppointmentType.virtual ? Icons.videocam_outlined : Icons.person_outline,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${appointment.hour.toString().padLeft(2, '0')}:00 hs',
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
                      appointment.professional.fullName,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
              if (appointment.canceled && appointment.cancelReason != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Motivo de cancelación: ${appointment.cancelReason}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.red,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: appointment.canceled ? Colors.red.shade100 : Colors.green.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        appointment.canceled ? 'Cancelada' : 'Confirmada',
        style: TextStyle(
          color: appointment.canceled ? Colors.red.shade700 : Colors.green.shade700,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
