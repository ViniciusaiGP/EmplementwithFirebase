import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loginapp/services/firebase_methods.dart';
import 'package:loginapp/utils/app_routes.dart';
import 'package:photo_view/photo_view.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<String> imageUrls = []; // Lista de URLs de download

  @override
  void initState() {
    super.initState();
    loadImages(); // Carrega as URLs de download ao iniciar o widget
  }

  Future<void> loadImages() async {
    // Obtém as URLs de download a partir do Firestore
    final userId = await FirebaseMethods().getUserUid();
    if (userId.isNotEmpty) {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userSnapshot.exists) {
        final imagens = userSnapshot.data()?['imagens'] as List<dynamic>;
        setState(() {
          imageUrls = imagens.cast<String>().toList();
        });
      }
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    // Exclui a imagem do Firestore e do armazenamento
    final userId = await FirebaseMethods().getUserUid();
    if (userId.isNotEmpty) {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(userId);
      await userRef.update({
        'imagens': FieldValue.arrayRemove([imageUrl]),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseMethods().uploadImageToStorage();
            },
            icon: const Icon(Icons.upload),
          ),
          IconButton(
            onPressed: () {
              FirebaseMethods().logout();
              Navigator.of(context).popAndPushNamed(AppRoutes.logincad);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => loadImages(),
        child: GridView.builder(
          padding: const EdgeInsets.all(10.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
          ),
          itemCount: imageUrls.length,
          itemBuilder: (context, index) {
            final imageUrl = imageUrls[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      body: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: PhotoView(
                                imageProvider: NetworkImage(imageUrl),
                              ),
                            ),
                            FloatingActionButton(
                              child: const Icon(Icons.delete_outline),
                              onPressed: () {
                                deleteImage(imageUrl);
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            );
          },
        ),
      ),
    );
  }
}
