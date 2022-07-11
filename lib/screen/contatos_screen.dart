import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/usuario_model.dart';

class ContatosScreen extends StatefulWidget {
  const ContatosScreen({Key? key}) : super(key: key);

  @override
  State<ContatosScreen> createState() => _ContatosScreenState();
}

class _ContatosScreenState extends State<ContatosScreen> {
  String? _idUsuarioLogado;
  String? _emailUsuarioLogado;
  Future<List<UsuarioModel>> _recuperarContatos() async {
    FirebaseFirestore _db = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot = await _db.collection("usuarios").get();
    List<UsuarioModel> listaUsuarios = [];
    for (var item in querySnapshot.docs) {
      var dados = item.data() as Map<String, dynamic>;
      var usuario = UsuarioModel();
      if (dados["email"] != _emailUsuarioLogado) {
        usuario.email = dados["email"];
        usuario.nome = dados["nome"];
        usuario.image = dados["imagem"] ?? "";
        usuario.idUsuario = item.id;
        listaUsuarios.add(usuario);
      }
    }
    return listaUsuarios;
  }

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore _db = FirebaseFirestore.instance;

    User? usuarioLogado = auth.currentUser;
    _idUsuarioLogado = usuarioLogado?.uid;

    var snapshot =
        await _db.collection("usuarios").doc(_idUsuarioLogado!).get();

    Map<String, dynamic>? dados = snapshot.data();
    _emailUsuarioLogado = dados!["email"];
    _idUsuarioLogado = dados["id"];
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UsuarioModel>>(
      future: _recuperarContatos(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Column(
                children: const [
                  Text("Carregando contatos..."),
                  CircularProgressIndicator()
                ],
              ),
            );
          case ConnectionState.active:
          case ConnectionState.done:
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  UsuarioModel usuario = snapshot.data![index];
                  return ListTile(
                    onTap: () async {
                      await Navigator.pushNamed(context, "/messages",
                          arguments: usuario);
                    },
                    contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    leading: CircleAvatar(
                      maxRadius: 30,
                      backgroundColor: Colors.grey,
                      backgroundImage: usuario.image != null
                          ? NetworkImage(usuario.image)
                          : null,
                    ),
                    title: Text(usuario.nome),
                    //subtitle: Text(usuario.email),
                  );
                },
              );
            }
            return Container();
        }
      },
    );
  }
}
