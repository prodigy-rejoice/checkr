import 'dart:async';
import 'dart:developer' as developer;

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

  static const _timeout = Duration(seconds: 30);

  Future<void> initialise() async {
    await runBusyFuture(_init());
  }

  Future<void> _init() async {
    try {
      await _runStep('hive init', _hiveService.init);
      await _runStep('tflite model load', _tfliteService.loadModel);
      await _runStep('camera permission', () => Permission.camera.request());
    } catch (e, s) {
      developer.log(
        'Splash init failed, continuing to HomeView',
        name: 'SplashViewModel',
        error: e,
        stackTrace: s,
      );
    } finally {
      developer.log('Navigating to HomeView', name: 'SplashViewModel');
      await _navigationService.replaceWithHomeView();
    }
  }

  Future<void> _runStep(String label, Future<dynamic> Function() step) async {
    developer.log('Starting: $label', name: 'SplashViewModel');
    final stopwatch = Stopwatch()..start();
    try {
      await step().timeout(_timeout);
      stopwatch.stop();
      developer.log(
        'Completed: $label (${stopwatch.elapsedMilliseconds}ms)',
        name: 'SplashViewModel',
      );
    } on TimeoutException {
      stopwatch.stop();
      developer.log(
        'Timeout: $label exceeded ${_timeout.inSeconds}s',
        name: 'SplashViewModel',
      );
    } catch (e, s) {
      stopwatch.stop();
      developer.log(
        'Error in $label',
        name: 'SplashViewModel',
        error: e,
        stackTrace: s,
      );
    }
  }
}
