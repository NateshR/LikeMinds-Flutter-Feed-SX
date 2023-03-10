import 'dart:io';

import 'package:feed_sx/src/utils/credentials/credentials.dart';
import 'package:flutter/foundation.dart';
import 'package:likeminds_feed/likeminds_feed.dart';

abstract class ILikeMindsService {
  FeedApi getFeedApi();
  Future<InitiateUserResponse> initiateUser(InitiateUserRequest request);
  Future<bool> getMemberState();
  Future<UniversalFeedResponse?> getUniversalFeed(UniversalFeedRequest request);
  Future<GetFeedRoomResponse> getFeedRoom(GetFeedRoomRequest request);
  Future<GetFeedOfFeedRoomResponse> getFeedOfFeedRoom(
      GetFeedOfFeedRoomRequest request);
  Future<AddPostResponse> addPost(AddPostRequest request);
  Future<GetPostResponse> getPost(GetPostRequest request);
  Future<GetPostLikesResponse> getPostLikes(GetPostLikesRequest request);
  Future<DeletePostResponse> deletePost(DeletePostRequest request);
  Future<LikePostResponse> likePost(LikePostRequest request);
  Future<DeleteCommentResponse> deleteComment(DeleteCommentRequest request);
  Future<String?> uploadFile(File file);
  Future<RegisterDeviceResponse> registerDevice(RegisterDeviceRequest request);
  Future<BrandingResponse> getBranding(BrandingRequest request);
  Future<TagResponseModel> getTags({int? feedroomId});
  void routeToProfile(String userId);
}

class LikeMindsService implements ILikeMindsService {
  late final SdkApplication _sdkApplication;
  late final bool isProd;

  int? feedroomId;

  set setFeedroomId(int feedroomId) {
    debugPrint("UI Layer: FeedroomId set to $feedroomId");
    this.feedroomId = feedroomId;
  }

  get getFeedroomId => feedroomId;

  LikeMindsService(LMSdkCallback sdkCallback, {this.isProd = false}) {
    print("UI Layer: LikeMindsService initialized");
    final apiKey = isProd ? CredsProd.apiKey : CredsDev.apiKey;
    _sdkApplication = LMClient.initiateLikeMinds(
      apiKey: apiKey,
      isProduction: isProd,
      sdkCallback: sdkCallback,
    );
    LMAnalytics.get().initialize();
  }

  @override
  Future<InitiateUserResponse> initiateUser(InitiateUserRequest request) async {
    return await _sdkApplication.getAuthApi().initiateUser(request);
  }

  @override
  FeedApi getFeedApi() {
    return _sdkApplication.getFeedApi();
  }

  @override
  Future<BrandingResponse> getBranding(BrandingRequest request) async {
    return await _sdkApplication.getBrandingApi().getBranding(request);
  }

  @override
  Future<UniversalFeedResponse?> getUniversalFeed(
      UniversalFeedRequest request) async {
    return await _sdkApplication.getFeedApi().getUniversalFeed(request);
  }

  @override
  Future<AddPostResponse> addPost(AddPostRequest request) async {
    return await _sdkApplication.getPostApi().addPost(request);
  }

  @override
  Future<DeletePostResponse> deletePost(DeletePostRequest request) async {
    return await _sdkApplication.getPostApi().deletePost(request);
  }

  @override
  Future<GetPostResponse> getPost(GetPostRequest request) async {
    return await _sdkApplication.getPostApi().getPost(request);
  }

  @override
  Future<GetPostLikesResponse> getPostLikes(GetPostLikesRequest request) async {
    return await _sdkApplication.getPostApi().getPostLikes(request);
  }

  @override
  Future<LikePostResponse> likePost(LikePostRequest likePostRequest) async {
    return await _sdkApplication.getPostApi().likePost(likePostRequest);
  }

  @override
  Future<DeleteCommentResponse> deleteComment(
      DeleteCommentRequest deleteCommentRequest) async {
    return await _sdkApplication
        .getFeedApi()
        .deleteComment(deleteCommentRequest);
  }

  @override
  Future<String?> uploadFile(File file) async {
    return await _sdkApplication.getMediaApi().uploadFile(file);
  }

  @override
  Future<GetFeedOfFeedRoomResponse> getFeedOfFeedRoom(
      GetFeedOfFeedRoomRequest request) async {
    return await _sdkApplication.getFeedApi().getFeedOfFeedRoom(request);
  }

  @override
  Future<GetFeedRoomResponse> getFeedRoom(GetFeedRoomRequest request) async {
    return await _sdkApplication.getFeedApi().getFeedRoom(request);
  }

  @override
  Future<bool> getMemberState() async {
    return await _sdkApplication.getAccessApi().getMemberState();
  }

  @override
  Future<RegisterDeviceResponse> registerDevice(
      RegisterDeviceRequest request) async {
    return await LMNotifications.registerDevice(request);
  }

  @override
  Future<TagResponseModel> getTags({
    int? feedroomId,
    int? page,
    int? pageSize,
    String? searchQuery,
  }) async {
    return await _sdkApplication.getHelperApi().getTags(
          feedroomId: feedroomId,
          page: page,
          pageSize: pageSize,
          searchQuery: searchQuery,
        );
  }

  @override
  void routeToProfile(String userId) {
    _sdkApplication.getHelperApi().routeProfilePage(userId);
  }
}
