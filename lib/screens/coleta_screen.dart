import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';

class Coleta {
  final String idColeta;
  final String os;
  final String op;
  final String unidadeProdutiva;
  final String endereco;
  final String produto;
  final String cliente;
  final String previsaoColeta;
  final String? dataColeta;
  final String? usuarioColeta;
  final String tipo; // P, I ou vazio
  final int qtdEnvio;
  final int qtdRetorno;
  final int saldo;

  Coleta({
    required this.idColeta,
    required this.os,
    required this.op,
    required this.unidadeProdutiva,
    required this.endereco,
    required this.produto,
    required this.cliente,
    required this.previsaoColeta,
    required this.dataColeta,
    required this.usuarioColeta,
    required this.tipo,
    required this.qtdEnvio,
    required this.qtdRetorno,
    required this.saldo,
  });

  factory Coleta.fromJson(Map<String, dynamic> j) {
    return Coleta(
      idColeta: (j['nnumerocltos'] ?? '').toString(),
      os: (j['nnumeroordem'] ?? '').toString(),
      op: (j['codigo_ficha'] ?? '').toString(),
      unidadeProdutiva: (j['unidade_produtiva'] ?? '').toString(),
      endereco: (j['endereco'] ?? '').toString(),
      produto: ((j['codigo_produto'] ?? '').toString().isNotEmpty
          ? '${j['codigo_produto']} - ${j['nome_produto'] ?? ''}'
          : (j['nome_produto'] ?? '').toString()),
      cliente: (j['nome_cliente'] ?? '').toString(),
      previsaoColeta: (j['data_previsao_coleta'] ?? '').toString(),
      dataColeta: (j['data_coleta'] ?? '').toString().isEmpty ? null : (j['data_coleta']).toString(),
      usuarioColeta: (j['usuario_coleta'] ?? '').toString().isEmpty ? null : (j['usuario_coleta']).toString(),
      tipo: (j['csituacltos'] ?? '').toString(),
      qtdEnvio: int.tryParse(j['qtd_envio']?.toString() ?? '') ?? 0,
      qtdRetorno: int.tryParse(j['qtd_retorno']?.toString() ?? '') ?? 0,
      saldo: int.tryParse(j['saldo']?.toString() ?? '') ?? 0,
    );
  }

  Coleta copyWith({
    String? dataColeta,
    String? usuarioColeta,
    String? tipo,
    int? saldo,
  }) {
    return Coleta(
      idColeta: idColeta,
      os: os,
      op: op,
      unidadeProdutiva: unidadeProdutiva,
      endereco: endereco,
      produto: produto,
      cliente: cliente,
      previsaoColeta: previsaoColeta,
      dataColeta: dataColeta ?? this.dataColeta,
      usuarioColeta: usuarioColeta ?? this.usuarioColeta,
      tipo: tipo ?? this.tipo,
      qtdEnvio: qtdEnvio,
      qtdRetorno: qtdRetorno,
      saldo: saldo ?? this.saldo,
    );
  }
}

class ColetaScreen extends StatefulWidget {
  final String baseUrl;
  final String token;
  final String idUsuario;
  const ColetaScreen({
    Key? key,
    required this.baseUrl,
    required this.token,
    required this.idUsuario,
  }) : super(key: key);

  @override
  State<ColetaScreen> createState() => _ColetaScreenState();
}

class _ColetaScreenState extends State<ColetaScreen> {
  late final ApiService api;
  bool filtrosVisiveis = true;
  bool emAberto = true;
  DateTime dataSelecionada = DateTime.now();
  String idUpSelecionada = '00';
  String nomeUpSelecionada = '...TODOS';
  bool carregando = false;
  List<Coleta> itens = [];
  final df = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    api = ApiService(
      baseUrl: widget.baseUrl,
      token: widget.token,
      idUsuario: widget.idUsuario,
    );
    _buscar();
  }

  Future<void> _buscar() async {
    setState(() => carregando = true);
    final dataColeta = emAberto ? '0' : df.format(dataSelecionada);
    try {
      final resp = await api.listarColeta(idUp: idUpSelecionada, dataColeta: dataColeta);
      setState(() {
        itens = resp.map((e) => Coleta.fromJson(e)).cast<Coleta>().toList();
        carregando = false;
      });
      if (filtrosVisiveis) setState(() => filtrosVisiveis = false);
    } catch (e) {
      setState(() => carregando = false);
      _showMsg('Erro ao listar coletas:\n$e');
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dataSelecionada,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => dataSelecionada = picked);
  }

  void _abrirUpPicker() async {
    try {
      final ups = await api.listarUnidadeProdutiva(idSetor: '00');
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        showDragHandle: true,
        builder: (_) => ListView(
          children: [
            ListTile(
              title: const Text('...TODOS'),
              onTap: () {
                setState(() {
                  idUpSelecionada = '00';
                  nomeUpSelecionada = '...TODOS';
                });
                Navigator.pop(context);
              },
            ),
            ...ups.map((u) {
              final id = (u['id_up'] ?? u['id']).toString();
              final nome = (u['nome_up'] ?? u['nome']).toString();
              return ListTile(
                title: Text(nome),
                onTap: () {
                  setState(() {
                    idUpSelecionada = id;
                    nomeUpSelecionada = nome;
                  });
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      );
    } catch (e) {
      _showMsg('Erro ao listar unidades:\n$e');
    }
  }

  void _registrarParcial(Coleta c) async {
    try {
      await api.registrarColeta(idColeta: c.idColeta, tipo: 'P');
      setState(() {
        itens = itens.map((it) {
          if (it.idColeta == c.idColeta) {
            return it.copyWith(
              dataColeta: df.format(DateTime.now()),
              usuarioColeta: widget.idUsuario,
              tipo: 'P',
            );
          }
          return it;
        }).toList();
      });
      _toast('Registrado como PARCIAL');
    } catch (e) {
      _showMsg('Erro ao registrar parcial:\n$e');
    }
  }

  void _registrarIntegralOuCancelar(Coleta c) async {
    final bool jaColetada = c.dataColeta != null;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(jaColetada ? 'Cancelar coleta' : 'Registrar coleta integral'),
        content: Text(jaColetada ? 'Deseja cancelar a coleta?' : 'Confirmar coleta integral?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Não')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sim')),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      // Quando já coletada, considere enviar um tipo específico se sua API exigir (ajuste se precisar)
      await api.registrarColeta(idColeta: c.idColeta, tipo: jaColetada ? 'C' : 'I');
      setState(() {
        itens = itens.map((it) {
          if (it.idColeta == c.idColeta) {
            if (jaColetada) {
              return it.copyWith(dataColeta: null, usuarioColeta: null, tipo: '');
            }
            return it.copyWith(
              dataColeta: df.format(DateTime.now()),
              usuarioColeta: widget.idUsuario,
              tipo: 'I',
            );
          }
          return it;
        }).toList();
      });
      _toast(jaColetada ? 'Coleta cancelada' : 'Registrada como INTEGRAL');
    } catch (e) {
      _showMsg('Erro ao registrar/cancelar:\n$e');
    }
  }

  void _showMsg(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(msg),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final dataTexto = df.format(dataSelecionada);
    return Scaffold(
      appBar: AppBar(
        title: const Text('COLETA'),
        backgroundColor: const Color(0xFF2DBE4A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(filtrosVisiveis ? Icons.expand_less : Icons.filter_alt),
            onPressed: () => setState(() => filtrosVisiveis = !filtrosVisiveis),
          ),
        ],
      ),
      body: Column(
        children: [
          if (filtrosVisiveis)
            _Filtros(
              unidadeSelecionada: nomeUpSelecionada,
              emAberto: emAberto,
              dataTexto: dataTexto,
              onPickDate: _pickDate,
              onPickUnidade: _abrirUpPicker,
              onToggleAberto: (v) => setState(() => emAberto = v),
              onBuscar: _buscar,
            ),
          Expanded(
            child: carregando
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _buscar,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: itens.length,
                      itemBuilder: (_, i) => _ColetaCard(
                        coleta: itens[i],
                        onParcial: _registrarParcial,
                        onIntegralOuCancelar: _registrarIntegralOuCancelar,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Filtros extends StatelessWidget {
  final String unidadeSelecionada;
  final bool emAberto;
  final String dataTexto;
  final ValueChanged<bool> onToggleAberto;
  final VoidCallback onPickDate;
  final VoidCallback onPickUnidade;
  final VoidCallback onBuscar;
  const _Filtros({
    required this.unidadeSelecionada,
    required this.emAberto,
    required this.dataTexto,
    required this.onToggleAberto,
    required this.onPickDate,
    required this.onPickUnidade,
    required this.onBuscar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.filter_list),
          title: const Text('Unidades Produtivas'),
          subtitle: Text(unidadeSelecionada),
          trailing: const Icon(Icons.chevron_right),
          onTap: onPickUnidade,
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      RadioListTile<bool>(
                        contentPadding: EdgeInsets.zero,
                        value: true,
                        groupValue: emAberto,
                        onChanged: (v) => onToggleAberto(v ?? true),
                        title: const Text('Em Aberto'),
                      ),
                      RadioListTile<bool>(
                        contentPadding: EdgeInsets.zero,
                        value: false,
                        groupValue: emAberto,
                        onChanged: (v) => onToggleAberto(v ?? false),
                        title: const Text('Coletadas em...'),
                      ),
                    ],
                  ),
                ),
                if (!emAberto)
                  ElevatedButton(
                    onPressed: onPickDate,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(120, 48)),
                    child: Text(dataTexto),
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: onBuscar,
              child: const Text('Buscar'),
            ),
          ),
        ),
      ],
    );
  }
}

class _ColetaCard extends StatelessWidget {
  final Coleta coleta;
  final ValueChanged<Coleta> onParcial;
  final ValueChanged<Coleta> onIntegralOuCancelar;
  const _ColetaCard({
    required this.coleta,
    required this.onParcial,
    required this.onIntegralOuCancelar,
  });

  @override
  Widget build(BuildContext context) {
    final coletada = coleta.dataColeta != null;
    final corFundo = coletada ? const Color(0xFFD8F5D0) : const Color(0xFFFFFBD6);
    return Card(
      color: corFundo,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _linhaTitulo('OS', coleta.os, 'Unidade Produtiva', coleta.unidadeProdutiva),
            const SizedBox(height: 6),
            _linhaLink('OP', coleta.op, () {
              // Ajuste: navegue para detalhes se houver tela
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Detalhes da OP')));
            }),
            _linhaLink('ENDEREÇO U.P.', coleta.endereco, () async {
              final uri = Uri.parse('https://maps.google.com/maps?q=${Uri.encodeComponent(coleta.endereco)}');
              if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
            }),
            const SizedBox(height: 6),
            _linhaTitulo('PRODUTO', coleta.produto, '', ''),
            _linhaTitulo('CLIENTE', coleta.cliente, '', ''),
            const SizedBox(height: 6),
            Row(
              children: [
                const Text('PREVISÃO COLETA ', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(coleta.previsaoColeta, style: const TextStyle(color: Colors.red)),
              ],
            ),
            if (coletada) ...[
              const SizedBox(height: 4),
              Text(
                'Coletado em ${coleta.dataColeta} por ${coleta.usuarioColeta ?? ''}',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                _campoValor('QTD ENVIO', coleta.qtdEnvio.toString()),
                _campoValor('QTD RETORNO', coleta.qtdRetorno.toString()),
                _campoValor('SALDO', coleta.saldo.toString()),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black87,
                    ),
                    onPressed: coletada ? null : () => onParcial(coleta),
                    child: const Text('PARCIAL'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black87,
                    ),
                    onPressed: () => onIntegralOuCancelar(coleta),
                    child: Text(coletada ? 'CANCELAR' : 'INTEGRAL'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _linhaTitulo(String labelL, String valorL, String labelR, String valorR) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _textoDuplo(labelL, valorL)),
        if (labelR.isNotEmpty) Expanded(child: _textoDuplo(labelR, valorR, corValor: Colors.green.shade700)),
      ],
    );
  }

  Widget _linhaLink(String label, String valor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: _textoDuplo(label, valor, corValor: Colors.blue),
    );
  }

  Widget _textoDuplo(String label, String valor, {Color? corValor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        Text(valor, style: TextStyle(fontSize: 14, color: corValor ?? Colors.black87, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _campoValor(String label, String valor) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          Text(valor, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
