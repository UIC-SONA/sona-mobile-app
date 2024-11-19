import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sona/application/common/auth/oauth2.dart';
import 'package:sona/application/common/auth/oauth2.dart' as oauth2;
import 'package:sona/application/widgets/full_state_widget.dart';
import 'package:sona/application/theme/backgrounds.dart';

class SonaAppBar extends StatelessWidget implements PreferredSizeWidget {
  //
  final SonaActionButton actionButton;
  final bool showLeading;

  const SonaAppBar({
    super.key,
    required this.actionButton,
    required this.showLeading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: preferredSize.height,
      leading: showLeading
          ? Builder(
              builder: (context) {
                return IconButton(
                  onPressed: Scaffold.of(context).openDrawer,
                  icon: const Icon(Icons.menu),
                );
              },
            )
          : null,
      actions: [actionButton],
      title: Row(
        children: [
          SvgPicture.asset(
            height: 45,
            'assets/images/logo.svg',
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          const SizedBox(width: 10),
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

UserInfo? _user;

class _SonaDrawerState extends FullState<SonaDrawer> {
  var _loading = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    _user = await oauth2.user();
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    var primaryColor = Theme.of(context).primaryColor;

    return Drawer(
      child: ListView(
        children: [
          SizedBox(
            height: 210,
            child: DrawerHeader(
              decoration: BoxDecoration(color: primaryColor),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 50,
                    child: Icon(Icons.person_3_rounded, size: 50, color: primaryColor),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _user?.name ?? 'Usuario',
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  Text(
                    _user?.email ?? 'Correo',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            title: const Text('Modo anónimo'),
            leading: Switch(value: false, onChanged: (value) {}),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Mi perfil'),
            leading: const Icon(Icons.person),
            onTap: () => Navigator.of(context).pushNamed('/profile'),
          ),
          ListTile(
            title: const Text('Notificaciones'),
            leading: const Icon(Icons.notifications),
            onTap: () => Navigator.of(context).pushNamed('/notifications'),
          ),
          ListTile(
            title: const Text('Acerca de'),
            leading: const Icon(Icons.info),
            onTap: () => Navigator.of(context).pushNamed('/about'),
          ),
          ListTile(
            title: const Text('Cambiar contraseña'),
            leading: const Icon(Icons.lock),
            onTap: () => Navigator.of(context).pushNamed('/change-password'),
          ),
          ListTile(
            title: const Text('Cerrar sesión'),
            leading: _loading ? const CircularProgressIndicator() : const Icon(Icons.logout),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    _loading = true;
    refresh();
    await _showLoadingDialog();
    try {
      await oauth2.logout();
      if (mounted) Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
    } finally {
      _loading = false;
      refresh();
    }
  }

  Future<void> _showLoadingDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Cerrando sesión..."),
            ],
          ),
        );
      },
    );
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
  final SonaActionButton actionButton;
  final bool showLeading;
  final Widget body;
  final Widget? floatingActionButton;

  const SonaScaffold({
    super.key,
    required this.actionButton,
    this.showLeading = true,
    required this.body,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SonaAppBar(
        actionButton: actionButton,
        showLeading: showLeading,
      ),
      drawer: showLeading ? const SonaDrawer() : null,
      body: Background(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: body,
            ),
          ),
        ),
      ),
      floatingActionButton: floatingActionButton,
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
      child: ElevatedButton(
        style: ButtonStyle(
          padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 10)),
          backgroundColor: WidgetStateProperty.all(Colors.white),
          foregroundColor: WidgetStateProperty.all(Colors.black),
        ),
        onPressed: () {
          onPressed(context);
        },
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  factory SonaActionButton.home() {
    return SonaActionButton(
      text: 'Inicio',
      onPressed: (context) => Navigator.of(context).popUntil(ModalRoute.withName('/home')),
    );
  }

  factory SonaActionButton.options() {
    return SonaActionButton(
      text: 'Opciones',
      onPressed: (context) => Navigator.of(context).pushNamed('/options'),
    );
  }
}
