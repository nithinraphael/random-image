import 'package:fpdart/fpdart.dart';

typedef FE<L, R> = Future<Either<L, R>>;

typedef FEB<R> = Future<Either<BError, R>>;

typedef FEBRight<R> = Right<BError, R>;

class BError {
  final String message;
  BError(this.message);
}

extension EitherGetValuesExtension<L, R> on Either<L, R> {
  bool get isOk => isRight();
  bool get isErr => isLeft();

  R getValue() {
    return fold((leftValue) {
      throw ArgumentError(
        'Tried to get the Right value of an Either that is a Left',
      );
    }, (rightValue) => rightValue);
  }

  R get v => getValue();
  L get e => getError();

  R? getValueOrNull() {
    return fold((leftValue) => null, (rightValue) => rightValue);
  }

  L getError() {
    return fold((leftValue) => leftValue, (rightValue) {
      throw ArgumentError(
        'Tried to get the Left value of an Either that is a Right',
      );
    });
  }

  void onLeft(void Function(L l) onLeft) {
    fold(onLeft, (_) {});
  }

  void onRight(void Function(R r) onRight) {
    fold((_) {}, onRight);
  }
}
