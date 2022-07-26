import '../rate_limiter.dart';

/// limiter extensions for [Function] class.
extension RateLimit on Function {
  /// Converts [Function] into a limited function.
  Limiter limited(List<Limit> limits) => Limiter(
        this,
        limits,
      );
}

/// TopLevel lambda to create [Limiter] functions.
Limiter limited(Function func, List<Limit> limits) => Limiter(
      func,
      limits,
    );
