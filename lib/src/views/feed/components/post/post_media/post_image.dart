import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:feed_sx/feed.dart';
import 'package:feed_sx/src/navigation/arguments.dart';
import 'package:feed_sx/src/utils/constants/ui_constants.dart';
import 'package:feed_sx/src/views/feed/components/post/post_media/post_video.dart';
import 'package:feed_sx/src/views/previews/image_preview.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed/likeminds_feed.dart';

class PostImage extends StatefulWidget {
  final String postId;
  double? height;
  final List<Attachment>? attachments;
  PostImage({
    super.key,
    this.height,
    required this.attachments,
    required this.postId,
  });

  @override
  State<PostImage> createState() => _PostImageState();
}

class _PostImageState extends State<PostImage> {
  Size? screenSize;
  int currPosition = 0; // Current index of carousel
  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    return widget.attachments!.isEmpty
        ? const SizedBox.shrink()
        : GestureDetector(
            onTap: () {
              LMAnalytics.get().track(AnalyticsKeys.clickedOnAttachment, {
                "post_id": widget.postId,
                "type": "photo",
              });

              locator<NavigationService>().navigateTo(
                ImagePreview.route,
                arguments: ImagePreviewArguments(
                  url: widget.attachments!,
                  postId: widget.postId,
                ),
              );
            },
            child: Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.only(top: kPaddingMedium),
                child: Column(children: [
                  CarouselSlider(
                    items: widget.attachments!.map((e) {
                      if (e.attachmentType == 1) {
                        return CachedNetworkImage(
                          imageUrl: e.attachmentMeta.url ?? '',
                          fit: BoxFit.cover,
                        );
                      } else if (e.attachmentType == 2) {
                        return PostVideo(url: e.attachmentMeta.url ?? '');
                      }
                      return const SizedBox();
                    }).toList(),
                    options: CarouselOptions(
                        aspectRatio: 1.0,
                        initialPage: 0,
                        disableCenter: true,
                        scrollDirection: Axis.horizontal,
                        enableInfiniteScroll: false,
                        enlargeFactor: 0.0,
                        viewportFraction: 1.0,
                        height: widget.height != null
                            ? max(widget.height! - 30, 0)
                            : screenSize!.width,
                        onPageChanged: (index, reason) {
                          setState(() {
                            currPosition = index;
                          });
                        }),
                  ),
                  widget.height != null && widget.height! < 30 ||
                          widget.attachments!.length == 1
                      ? const SizedBox()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: widget.attachments!.map((url) {
                            int index = widget.attachments!.indexOf(url);
                            return Container(
                              width:
                                  widget.height != null && widget.height! < 150
                                      ? 4.0
                                      : 8.0,
                              height:
                                  widget.height != null && widget.height! < 150
                                      ? 4.0
                                      : 8.0,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 7.0, horizontal: 2.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: currPosition == index
                                    ? const Color.fromRGBO(0, 0, 0, 0.9)
                                    : const Color.fromRGBO(0, 0, 0, 0.4),
                              ),
                            );
                          }).toList(),
                        ),
                ])),
          );
  }
}
