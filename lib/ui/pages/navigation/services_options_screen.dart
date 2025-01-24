import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/domain/models/models.dart';
import 'package:sona/domain/services/services.dart';
import 'package:sona/ui/pages/routing/router.dart';
import 'package:sona/ui/theme/colors.dart';
import 'package:sona/ui/widgets/menu.dart';
import 'package:sona/ui/widgets/sona_scaffold.dart';

@RoutePage()
class ServicesOptionsScreen extends StatelessWidget {
  late final _userService = injector.get<UserService>();

  ServicesOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isProfessional = _userService.currentUser.authorities.any((element) => element == Authority.medicalProfessional || element == Authority.legalProfessional);

    return SonaScaffold(
      actionButton: SonaActionButton.home(),
      body: Column(
        children: [
          GridMenu(
            buttons: [
              MenuButton(
                label: 'Chatbot',
                icon: SvgPicture.asset('assets/icons/ICON4.svg', height: 90,),
                onPressed: () => AutoRouter.of(context).push(const ChatBotRoute()),
                gradient: bgGradientButton1,
              ),
              MenuButton(
                label: isProfessional ? 'Chat' : 'Chat con Profesionales',
                icon: SvgPicture.asset('assets/icons/ICON5.svg', height: 90,),
                onPressed: () => AutoRouter.of(context).push(const ChatRoute()),
                gradient: bgGradientButton1,
              ),
              MenuButton(
                label: 'Agendamiento de Citas',
                icon: SvgPicture.asset('assets/icons/ICON6.svg', height: 90,),
                onPressed: () => AutoRouter.of(context).push(const AppointmentMenuRoute()),
                gradient: bgGradientButton1,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
