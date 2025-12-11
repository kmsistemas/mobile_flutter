import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home_screen.dart';
import '../services/api_service.dart';
import 'dart:io';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _host1Ctrl = TextEditingController();
  final _host2Ctrl = TextEditingController();
  bool _useFirst = true;
  String _version = '1.0';

  // ignore: non_constant_identifier_names
  String vgIdUsuario = '';
  // ignore: non_constant_identifier_names
  String vgToken = '';
  // ignore: non_constant_identifier_names
  String vgGrupo = '';
  // ignore: non_constant_identifier_names
  String vgVappkmind = '';
  // ignore: non_constant_identifier_names
  String vgCperocoindus = '';
  // ignore: non_constant_identifier_names
  String vgVtpappkmind = '';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _host1Ctrl.text = p.getString('HOST1') ?? '';
      _host2Ctrl.text = p.getString('HOST2') ?? '';
      _loginCtrl.text = p.getString('LOGIN') ?? '';
      _passCtrl.text = p.getString('SENHA') ?? '';
      final op = p.getString('OPCAO') ?? '1';
      _useFirst = (op == '1');
      _version = p.getString('VERSAO') ?? '1.0';

      // Preenche valores default ao rodar em debug para agilizar testes.
      if (kDebugMode) {
        _host1Ctrl.text = _host1Ctrl.text.isEmpty ? 'http://192.168.10.210:9000' : _host1Ctrl.text;
        _loginCtrl.text = _loginCtrl.text.isEmpty ? 'km' : _loginCtrl.text;
        _passCtrl.text = _passCtrl.text.isEmpty ? 'asdkm1090' : _passCtrl.text;
        _useFirst = true;
      }
    });
  }

  Future<void> _savePrefs() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('HOST1', _host1Ctrl.text);
    await p.setString('HOST2', _host2Ctrl.text);
    await p.setString('LOGIN', _loginCtrl.text);
    await p.setString('SENHA', _passCtrl.text);
    await p.setString('OPCAO', _useFirst ? '1' : '2');
  }

  Future<bool> _authenticateHost(String baseUrl) async {
    try {
      // Criar instância da ApiService com token/usuario vazios (para login)
      final apiService = ApiService(
        baseUrl: baseUrl,
        token: '',
        idUsuario: '',
      );

      // Chamar o método login centralizado
      final data = await apiService.login(
        user: _loginCtrl.text,
        password: _passCtrl.text,
      );

      // Armazenar dados da resposta
      vgIdUsuario = data['id_usuario'] ?? '';
      vgToken = data['token'] ?? '';
      vgGrupo = data['grupo'] ?? '';
      vgVappkmind = data['vappkmind'] ?? '';
      vgCperocoindus = data['cperocoindus'] ?? '';
      vgVtpappkmind = data['vtpappkmind'] ?? '';

      return true;
    } on SocketException catch (e) {
      throw Exception('Falha na conexão com o servidor: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _onLogin() async {
    if (_loginCtrl.text.isEmpty) {
      _showMessage('O Login deve ser informado !');
      return;
    }
    if (_passCtrl.text.isEmpty) {
      _showMessage('A Senha deve ser informada !');
      return;
    }

    if (_useFirst && _host1Ctrl.text.isEmpty) {
      _showMessage('O IP:PORTA devem ser informados !');
      return;
    }
    if (!_useFirst && _host2Ctrl.text.isEmpty) {
      _showMessage('O IP:PORTA devem ser informados !');
      return;
    }

    final primary = (_useFirst ? _host1Ctrl.text : _host2Ctrl.text);
    final secondary = (_useFirst ? _host2Ctrl.text : _host1Ctrl.text);
    final p1 = primary.startsWith('http') ? primary : 'http://$primary';
    final p2 = (secondary.isEmpty ? '' : (secondary.startsWith('http') ? secondary : 'http://$secondary'));

    _showLoading('Autenticando em:\n$p1');
    try {
      await _authenticateHost(p1);
      _hideLoading();
      await _savePrefs();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            idUsuario: vgIdUsuario,
            token: vgToken,
            grupo: vgGrupo,
            vappkmind: vgVappkmind,
            cperocoindus: vgCperocoindus,
            vtpappkmind: vgVtpappkmind,
            nomeUsuario: _loginCtrl.text,
            ipConectado: p1,
            versao: _version,
          ),
        ),
      );
    } catch (e) {
      _hideLoading();
      
      // Try secondary host if primary failed
      if (p2.isNotEmpty) {
        _showLoading('Autenticando em:\n$p2');
        try {
          await _authenticateHost(p2);
          _hideLoading();
          await _savePrefs();
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => HomeScreen(
                idUsuario: vgIdUsuario,
                token: vgToken,
                grupo: vgGrupo,
                vappkmind: vgVappkmind,
                cperocoindus: vgCperocoindus,
                vtpappkmind: vgVtpappkmind,
                nomeUsuario: _loginCtrl.text,
                ipConectado: p2,
                versao: _version,
              ),
            ),
          );
        } catch (e2) {
          _hideLoading();
          _showMessage('Falha em ambos servidores:\n${e2.toString()}');
        }
      } else {
        _showMessage('Erro na autenticação:\n${e.toString()}');
      }
    }
  }

  void _showMessage(String msg) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              content: Text(msg),
              actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
            ));
  }

  void _showLoading(String text) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
        // ignore: deprecated_member_use
        WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text(text),
          ]),
        ),
      ),
    );
  }

  void _hideLoading() {
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    const greenColor = Color(0xFF2DBE4A);
    const lightYellow = Color(0xFFFFFBD6);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              Center(
                child: Image.asset(
                  'assets/km_ind_1024.png',
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 120,
                    width: 120,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.local_shipping, size: 64, color: Colors.black26),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              // IP 01 Field (highlighted yellow, active)
              _buildHostField(
                label: 'IP 01',
                controller: _host1Ctrl,
                isActive: _useFirst,
                backgroundColor: _useFirst ? lightYellow : Colors.white,
              ),
              const SizedBox(height: 12),
              
              // IP 02 Field (grey/disabled)
              _buildHostField(
                label: 'IP 02',
                controller: _host2Ctrl,
                isActive: !_useFirst,
                backgroundColor: !_useFirst ? lightYellow : Colors.grey.shade100,
              ),
              const SizedBox(height: 20),
              
              // Login Field
              TextField(
                controller: _loginCtrl,
                decoration: InputDecoration(
                  labelText: 'Login',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              
              // Password Field
              TextField(
                controller: _passCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 24),
              
              // Entrar Button (green, large)
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _onLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: greenColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Entrar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Settings Icon
              Center(
                child: GestureDetector(
                  onTap: () {
                    // TODO: Open settings/configuration screen
                  },
                  child: Icon(Icons.settings, color: Colors.grey.shade400, size: 32),
                ),
              ),
              const SizedBox(height: 24),
              
              // Version and website link
              Center(
                child: Column(
                  children: [
                    Text(
                      'Versão: $_version',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () async {
                        final url = Uri.parse('http://www.kmsistemas.com.br');
                        if (await canLaunchUrl(url)) await launchUrl(url);
                      },
                      child: const Text(
                        'kmsistemas.com.br',
                        style: TextStyle(color: Color(0xFF0066CC), fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to build host field with proper styling
  Widget _buildHostField({
    required String label,
    required TextEditingController controller,
    required bool isActive,
    required Color backgroundColor,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _useFirst = (label == 'IP 01');
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? const Color(0xFFCFBF42) : Colors.grey.shade300,
            width: isActive ? 2 : 1,
          ),
        ),
        child: TextField(
          controller: controller,
          enabled: isActive,
          onTap: () {
            setState(() {
              _useFirst = (label == 'IP 01');
            });
          },
          style: TextStyle(
            color: isActive ? Colors.black : Colors.grey.shade500,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: isActive ? Colors.black87 : Colors.grey.shade400,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            suffixIcon: Icon(
              Icons.file_copy_outlined,
              color: isActive ? Colors.grey.shade600 : Colors.grey.shade300,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
