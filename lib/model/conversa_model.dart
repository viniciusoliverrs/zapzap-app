import 'package:cloud_firestore/cloud_firestore.dart';

class ConversaModel {
  String? _nome;
  String? _mensagem;
  String? _caminhoFoto;
  String? _idRemetente;
  String? _idDestinatario;
  String? _tipoMensagem;

  ConversaModel();

  String get tipoMensagem => _tipoMensagem!;
  set tipoMensagem(String value) => _tipoMensagem = value;

  String get idDestinatario => _idDestinatario!;
  set idDestinatario(String value) => _idDestinatario = value;

  String get idRemetente => _idRemetente!;
  set idRemetente(String value) => _idRemetente = value;

  String get nome => _nome!;

  set nome(String value) {
    _nome = value;
  }

  String get mensagem => _mensagem!;

  String get caminhoFoto => _caminhoFoto!;

  set caminhoFoto(String value) {
    _caminhoFoto = value;
  }

  set mensagem(String value) {
    _mensagem = value;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "idRemetente": idRemetente,
      "idDestinatario": idDestinatario,
      "nome": nome,
      "mensagem": mensagem,
      "caminhoFoto": caminhoFoto,
      "tipoMensagem": tipoMensagem,
    };

    return map;
  }

  salvar() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db
        .collection("conversas")
        .doc(idRemetente)
        .collection("ultima_conversa")
        .doc(idDestinatario)
        .set(toMap());
  }
}
