import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';

import '../services/tflite_service.dart';
import '../services/ocr_service.dart';
import '../services/hive_service.dart';
import '../services/image_quality_service.dart';
import '../repositories/blacklist_repository.dart';
import '../ui/views/splash/splash_view.dart';
import '../ui/views/home/home_view.dart';
import '../ui/views/scan/scan_view.dart';
import '../ui/views/result/result_view.dart';

@StackedApp(
  routes: [
    MaterialRoute(page: SplashView, initial: true),
    MaterialRoute(page: HomeView),
    MaterialRoute(page: ScanView),
    MaterialRoute(page: ResultView),
  ],
  dependencies: [
    LazySingleton(classType: TfliteService),
    LazySingleton(classType: OcrService),
    LazySingleton(classType: HiveService),
    LazySingleton(classType: ImageQualityService),
    LazySingleton(classType: BlacklistRepository),
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: SnackbarService),
    LazySingleton(classType: DialogService),
  ],
)
class App {}
