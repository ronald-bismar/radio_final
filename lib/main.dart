import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:radio_final/providers/audio_provider.dart';
import 'package:radio_final/providers/theme_provider.dart';
import 'package:radio_final/screens/home_page.dart';
import 'package:just_audio_background/just_audio_background.dart';

Future<void> main() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  runApp(
    Builder(
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider(context)),
          ChangeNotifierProvider(create: (_) => AudioProvider()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Radio Filadelfia',
          theme: themeProvider.themeData,
          home: const HomePage(title: 'Filadelfia Radio'),
        );
      },
    );
  }
}
