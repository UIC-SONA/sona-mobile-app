import 'package:flutter/widgets.dart';
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/domain/models/models.dart';
import 'package:sona/domain/services/post.dart';
import 'package:sona/ui/widgets/sona_scaffold.dart';

class ForumPostScreen extends StatefulWidget {
  //
  final Post post;

  const ForumPostScreen({super.key, required this.post});

  @override
  State<ForumPostScreen> createState() => _ForumPostScreenState();
}

class _ForumPostScreenState extends State<ForumPostScreen> {
  //
  final _postService = injector.get<PostService>();

  @override
  Widget build(BuildContext context) {
    return SonaScaffold(
      actionButton: SonaActionButton.home(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(widget.post.content),
            // Add images here
            // Add comments here
          ],
        ),
      ),
    );
  }
}
