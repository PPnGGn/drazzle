import 'package:drazzle/core/di/firebase_providers.dart';
import 'package:drazzle/core/di/auth_providers.dart';
import 'package:drazzle/features/drawing/models/drawing_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// StreamProvider для списка рисунков текущего пользователя
final userDrawingsProvider = StreamProvider<List<DrawingModel>>((ref) {
  try {
    final authAsync = ref.watch(authUserProvider);

    return authAsync.when(
      data: (user) {
        if (user == null) {
          return Stream.value([]);
        }
        final firestore = ref.watch(firestoreProvider);

        return firestore
            .collection('drawings')
            .where('authorId', isEqualTo: user.id)
            .orderBy('createdAt', descending: true)
            .snapshots()
            .map((snapshot) {
              return snapshot.docs
                  .map((doc) => DrawingModel.fromFirestore(doc))
                  .toList();
            })
            .handleError((error) {
              throw error;
            });
      },
      loading: () {
        return Stream.value([]);
      },
      error: (error, stack) {
        return Stream.value([]);
      },
    );
  } catch (e) {
    return Stream.value([]);
  }
});
