
import 'package:todo_app/Utils.dart';
import 'package:todo_app/domain/entity/CheckPoint.dart';
import 'package:todo_app/domain/entity/DateInWeek.dart';
import 'package:todo_app/domain/entity/DayPreview.dart';
import 'package:todo_app/domain/entity/WeekRecord.dart';
import 'package:todo_app/domain/repository/DateRepository.dart';
import 'package:todo_app/domain/repository/LockRepository.dart';
import 'package:todo_app/domain/repository/MemoRepository.dart';
import 'package:todo_app/domain/repository/PrefRepository.dart';
import 'package:todo_app/domain/repository/ToDoRepository.dart';

class WeekUsecases {
  final MemoRepository _memoRepository;
  final DateRepository _dateRepository;
  final ToDoRepository _toDoRepository;
  final LockRepository _lockRepository;
  final PrefsRepository _prefsRepository;

  const WeekUsecases(this._memoRepository, this._dateRepository, this._toDoRepository, this._lockRepository, this._prefsRepository);

  DateTime getToday() {
    return _dateRepository.getToday();
  }

  Future<WeekRecord> getWeekRecord(DateTime date) async {
    final today = _dateRepository.getToday();
    final dateInWeek = DateInWeek.fromDate(date);
    final defaultLocked = await _prefsRepository.getUseLockScreen();
    final isCheckPointsLocked = await _lockRepository.getIsCheckPointsLocked(date, defaultLocked);
    final checkPoints = await _memoRepository.getCheckPoints(date);

    final datesInWeek = Utils.getDatesInWeek(date);
    List<DayPreview> dayPreviews = [];
    bool prevDayCompleted = false;
    bool curDayCompleted = false;
    for (int i = 0; i < datesInWeek.length; i++) {
      final date = datesInWeek[i];
      final toDos = await _toDoRepository.getToDos(date);
      final isLocked = await _lockRepository.getIsDayRecordLocked(date, defaultLocked);
      final memo = await _memoRepository.getDayMemo(date);

      toDos.sort((t1, t2) {
        if (t1.isDone && !t2.isDone) {
          return 1;
        } else if (!t1.isDone && t2.isDone){
          return -1;
        } else {
          return t1.order - t2.order;
        }
      });
      curDayCompleted = toDos.length > 0 && toDos.length == toDos.where((toDo) => toDo.isDone).length;
      final dayPreview = DayPreview(
        year: date.year,
        month: date.month,
        day: date.day,
        weekday: date.weekday,
        totalToDosCount: toDos.length,
        doneToDosCount: toDos.where((it) => it.isDone).length,
        isLocked: isLocked,
        isToday: Utils.isSameDay(date, today),
        isLightColor: !curDayCompleted && today.compareTo(date) > 0,
        isTopLineVisible: (curDayCompleted && prevDayCompleted) || (date == today && prevDayCompleted),
        isTopLineLightColor: !curDayCompleted,
        memoPreview: memo.text.length > 0 ? memo.text.replaceAll(RegExp(r'\n'), ', ') : '-',
        toDoPreviews: toDos.length > 2 ? toDos.sublist(0, 2) : toDos,
      );
      dayPreviews.add(dayPreview);

      if (i > 0) {
        dayPreviews[i - 1] = dayPreviews[i - 1].buildNew(
          isBottomLineVisible: (prevDayCompleted && curDayCompleted) || (date == today && prevDayCompleted),
          isBottomLineLightColor: !curDayCompleted,
        );
      }

      prevDayCompleted = curDayCompleted;
    }

    return WeekRecord(dateInWeek: dateInWeek, isCheckPointsLocked: isCheckPointsLocked, checkPoints: checkPoints, dayPreviews: dayPreviews);
  }

  void setCheckPoint(CheckPoint checkPoint) {
    _memoRepository.setCheckPoint(checkPoint);
  }

  void setCheckPointsLocked(DateInWeek dateInWeek, bool value) {
    _lockRepository.setIsCheckPointsLocked(dateInWeek, value);
  }

  void setDayRecordLocked(DateTime date, bool value) {
    _lockRepository.setIsDayRecordLocked(date, value);
  }

  Future<String> getUserPassword() async {
    return _prefsRepository.getUserPassword();
  }
}