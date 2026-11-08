import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/card_repository.dart';
import '../../domain/repositories/storage_repository.dart';
import '../../data/repositories/fake_card_repository.dart';
import '../../data/repositories/fake_storage_repository.dart';
import '../../data/repositories/firebase_card_repository.dart';
import '../../data/repositories/firebase_storage_repository.dart';

/// Cờ điều khiển nguồn dữ liệu:
/// - true: Chạy offline độc lập với dữ liệu mẫu (InMemory/Mock)
/// - false: Kết nối Firebase Cloud Firestore & Storage thật
final useMockDataProvider = StateProvider<bool>((ref) => true);

// Giữ lại 1 instance duy nhất của Fake repo trong suốt phiên chạy để không bị mất dữ liệu khi chuyển màn hình
final _fakeCardRepoInstance = FakeCardRepository();
final _fakeStorageRepoInstance = FakeStorageRepository();

/// Provider cung cấp CardRepository tùy theo cấu hình useMockData
final cardRepositoryProvider = Provider<CardRepository>((ref) {
  final useMock = ref.watch(useMockDataProvider);
  if (useMock) {
    return _fakeCardRepoInstance;
  }
  return FirebaseCardRepository();
});

/// Provider cung cấp StorageRepository
final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  final useMock = ref.watch(useMockDataProvider);
  if (useMock) {
    return _fakeStorageRepoInstance;
  }
  return FirebaseStorageRepository();
});
