import 'package:feed_sx/src/views/comments/components/dropdown_options_comment.dart';
import 'package:feed_sx/src/views/comments/components/dropdown_options_reply.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:feed_sx/feed.dart';
import 'package:feed_sx/src/packages/expandable_text/expandable_text.dart';
import 'package:feed_sx/src/services/likeminds_service.dart';
import 'package:feed_sx/src/utils/constants/assets_constants.dart';
import 'package:feed_sx/src/utils/constants/ui_constants.dart';
import 'package:feed_sx/src/utils/utils.dart';
import 'package:feed_sx/src/views/comments/blocs/comment_replies/comment_replies_bloc.dart';
import 'package:feed_sx/src/views/comments/blocs/toggle_like_comment/toggle_like_comment_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ReplyTile extends StatefulWidget {
  final String postId;
  final String commentId;
  final CommentReply reply;
  final PostUser user;
  final Function() refresh;

  const ReplyTile({
    super.key,
    required this.reply,
    required this.user,
    required this.postId,
    required this.commentId,
    required this.refresh,
  });

  @override
  State<ReplyTile> createState() => _ReplyTileState();
}

class _ReplyTileState extends State<ReplyTile> {
  late final ToggleLikeCommentBloc _toggleLikeCommentBloc;
  late final CommentRepliesBloc _commentRepliesBloc;
  late final CommentReply reply;
  late final PostUser user;
  late final String postId;
  late final String commentId;
  late final Function() refresh;

  bool isLiked = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    reply = widget.reply;
    user = widget.user;
    postId = widget.postId;
    isLiked = reply.isLiked;
    commentId = widget.commentId;
    refresh = widget.refresh;
    FeedApi feedApi = locator<LikeMindsService>().getFeedApi();
    _toggleLikeCommentBloc = ToggleLikeCommentBloc(feedApi: feedApi);
    _commentRepliesBloc = CommentRepliesBloc(feedApi: feedApi);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: kWhiteColor),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.user.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              DropdownOptionsReply(
                menuItems: reply.menuItems,
                replyDetails: reply,
                postId: postId,
                commentId: widget.commentId,
                refresh: refresh,
              ),
            ],
          ),
          kVerticalPaddingSmall,
          ExpandableText(widget.reply.text,
              expandText: 'show more', collapseText: 'show less'),
          kVerticalPaddingLarge,
          Row(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isLiked = !isLiked;
                      });

                      _toggleLikeCommentBloc.add(ToggleLikeComment(
                          toggleLikeCommentRequest: ToggleLikeCommentRequest(
                        commentId: reply.id,
                        postId: postId,
                      )));
                    },
                    child: Builder(builder: ((context) {
                      return isLiked
                          ? SvgPicture.asset(
                              kAssetLikeFilledIcon,
                              // color: kPrimaryColor,
                              height: 17,
                            )
                          : SvgPicture.asset(
                              kAssetLikeIcon,
                              color: kGrey3Color,
                              height: 13,
                            );
                    })),
                  ),
                  kHorizontalPaddingSmall,
                  const Text(
                    'Like',
                    style:
                        TextStyle(fontSize: kFontSmallMed, color: kGrey3Color),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                reply.createdAt.timeAgo(),
                style: const TextStyle(
                    fontSize: kFontSmallMed, color: kGrey3Color),
              ),
            ],
          )
        ],
      ),
    );
  }
}
