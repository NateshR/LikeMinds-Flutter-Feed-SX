part of 'comment_replies_bloc.dart';

abstract class CommentRepliesEvent extends Equatable {
  const CommentRepliesEvent();
}

class GetCommentReplies extends CommentRepliesEvent {
  final CommentDetailRequest commentDetailRequest;
  final bool forLoadMore;
  GetCommentReplies(
      {required this.commentDetailRequest, required this.forLoadMore});

  @override
  List<Object?> get props => [commentDetailRequest, forLoadMore];
}
