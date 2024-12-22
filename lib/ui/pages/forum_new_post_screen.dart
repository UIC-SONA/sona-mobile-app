import 'package:flutter/material.dart';
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/domain/services/post.dart';
import 'package:sona/ui/widgets/sona_scaffold.dart';

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({super.key});

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final _postService = injector.get<PostService>();

  @override
  Widget build(BuildContext context) {
    return SonaScaffold(
      actionButton: SonaActionButton.home(),
      body: const NotePad(),
    );
  }
}

class NotePad extends StatelessWidget {
  const NotePad({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        keyboardType: TextInputType.multiline,
        maxLines: null,
        decoration: InputDecoration(
          hintText: "Escribe aquí...",
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          filled: true,
          fillColor: Colors.yellow[100], // Color de fondo como un bloc de notas
        ),
        style: const TextStyle(
          fontFamily: 'Courier New',
          fontSize: 16,
          height: 1.5, // Espaciado entre líneas
        ),
      ),
    );
  }
}
