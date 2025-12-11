import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import 'passagem_screen.dart';

/// Tela de detalhes da ficha, inspirada no formulário Delphi.
class DetalheFichaScreen extends StatefulWidget {
  final PassagemData data;
  final PassagemSetor setor;
  final ApiService api;

  const DetalheFichaScreen({
    Key? key,
    required this.data,
    required this.setor,
    required this.api,
  }) : super(key: key);

  @override
  State<DetalheFichaScreen> createState() => _DetalheFichaScreenState();
}

class _DetalheFichaScreenState extends State<DetalheFichaScreen> {
  late PassagemSetor setor;
  late String dataEntrada;
  late String dataFinalizacao;
  bool carregando = false;

  @override
  void initState() {
    super.initState();
    setor = widget.setor;
    dataEntrada = setor.dataEntrada.isNotEmpty ? setor.dataEntrada : DateFormat('dd/MM/yyyy').format(DateTime.now());
    dataFinalizacao = setor.dataFinalizacao.isNotEmpty ? setor.dataFinalizacao : DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  Future<void> _registrarEntrada() async {
    if (setor.idPassagem.isEmpty) {
      _msg('ID da passagem não informado.');
      return;
    }
    final cancelar = setor.dataEntrada.isNotEmpty;
    final dtParaEnvio = _normalizeDate(cancelar ? setor.dataEntrada : dataEntrada);
    setState(() => carregando = true);
    try {
      debugPrint(
          '[detalhe_ficha] ${cancelar ? 'cancelar' : 'registrar'} entrada id_passagem=${setor.idPassagem} dt=${dtParaEnvio}');
      if (cancelar) {
        await widget.api.cancelarEntrada(
          idPassagem: setor.idPassagem,
          dataEntrada: dtParaEnvio,
        );
        _msg('Entrada cancelada com sucesso.');
        setState(() {
          setor = setor.copyWith(dataEntrada: '');
          dataEntrada = DateFormat('dd/MM/yyyy').format(DateTime.now());
        });
      } else {
        await widget.api.registrarEntrada(
          idPassagem: setor.idPassagem,
          dataEntrada: dtParaEnvio,
        );
        _msg('Entrada registrada com sucesso.');
        setState(() {
          setor = setor.copyWith(dataEntrada: dtParaEnvio);
        });
      }
    } catch (e) {
      _msg('Erro ao processar entrada:\n$e');
    } finally {
      setState(() => carregando = false);
    }
  }

  // Placeholders para futuras integrações
  void _registrarQuantidade() {
    _msg('Registrar quantidade não implementado nesta versão.');
  }

  String _normalizeDate(String value) {
    final v = value.trim();
    final m = RegExp(r'^(\\d{2})/(\\d{2})/(\\d{2})$').firstMatch(v);
    if (m != null) {
      return '${m.group(1)}/${m.group(2)}/20${m.group(3)}';
    }
    return v;
  }

  void _registrarOcorrencia() {
    _msg('Registrar ocorrência não implementado nesta versão.');
  }

  void _registrarFinalizacao() {
    _msg('Registrar finalização não implementado nesta versão.');
  }

  Future<void> _selecionarDataEntrada() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        dataEntrada = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _selecionarDataFinalizacao() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        dataFinalizacao = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _msg(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Ficha'),
        backgroundColor: const Color(0xFF2DBE4A),
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _cardCabecalho(df),
                  const SizedBox(height: 12),
                  _cardImagemQuantidade(),
                  const SizedBox(height: 12),
                  if (widget.data.grades.isNotEmpty) _cardGrades(),
                  const SizedBox(height: 12),
                  _cardSetor(),
                  const SizedBox(height: 16),
                  _cardAcoes(),
                ],
              ),
            ),
    );
  }

  Widget _cardCabecalho(DateFormat df) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.data.ficha, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(widget.data.produto),
            const SizedBox(height: 4),
            Text('Cliente: ${widget.data.cliente}'),
            const SizedBox(height: 4),
            Text('ID PCP: ${widget.data.idPcp}'),
            Text('Data produção: ${widget.data.dataProducao}'),
            Text('Data entrega: ${widget.data.dataEntrega}'),
            if (widget.data.finalizada)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Chip(label: Text('Finalizada')),
              ),
          ],
        ),
      ),
    );
  }

  Widget _cardImagemQuantidade() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Quantidades', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                _campoValor('Qtd produção', widget.data.qtdAtual.toStringAsFixed(2)),
                _campoValor('Qtd inicial', widget.data.totalPassado.toStringAsFixed(2)),
                _campoValor('Qtd atual', widget.data.saldo.toStringAsFixed(2)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardGrades() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Grades', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.data.grades
                  .map((g) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade200,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(g.grade, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('Saldo: ${g.saldo}'),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardSetor() {
    final textColor = Colors.black87;
    return Card(
      color: setor.backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(setor.setor, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                Icon(Icons.autorenew, color: textColor.withOpacity(0.8)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _campoValor('Entrada', setor.dataEntrada.isEmpty ? '--' : setor.dataEntrada, color: textColor),
                _campoValor('Finalizada', setor.dataFinalizacao.isEmpty ? '--' : setor.dataFinalizacao, color: textColor),
                _campoValor('Dias', setor.diasSetor.toString(), color: textColor),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _campoValor('P. Envio', setor.dataPrevistaEnvio.isEmpty ? '--' : setor.dataPrevistaEnvio, color: textColor),
                _campoValor('P. Retorno', setor.dataPrevistaRetorno.isEmpty ? '--' : setor.dataPrevistaRetorno, color: textColor),
              ],
            ),
            const SizedBox(height: 6),
            Text('Detalhes', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
            Text(setor.detalhes.isEmpty ? '-' : setor.detalhes, style: TextStyle(color: textColor)),
          ],
        ),
      ),
    );
  }

  Widget _cardAcoes() {
    final permite = setor.permissaoUsuario != '0';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Ações', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _secaoEntrada(permite),
            const SizedBox(height: 12),
            _secaoFinalizacao(permite),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _botaoAcao('Registrar Quantidade', Icons.playlist_add_check, permite ? _registrarQuantidade : null),
                _botaoAcao('Registrar Ocorrência', Icons.report_gmailerrorred, permite ? _registrarOcorrencia : null),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _secaoEntrada(bool permite) {
    final temEntrada = setor.dataEntrada.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Data Entrada', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: permite ? _selecionarDataEntrada : null,
                child: Text(dataEntrada),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: permite ? _registrarEntrada : null,
                child: Text(temEntrada ? 'Cancelar Entrada' : 'Confirmar'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _secaoFinalizacao(bool permite) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Data Finalização', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: permite ? _selecionarDataFinalizacao : null,
                child: Text(dataFinalizacao),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: permite ? _registrarFinalizacao : null,
                child: const Text('Confirmar'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _botaoAcao(String label, IconData icon, VoidCallback? onTap) {
    return SizedBox(
      width: 200,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label, textAlign: TextAlign.center),
      ),
    );
  }

  Widget _campoValor(String label, String valor, {Color color = Colors.black87}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          Text(valor, style: TextStyle(fontSize: 14, color: color)),
        ],
      ),
    );
  }
}
