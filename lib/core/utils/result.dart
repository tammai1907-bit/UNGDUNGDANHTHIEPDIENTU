/// Pattern Result xử lý kết quả thành công hoặc thất bại mà không nuốt Exception
sealed class Result<T> {
  const Result();

  factory Result.success(T data) = Success<T>;
  factory Result.failure(Object error, [StackTrace? stackTrace]) =>
      Failure(error.toString(), error: error, stackTrace: stackTrace);

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull => switch (this) {
        Success(data: final d) => d,
        Failure() => null,
      };

  String? get errorOrNull => switch (this) {
        Success() => null,
        Failure(message: final m) => m,
      };

  R when<R>({
    required R Function(T data) success,
    required R Function(String error) failure,
  }) {
    return switch (this) {
      Success(data: final d) => success(d),
      Failure(message: final m) => failure(m),
    };
  }
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class Failure<T> extends Result<T> {
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  const Failure(this.message, {this.error, this.stackTrace});
}
