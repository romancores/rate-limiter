class Limit {
  final int timeMs;
  final int requestCount;

  Limit(this.timeMs, this.requestCount);

  @override
  String toString() => 'timeMs $timeMs, requestCount $requestCount';
}