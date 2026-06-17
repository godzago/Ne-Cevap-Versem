import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeViewModelProvider = NotifierProvider<HomeViewModel, String?>(() {
  return HomeViewModel();
});

class HomeViewModel extends Notifier<String?> {
  @override
  String? build() {
    return null;
  }

  void selectMode(String modeName) {
    state = modeName;
    print('$modeName moduna tıklandı');
  }
}
