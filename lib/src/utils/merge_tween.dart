import 'package:flutter/material.dart';

/// Collapse [object] into nothing.
typedef T Collapser<T>(T object);

/// An object which can be tweened as part of a list.
/// [T] should be the same object which is extending [MergeTweenable].
abstract class MergeTweenable<T> {
  /// An "empty" or "collapsed" version of this object. When used with
  /// [MergeTween], the value of [empty] is used when this object is
  /// animating from nothing, or animating to nothing.
  T get empty;

  /// Create a tween to another object.
  Tween<T> tweenTo(T other);
}

/// Intelligently lerps two lists of tweenable objects.
class MergeTween<T extends MergeTweenable<T>> extends Tween<List<T>> {
  MergeTween(List<T> begin, List<T> end) : super(begin: begin, end: end) {
    final bMax = begin.length;
    final eMax = end.length;
    var b = 0;
    var e = 0;
    while (b + e < bMax + eMax) {
      if (b < bMax && (e == eMax || b < e)) {
        _tweens.add(begin[b].tweenTo(begin[b].empty));
        b++;
      } else if (e < eMax && (b == bMax || e < b)) {
        _tweens.add(end[e].empty.tweenTo(end[e]));
        e++;
      } else {
        _tweens.add(begin[b].tweenTo(end[e]));
        b++;
        e++;
      }
    }
  }

  final _tweens = <Tween<T>>[];

  @override
  List<T> lerp(double t) {
    return new List.generate(
      _tweens.length,
      (i) => _tweens[i].lerp(t),
    );
  }
}
