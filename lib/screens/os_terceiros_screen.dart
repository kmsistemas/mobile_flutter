import 'package:flutter/material.dart';
import '../services/api_service.dart';

class OsItem {
  final String ordem;
  final String codigoFicha;
  final String idItemPedido;
  final String setor;
  final String unidadeProdutiva;
  final String produto;
  final String cliente;
  final String dataEnvio;
  final String dataRetorno;
  final num qtdEnvio;
  final num qtdRetorno;
  final num saldo;
  final num vlrUnitario;
  final num vlrEnviado;

  String get op => '$codigoFicha = $idItemPedido';

  OsItem({
    required this.ordem,
    required this.codigoFicha,
    required this.idItemPedido,
    required this.setor,
    required this.unidadeProdutiva,
    required this.produto,
    required this.cliente,
    required this.dataEnvio,
    required this.dataRetorno,
    required this.qtdEnvio,
    required this.qtdRetorno,
    required this.saldo,
    required this.vlrUnitario,
    required this.vlrEnviado,
  });

  factory OsItem.fromJson(Map<String, dynamic> j) {
    num parseNum(dynamic v) => num.tryParse((v ?? '').toString()) ?? 0;
    return OsItem(
      ordem: (j['ordem'] ?? '').toString(),
      codigoFicha: (j['codigo_ficha'] ?? '').toString(),
      idItemPedido: (j['id_item_pedido'] ?? '').toString(),
      setor: (j['setor'] ?? '').toString(),
      unidadeProdutiva: (j['unidade_produtiva'] ?? '').toString(),
      produto: ((j['codigo_produto'] ?? '').toString().isNotEmpty
          ? '${j['codigo_produto']} - ${j['nome_produto'] ?? ''}'
          : (j['nome_produto'] ?? '').toString()),
      cliente: (j['nome_cliente'] ?? '').toString(),
      dataEnvio: (j['data_envio'] ?? '').toString(),
      dataRetorno: (j['data_retorno'] ?? '').toString(),
      qtdEnvio: parseNum(j['qtd_envio']),
      qtdRetorno: parseNum(j['qtd_retorno']),
      saldo: parseNum(j['saldo']),
      vlrUnitario: parseNum(j['vlr_unitario']),
      vlrEnviado: parseNum(j['vlr_enviado']),
    );
  }
}

class OsTerceirosScreen extends StatefulWidget {
  final String baseUrl;
  final String token;
  final String idUsuario;
  const OsTerceirosScreen({
    Key? key,
    required this.baseUrl,
    required this.token,
    required this.idUsuario,
  }) : super(key: key);

  @override
  State<OsTerceirosScreen> createState() => _OsTerceirosScreenState();
}

class _OsTerceirosScreenState extends State<OsTerceirosScreen> {
  late final ApiService api;
  bool filtrosVisiveis = true;
  bool buscaPorId = true;
  String grupoId = '00';
  String grupoNome = '...TODOS';
  String setorNome = '...TODOS';
  String setorId = '00';
  String upId = '00';
  String upNome = '...TODOS';
  final _buscaCtrl = TextEditingController();
  bool carregando = false;
  List<OsItem> itens = [];

  @override
  void initState() {
    super.initState();
    api = ApiService(
        baseUrl: widget.baseUrl,
        token: widget.token,
        idUsuario: widget.idUsuario);
  }

  Future<void> _buscar() async {
    setState(() => carregando = true);
    try {
      final setorParam = (setorNome == '...TODOS') ? '00' : setorNome;
      final resp = await api.listarOS(
        setor: setorParam,
        idUp: upId,
        idFicha: buscaPorId ? _buscaCtrl.text.trim() : '',
        codFicha: buscaPorId ? '' : _buscaCtrl.text.trim(),
      );
      setState(() {
        itens = resp
            .map((e) => OsItem.fromJson(e as Map<String, dynamic>))
            .toList();
        carregando = false;
        if (filtrosVisiveis) filtrosVisiveis = false;
      });
    } catch (e) {
      setState(() => carregando = false);
      _msg('Erro ao listar OS:\n$e');
    }
  }

  Future<void> _selecionarGrupo() async {
    try {
      final grupos = await api.listarGrupoIndustrial();
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        showDragHandle: true,
        builder: (_) => ListView(
          children: grupos.map<Widget>((g) {
            final id = (g['nnumerogruin'] ?? g['id_grupo'] ?? g['id']).toString();
            final nome = (g['cdescrigruin'] ?? g['nome_grupo'] ?? g['nome']).toString();
            return ListTile(
              title: Text(nome),
              onTap: () {
                setState(() {
                  grupoId = id;
                  grupoNome = nome;
                  setorId = '00';
                  setorNome = '...TODOS';
                  upId = '00';
                  upNome = '...TODOS';
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      );
    } catch (e) {
      _msg('Erro ao listar grupos:\n$e');
    }
  }

  Future<void> _selecionarSetor() async {
    if (grupoId == '00' || grupoId.isEmpty) {
      _msg('Selecione o Grupo Industrial primeiro.');
      return;
    }
    try {
      final setores = await api.listarSetorIndustrial(idGrupo: grupoId);
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        showDragHandle: true,
        builder: (_) => ListView(
          children: setores.map<Widget>((s) {
            final id = (s['id_setor'] ?? s['id']).toString();
            final nome = (s['nome_setor'] ?? s['nome']).toString();
            return ListTile(
              title: Text(nome),
              onTap: () {
                setState(() {
                  setorId = id;
                  setorNome = nome;
                  upId = '00';
                  upNome = '...TODOS';
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      );
    } catch (e) {
      _msg('Erro ao listar setores:\n$e');
    }
  }

  Future<void> _selecionarUp() async {
    try {
      final ups = await api.listarUnidadeProdutiva(idSetor: setorId);
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
                  upId = '00';
                  upNome = '...TODOS';
                });
                Navigator.pop(context);
              },
            ),
            ...ups.map<Widget>((u) {
              final id = (u['id_up'] ?? u['id']).toString();
              final nome = (u['nome_up'] ?? u['nome']).toString();
              return ListTile(
                title: Text(nome),
                onTap: () {
                  setState(() {
                    upId = id;
                    upNome = nome;
                  });
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      );
    } catch (e) {
      _msg('Erro ao listar unidades:\n$e');
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
        title: const Text('OS em Terceiros'),
        backgroundColor: const Color(0xFF2DBE4A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(filtrosVisiveis ? Icons.expand_less : Icons.filter_alt),
            onPressed: () => setState(() => filtrosVisiveis = !filtrosVisiveis),
          )
        ],
      ),
      body: Column(
        children: [
          if (filtrosVisiveis)
            _Filtros(
              buscaPorId: buscaPorId,
              grupoNome: grupoNome,
              setorNome: setorNome,
              upNome: upNome,
              onToggleId: (v) => setState(() => buscaPorId = v),
              onGrupo: _selecionarGrupo,
              onSetor: _selecionarSetor,
              onUp: _selecionarUp,
              controller: _buscaCtrl,
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
                      itemBuilder: (_, i) => _OsCard(item: itens[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Filtros extends StatelessWidget {
  final bool buscaPorId;
  final String grupoNome;
  final String setorNome;
  final String upNome;
  final ValueChanged<bool> onToggleId;
  final VoidCallback onGrupo;
  final VoidCallback onSetor;
  final VoidCallback onUp;
  final TextEditingController controller;
  final VoidCallback onBuscar;
  const _Filtros({
    required this.buscaPorId,
    required this.grupoNome,
    required this.setorNome,
    required this.upNome,
    required this.onToggleId,
    required this.onGrupo,
    required this.onSetor,
    required this.onUp,
    required this.controller,
    required this.onBuscar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: const Text('Grupo Industrial'),
          subtitle: Text(grupoNome),
          trailing: const Icon(Icons.chevron_right),
          onTap: onGrupo,
        ),
        ListTile(
          title: const Text('Setor Industrial'),
          subtitle: Text(setorNome),
          trailing: const Icon(Icons.chevron_right),
          onTap: onSetor,
        ),
        ListTile(
          title: const Text('Unidade Produtiva'),
          subtitle: Text(upNome),
          trailing: const Icon(Icons.chevron_right),
          onTap: onUp,
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Por ID'),
                        value: true,
                        groupValue: buscaPorId,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (v) => onToggleId(true),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Por Ficha'),
                        value: false,
                        groupValue: buscaPorId,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (v) => onToggleId(false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: buscaPorId ? 'Digite o ID' : 'Digite a Ficha',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => controller.clear(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                      onPressed: onBuscar, child: const Text('Buscar')),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OsCard extends StatelessWidget {
  final OsItem item;
  const _OsCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('OS ${item.ordem}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('OP: ${item.op}', style: const TextStyle(color: Colors.blue)),
            const SizedBox(height: 6),
            _row('Setor', item.setor,
                rightLabel: 'Unidade Produtiva',
                rightValue: item.unidadeProdutiva),
            const SizedBox(height: 6),
            _row('Produto', item.produto,
                rightLabel: 'Cliente', rightValue: item.cliente),
            const SizedBox(height: 6),
            _row('Envio', item.dataEnvio,
                rightLabel: 'Retorno', rightValue: item.dataRetorno),
            const SizedBox(height: 8),
            Row(
              children: [
                _campoValor('Qtd Envio', item.qtdEnvio.toString()),
                _campoValor('Qtd Retorno', item.qtdRetorno.toString()),
                _campoValor('Saldo', item.saldo.toString()),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _campoValor('Vlr Unit', item.vlrUnitario.toStringAsFixed(2)),
                _campoValor('Vlr Enviado', item.vlrEnviado.toStringAsFixed(2)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String l1, String v1,
      {String rightLabel = '', String rightValue = ''}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _textoDuplo(l1, v1)),
        if (rightLabel.isNotEmpty)
          Expanded(child: _textoDuplo(rightLabel, rightValue)),
      ],
    );
  }

  Widget _textoDuplo(String label, String valor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        Text(valor,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ],
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
