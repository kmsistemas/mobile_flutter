import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../widgets/scanner_dialog.dart';
import 'detalhe_ficha_screen.dart';

class PassagemData {
  final String ficha;
  final String produto;
  final String cliente;
  final String idPcp;
  final String dataEntrega;
  final String dataProducao;
  final bool finalizada;
  final String setor;
  final double qtdAtual;
  final double totalPassado;
  final List<PassagemRegistro> registros;
  final List<PassagemGrade> grades;
  final List<PassagemSetor> setores;

  double get saldo => qtdAtual - totalPassado;

  PassagemData({
    required this.ficha,
    required this.produto,
    required this.cliente,
    required this.idPcp,
    required this.dataEntrega,
    required this.dataProducao,
    required this.setor,
    required this.finalizada,
    required this.qtdAtual,
    required this.totalPassado,
    required this.registros,
    required this.grades,
    required this.setores,
  });

  factory PassagemData.fromJson(Map<String, dynamic> json) {
    double num(dynamic v) =>
        double.tryParse((v ?? '').toString().replaceAll(',', '.')) ?? 0;
    List list(dynamic v) => v is List ? v : [];
    final registros = list(json['QTDST'])
        .map((e) => PassagemRegistro.fromJson(e as Map<String, dynamic>))
        .cast<PassagemRegistro>()
        .toList();
    final grades = list(json['GRD'])
        .map((e) => PassagemGrade.fromJson(e as Map<String, dynamic>))
        .cast<PassagemGrade>()
        .toList();
    final setores = list(json['SETOR'])
        .map((e) => PassagemSetor.fromJson(e as Map<String, dynamic>))
        .cast<PassagemSetor>()
        .toList();
    return PassagemData(
      ficha: (json['codigo_ficha'] ?? '').toString(),
      produto: ((json['codigo_produto'] ?? '').toString().isNotEmpty
          ? '${json['codigo_produto']} - ${json['nome_produto'] ?? ''}'
          : (json['nome_produto'] ?? '').toString()),
      cliente: (json['nome_cliente'] ?? '').toString(),
      idPcp: (json['id_pcp'] ?? json['id_pedido'] ?? '').toString(),
      dataEntrega: (json['data_entrega'] ?? json['data_pedido'] ?? '')
          .toString(),
      dataProducao:
          (json['data_producao'] ?? json['nome_data_producao'] ?? '').toString(),
      setor: (json['setor'] ?? '').toString(),
      finalizada: (json['finalizada'] ?? '').toString() == '1',
      qtdAtual: num(json['qtde_atual'] ?? json['qtd_atual']),
      totalPassado: num(json['total_passado'] ?? json['qtde_iniciada']),
      registros: registros,
      grades: grades,
      setores: setores,
    );
  }
}

class PassagemSetor {
  final String setor;
  final String idSetor;
  final String idPassagem;
  final String dataEntrada;
  final String dataPrevistaEnvio;
  final String dataPrevistaRetorno;
  final String dataFinalizacao;
  final String detalhes;
  final int diasSetor;
  final int corR;
  final int corG;
  final int corB;
  final String permissaoUsuario;

  const PassagemSetor({
    required this.setor,
    required this.idSetor,
    required this.idPassagem,
    required this.dataEntrada,
    required this.dataPrevistaEnvio,
    required this.dataPrevistaRetorno,
    required this.dataFinalizacao,
    required this.detalhes,
    required this.diasSetor,
    required this.corR,
    required this.corG,
    required this.corB,
    required this.permissaoUsuario,
  });

  factory PassagemSetor.fromJson(Map<String, dynamic> json) {
    int _int(dynamic v) => int.tryParse((v ?? '').toString()) ?? 0;
    return PassagemSetor(
      setor: (json['setor'] ?? '').toString(),
      idSetor: (json['id_setor'] ?? '').toString(),
      idPassagem: (json['id_passagem'] ?? '').toString(),
      dataEntrada: (json['data_entrada'] ?? '').toString(),
      dataPrevistaEnvio: (json['data_prevista_envio'] ?? '').toString(),
      dataPrevistaRetorno: (json['data_prevista_retorno'] ?? '').toString(),
      dataFinalizacao: (json['data_finalizacao'] ?? '').toString(),
      detalhes: (json['detalhes'] ?? '').toString(),
      diasSetor: _int(json['dias_setor']),
      corR: _int(json['cor_r']),
      corG: _int(json['cor_g']),
      corB: _int(json['cor_b']),
      permissaoUsuario: (json['permissao_usuar'] ?? '').toString(),
    );
  }

  Color get backgroundColor =>
      Color.fromARGB(255, corR.clamp(0, 255), corG.clamp(0, 255), corB.clamp(0, 255));

  PassagemSetor copyWith({
    String? setor,
    String? idSetor,
    String? idPassagem,
    String? dataEntrada,
    String? dataPrevistaEnvio,
    String? dataPrevistaRetorno,
    String? dataFinalizacao,
    String? detalhes,
    int? diasSetor,
    int? corR,
    int? corG,
    int? corB,
    String? permissaoUsuario,
  }) {
    return PassagemSetor(
      setor: setor ?? this.setor,
      idSetor: idSetor ?? this.idSetor,
      idPassagem: idPassagem ?? this.idPassagem,
      dataEntrada: dataEntrada ?? this.dataEntrada,
      dataPrevistaEnvio: dataPrevistaEnvio ?? this.dataPrevistaEnvio,
      dataPrevistaRetorno: dataPrevistaRetorno ?? this.dataPrevistaRetorno,
      dataFinalizacao: dataFinalizacao ?? this.dataFinalizacao,
      detalhes: detalhes ?? this.detalhes,
      diasSetor: diasSetor ?? this.diasSetor,
      corR: corR ?? this.corR,
      corG: corG ?? this.corG,
      corB: corB ?? this.corB,
      permissaoUsuario: permissaoUsuario ?? this.permissaoUsuario,
    );
  }
}

class PassagemRegistro {
  final String id;
  final String unidade;
  final String idUnidade;
  final String dataRegistro;
  final String qtdPassagem;
  final String qtdPedida;
  final String usuario;
  final List<PassagemGradeRegistro> gradeDetalhes;

  PassagemRegistro({
    required this.id,
    required this.unidade,
    required this.idUnidade,
    required this.dataRegistro,
    required this.qtdPassagem,
    required this.qtdPedida,
    required this.usuario,
    required this.gradeDetalhes,
  });

  factory PassagemRegistro.fromJson(Map<String, dynamic> json) {
    List list(dynamic v) => v is List ? v : [];
    final grades = list(json['GRADE'])
        .map((e) => PassagemGradeRegistro.fromJson(e as Map<String, dynamic>))
        .cast<PassagemGradeRegistro>()
        .toList();
    return PassagemRegistro(
      id: (json['nnumeroqtdst'] ?? '').toString(),
      unidade: (json['unidade'] ?? '').toString(),
      idUnidade: (json['id_unidade'] ?? '').toString(),
      dataRegistro: (json['data_registro'] ?? '').toString(),
      qtdPassagem: (json['nqtdregqtdst'] ?? '').toString(),
      qtdPedida: (json['qtde_ped'] ?? '').toString(),
      usuario: (json['usuario'] ?? '').toString(),
      gradeDetalhes: grades,
    );
  }
}

class PassagemGradeRegistro {
  final String grade;
  final String qtd;
  PassagemGradeRegistro({required this.grade, required this.qtd});
  factory PassagemGradeRegistro.fromJson(Map<String, dynamic> json) {
    return PassagemGradeRegistro(
      grade: (json['cdescriitgra'] ?? '').toString(),
      qtd: (json['nqtdregqtdgr'] ?? '').toString(),
    );
  }
}

class PassagemGrade {
  final String id;
  final String grade;
  final String saldo;
  PassagemGrade({required this.id, required this.grade, required this.saldo});
  factory PassagemGrade.fromJson(Map<String, dynamic> json) {
    return PassagemGrade(
      id: (json['nnumerograde'] ?? '').toString(),
      grade: (json['cdescriitgra'] ?? '').toString(),
      saldo: (json['saldo'] ?? '').toString(),
    );
  }
}

class PassagemScreen extends StatefulWidget {
  final String baseUrl;
  final String token;
  final String idUsuario;
  const PassagemScreen({
    Key? key,
    required this.baseUrl,
    required this.token,
    required this.idUsuario,
  }) : super(key: key);

  @override
  State<PassagemScreen> createState() => _PassagemScreenState();
}

class _PassagemScreenState extends State<PassagemScreen> {
  late final ApiService api;
  final _controller = TextEditingController();
  final _qtdController = TextEditingController();
  bool searchById = true;
  bool loading = false;
  PassagemData? data;
  String _grupoId = '00';
  String _grupoNome = 'Selecione o Grupo Industrial';
  String _setorId = '00';
  String _setorNome = 'Selecione o Setor Industrial';
  String _idUpSelecionada = '00';
  String _nomeUpSelecionada = '...TODOS';
  List<Map<String, String>> _unidadesDaPassagem = [];
  bool filtrosVisiveis = true;

  @override
  void initState() {
    super.initState();
    api = ApiService(
        baseUrl: widget.baseUrl,
        token: widget.token,
        idUsuario: widget.idUsuario);
  }

  Future<void> _buscar() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      _msg('Informe o ${searchById ? 'ID' : 'Ficha'}');
      return;
    }
    setState(() {
      loading = true;
      data = null;
    });
    try {
      // Atualmente só temos endpoint por ID de passagem.
      final resp = await api.buscarPassagem(idPassagem: text);
      setState(() {
        data = PassagemData.fromJson(resp);
        loading = false;
        // preenche quantidade com saldo disponível
        _qtdController.text = data!.saldo.toStringAsFixed(2);
        _unidadesDaPassagem = _extractUnidades(data!);
        if (_unidadesDaPassagem.isNotEmpty) {
          _idUpSelecionada = _unidadesDaPassagem.first['id'] ?? '00';
          _nomeUpSelecionada = _unidadesDaPassagem.first['nome'] ?? '...TODOS';
        }
        if (data!.setores.isNotEmpty) {
          _setorId = data!.setores.first.idSetor;
          _setorNome = data!.setores.first.setor;
        } else if (data!.setor.isNotEmpty) {
          _setorNome = data!.setor;
        }
        filtrosVisiveis = false; // esconde filtros apÛs busca
      });
    } catch (e) {
      setState(() => loading = false);
      _msg('Erro ao buscar passagem:\n$e');
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

  Future<void> _lerCodigo() async {
    final codigo = await showScannerDialog(context);
    if (codigo != null && codigo.isNotEmpty) {
      setState(() {
        _controller.text = codigo;
      });
      await _buscar();
    }
  }

  Future<void> _consultaProdutos() async {
    _msg('Consulta por produtos ainda não implementada nesta tela.');
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd/MM/yyyy');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Passagem'),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: _FiltrosPassagem(
                grupoNome: _grupoNome,
                setorNome: _setorNome,
                onGrupoTap: _selecionarGrupo,
                onSetorTap: _selecionarSetor,
                searchById: searchById,
                onTipoChange: (v) => setState(() => searchById = v),
                controller: _controller,
                onBuscar: loading ? null : _buscar,
                onScan: loading ? null : _lerCodigo,
                onConsultaProdutos: _consultaProdutos,
              ),
            ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : data == null
                    ? const SizedBox.shrink()
                    : _ConteudoPassagem(
                        data: data!,
                        df: df,
                        onCancelar: _cancelar,
                        onRegistrar: _registrar,
                        idUpSelecionada: _idUpSelecionada,
                        nomeUpSelecionada: _nomeUpSelecionada,
                        onSelecionarUp: _selecionarUp,
                        qtdController: _qtdController,
                        onSelecionarSetor: _onSelecionarSetorDaLista,
                      ),
          ),
        ],
      ),
    );
  }

  void _onSelecionarSetorDaLista(PassagemSetor s) async {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => DetalheFichaScreen(
        data: data!,
        setor: s,
        api: api,
      ),
    ));
  }

  Future<void> _selecionarUp() async {
    // Se a passagem trouxe unidades nos registros, use-as como opções
    if (_unidadesDaPassagem.isNotEmpty) {
      await showModalBottomSheet(
        context: context,
        showDragHandle: true,
        builder: (_) => ListView(
          children: _unidadesDaPassagem.map((u) {
            return ListTile(
              title: Text(u['nome'] ?? ''),
              onTap: () {
                setState(() {
                  _idUpSelecionada = u['id'] ?? '00';
                  _nomeUpSelecionada = u['nome'] ?? '...TODOS';
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      );
      return;
    }
    try {
      final ups = await api.listarUnidadeProdutiva(idSetor: _setorId);
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
                  _idUpSelecionada = '00';
                  _nomeUpSelecionada = '...TODOS';
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
                    _idUpSelecionada = id;
                    _nomeUpSelecionada = nome;
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

  Future<void> _selecionarGrupo() async {
    try {
      final grupos = await api.listarGrupoIndustrial();
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        showDragHandle: true,
        builder: (_) => ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.filter_alt),
              title: const Text('...TODOS'),
              onTap: () {
                setState(() {
                  _grupoId = '00';
                  _grupoNome = 'Selecione o Grupo Industrial';
                  _setorId = '00';
                  _setorNome = 'Selecione o Setor Industrial';
                  _idUpSelecionada = '00';
                  _nomeUpSelecionada = '...TODOS';
                });
                Navigator.pop(context);
              },
            ),
            ...grupos.map((g) {
              final id = (g['nnumerogruin'] ?? g['id']).toString();
              final nome = (g['cdescrigruin'] ?? g['nome']).toString();
              return ListTile(
                title: Text(nome),
                onTap: () {
                  setState(() {
                    _grupoId = id;
                    _grupoNome = nome;
                    _setorId = '00';
                    _setorNome = 'Selecione o Setor Industrial';
                    _idUpSelecionada = '00';
                    _nomeUpSelecionada = '...TODOS';
                  });
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      );
    } catch (e) {
      _msg('Erro ao listar grupos:\n$e');
    }
  }

  Future<void> _selecionarSetor() async {
    if (_grupoId == '00') {
      _msg('Selecione o grupo industrial primeiro.');
      return;
    }
    try {
      final setores = await api.listarSetorIndustrial(idGrupo: _grupoId);
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        showDragHandle: true,
        builder: (_) => ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.filter_alt),
              title: const Text('...TODOS'),
              onTap: () {
                setState(() {
                  _setorId = '00';
                  _setorNome = 'Selecione o Setor Industrial';
                  _idUpSelecionada = '00';
                  _nomeUpSelecionada = '...TODOS';
                });
                Navigator.pop(context);
              },
            ),
            ...setores.map((s) {
              final id = (s['nnumerosetin'] ?? s['id']).toString();
              final nome = (s['cdescrisetin'] ?? s['nome']).toString();
              return ListTile(
                title: Text(nome),
                onTap: () {
                  setState(() {
                    _setorId = id;
                    _setorNome = nome;
                    _idUpSelecionada = '00';
                    _nomeUpSelecionada = '...TODOS';
                  });
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      );
    } catch (e) {
      _msg('Erro ao listar setores:\n$e');
    }
  }

  List<Map<String, String>> _extractUnidades(PassagemData d) {
    final set = <String>{};
    final list = <Map<String, String>>[];
    for (final r in d.registros) {
      final id = r.idUnidade;
      final nome = r.unidade;
      if (id.isNotEmpty && !set.contains(id)) {
        set.add(id);
        list.add({'id': id, 'nome': nome});
      }
    }
    return list;
  }

  Future<void> _registrar() async {
    if (data == null) return;
    final qtd = _qtdController.text.trim();
    if (qtd.isEmpty || qtd == '0') {
      _msg('Informe a quantidade.');
      return;
    }
    if (_idUpSelecionada == '00') {
      _msg('Selecione a Unidade Produtiva.');
      return;
    }
    setState(() => loading = true);
    try {
      await api.registrarPassagem(
        idPassagem: _controller.text.trim(),
        idUnidade: _idUpSelecionada,
        quantidade: qtd,
        jsonGrade: '', // se precisar grades, ajustar aqui
      );
      _msg('Passagem registrada com sucesso.');
      await _buscar();
    } catch (e) {
      setState(() => loading = false);
      _msg('Erro ao registrar passagem:\n$e');
    }
  }

  Future<void> _cancelar(String idQtdst) async {
    if (idQtdst.isEmpty) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancelar passagem'),
        content: const Text('Deseja realmente cancelar este registro?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Não')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sim')),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => loading = true);
    try {
      await api.cancelarPassagem(idQtdst: idQtdst);
      _msg('Registro cancelado com sucesso.');
      await _buscar();
    } catch (e) {
      setState(() => loading = false);
      _msg('Erro ao cancelar passagem:\n$e');
    }
  }
}

class _FiltrosPassagem extends StatelessWidget {
  final String grupoNome;
  final String setorNome;
  final VoidCallback onGrupoTap;
  final VoidCallback onSetorTap;
  final bool searchById;
  final ValueChanged<bool> onTipoChange;
  final TextEditingController controller;
  final Future<void> Function()? onBuscar;
  final Future<void> Function()? onScan;
  final Future<void> Function()? onConsultaProdutos;

  const _FiltrosPassagem({
    required this.grupoNome,
    required this.setorNome,
    required this.onGrupoTap,
    required this.onSetorTap,
    required this.searchById,
    required this.onTipoChange,
    required this.controller,
    required this.onBuscar,
    required this.onScan,
    required this.onConsultaProdutos,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tileFiltro(
            label: 'Grupo Industrial', valor: grupoNome, onTap: onGrupoTap),
        const SizedBox(height: 8),
        _tileFiltro(
            label: 'Setor Industrial', valor: setorNome, onTap: onSetorTap),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('ID da Ficha'),
                        value: true,
                        groupValue: searchById,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (v) {
                          if (v != null) onTipoChange(v);
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Ficha'),
                        value: false,
                        groupValue: searchById,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (v) {
                          if (v != null) onTipoChange(v);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    labelText:
                        searchById ? 'Digite o ID da Ficha' : 'Digite a Ficha',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: onBuscar,
                          child: const Text('Buscar'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: onScan,
                          child: const Text('Ler Código'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: onConsultaProdutos,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700),
                    child: const Text('Consulta por Produtos'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _tileFiltro(
      {required String label,
      required String valor,
      required VoidCallback onTap}) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.filter_alt, color: Colors.grey),
        title: Text(label, style: const TextStyle(fontSize: 12)),
        subtitle:
            Text(valor, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _ConteudoPassagem extends StatelessWidget {
  final PassagemData data;
  final DateFormat df;
  final void Function(String idQtdst) onCancelar;
  final VoidCallback onRegistrar;
  final String idUpSelecionada;
  final String nomeUpSelecionada;
  final VoidCallback onSelecionarUp;
  final TextEditingController qtdController;
  final void Function(PassagemSetor) onSelecionarSetor;
  const _ConteudoPassagem({
    required this.data,
    required this.df,
    required this.onCancelar,
    required this.onRegistrar,
    required this.idUpSelecionada,
    required this.nomeUpSelecionada,
    required this.onSelecionarUp,
    required this.qtdController,
    required this.onSelecionarSetor,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      children: [
        _cardHead(),
        const SizedBox(height: 12),
        _cardSetores(),
      ],
    );
  }

  Widget _cardHead() {
    return Card(
      color: data.finalizada ? const Color(0xFFE6F4EA) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ficha: ${data.ficha}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Produto: ${data.produto}',
                style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 4),
            Text('Cliente: ${data.cliente}',
                style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 4),
            Text('ID PCP: ${data.idPcp}', style: const TextStyle(fontSize: 14)),
            if (data.setor.isNotEmpty)
              Text('Setor: ${data.setor}',
                  style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 4),
            Text('Entrega: ${data.dataEntrega}',
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
            Text('Produção: ${data.dataProducao}',
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _cardResumo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Resumo',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                _campoValor('Qtd Atual', data.qtdAtual.toStringAsFixed(2)),
                _campoValor(
                    'Total Passado', data.totalPassado.toStringAsFixed(2)),
                _campoValor('Saldo', data.saldo.toStringAsFixed(2)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardSetores() {
    if (data.setores.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Text('Nenhum setor retornado.'),
        ),
      );
    }
    return Column(
      children: data.setores.map((s) {
        final bg = s.backgroundColor;
        return Card(
          color: bg,
          child: InkWell(
            onTap: () => onSelecionarSetor(s),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        s.setor,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: () => onSelecionarSetor(s),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _campoValor('Entrada', s.dataEntrada),
                      _campoValor('Finalizada', s.dataFinalizacao.isEmpty ? '--' : s.dataFinalizacao),
                      _campoValor('Dias Setor', s.diasSetor.toString()),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _campoValor('P. Envio', s.dataPrevistaEnvio.isEmpty ? '--' : s.dataPrevistaEnvio),
                      _campoValor('P. Retorno', s.dataPrevistaRetorno.isEmpty ? '--' : s.dataPrevistaRetorno),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text('Detalhes',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  Text(s.detalhes.isEmpty ? '-' : s.detalhes),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _cardGrades() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Grades (saldo)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: data.grades
                  .map((g) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade200,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(g.grade,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
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

  Widget _cardRegistros() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Registros',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...data.registros.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Unidade: ${r.unidade}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          Text(r.dataRegistro,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black54)),
                        ],
                      ),
                      Text(
                          'Qtd passagem: ${r.qtdPassagem} | Qtd pedida: ${r.qtdPedida}'),
                      Text('Usuário: ${r.usuario}',
                          style: const TextStyle(fontSize: 12)),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed:
                              r.id.isEmpty ? null : () => onCancelar(r.id),
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text('Cancelar'),
                        ),
                      ),
                      if (r.gradeDetalhes.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: r.gradeDetalhes
                              .map((g) => Chip(
                                    label: Text('${g.grade}: ${g.qtd}'),
                                    backgroundColor: Colors.grey.shade200,
                                  ))
                              .toList(),
                        )
                      ]
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _registroForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Registrar passagem',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Unidade Produtiva'),
              subtitle: Text(nomeUpSelecionada),
              trailing: const Icon(Icons.chevron_right),
              onTap: onSelecionarUp,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: qtdController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Quantidade',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: onRegistrar,
                child: const Text('Registrar'),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Observação: registro por grade não está implementado. Ajuste se precisar enviar detalhamento de grades.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _alertaRegistro(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Para registrar/estornar passagem',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        SizedBox(height: 4),
        Text(
          'Necessário mapear os IDs de unidade/passagem e grades. Ajuste a tela conforme o backend para habilitar registrar/cancelar.',
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
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
