import 'package:chewie/chewie.dart';
import 'package:feed_sx/src/utils/constants/ui_constants.dart';
import 'package:feed_sx/src/views/feed/components/post/post_media/post_image.dart';
import 'package:feed_sx/src/views/feed/components/post/post_media/post_video.dart';
import 'package:flutter/material.dart';

class PostMediaCarousel extends StatefulWidget {
  List<String> urls;
  final String postId;

  PostMediaCarousel({
    super.key,
    required this.urls,
    required this.postId,
  });

  @override
  State<PostMediaCarousel> createState() => _PostMediaCarouselState();
}

class _PostMediaCarouselState extends State<PostMediaCarousel> {
  late List<Widget> widgets;
  late final int itemCount;
  final PageController carouselController = PageController();

  double currPage = 0;
  @override
  void initState() {
    super.initState();
    widgets = widget.urls
        .map((e) => PostImage(
              url: e,
              postId: widget.postId,
            ))
        .toList();
    itemCount = widgets.length;
  }

  Widget _indicator(bool isActive) {
    return Container(
      height: 10,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        margin: EdgeInsets.symmetric(horizontal: 4.0),
        height: isActive ? 10 : 8.0,
        width: isActive ? 12 : 8.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? Theme.of(context).primaryColor : Color(0XFFEAEAEA),
        ),
      ),
    );
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < widgets.length; i++) {
      list.add(i == pageIndex ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  int pageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 360.0 / 296.0,
          child: PageView.builder(
              onPageChanged: (value) {
                setState(() {
                  pageIndex = value;
                });
              },
              itemCount: itemCount,
              pageSnapping: true,
              controller: carouselController,
              itemBuilder: (context, pagePosition) {
                // carouselController.
                return widgets[pagePosition];
              }),
        ),
        kVerticalPaddingLarge,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _buildPageIndicator(),
        ),
        kVerticalPaddingLarge
      ],
    );
  }
}
