import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:feed_sdk/feed_sdk.dart';

part 'all_comments_event.dart';
part 'all_comments_state.dart';

class AllCommentsBloc extends Bloc<AllCommentsEvent, AllCommentsState> {
  final FeedApi feedApi;
  AllCommentsBloc({required this.feedApi}) : super(AllCommentsInitial()) {
    on<AllCommentsEvent>((event, emit) async {
      if (event is GetAllComments) {
        await _mapGetAllCommentsToState(
          postDetailRequest: event.postDetailRequest,
          forLoadMore: event.forLoadMore,
          emit: emit,
        );
      }
    });
  }

  FutureOr<void> _mapGetAllCommentsToState(
      {required PostDetailRequest postDetailRequest,
      required bool forLoadMore,
      required Emitter<AllCommentsState> emit}) async {
    // if (!hasReachedMax(state, forLoadMore)) {
    Map<String, PostUser> users = {};
    if (state is AllCommentsLoaded) {
      users = (state as AllCommentsLoaded).postDetails.users;
      emit(PaginatedAllCommentsLoading(
          prevPostDetails: (state as AllCommentsLoaded).postDetails));
    } else {
      emit(AllCommentsLoading());
    }
    print("hellobook");

    PostDetailResponse? response = await feedApi.getPost(postDetailRequest);
    if (response == null) {
      emit(AllCommentsError(message: "No data found"));
    } else {
      response.users.addAll(users);
      emit(AllCommentsLoaded(
          postDetails: response,
          hasReachedMax: response.postReplies.replies.isEmpty));
    }
  }
}