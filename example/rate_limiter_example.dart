import 'package:rate_limiter/rate_limiter.dart';

void main() {
  // var awesome = Awesome();
  // print('awesome: ${awesome.isAwesome}');

  final awesomeFunc =
      limited(() => print('limiter here ${DateTime.now().minute}:${DateTime.now().second}\n\n'), [Limit(1000, 1), Limit(60000, 10)]);

  //first call
  awesomeFunc.call();
  awesomeFunc.call();
  awesomeFunc.call();
  awesomeFunc.call();
  awesomeFunc.call();
  awesomeFunc.call();
  awesomeFunc.call();
  awesomeFunc.call();
  awesomeFunc.call();
  awesomeFunc.call();
  awesomeFunc.call();
  awesomeFunc.call();
  awesomeFunc.call();

  //other calls
  // Future.delayed(Duration(seconds: 2)).then((value) => awesomeFunc.call());
  // Future.delayed(Duration(seconds: 6)).then((value) => awesomeFunc.call());
  // Future.delayed(Duration(seconds: 11)).then((value) => awesomeFunc.call());
}
