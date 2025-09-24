import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/domain/providers/auth.dart';
import 'package:sona/domain/services/services.dart';
import 'package:sona/ui/pages/routing/router.dart';
import 'package:sona/ui/theme/backgrounds.dart';
import 'package:sona/ui/theme/colors.dart';
import 'package:sona/ui/theme/icons.dart';
import 'package:sona/ui/utils/dialogs.dart';
import 'package:sona/ui/utils/helpers/user_service_widget_helper.dart';
import 'package:sona/ui/widgets/full_state_widget.dart';
import 'package:sona/ui/widgets/rounded_button_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SonaAppBar extends StatelessWidget implements PreferredSizeWidget {
  //
  final Widget actionButton;
  final Widget? title;
  final bool showLeading;

  const SonaAppBar({
    super.key,
    required this.actionButton,
    required this.showLeading,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: preferredSize.height,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: bgGradientAppBar,
        ),
      ),
      leading: showLeading
          ? Builder(
              builder: (context) {
                return IconButton(
                  padding: const EdgeInsets.all(0),
                  onPressed: Scaffold.of(context).openDrawer,
                  icon: Icon(SonaIcons.menu),
                );
              },
            )
          : null,
      actions: [actionButton],
      title: title ??
          Row(
            children: [
              SvgPicture.asset(
                height: 45,
                'assets/images/logo.svg',
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
              const SizedBox(width: 5),
              const Text(
                'Sona',
                style: TextStyle(fontSize: 45, fontWeight: FontWeight.w500),
              ),
            ],
          ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4.0),
        child: Container(
          color: Colors.white,
          height: 2.0,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

class SonaDrawer extends StatefulWidget {
  const SonaDrawer({super.key});

  @override
  State<SonaDrawer> createState() => _SonaDrawerState();
}

class _SonaDrawerState extends FullState<SonaDrawer> with UserServiceWidgetHelper {
  @override
  final userService = injector.get<UserService>();
  final authProvider = injector.get<AuthProvider>();
  late final anonymizeState = fetchState(([positionalArguments, namedArguments]) => _anonymize(positionalArguments![0]));

  @override
  void initState() {
    super.initState();
    userService.refreshCurrentUser().whenComplete(refresh);
  }

  @override
  Widget build(BuildContext context) {
    final user = userService.currentUser;

    return Drawer(
      child: Column(
        children: [
          SizedBox(
            height: 260,
            width: double.infinity,
            child: DrawerHeader(
              decoration: BoxDecoration(
                gradient: bgGradientAppBar,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildProfilePictureAvatar(radius: 50),
                  const SizedBox(height: 10),
                  Column(
                    children: [
                      Text(
                        user.fullName,
                        style: const TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      Text(
                        user.email,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: anonymizeState.isLoading
                      ? const Text('Cambiando...')
                      : user.anonymous
                          ? const Text('Desactivar anonimato')
                          : const Text('Activar anonimato'),
                  leading: Switch(
                    value: user.anonymous,
                    onChanged: anonymizeState.isLoading ? null : (value) => anonymizeState.fetch([value]),
                  ),
                ),
                ListTile(
                  title: const Text('Mi perfil'),
                  leading: Icon(SonaIcons.emptyUser),
                  onTap: () => AutoRouter.of(context).push(ProfileRoute()),
                ),
                ListTile(
                  title: const Text('Funciones'),
                  leading: Icon(Icons.view_module),
                  onTap: () => AutoRouter.of(context).push(MenuOptionsRoute()),
                ),
                ListTile(
                  title: const Text('Acerca de'),
                  leading: Icon(SonaIcons.warning),
                  onTap: () => AutoRouter.of(context).push(AboutUsRoute()),
                ),
                ListTile(
                  title: const Text('Cambiar contraseña'),
                  leading: Icon(SonaIcons.reloadPadlock),
                  onTap: () => AutoRouter.of(context).push(ChangePasswordRoute()),
                ),
                ListTile(
                  title: const Text('911'),
                  leading: Icon(SonaIcons.phone),
                  onTap: _openTel911,
                ),
                ListTile(
                  title: const Text('Cerrar sesión'),
                  leading: Icon(SonaIcons.back),
                  onTap: _showLogoutConfirmDialog,
                ),
                ListTile(
                  title: const Text('Eliminar cuenta'),
                  leading: Icon(Icons.delete_forever, color: Colors.red.shade700),
                  onTap: _showDeleteAccountDialog,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteAccountDialog() async {
    final isConfirmed = await showAlertDialog<bool>(
      context,
      title: 'Eliminar cuenta',
      message: '¿Estás seguro de que deseas eliminar tu cuenta? Esta acción es irreversible.',
      actions: {
        'Cancelar': () => Navigator.of(context).pop(false),
        'Aceptar': () => Navigator.of(context).pop(true),
      },
    );

    if (!mounted) return;

    if (isConfirmed != null && isConfirmed) {
      showLoadingDialog(context);
      try {
        await userService.deleteMyAccount();
        await authProvider.logout();
        if (mounted) AutoRouter.of(context).replaceAll([const HomeRoute()], updateExistingRoutes: false);
      } catch (error) {
        if (!mounted) return;
        showAlertDialog(context, title: 'Error', message: error.toString());
        Navigator.of(context).pop(); // Close loading dialog
      }
    }
  }

  Future<void> _openTel911() async {
    const url = 'tel:911';
    if (await canLaunchUrlString(url)) {
      launchUrlString(url);
    }
  }

  Future<void> _showLogoutConfirmDialog() async {
    final isConfirmed = await showAlertDialog<bool>(
      context,
      title: 'Cerrar sesión',
      message: '¿Estás seguro de que deseas cerrar sesión?',
      actions: {
        'Cancelar': () => Navigator.of(context).pop(false),
        'Aceptar': () => Navigator.of(context).pop(true),
      },
    );

    if (!mounted) return;

    if (isConfirmed != null && isConfirmed) {
      showLoadingDialog(context);
      await authProvider.logout();
      if (mounted) AutoRouter.of(context).replaceAll([const HomeRoute()], updateExistingRoutes: false);
    }
  }

  Future<void> _anonymize(bool value) async {
    await userService.anonymize(value);
    await userService.refreshCurrentUser();
  }
}

class SonaDrawerItem {
  final String option;
  final Widget icon;
  final VoidCallback onPressed;

  const SonaDrawerItem({
    required this.option,
    required this.icon,
    required this.onPressed,
  });
}

class SonaCardDrawer extends StatelessWidget {
  final String title;
  final List<SonaDrawerItem> items;

  const SonaCardDrawer({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 7.5),
      child: Column(
        children: [
          ListTile(
            title: Text(title, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            onTap: () {},
          ),
          Column(
            children: items.map((item) {
              return ListTile(
                title: Text(item.option),
                leading: item.icon,
                onTap: item.onPressed,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class SonaScaffold extends StatelessWidget {
  //
  final Widget actionButton;
  final bool showLeading;
  final Widget? appBarTittle;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final double padding;
  final Gradient? bgGradient;
  final bool hideBgLogo;

  const SonaScaffold({
    super.key,
    required this.actionButton,
    this.showLeading = true,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.padding = 10,
    this.appBarTittle,
    this.bgGradient,
    this.hideBgLogo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SonaAppBar(
        actionButton: actionButton,
        showLeading: showLeading,
        title: appBarTittle,
      ),
      drawer: showLeading ? const SonaDrawer() : null,
      body: Background(
        gradient: bgGradient ?? bgGradientLight,
        hideLogo: hideBgLogo,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: body,
          ),
        ),
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

class SonaActionButton extends StatelessWidget {
  //
  final String text;
  final void Function(BuildContext) onPressed;

  const SonaActionButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: RoundedButtonWidget(
        onPressed: () => onPressed(context),
        gradient: bgGradientButton2,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  factory SonaActionButton.home() {
    return SonaActionButton(
      text: 'Inicio',
      onPressed: (context) => AutoRouter.of(context).popUntil((route) => route.isFirst),
    );
  }

  factory SonaActionButton.options() {
    return SonaActionButton(
      text: 'Opciones',
      onPressed: (context) => AutoRouter.of(context).push(const MenuOptionsRoute()),
    );
  }
}
