import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:roblo_firebase/firebase_options.dart';
import 'package:roblo_firebase/services/auth_service.dart';
import 'package:roblo_firebase/services/navigation_service.dart';

Future<void> setupFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> registerServices() async {
  final GetIt getIt = GetIt.instance;
  getIt.registerSingleton<AuthService>(
    AuthService(),
  );
  getIt.registerSingleton<NavigationService>(
    NavigationService(),
  );
}