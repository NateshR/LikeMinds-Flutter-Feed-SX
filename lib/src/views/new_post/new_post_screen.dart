import 'dart:io';
import 'package:feed_sx/src/views/tagging/bloc/tagging_bloc.dart';
import 'package:feed_sx/src/views/tagging/helpers/tagging_helper.dart';
import 'package:feed_sx/src/views/tagging/tagging_textfield_ta.dart';
import 'package:feed_sx/src/widgets/loader.dart';
import 'package:feed_sx/src/widgets/profile_picture.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:feed_sx/feed.dart';
import 'package:feed_sx/src/services/likeminds_service.dart';
import 'package:feed_sx/src/utils/constants/ui_constants.dart';
import 'package:feed_sx/src/views/feed/blocs/feedroom/feedroom_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:feed_sx/src/services/service_locator.dart';
import 'package:image_picker/image_picker.dart';

List<Attachment> attachments = [];

class NewPostScreen extends StatefulWidget {
  static const String route = "/new_post_screen";
  final int feedRoomId;
  final User user;

  const NewPostScreen({
    super.key,
    required this.feedRoomId,
    required this.user,
  });

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  TextEditingController? _controller;
  final ImagePicker _picker = ImagePicker();
  bool uploaded = false;
  bool isUploading = false;
  late final User user;
  late final FeedRoomBloc feedBloc;
  late final int feedRoomId;

  List<UserTag> userTags = [];
  String? result;
  late final TaggingBloc taggingBloc;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    feedRoomId = widget.feedRoomId;
    taggingBloc = TaggingBloc()
      ..add(GetTaggingListEvent(feedroomId: feedRoomId));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        locator<NavigationService>().goBack(
          result: {
            "feedroomId": feedRoomId,
            "isBack": false,
          },
        );
        return Future(() => false);
      },
      child: Scaffold(
          backgroundColor: kWhiteColor,
          // appBar: const GeneralAppBar(
          //     autoImplyEnd: false,
          //     title: ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BackButton(
                    onPressed: () {
                      locator<NavigationService>().goBack(
                        result: {
                          "feedroomId": feedRoomId,
                          "isBack": false,
                        },
                      );
                    },
                  ),
                  const Text(
                    'Create a Post',
                    style: TextStyle(fontSize: 18, color: kGrey1Color),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (_controller != null && _controller!.text.isNotEmpty) {
                        userTags = TaggingHelper.matchTags(
                            _controller!.text, userTags);
                        result = TaggingHelper.encodeString(
                            _controller!.text, userTags);
                        final AddPostRequest request = AddPostRequest(
                          text: result!,
                          attachments: attachments,
                          feedroomId: feedRoomId,
                        );
                        final AddPostResponse response =
                            await locator<LikeMindsService>().addPost(request);
                        if (response.success) {
                          LMAnalytics.get().track(
                            AnalyticsKeys.postCreationCompleted,
                            {
                              "user_tagged": "no",
                              "link_attached": "no",
                              "image_attached": {
                                "yes": {"image_count": attachments.length},
                              },
                              "video_attached": "no",
                              "document_attached": "no",
                            },
                          );
                          locator<NavigationService>().goBack(result: {
                            "feedroomId": feedRoomId,
                            "isBack": true,
                          });
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              "The text in a post can't be empty",
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                            backgroundColor: Colors.grey.shade500,
                          ),
                        );
                      }
                    },
                    child: const Text(
                      "POST",
                      style: TextStyle(
                        color: kPrimaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(children: [
                ProfilePicture(
                    user: PostUser(
                  id: user.id,
                  imageUrl: user.imageUrl,
                  name: user.name,
                  userUniqueId: user.userUniqueId,
                  isGuest: user.isGuest,
                  isDeleted: false,
                )),
                kHorizontalPaddingLarge,
                Text(
                  user.name,
                  style: const TextStyle(
                      fontSize: kFontMedium,
                      color: kGrey1Color,
                      fontWeight: FontWeight.w500),
                ),
              ]),
              kVerticalPaddingMedium,
              TaggingAheadTextField(
                feedroomId: feedRoomId,
                isDown: true,
                onTagSelected: (tag) {
                  print(tag);
                  userTags.add(tag);
                },
                getController: ((p0) {
                  _controller = p0;
                }),
                onChange: (p0) {
                  print(p0);
                },
              ),
              Spacer(),
              if (isUploading) const Loader(),
              if (uploaded && attachments.isNotEmpty)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: kGrey2Color.withOpacity(0.2),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image:
                            NetworkImage(attachments.first.attachmentMeta.url!),
                      ),
                    ),
                  ),
                ),
              kVerticalPaddingXLarge,
              AddAssetsButton(
                leading: SvgPicture.asset(
                  'packages/feed_sx/assets/icons/add_photo.svg',
                  height: 24,
                ),
                title: const Text('Add Photo'),
                picker: _picker,
                uploading: () {
                  setState(() {
                    isUploading = true;
                  });
                },
                onUploaded: (bool uploadResponse) {
                  if (uploadResponse) {
                    setState(() {
                      uploaded = true;
                      isUploading = false;
                    });
                  } else {
                    setState(() {
                      isUploading = false;
                    });
                  }
                },
              ),
              // AddAssetsButton(
              //     leading: SvgPicture.asset(
              //         'packages/feed_sx/assets/icons/add_video.svg'),
              //     title: const Text('Add Video'),
              //     picker: _picker),
              // AddAssetsButton(
              //     leading: SvgPicture.asset(
              //         'packages/feed_sx/assets/icons/add_attachment.svg'),
              //     title: const Text('Attach Files'),
              //     picker: _picker),
            ]),
          )),
    );
  }
}

class AddAssetsButton extends StatelessWidget {
  final Widget title;
  final Widget leading;
  final ImagePicker picker;
  final Function(bool uploadResponse) onUploaded;
  final Function() uploading;

  const AddAssetsButton({
    super.key,
    required this.leading,
    required this.title,
    required this.picker,
    required this.onUploaded,
    required this.uploading,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        uploading();
        final list = await picker.pickMultiImage();
        for (final image in list) {
          try {
            File file = File.fromUri(Uri(path: image.path));
            final String? response =
                await locator<LikeMindsService>().uploadFile(file);
            if (response != null) {
              attachments.add(Attachment(
                attachmentType: 1,
                attachmentMeta: AttachmentMeta(
                  url: response,
                ),
              ));
            } else {
              throw ('Error uploading file');
            }
          } catch (e) {
            print(e);
          }
        }
        onUploaded(true);
      },
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [leading, kHorizontalPaddingLarge, title],
        ),
      ),
    );
  }
}
