import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../services/tflite_service.dart';

class HomeViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _snackbarService = locator<SnackbarService>();
  final _tfliteService = locator<TfliteService>();

  void navigateToScan() {
    if (!_tfliteService.isLoaded) {
      _snackbarService.showSnackbar(
        message: 'Model not ready. Please restart the app.',
        title: 'Error',
      );
      return;
    }
    _navigationService.navigateToScanView();
  }
}
