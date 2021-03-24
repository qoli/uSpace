import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

AsyncSnapshot<T> useMemoizedFuture<T>(
  Future<T> Function() futureBuilder,
  T initialData, {
  List<Object?> keys = const <Object>[],
}) =>
    useFuture(
      useMemoized(
        futureBuilder,
        keys,
      ),
      initialData: initialData,
    );

T useChangeNotifier<T extends ChangeNotifier>(
  T Function() valueBuilder, [
  List<Object?> keys = const <Object>[],
]) {
  var changeNotifier = useMemoized(
    valueBuilder,
    keys,
  );
  useEffect(() => changeNotifier.dispose, keys);

  return changeNotifier;
}
