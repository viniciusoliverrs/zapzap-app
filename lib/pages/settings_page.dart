import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  final TextEditingController _controllerNome = TextEditingController();
  String? _idUsuarioLogado;
  bool _subindoImagem = false;
  String? _urlImagemRecuperada;
  Future _recuperarImagem(String imageOrigin) async {
    XFile? image;
    switch (imageOrigin) {
      case "camera":
        image = await _picker.pickImage(source: ImageSource.camera);
        break;
      case "galeria":
        image = await _picker.pickImage(source: ImageSource.gallery);
        break;
    }
    setState(() {
      _image = File(image!.path);
      if (_image != null) {
        _subindoImagem = true;
        _uploadImagem();
      }
    });
  }

  Future _uploadImagem() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    var pastaRaiz = storage.ref();
    var arquivo = pastaRaiz.child("perfil").child("$_idUsuarioLogado.jpg");

    //Upload da imagem
    var task = await arquivo.putFile(_image!);
    setState(() {
      _subindoImagem = true;
    });
    _recuperarUrlImagem(task);
    //Controlar progresso do upload
  }

  Future _recuperarUrlImagem(TaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();
    _atualizarImagemFirestore(url);
    setState(() {
      _subindoImagem = false;
      _urlImagemRecuperada = url;
    });
  }

  _atualizarNomeFirestore() {
    String nome = _controllerNome.text;
    if (nome.isEmpty) return;
    FirebaseFirestore _db = FirebaseFirestore.instance;
    _db.collection("usuarios").doc(_idUsuarioLogado!).update({
      "nome": nome,
    });
  }

  _atualizarImagemFirestore(String url) {
    FirebaseFirestore _db = FirebaseFirestore.instance;
    _db.collection("usuarios").doc(_idUsuarioLogado!).update({
      "imagem": url,
    });
  }

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore _db = FirebaseFirestore.instance;

    User usuarioLogado = auth.currentUser!;
    _idUsuarioLogado = usuarioLogado.uid;

    var snapshot =
        await _db.collection("usuarios").doc(_idUsuarioLogado!).get();

    Map<String, dynamic>? dados = snapshot.data();
    _controllerNome.text = dados!["nome"];

    if (dados["imagem"] != null) {
      _urlImagemRecuperada = dados["imagem"];
    }
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: _subindoImagem
                      ? const CircularProgressIndicator()
                      : const SizedBox(),
                ),
                CircleAvatar(
                    radius: 100,
                    backgroundColor: Colors.grey,
                    backgroundImage: _urlImagemRecuperada != null
                        ? NetworkImage(_urlImagemRecuperada!)
                        : null),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        _recuperarImagem("camera");
                      },
                      child: const Text("Câmera"),
                    ),
                    TextButton(
                      onPressed: () {
                        _recuperarImagem("galeria");
                      },
                      child: const Text("Galeria"),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextField(
                    autofocus: true,
                    controller: _controllerNome,
                    keyboardType: TextInputType.text,
                    // onChanged: (String nome) {
                    //   _atualizarNomeFirestore(nome);
                    // },
                    style: const TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "Nome",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 10),
                  child: ElevatedButton(
                      child: const Text(
                        "Salvar",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green,
                        padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32)),
                      ),
                      onPressed: () {
                        _atualizarNomeFirestore();
                      }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
