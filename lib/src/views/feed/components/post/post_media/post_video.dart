import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class PostVideo extends StatefulWidget {
  final String url;
  const PostVideo({super.key, required this.url});

  @override
  State<PostVideo> createState() => _PostVideoState();
}

class _PostVideoState extends State<PostVideo>
    with AutomaticKeepAliveClientMixin {
  late final VideoPlayerController videoPlayerController;
  late ChewieController chewieController;
  @override
  void initState() {
    super.initState();
  }

  Future initialiseControllers() async {
    videoPlayerController = VideoPlayerController.network(widget.url);
    await videoPlayerController.initialize();
    chewieController = ChewieController(
      deviceOrientationsOnEnterFullScreen: [DeviceOrientation.portraitUp],
      videoPlayerController: videoPlayerController,
      autoPlay: true,
      looping: true,
      aspectRatio: 1.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
        aspectRatio: 1.0,
        child: FutureBuilder(
            future: initialiseControllers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Chewie(
                  controller: chewieController,
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            }));
  }

  @override
  bool get wantKeepAlive => true;
}
