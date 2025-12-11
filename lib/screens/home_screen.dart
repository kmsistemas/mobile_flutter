import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login_screen.dart';
import 'passagem_screen.dart';
import 'os_terceiros_screen.dart';
import 'coleta_screen.dart';
import 'estoque_screen.dart';
import 'inventario_screen.dart';

class HomeScreen extends StatefulWidget {
  final String idUsuario;
  final String token;
  final String grupo;
  final String vappkmind;
  final String cperocoindus;
  final String vtpappkmind;
  final String nomeUsuario;
  final String ipConectado;
  final String versao;

  const HomeScreen({
    Key? key,
    required this.idUsuario,
    required this.token,
    required this.grupo,
    required this.vappkmind,
    required this.cperocoindus,
    required this.vtpappkmind,
    required this.nomeUsuario,
    required this.ipConectado,
    required this.versao,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<_MenuItem> _items = [
    const _MenuItem('Passagem', Icons.view_list, '/passagem'),
    const _MenuItem('OS em Terceiros', Icons.assignment, '/os'),
    const _MenuItem('Coleta', Icons.local_shipping, '/coleta'),
    const _MenuItem('Estoque', Icons.inventory_2, '/estoque'),
    const _MenuItem('Inventário', Icons.list_alt, '/inventario'),
    const _MenuItem('Sair do Aplicativo', Icons.close, '/sair'),
  ];

  void _logout() {
    // Em web ou desktop, volta para a tela de login; mobile fecha o app.
    final isDesktop = defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;

    if (kIsWeb || isDesktop) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } else {
      SystemNavigator.pop();
    }
  }

  void _onSelectItem(int index) {
    final item = _items[index];
    if (item.route == '/sair') {
      _logout();
      return;
    }
    // Navigate to the matching screen
    Widget screen;
    switch (item.route) {
      case '/passagem':
        screen = PassagemScreen(
          baseUrl: widget.ipConectado,
          token: widget.token,
          idUsuario: widget.idUsuario,
        );
        break;
      case '/os':
        screen = OsTerceirosScreen(
          baseUrl: widget.ipConectado,
          token: widget.token,
          idUsuario: widget.idUsuario,
        );
        break;
      case '/coleta':
        screen = ColetaScreen(
          baseUrl: widget.ipConectado,
          token: widget.token,
          idUsuario: widget.idUsuario,
        );
        break;
      case '/estoque':
        screen = EstoqueScreen(
          baseUrl: widget.ipConectado,
          token: widget.token,
          idUsuario: widget.idUsuario,
        );
        break;
      case '/inventario':
        screen = InventarioScreen(
          baseUrl: widget.ipConectado,
          token: widget.token,
          idUsuario: widget.idUsuario,
        );
        break;
      default:
        screen = _PlaceholderScreen(title: item.title);
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('✓ Login realizado com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KM Industrial'),
        backgroundColor: const Color(0xFF2DBE4A),
        leading: Builder(builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          );
        }),
      ),
      drawer: _buildDrawer(),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final it = _items[i];
          return ListTile(
            leading: Icon(it.icon, color: const Color(0xFF2DBE4A)),
            title: Text(it.title, style: const TextStyle(fontSize: 16)),
            onTap: () => _onSelectItem(i),
          );
        },
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: const Color(0xFF2DBE4A),
            padding: const EdgeInsets.all(16),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: Color(0xFF2DBE4A))),
                  const SizedBox(height: 12),
                  Text(
                      'Olá, ${widget.nomeUsuario.isEmpty ? 'Usuário' : widget.nomeUsuario}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text('ID: ${widget.idUsuario}',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text('Grupo: ${widget.grupo}',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text('IP: ${widget.ipConectado}',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text('Versão: ${widget.versao}',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2DBE4A)),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) =>
                            const _PlaceholderScreen(title: 'Contato')));
                  },
                  child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('Entre em contato')),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2DBE4A)),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) =>
                            const _PlaceholderScreen(title: 'Configurações')));
                  },
                  child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('Configurações')),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _logout();
                  },
                  child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('Sair do Aplicativo')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final String title;
  final IconData icon;
  final String route;
  const _MenuItem(this.title, this.icon, this.route);
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(title), backgroundColor: const Color(0xFF2DBE4A)),
      body: Center(child: Text('Tela $title - placeholder')),
    );
  }
}
