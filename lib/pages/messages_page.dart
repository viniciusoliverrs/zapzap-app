import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatsapp_app/model/conversa_model.dart';
import 'package:whatsapp_app/model/mensagem_model.dart';
import 'package:whatsapp_app/model/usuario_model.dart';

class MessagesPage extends StatefulWidget {
  UsuarioModel contato;
  MessagesPage(this.contato);

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final _controller = StreamController<QuerySnapshot>.broadcast();
  String? _idUsuarioLogado;
  String? _idUsuarioDestinatario;
  FirebaseFirestore db = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  bool _subindoImagem = false;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _controllerMensagem = TextEditingController();
  _adicionarListenerMensagens() {
    final stream = db
        .collection("mensagens")
        .doc(_idUsuarioLogado)
        .collection(_idUsuarioDestinatario!)
        .orderBy("data", descending: false)
        .snapshots();

    stream.listen((dados) {
      _controller.add(dados);
      Timer(const Duration(seconds: 1), () {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    });
  }

  _enviarMensagem() {
    String textoMensagem = _controllerMensagem.text;
    if (textoMensagem.isNotEmpty) {
      MensagemModel mensagem = MensagemModel();
      mensagem.idUsuario = _idUsuarioLogado!;
      mensagem.mensagem = textoMensagem;
      mensagem.urlImagem = "";
      mensagem.data = Timestamp.now().toString();
      mensagem.tipo = "texto";

      _salvarMensagem(_idUsuarioLogado!, _idUsuarioDestinatario!, mensagem);
      _salvarMensagem(_idUsuarioDestinatario!, _idUsuarioLogado!, mensagem);
      _salvarConversa(mensagem);
    }
  }

  _salvarConversa(MensagemModel msg) {
    ConversaModel cRemetente = ConversaModel();
    cRemetente.idRemetente = _idUsuarioLogado!;
    cRemetente.idDestinatario = _idUsuarioDestinatario!;
    cRemetente.mensagem = msg.mensagem;
    cRemetente.nome = widget.contato.nome;
    cRemetente.caminhoFoto = widget.contato.image;
    cRemetente.tipoMensagem = msg.tipo;
    cRemetente.salvar();

    //Salvar conversa destinatario
    ConversaModel cDestinatario = ConversaModel();
    cDestinatario.idRemetente = _idUsuarioDestinatario!;
    cDestinatario.idDestinatario = _idUsuarioLogado!;
    cDestinatario.mensagem = msg.mensagem;
    cDestinatario.nome = widget.contato.nome;
    cDestinatario.caminhoFoto = widget.contato.image;
    cDestinatario.tipoMensagem = msg.tipo;
    cDestinatario.salvar();
  }

  _salvarMensagem(
      String idRemetente, String idDestinatario, MensagemModel msg) async {
    await db
        .collection("mensagens")
        .doc(idRemetente)
        .collection(idDestinatario)
        .add(msg.toMap());

    //Limpa texto
    _controllerMensagem.clear();
  }

  _enviarFoto() async {
    XFile? image = await _picker.pickImage(source: ImageSource.camera);
    _subindoImagem = true;
    String nomeImagem = DateTime.now().millisecondsSinceEpoch.toString();
    FirebaseStorage storage = FirebaseStorage.instance;
    var pastaRaiz = storage.ref();
    var arquivo = pastaRaiz
        .child("perfil")
        .child(_idUsuarioLogado!)
        .child("$nomeImagem.jpg");
    if (image == null) return;
    //Upload da imagem
    var task = await arquivo.putFile(File(image.path));
    setState(() {
      _subindoImagem = true;
    });
    _recuperarUrlImagem(task);
    //Controlar progresso do upload
  }

  Future _recuperarUrlImagem(TaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();
    MensagemModel mensagem = MensagemModel();
    mensagem.idUsuario = _idUsuarioLogado!;
    mensagem.mensagem = "";
    mensagem.urlImagem = url;
    mensagem.tipo = "imagem";
    mensagem.data = Timestamp.now().toString();
    setState(() {
      _subindoImagem = false;
    });
    _salvarMensagem(_idUsuarioLogado!, _idUsuarioDestinatario!, mensagem);
    _salvarMensagem(_idUsuarioDestinatario!, _idUsuarioLogado!, mensagem);
  }

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    var usuarioLogado = auth.currentUser;
    _idUsuarioLogado = usuarioLogado!.uid;
    _idUsuarioDestinatario = widget.contato.idUsuario;
    _adicionarListenerMensagens();
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    var caixaMensagem = Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextField(
                controller: _controllerMensagem,
                keyboardType: TextInputType.text,
                style: const TextStyle(fontSize: 20),
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(32, 8, 32, 8),
                    hintText: "Digite uma mensagem...",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32)),
                    prefixIcon: IconButton(
                        icon: const Icon(Icons.camera_alt),
                        onPressed: _enviarFoto)),
              ),
            ),
          ),
          FloatingActionButton(
            backgroundColor: const Color(0xff075E54),
            child: const Icon(
              Icons.send,
              color: Colors.white,
            ),
            mini: true,
            onPressed: _enviarMensagem,
          )
        ],
      ),
    );

    var stream = StreamBuilder(
      stream: _controller.stream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Column(
                children: const [
                  Text("Carregando mensagens"),
                  CircularProgressIndicator()
                ],
              ),
            );
          case ConnectionState.active:
          case ConnectionState.done:
            var querySnapshot = snapshot.data?.docs;

            if (snapshot.hasError) {
              return const Expanded(
                child: Text("Erro ao carregar os dados!"),
              );
            }
            return Expanded(
              child: ListView.builder(
                  controller: _scrollController,
                  itemCount: querySnapshot?.length,
                  itemBuilder: (context, indice) {
                    //recupera mensagem
                    List<DocumentSnapshot> mensagens = querySnapshot!.toList();
                    DocumentSnapshot item = mensagens[indice];

                    double larguraContainer =
                        MediaQuery.of(context).size.width * 0.8;

                    //Define cores e alinhamentos
                    Alignment alinhamento = Alignment.centerRight;
                    Color cor = const Color(0xffd2ffa5);
                    if (_idUsuarioLogado != item["idUsuario"]) {
                      alinhamento = Alignment.centerLeft;
                      cor = Colors.white;
                    }

                    return Align(
                      alignment: alinhamento,
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Container(
                          width: larguraContainer,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: cor,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8))),
                          child: item["tipo"] == "texto"
                              ? Text(
                                  item["mensagem"],
                                  style: const TextStyle(fontSize: 18),
                                )
                              : Image.network(item["urlImagem"]),
                        ),
                      ),
                    );
                  }),
            );
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
                maxRadius: 20,
                backgroundColor: Colors.grey,
                backgroundImage: widget.contato.image != null
                    ? NetworkImage(widget.contato.image)
                    : null),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(widget.contato.nome),
            )
          ],
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/bg.png"), fit: BoxFit.cover)),
        child: SafeArea(
            child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: <Widget>[
              stream,
              caixaMensagem,
            ],
          ),
        )),
      ),
    );
  }
}
