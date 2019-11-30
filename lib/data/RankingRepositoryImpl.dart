
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:rxdart/rxdart.dart';
import 'package:todo_app/domain/entity/RankingUserInfo.dart';
import 'package:todo_app/domain/entity/RankingUserInfosEvent.dart';
import 'package:todo_app/domain/repository/RankingRepository.dart';

class RankingRepositoryImpl implements RankingRepository {
  static const FIRESTORE_RANKING_USER_INFO_COLLECTION = 'ranking_user_info';
  static const RANKING_PAGING_SIZE = 2;

  StreamSubscription _rankingUserInfosSubscription;
  int _currentRankingMaxCount = RANKING_PAGING_SIZE;

  final _rankingUserInfosEventSubject = BehaviorSubject<RankingUserInfosEvent>();

  RankingRepositoryImpl() {
    _rankingUserInfosEventSubject.onCancel = () {
      _rankingUserInfosSubscription?.cancel();
    };
  }

  @override
  Future<RankingUserInfo> getRankingUserInfo(String uid) async {
    final snapshot = await Firestore.instance
      .collection(FIRESTORE_RANKING_USER_INFO_COLLECTION)
      .document(uid)
      .get();
    if (snapshot == null) {
      return RankingUserInfo.INVALID;
    } else {
      return RankingUserInfo.fromMap(snapshot.data);
    }
  }

  @override
  Future<void> setMyRankingUserInfo(RankingUserInfo info) {
    final callable = CloudFunctions.instance.getHttpsCallable(functionName: 'setRankingUserInfo');
    return callable.call(info.toMyRankingUserInfoUpdateMap()).timeout(const Duration(seconds: 10));
  }

  @override
  Stream<RankingUserInfosEvent> observeRankingUserInfosEvent() {
    return _rankingUserInfosEventSubject.distinct();
  }

  @override
  void initRankingUserInfosCount() {
    _setRankingUserInfosMaxCount(RANKING_PAGING_SIZE);
  }

  void _setRankingUserInfosMaxCount(int maxCount) {
    _rankingUserInfosSubscription?.cancel();
    _rankingUserInfosSubscription = Firestore.instance
      .collection(FIRESTORE_RANKING_USER_INFO_COLLECTION)
      .orderBy(RankingUserInfo.KEY_COMPLETION_RATIO, descending: true)
      .orderBy(RankingUserInfo.KEY_NAME)
      .limit(maxCount)
      .snapshots()
      .listen((querySnapshot) {
      // todo: use documentChanges instead of documents
      final snapshots = querySnapshot.documents;

      int rank = 0;
      double prevCompletionRatio;

      final infos = snapshots.map((snapshot) {
        final userInfo = RankingUserInfo.fromMap(snapshot.data);

        if (prevCompletionRatio == null) {
          rank += 1;
          prevCompletionRatio = userInfo.completionRatio;
        } else {
          if (userInfo.completionRatio != prevCompletionRatio) {
            rank += 1;
            prevCompletionRatio = userInfo.completionRatio;
          }
        }

        return userInfo.buildNew(rank: rank);
      }).toList();
      final hasMore = snapshots.length == maxCount;
      final event =  RankingUserInfosEvent(
        rankingUserInfos: infos,
        hasMore: hasMore,
      );
      _rankingUserInfosEventSubject.add(event);
    });

    _currentRankingMaxCount = maxCount;
  }

  @override
  void increaseRankingUserInfosCount() {
    _setRankingUserInfosMaxCount(_currentRankingMaxCount + RANKING_PAGING_SIZE);
  }

  @override
  Future<void> deleteRankingUserInfo(String uid) {
    return Firestore.instance
      .collection(FIRESTORE_RANKING_USER_INFO_COLLECTION)
      .document(uid)
      .delete();
  }

  @override
  void increaseThumbsUp(RankingUserInfo info) {
    final increasedInfo = info.buildNew(
      thumbsUp: info.thumbsUp + 1,
    );
    Firestore.instance
      .collection(FIRESTORE_RANKING_USER_INFO_COLLECTION)
      .document(increasedInfo.uid)
      .setData(increasedInfo.toThumbsUpUpdateMap(), merge: true);
  }
}