import 'package:permission_handler/permission_handler.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../services/hive_service.dart';
import '../../../services/tflite_service.dart';

class SplashViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _tfliteService = locator<TfliteService>();
  final _hiveService = locator<HiveService>();

  Future<void> initialise() async {
    await runBusyFuture(_init());
  }

  Future<void> _init() async {
    await _hiveService.init();
    await _tfliteService.loadModel();
    await Permission.camera.request();
    await _navigationService.replaceWithHomeView();
  }
}
