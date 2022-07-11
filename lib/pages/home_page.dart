import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/AppRoutes.dart';
import '../screen/contatos_screen.dart';
import '../screen/conversas_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  String? _emailUsuario;
  final List<String> _itemsMenu = ['Configurações', 'Deslogar'];
  _recuperarDadosUsuario() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? usuarioLogado = auth.currentUser;

    setState(() {
      _emailUsuario = usuarioLogado?.email;
    });
  }

  @override
  void initState() {
    super.initState();
    _verificarUsuarioLogado();
    _recuperarDadosUsuario();
    _tabController = TabController(length: 2, vsync: this);
  }

  _escolhaMenuItem(String item) async {
    switch (item) {
      case 'Configurações':
        await Navigator.pushNamed(context, AppRoutes.settings);
        break;
      case 'Deslogar':
        _deslogarUsuario();
        break;
    }
  }

  _deslogarUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
    await Navigator.pushReplacementNamed(
      context,
      AppRoutes.login,
    );
  }

  _verificarUsuarioLogado() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? usuarioLogado = auth.currentUser;
    if (usuarioLogado?.uid == null) {
      await Navigator.pushReplacementNamed(
        context,
        AppRoutes.login,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("WhatsApp"),
        centerTitle: true,
        bottom: TabBar(
          indicatorColor: Colors.white,
          controller: _tabController,
          labelStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          tabs: const [
            Tab(
              child: Text("Conversas"),
            ),
            Tab(
              child: Text("Contatos"),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: _escolhaMenuItem,
            itemBuilder: (context) {
              return _itemsMenu.map((String item) {
                return PopupMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList();
            },
          )
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ConversasScreen(),
          ContatosScreen(),
        ],
      ),
    );
  }
}
