import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'providers/app_state.dart';
import 'modules/auth/screens/video_splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  runApp(const IdrakLiseyiApp());
}

class IdrakLiseyiApp extends StatelessWidget {
  const IdrakLiseyiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final state = AppState();
            state.initFirebaseData();
            return state;
          },
        ),
      ],
      child: MaterialApp(
        title: 'İdrak Liseyi',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const VideoSplashScreen(),
      ),
    );
  }
}
