import '../repositories/navigation_repository.dart';

/// UseCase untuk mengubah dan menyimpan tab index aktif
class ChangeTabUseCase {
  const ChangeTabUseCase(this.repository);

  final NavigationRepository repository;

  Future<int> execute(int newIndex, {int maxIndex = 2}) async {
    if (newIndex < 0 || newIndex > maxIndex) {
      throw RangeError.range(newIndex, 0, maxIndex, 'newIndex');
    }

    await repository.saveCurrentTab(newIndex);
    return newIndex;
  }
}

