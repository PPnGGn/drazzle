sealed class DrawingOperationState {
  const DrawingOperationState();
}

class DrawingOperationIdle extends DrawingOperationState {
  const DrawingOperationIdle();
}

class DrawingOperationLoading extends DrawingOperationState {
  const DrawingOperationLoading();
}

class DrawingOperationSuccess extends DrawingOperationState {
  final String? operation;
  const DrawingOperationSuccess({this.operation});
}

class DrawingOperationError extends DrawingOperationState {
  final String message;
  const DrawingOperationError(this.message);
}
