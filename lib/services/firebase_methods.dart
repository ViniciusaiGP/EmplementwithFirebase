import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseMethods {
  Future<String> getUserUid() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User? user = _auth.currentUser;
    if (user != null) {
      print('User UID: ${user.uid}');
      return user.uid;
    } else {
      throw Exception('Usuário não está autenticado.');
    }
  }

  Future<void> register(String email, String senha) async {
    FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: senha)
        .then((value) {
      print("nova conta criada ${value.toString()}");
    }).catchError((error) {
      print('Error ${error.toString()}');
    });
  }

  Future<void> login(String email, String senha) async {
    FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: senha)
        .then((value) {
      print('conta logada');
    }).catchError((error) {
      print('Erro ${error.toString()}');
    });
  }

  Future<void> logout() async {
    FirebaseAuth.instance.signOut().then((value) {
      print('saindo');
    });
  }

  Future<void> uploadImageToStorage() async {
    final ImagePicker _picker = ImagePicker();
    final storage = FirebaseStorage.instance;

    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage == null) {
      // Nenhuma imagem selecionada
      return;
    }

    File imageFile = File(pickedImage.path);
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      TaskSnapshot snapshot =
          await storage.ref().child('images/$fileName').putFile(imageFile);
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print('Imagem enviada com sucesso. URL de download: $downloadUrl');

      String userId = await getUserUid();
      associarImagemAoUsuario(userId, downloadUrl);
    } catch (e) {
      print('Erro ao enviar a imagem: $e');
    }
  }

  void associarImagemAoUsuario(String userId, String imageUrl) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Crie uma referência para o documento do usuário no Firestore
    DocumentReference userRef = firestore.collection('users').doc(userId);

    userRef.get().then((snapshot) {
      if (snapshot.exists) {
        // O documento do usuário existe atualize os campos imagens e uid
        userRef.update({
          'imagens': FieldValue.arrayUnion([imageUrl]),
          'uid': userId,
        }).then((value) {
          print('Imagem associada ao usuário com sucesso!');
        }).catchError((error) {
          print('Erro ao associar imagem ao usuário: $error');
        });
      } else {
        // O documento do usuário não existe, então cria um com os campos imagens e uid
        userRef.set({
          'imagens': [imageUrl],
          'uid': userId,
        }).then((value) {
          print('Imagem associada ao usuário com sucesso!');
        }).catchError((error) {
          print('Erro ao associar imagem ao usuário: $error');
        });
      }
    }).catchError((error) {
      print('Erro ao verificar o documento do usuário: $error');
    });
  }

  String getCurrentUser() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print('User UID: ${user.uid}');
      return user.uid;
    } else {
      return '';
    }
  }
}
