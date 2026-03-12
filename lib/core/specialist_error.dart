/// Errors that can occur during specialist lifecycle or inference.
sealed class SpecialistError implements Exception {
  const SpecialistError();
}

class NotLoadedError extends SpecialistError {
  const NotLoadedError();
  @override
  String toString() => 'SpecialistError: not loaded';
}

class LoadFailedError extends SpecialistError {
  final String reason;
  const LoadFailedError(this.reason);
  @override
  String toString() => 'SpecialistError: load failed - $reason';
}

class InferenceFailedError extends SpecialistError {
  final String reason;
  const InferenceFailedError(this.reason);
  @override
  String toString() => 'SpecialistError: inference failed - $reason';
}
