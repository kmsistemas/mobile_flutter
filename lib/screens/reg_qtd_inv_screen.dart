import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegQtdInvScreen extends StatefulWidget {
  final String baseUrl;
  final String token;
  final String idUsuario;
  final String inventarioId;
  final ProdutoReg reg;
  const RegQtdInvScreen({
    super.key,
    required this.baseUrl,
    required this.token,
    required this.idUsuario,
    required this.inventarioId,
    required this.reg,
  });

  @override
  State<RegQtdInvScreen> createState() => _RegQtdInvScreenState();
}

class ProdutoReg {
  final String idProduto;
  final String codigo;
  final String descricao;
  final String saldo;
  final String qtdReal;
  final String diferenca;
  final String descGrade;
  final String saldoGrade;
  final String realGrade;
  ProdutoReg({
    required this.idProduto,
    required this.codigo,
    required this.descricao,
    required this.saldo,
    required this.qtdReal,
    required this.diferenca,
    required this.descGrade,
    required this.saldoGrade,
    required this.realGrade,
  });
}

class _RegQtdInvScreenState extends State<RegQtdInvScreen> {
  late final ApiService api;
  final _qtdCtrl = TextEditingController();
  bool carregando = false;

  @override
  void initState() {
    super.initState();
    api = ApiService(
        baseUrl: widget.baseUrl,
        token: widget.token,
        idUsuario: widget.idUsuario);
    _qtdCtrl.text = widget.reg.qtdReal;
  }

  Future<void> _salvar() async {
    final qtd = _qtdCtrl.text.trim();
    if (qtd.isEmpty) {
      _msg('Informe a quantidade real.');
      return;
    }
    setState(() => carregando = true);
    try {
      // TODO: chamar endpoint correto de atualização de inventário (AtualizaGradesInventario/AtualizaCodBarrasInventario)
      _msg(
          'Registro ainda não integrado. Ajuste para chamar a API de inventário.');
    } catch (e) {
      _msg('Erro ao registrar quantidade: $e');
    } finally {
      setState(() => carregando = false);
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
        title: Text('Registrar Inventário ${widget.inventarioId}'),
        backgroundColor: const Color(0xFF2DBE4A),
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${widget.reg.codigo} - ${widget.reg.descricao}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Saldo: ${widget.reg.saldo}'),
                  if (widget.reg.descGrade.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(widget.reg.descGrade),
                    Text(
                        'Saldo grade: ${widget.reg.saldoGrade} | Real grade: ${widget.reg.realGrade}'),
                  ],
                  const SizedBox(height: 12),
                  TextField(
                    controller: _qtdCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Quantidade real',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _salvar,
                      child: const Text('Salvar'),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
