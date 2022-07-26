import 'dart:async';

import '../rate_limiter.dart';

class Limiter {
  final Function _func;

  final List<Limit> _limits;

  Limiter(this._func, this._limits)
      : _currentLimits = List.generate(_limits.length, (index) => Limit(0, 0));

  List<Limit> _currentLimits;

  List<Object?> _argsQueue = [];
  List<Object?> _namedArgsQueue = [];

  Object? _result;
  int _lastInvokeTime = 0;

  void _addInvokationData(int timeSinceLastInvoke) {

    for (int i = 0; i < _currentLimits.length; i++) {
      _currentLimits[i] = Limit(
          _currentLimits[i].timeMs , _currentLimits[i].requestCount + 1);
    }
  }

  void _addTimeData(int timeSinceLastInvoke){
    for (int i = 0; i < _currentLimits.length; i++) {
      _currentLimits[i] = Limit(
          _currentLimits[i].timeMs + timeSinceLastInvoke, _currentLimits[i].requestCount);
    }
  }



  Object? _invokeFunc(int time) {
    ///Checking if func passed count limit in setted time slots
    final timeSinceLastInvoke = time - _lastInvokeTime;
    _addInvokationData(timeSinceLastInvoke);

    final args = _argsQueue.first as List<Object>?;
    final namedArgs = _namedArgsQueue.first as Map<Symbol, Object>?;

    _lastInvokeTime = time;
    _argsQueue.removeAt(0);
    _namedArgsQueue.removeAt(0);
    return _result = Function.apply(_func, args, namedArgs);
  }

  Timer _startTimer(Function pendingFunc, int wait) =>
      Timer(Duration(milliseconds: wait), () => pendingFunc());

  bool _shouldInvoke(int timeNow) {

    bool hasPassedLimits = true;
    for (int i = 0; i < _currentLimits.length; i++) {
      //if we passed time or requestCount with this invoke - set zero to current limit
      if(_currentLimits[i].timeMs > _limits[i].timeMs || _currentLimits[i].requestCount >= _limits[i].requestCount){
        hasPassedLimits = false;
      }
    }
    return hasPassedLimits;
  }

  int _remainingWait(int time) {
    final timeSinceLastInvoke = time - _lastInvokeTime;
    int? wait;

    for (int i = 0; i < _currentLimits.length; i++) {
      //if we passed time or requestCount with this invoke - set zero to current limit
      if(_currentLimits[i].timeMs  > _limits[i].timeMs || _currentLimits[i].requestCount +1 >= _limits[i].requestCount){
        wait = _limits[i].timeMs;
      }
    }

    final timeWaiting = (wait ?? timeSinceLastInvoke) - timeSinceLastInvoke;
print('_remainingWait - $timeWaiting');
    return timeWaiting > 0 ? timeWaiting : timeWaiting*-1;
  }

  void _timerExpired() {
    final timeNow = DateTime.now().millisecondsSinceEpoch;

    _addTimeData(timeNow-_lastInvokeTime);

    print('_timerExpired $_currentLimits');

    for (int i = 0; i < _currentLimits.length; i++) {
      if(_currentLimits[i].timeMs > _limits[i].timeMs && _currentLimits[i].requestCount + 1 >= _limits[i].requestCount){
        _currentLimits[i] = Limit(0,0);
      }
    }

    if (_shouldInvoke(timeNow)) {
      _invokeFunc(timeNow);
    } else {
      // Restart the timer.
      _startTimer(_timerExpired, _remainingWait(timeNow));
    }
  }

  Object? call([List<Object>? args, Map<Symbol, Object>? namedArgs]) {
    final timeNow = DateTime.now().millisecondsSinceEpoch;
    final isInvoking = _shouldInvoke(timeNow);

    _argsQueue.add(args);
    _namedArgsQueue.add(namedArgs);
    if (isInvoking) {
        _lastInvokeTime = timeNow;
        return _invokeFunc(timeNow);
    }
     _startTimer(_timerExpired, _remainingWait(timeNow));
    return _result;
  }
}
