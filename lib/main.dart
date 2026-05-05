import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:jarvis_lite/core/utils/service_locator.dart';
import 'package:jarvis_lite/core/services/voice_service.dart';
import 'package:jarvis_lite/ui/theme/app_theme.dart';
import 'package:jarvis_lite/ui/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize service locator and all services
  await setupServiceLocator();

  runApp(const JarvisLiteApp());
}

class JarvisLiteApp extends StatelessWidget {
  const JarvisLiteApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        /// Provide VoiceService with ChangeNotifier
        ChangeNotifierProvider<VoiceService>(
          create: (_) => getIt<VoiceService>(),
        ),
      ],
      child: MaterialApp(
        title: 'JARVIS Lite',
        theme: AppTheme.darkTheme,
        home: HomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
