sealed class AuthOperationState {
  const AuthOperationState();
}

class AuthOperationInitial extends AuthOperationState {
  const AuthOperationInitial();
}

class AuthOperationLoading extends AuthOperationState {
  const AuthOperationLoading();
}

class AuthOperationSuccess extends AuthOperationState {
  const AuthOperationSuccess();
}

class AuthOperationError extends AuthOperationState {
  final String message;
  const AuthOperationError(this.message);
}
