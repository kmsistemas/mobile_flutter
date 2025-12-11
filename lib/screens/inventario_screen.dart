import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'produtos_inventario_screen.dart';
import '../widgets/scanner_dialog.dart';

class InventarioItem {
  final String id;
  final String descricao;
  final String almoxarifado;
  final String database;
  InventarioItem({
    required this.id,
    required this.descricao,
    required this.almoxarifado,
    required this.database,
  });

  factory InventarioItem.fromJson(Map<String, dynamic> json) {
    return InventarioItem(
      id: (json['id'] ?? '').toString(),
      descricao: (json['descricao'] ?? '').toString(),
      almoxarifado: (json['almoxarifado'] ?? '').toString(),
      database: (json['databasepro'] ?? '').toString(),
    );
  }
}

class InventarioScreen extends StatefulWidget {
  final String baseUrl;
  final String token;
  final String idUsuario;
  const InventarioScreen({
    Key? key,
    required this.baseUrl,
    required this.token,
    required this.idUsuario,
  }) : super(key: key);

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  late final ApiService api;
  final _codigoCtrl = TextEditingController();
  bool carregando = false;
  List<InventarioItem> itens = [];

  @override
  void initState() {
    super.initState();
    api = ApiService(baseUrl: widget.baseUrl, token: widget.token, idUsuario: widget.idUsuario);
  }

  Future<void> _buscar() async {
    final codigo = _codigoCtrl.text.trim();
    if (codigo.isEmpty) {
      _msg('Informe o código do inventário');
      return;
    }
    setState(() {
      carregando = true;
      itens = [];
    });
    try {
      final resp = await api.listarInventarioIndustrial(codigo: codigo);
      final parsed = _parseInventario(resp);
      setState(() {
        itens = parsed;
        carregando = false;
      });
    } catch (e) {
      setState(() => carregando = false);
      _msg('Erro ao listar inventário:\n$e');
    }
  }

  List<InventarioItem> _parseInventario(dynamic resp) {
    if (resp is List) {
      return resp.map((e) => InventarioItem.fromJson(e as Map<String, dynamic>)).toList();
    }
    if (resp is Map<String, dynamic>) {
      if (resp['docs'] is List) {
        return (resp['docs'] as List).map((e) => InventarioItem.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [InventarioItem.fromJson(resp)];
    }
    return [];
  }

  void _msg(String m) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(m),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventário'),
        backgroundColor: const Color(0xFF2DBE4A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _codigoCtrl,
                      decoration: InputDecoration(
                        labelText: 'Código do inventário',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _codigoCtrl.clear(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: ElevatedButton(
                              onPressed: carregando ? null : _buscar,
                              child: const Text('Buscar'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                              onPressed: () async {
                                final code = await showDialog<String>(
                                  context: context,
                                  builder: (_) => const ScannerDialog(),
                                );
                                if (code != null && code.isNotEmpty) {
                                  _codigoCtrl.text = code;
                                  await _buscar();
                                }
                              },
                              child: const Text('Scanner'),
                            ),
                      ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: carregando
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: itens.length,
                    itemBuilder: (_, i) => _InventarioCard(
                      item: itens[i],
                      onOpen: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => ProdutosInventarioScreen(
                            baseUrl: widget.baseUrl,
                            token: widget.token,
                            idUsuario: widget.idUsuario,
                            inventarioId: itens[i].id,
                          ),
                        ));
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _InventarioCard extends StatelessWidget {
  final InventarioItem item;
  final VoidCallback onOpen;
  const _InventarioCard({required this.item, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(item.descricao, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Almoxarifado: ${item.almoxarifado}'),
            Text('Database: ${item.database}'),
            Text('ID: ${item.id}'),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onOpen,
      ),
    );
  }
}
