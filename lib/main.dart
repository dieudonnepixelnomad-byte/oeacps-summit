import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:summitoeacp/data/wordpress_service.dart';
import 'package:summitoeacp/data/smugmug_service.dart';
import 'package:summitoeacp/firebase_options.dart';
import 'package:summitoeacp/ui/screens/press_room_screen.dart';
import 'package:summitoeacp/ui/screens/splash_screen.dart';
import 'package:summitoeacp/ui/screens/language_selection_screen.dart';
import 'ui/theme/app_theme.dart';
import 'ui/screens/main_scaffold.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/events_screen.dart';
import 'ui/screens/event_detail_screen.dart';
import 'ui/screens/news_screen.dart';
import 'ui/screens/speakers_screen.dart';
import 'ui/screens/speaker_detail_screen.dart';
import 'ui/screens/info_screen.dart';
import 'ui/screens/accreditation_screen.dart';
import 'ui/screens/accreditation_confirmation_screen.dart';
import 'ui/screens/notifications_screen.dart';
import 'ui/screens/news_detail_screen.dart';
import 'ui/screens/media_screen.dart';
import 'ui/screens/media_detail_screen.dart';
import 'ui/screens/album_detail_screen.dart';
import 'ui/screens/contact_screen.dart';
import 'ui/screens/about_screen.dart';

import 'package:summitoeacp/providers/language_provider.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('fr_FR', null);

  // Désactiver Crashlytics en mode debug
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
    !kDebugMode,
  );

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const MainApp());
}

final _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/language',
      builder: (context, state) => const LanguageSelectionScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScaffold(navigationShell: navigationShell);
      },
      branches: [
        // BRANCH 0: HOME
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: 'news',
                  name: 'news',
                  builder: (context, state) => const NewsScreen(),
                  routes: [
                    GoRoute(
                      path: 'detail/:id',
                      name: 'news_detail',
                      builder: (context, state) =>
                          NewsDetailScreen(newsId: state.pathParameters['id']!),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'speakers',
                  builder: (context, state) => const SpeakersScreen(),
                  routes: [
                    GoRoute(
                      path: 'detail/:id',
                      builder: (context, state) => SpeakerDetailScreen(
                        speakerId: state.pathParameters['id']!,
                      ),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'info',
                  builder: (context, state) => const InfoScreen(),
                ),
                // Accreditation moved here from main tab
                GoRoute(
                  path: 'accreditation',
                  builder: (context, state) => const AccreditationScreen(),
                  routes: [
                    GoRoute(
                      path: 'confirmation',
                      builder: (context, state) =>
                          const AccreditationConfirmationScreen(),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'press_room',
                  builder: (context, state) => const PressRoomScreen(),
                ),
                GoRoute(
                  path: 'notifications',
                  builder: (context, state) => const NotificationsScreen(),
                ),
                GoRoute(
                  path: 'contact',
                  builder: (context, state) => const ContactScreen(),
                ),
                GoRoute(
                  path: 'about',
                  builder: (context, state) => const AboutScreen(),
                ),
              ],
            ),
          ],
        ),
        // BRANCH 1: EVENTS
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/events',
              builder: (context, state) => const EventsScreen(),
              routes: [
                GoRoute(
                  path: 'detail/:id',
                  builder: (context, state) =>
                      EventDetailScreen(eventId: state.pathParameters['id']!),
                ),
              ],
            ),
          ],
        ),
        // BRANCH 2: MEDIA (GALLERY)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/media',
              builder: (context, state) => const MediaScreen(),
              routes: [
                GoRoute(
                  path: 'album/:albumId',
                  builder: (context, state) {
                    final id = state.pathParameters['albumId']!;
                    final title = state.extra as String?;
                    return AlbumDetailScreen(albumId: id, albumTitle: title);
                  },
                ),
                GoRoute(
                  path: 'detail/:id',
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return MediaDetailScreen(mediaId: id);
                  },
                ),
              ],
            ),
          ],
        ),
        // BRANCH 3: NEWS
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/news',
              builder: (context, state) => const NewsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        Provider<WordpressService>(create: (_) => WordpressService()),
        Provider<SmugMugService>(create: (_) => SmugMugService()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp.router(
            title: 'OEACP Sommet',
            theme: AppTheme.lightTheme,
            routerConfig: _router,
            debugShowCheckedModeBanner: false,
            locale: languageProvider.currentLocale,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('fr'),
              Locale('en'),
              Locale('es'),
              Locale('pt'),
            ],
          );
        },
      ),
    );
  }
}
