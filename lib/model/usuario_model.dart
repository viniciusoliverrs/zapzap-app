class UsuarioModel {
  String? _idUsuario;
  String? _nome;
  String? _email;
  String? _senha;
  String? _image;
  UsuarioModel();
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {"nome": nome, "email": email};

    return map;
  }

  String get senha => _senha!;

  set senha(String value) {
    _senha = value;
  }

  String get idUsuario => _idUsuario!;

  set idUsuario(String value) {
    _idUsuario = value;
  }

  String get email => _email!;

  set email(String value) {
    _email = value;
  }

  String get nome => _nome!;

  set nome(String value) {
    _nome = value;
  }

  String get image => _image!;

  set image(String value) {
    _image = value;
  }
}
