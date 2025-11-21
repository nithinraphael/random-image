# GitHub Copilot Instructions for Dart

Write **short**, **ultra-performant**, and **simple** Dart code.

* Use **modern Dart features** (null safety, extension methods, concise function syntax, pattern matching).
* Prioritize **performance** by avoiding unnecessary allocations and using efficient data structures.
* Keep code **minimal and readable**, avoiding boilerplate and excessive abstraction.
* Use **arrow functions (`=>`)**, spread operators (`...`) and collection methods (`map`, `where`).
* Prefer **immutable data** (`final`, `const`) and **functional programming** patterns where applicable.
* I have **FpDart** installed—use **functional programming techniques**, `Either`, and monads for better error handling and composition.

Always use:

```dart
import 'package:aurora/models/all.dart';
import 'package:fpdart/fpdart.dart';

typedef FE<L, R> = Future<Either<L, R>>;
typedef FEB<R> = Future<Either<BError, R>>;
typedef FEBRight<R> = Right<BError, R>;
```

wherever possible for consistency, clarity, and conciseness.

* Optimize loops, minimize memory usage, and avoid unnecessary computations.
* Use **simple, short variable names** to keep the code concise and clear.
* **Avoid nested if statements**—use early returns and simple boolean conditions to keep the code flat and easy to follow.
* **Avoid comments**—only add comments when absolutely necessary. The code must speak for itself.
* Extract UI components into sub-widgets instead of methods where appropriate to improve readability, performance, and reusability. Maintain a balance — avoid creating overly small widgets that add unnecessary complexity or hurt clarity.
* All constants and only constants should start with `k`, e.g. `kHeight`, `kWidth`.

Focus on **clean, direct, and high-performance solutions**.

---

### ✅ Use Go-style `Either` usage with early return

```dart
Either<String, int> parseId(String s) =>
    s.isEmpty ? left('empty') : int.tryParse(s).mapOrElse(left, right);

void run() {
  final res = parseId('42');
  if (res.isErr) return print(res.e);
  final id = res.v;
  print(id);
}
```