import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/domain/models/models.dart';
import 'package:sona/domain/services/services.dart';
import 'package:sona/shared/crud.dart';
import 'package:sona/ui/utils/helpers/user_service_widget_helper.dart';
import 'package:sona/ui/widgets/dropdown.dart';
import 'package:sona/ui/widgets/professional_botton_sheet.dart';
import 'package:sona/ui/widgets/sona_scaffold.dart';

@RoutePage()
class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> with UserServiceWidgetHelper {
  final _appointmentService = injector.get<AppointmentService>();
  final _userService = injector.get<UserService>();
  final int _pageSize = 20;

  List<Authority> _authorities = professionalAuthorities;
  User? _selectedProfessional;

  void _openFilterSettings() {
    showPorfessionalAuthoritiesSelector(
      context: context,
      onSelected: (authorities) {
        setState(() => _authorities = authorities);
      },
    );
  }

  Future<List<User>> _onSearch(String query, int page) async {
    final users = await _userService.page(PageQuery(
      search: query,
      page: page - 1,
      size: _pageSize,
      params: {
        'authorities': _authorities.map((e) => e.authority).toList(),
      },
    ));
    return users.content;
  }

  void _setSelectedProfessional(User user) {
    setState(() => _selectedProfessional = user);
  }

  @override
  Widget build(BuildContext context) {
    return SonaScaffold(
      actionButton: SonaActionButton.home(),
      body: Column(
        children: [
          const SizedBox(height: 20),
          SearchDropdown(
            hideOnEmpty: true,
            pageSize: _pageSize,
            onSearch: _onSearch,
            onSelected: _setSelectedProfessional,
            dependencies: [_authorities],
            itemBuilder: (context, user, isSelected) {
              return ListTile(
                title: Text(user.fullName),
                subtitle: Text("@${user.username}"),
                leading: buildProfilePicture(user.id),
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
