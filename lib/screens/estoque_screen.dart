import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EstoqueProduto {
  final String codigo;
  final String produto;
  final String idProduto;
  final String saldoTotal;
  final String reservadoTotal;
  final List<Almox> almoxes;

  EstoqueProduto({
    required this.codigo,
    required this.produto,
    required this.idProduto,
    required this.saldoTotal,
    required this.reservadoTotal,
    required this.almoxes,
  });

  factory EstoqueProduto.fromJson(Map<String, dynamic> json) {
    List list(dynamic v) => v is List ? v : [];
    final almox = list(json['ALMOXARIFADOS'])
        .map((e) => Almox.fromJson(e as Map<String, dynamic>))
        .toList();
    return EstoqueProduto(
      codigo: (json['codigo'] ?? '').toString(),
      produto: (json['produto'] ?? '').toString(),
      idProduto: (json['nnumeroprodu'] ?? '').toString(),
      saldoTotal: (json['qtd_saldo_total'] ?? '').toString(),
      reservadoTotal: (json['disponiveltotal'] ?? '').toString(),
      almoxes: almox,
    );
  }
}

class Almox {
  final String nome;
  final String saldo;
  final String disponivel;
  final List<GradeEstoque> grades;
  final List<LoteEstoque> lotes;

  Almox({
    required this.nome,
    required this.saldo,
    required this.disponivel,
    required this.grades,
    required this.lotes,
  });

  factory Almox.fromJson(Map<String, dynamic> json) {
    List list(dynamic v) => v is List ? v : [];
    final grades = list(json['GRADES'])
        .map((e) => GradeEstoque.fromJson(e as Map<String, dynamic>))
        .toList();
    final lotes = list(json['LOTES'])
        .map((e) => LoteEstoque.fromJson(e as Map<String, dynamic>))
        .toList();
    return Almox(
      nome: (json['almoxarifado'] ?? '').toString(),
      saldo: (json['saldo_dia'] ?? '').toString(),
      disponivel: (json['disponivel'] ?? '').toString(),
      grades: grades,
      lotes: lotes,
    );
  }
}

class GradeEstoque {
  final String grade;
  final String saldo;
  final String disponivel;
  GradeEstoque({
    required this.grade,
    required this.saldo,
    required this.disponivel,
  });
  factory GradeEstoque.fromJson(Map<String, dynamic> json) {
    return GradeEstoque(
      grade: (json['cdescriitgra'] ?? '').toString(),
      saldo: (json['saldo_dia'] ?? '').toString(),
      disponivel: (json['disponivel'] ?? '').toString(),
    );
  }
}

class LoteEstoque {
  final String lote;
  final String saldo;
  final String validade;
  final String saldoTotal;
  LoteEstoque({
    required this.lote,
    required this.saldo,
    required this.validade,
    required this.saldoTotal,
  });
  factory LoteEstoque.fromJson(Map<String, dynamic> json) {
    return LoteEstoque(
      lote: (json['lote'] ?? '').toString(),
      saldo: (json['saldo'] ?? '').toString(),
      validade: (json['datavalidade'] ?? '').toString(),
      saldoTotal: (json['saldo_total'] ?? '').toString(),
    );
  }
}

class EstoqueScreen extends StatefulWidget {
  final String baseUrl;
  final String token;
  final String idUsuario;
  const EstoqueScreen({
    Key? key,
    required this.baseUrl,
    required this.token,
    required this.idUsuario,
  }) : super(key: key);

  @override
  State<EstoqueScreen> createState() => _EstoqueScreenState();
}

class _EstoqueScreenState extends State<EstoqueScreen> {
  late final ApiService api;
  final _codigoCtrl = TextEditingController();
  bool carregando = false;
  EstoqueProduto? produto;

  @override
  void initState() {
    super.initState();
    api = ApiService(
        baseUrl: widget.baseUrl,
        token: widget.token,
        idUsuario: widget.idUsuario);
  }

  Future<void> _buscar() async {
    final codigo = _codigoCtrl.text.trim();
    if (codigo.isEmpty) {
      _msg('Informe o código do produto');
      return;
    }
    setState(() {
      carregando = true;
      produto = null;
    });
    try {
      final resp = await api.listarEstoque(codigo: codigo);
      setState(() {
        produto = EstoqueProduto.fromJson(resp);
        carregando = false;
      });
    } catch (e) {
      setState(() => carregando = false);
      _msg('Erro ao consultar estoque:\n$e');
    }
  }

  void _msg(String m) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(m),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estoque'),
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
                        labelText: 'Código ou Código de barras',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _codigoCtrl.clear(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: carregando ? null : _buscar,
                        child: const Text('Buscar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: carregando
                ? const Center(child: CircularProgressIndicator())
                : produto == null
                    ? const SizedBox.shrink()
                    : ListView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        children: [
                          _cardHead(produto!),
                          const SizedBox(height: 12),
                          ...produto!.almoxes.map(_cardAlmox),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _cardHead(EstoqueProduto p) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${p.codigo} - ${p.produto}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('ID: ${p.idProduto}'),
            const SizedBox(height: 6),
            Row(
              children: [
                _campoValor('Saldo total', p.saldoTotal),
                _campoValor('Disponível total', p.reservadoTotal),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardAlmox(Almox a) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(a.nome,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Row(
              children: [
                _campoValor('Saldo', a.saldo),
                _campoValor('Disponível', a.disponivel),
              ],
            ),
            if (a.grades.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Grades',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: a.grades
                    .map((g) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(g.grade,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text('Saldo: ${g.saldo}'),
                              Text('Disp.: ${g.disponivel}'),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ],
            if (a.lotes.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Lotes',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              ...a.lotes.map((l) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Lote: ${l.lote}'),
                    subtitle:
                        Text('Saldo: ${l.saldo} | Validade: ${l.validade}'),
                    trailing: Text(l.saldoTotal),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _campoValor(String label, String valor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          Text(valor, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
