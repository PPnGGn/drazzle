import 'package:draw_hub/core/services/auth_service.dart';
import 'package:draw_hub/features/auth/domain/usecases/auth_usecase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([
  AuthService,
  AuthUseCase,
  User,
])
void main() {}