import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/scanner_dialog.dart';
import 'reg_qtd_inv_screen.dart';

class ProdutoInv {
  final String id;
  final String codigo;
  final String descricao;
  final String qtdReal;
  final String qtdSaldo;
  final String diferenca;
  final String descGrade;
  final String saldoGrade;
  final String realGrade;
  final String paginaItem;

  ProdutoInv({
    required this.id,
    required this.codigo,
    required this.descricao,
    required this.qtdReal,
    required this.qtdSaldo,
    required this.diferenca,
    required this.descGrade,
    required this.saldoGrade,
    required this.realGrade,
    required this.paginaItem,
  });

  factory ProdutoInv.fromJson(Map<String, dynamic> j) {
    return ProdutoInv(
      id: (j['nnumeroprodu'] ?? '').toString(),
      codigo: (j['codigopro'] ?? '').toString(),
      descricao: (j['descricaopro'] ?? '').toString(),
      qtdReal: (j['qtdreal'] ?? '').toString(),
      qtdSaldo: (j['qtdsaldo'] ?? '').toString(),
      diferenca: (j['diferenca'] ?? '').toString(),
      descGrade: (j['desc_grade'] ?? '').toString(),
      saldoGrade: (j['saldo_grade'] ?? '').toString(),
      realGrade: (j['qtde_real_grade'] ?? '').toString(),
      paginaItem: (j['page'] ?? '').toString(),
    );
  }
}

class ProdutosInventarioScreen extends StatefulWidget {
  final String baseUrl;
  final String token;
  final String idUsuario;
  final String inventarioId;
  const ProdutosInventarioScreen({
    Key? key,
    required this.baseUrl,
    required this.token,
    required this.idUsuario,
    required this.inventarioId,
  }) : super(key: key);

  @override
  State<ProdutosInventarioScreen> createState() => _ProdutosInventarioScreenState();
}

class _ProdutosInventarioScreenState extends State<ProdutosInventarioScreen> {
  late final ApiService api;
  final _codigoCtrl = TextEditingController();
  bool carregando = false;
  List<ProdutoInv> itens = [];
  int pagina = 1;
  int totalPaginas = 1;
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    api = ApiService(baseUrl: widget.baseUrl, token: widget.token, idUsuario: widget.idUsuario);
    _scrollCtrl.addListener(_onScroll);
    _buscar(clear: true);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 100 &&
        !carregando &&
        pagina < totalPaginas) {
      _buscar(clear: false, page: pagina + 1);
    }
  }

  Future<void> _buscar({bool clear = true, int? page}) async {
    final codigoProd = _codigoCtrl.text.trim();
    setState(() => carregando = true);
    try {
      final resp = await api.listarItensInventario(
        codigoInventario: widget.inventarioId,
        codigoProduto: codigoProd,
        page: page ?? 1,
      );
      final parsed = _parseItens(resp);
      setState(() {
        if (clear) itens = [];
        itens.addAll(parsed.items);
        pagina = parsed.page;
        totalPaginas = parsed.pages;
        carregando = false;
      });
    } catch (e) {
      setState(() => carregando = false);
      _msg('Erro ao listar itens:\n$e');
    }
  }

  _ItensPage _parseItens(dynamic resp) {
    int page = 1;
    int pages = 1;
    List docs = [];
    if (resp is Map<String, dynamic>) {
      page = int.tryParse(resp['page']?.toString() ?? '') ?? page;
      pages = int.tryParse(resp['pages']?.toString() ?? '') ?? pages;
      docs = resp['docs'] is List ? (resp['docs'] as List) : [];
    } else if (resp is List) {
      docs = resp;
    }
    final items = docs.map((e) => ProdutoInv.fromJson(e as Map<String, dynamic>)).toList();
    return _ItensPage(items: items, page: page, pages: pages);
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
        title: Text('Itens do Inventário ${widget.inventarioId}'),
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
                  children: [
                    TextField(
                      controller: _codigoCtrl,
                      decoration: InputDecoration(
                        labelText: 'Filtrar por código (opcional)',
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
                              onPressed: () => _buscar(clear: true, page: 1),
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
                                  await _buscar(clear: true, page: 1);
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
            child: carregando && itens.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => _buscar(clear: true, page: 1),
                    child: ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.all(12),
                      itemCount: itens.length + (carregando ? 1 : 0),
                      itemBuilder: (_, i) {
                        if (i >= itens.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        return _ItemCard(
                          item: itens[i],
                          onRegistrar: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => RegQtdInvScreen(
                                  baseUrl: widget.baseUrl,
                                  token: widget.token,
                                  idUsuario: widget.idUsuario,
                                  inventarioId: widget.inventarioId,
                                  reg: ProdutoReg(
                                    idProduto: itens[i].id,
                                    codigo: itens[i].codigo,
                                    descricao: itens[i].descricao,
                                    saldo: itens[i].qtdSaldo,
                                    qtdReal: itens[i].qtdReal,
                                    diferenca: itens[i].diferenca,
                                    descGrade: itens[i].descGrade,
                                    saldoGrade: itens[i].saldoGrade,
                                    realGrade: itens[i].realGrade,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ItensPage {
  final List<ProdutoInv> items;
  final int page;
  final int pages;
  _ItensPage({required this.items, required this.page, required this.pages});
}

class _ItemCard extends StatelessWidget {
  final ProdutoInv item;
  final VoidCallback onRegistrar;
  const _ItemCard({required this.item, required this.onRegistrar});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${item.codigo} - ${item.descricao}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Saldo: ${item.qtdSaldo} | Real: ${item.qtdReal} | Dif: ${item.diferenca}'),
            if (item.descGrade.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(item.descGrade, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('Saldo grade: ${item.saldoGrade} | Real grade: ${item.realGrade}'),
            ],
            const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onRegistrar,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Registrar'),
            ),
          ),
          ],
        ),
      ),
    );
  }
}
