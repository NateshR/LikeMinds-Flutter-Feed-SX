import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:likeminds_feed/likeminds_feed.dart';

part 'comment_replies_event.dart';
part 'comment_replies_state.dart';

class CommentRepliesBloc
    extends Bloc<CommentRepliesEvent, CommentRepliesState> {
  final FeedApi feedApi;
  CommentRepliesBloc({required this.feedApi}) : super(CommentRepliesInitial()) {
    on<CommentRepliesEvent>((event, emit) async {
      if (event is GetCommentReplies) {
        await _mapGetCommentRepliesToState(
          commentDetailRequest: event.commentDetailRequest,
          forLoadMore: event.forLoadMore,
          emit: emit,
        );
      }
    });
  }

  FutureOr<void> _mapGetCommentRepliesToState(
      {required CommentDetailRequest commentDetailRequest,
      required bool forLoadMore,
      required Emitter<CommentRepliesState> emit}) async {
    // if (!hasReachedMax(state, forLoadMore)) {
    Map<String, PostUser> users = {};
    List<CommentReply> comments = [];
    if (state is CommentRepliesLoaded && forLoadMore) {
      comments =
          (state as CommentRepliesLoaded).commentDetails.postReplies.replies;
      users = (state as CommentRepliesLoaded).commentDetails.users;
      emit(PaginatedCommentRepliesLoading(
          prevCommentDetails: (state as CommentRepliesLoaded).commentDetails));
    } else {
      emit(CommentRepliesLoading());
    }
    print("hellobook");

    CommentDetailResponse? response =
        await feedApi.getComment(commentDetailRequest);
    if (response == null) {
      emit(CommentRepliesError(message: "No data found"));
    } else {
      response.postReplies.replies.insertAll(0, comments);
      response.users.addAll(users);
      emit(CommentRepliesLoaded(
          commentDetails: response,
          hasReachedMax: response.postReplies.replies.isEmpty));
    }
  }
}
