import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:roblo_firebase/services/navigation_service.dart';

class AlertService {
  final GetIt _getIt = GetIt.instance;
  late NavigationService _navigationService;
  AlertService() {
    _navigationService = _getIt.get<NavigationService>();
  }

  void showToast({
    required String text,
    required Color color,
    IconData icon = Icons.info,
  }) {
    try {
      DelightToastBar(
          autoDismiss: true,
          position: DelightSnackbarPosition.bottom,
          builder: (context) {
            return ToastCard(
              color: color,
              leading: Icon(
                icon,
                size: 28,
                color: Colors.white,
                shadows: const [
                  Shadow(
                    offset: Offset(1.0,
                        1.0), // Change the offset to adjust the shadow position
                    blurRadius:
                        1.5, // Change the blur radius to adjust the shadow spread
                    color: Colors.black, // Color of the shadow
                  ),
                ],
              ),
              title: Text(
                text,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(1.0,
                          1.0), // Change the offset to adjust the shadow position
                      blurRadius:
                          2.0, // Change the blur radius to adjust the shadow spread
                      color: Colors.black, // Color of the shadow
                    ),
                  ],
                ),
              ),
            );
          }).show(
        _navigationService.navigatorKey!.currentContext!,
      );
    } catch (e) {
      print(e);
    }
  }
}
