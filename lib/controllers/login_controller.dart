import 'package:get/get.dart';

class LogInController extends GetxController {
  bool _isAdmin = false;

  bool get isAdmin => _isAdmin;

  void setIsAdmin(bool val) {
    _isAdmin = val;
    update();
  }
}
