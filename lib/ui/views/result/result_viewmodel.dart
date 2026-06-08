import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../../app/app.locator.dart';
import '../../../app/app.router.dart';
import '../../../models/scan_result.dart';

class ResultViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();

  late ScanResult _result;

  ScanResult get result => _result;

  String get formattedMse => _result.mseScore.toStringAsFixed(4);

  String get displaySerial => _result.extractedSerial ?? 'Not extracted';

  String get verdictReason => _result.verdictReason;

  void initialise(ScanResult result) {
    _result = result;
    notifyListeners();
  }

  void scanAnother() {
    _navigationService.navigateToScanView();
  }

  void goHome() {
    _navigationService.navigateToHomeView();
  }
}
