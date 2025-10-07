import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = AppState();
  try {
    await appState.init();
  } catch (e, st) {
    // Log but continue to run the app with whatever state we have
    print('App initialization error: $e');
    print(st);
  }
  runApp(ChangeNotifierProvider.value(
    value: appState,
    child: MyApp(appState: appState),
  ));
}

class MyApp extends StatefulWidget {
  final AppState appState;
  const MyApp({super.key, required this.appState});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.grey.shade50,
        cardColor: Colors.white,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 2),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        ),
        inputDecorationTheme: InputDecorationTheme(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
        listTileTheme: const ListTileThemeData(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
      ),
      home: const RootApp(),
    );
  }
}

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    if (!appState.initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (appState.initError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Gym Manager - Error')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(child: Text('Initialization error:\n${appState.initError}')),
        ),
      );
    }
    return FutureBuilder<String>(
      future: appState.storage.getDirectoryPath(),
      builder: (context, snapshot) {
        final path = snapshot.data ?? 'unknown';
        return Scaffold(
          appBar: AppBar(title: const Text('Gym Manager')),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: Colors.orange.shade50,
                padding: const EdgeInsets.all(8),
                child: Text('Initialized: ${appState.initialized}  •  Storage: $path'),
              ),
              const Expanded(child: HomeScreen()),
            ],
          ),
        );
      },
    );
  }
}


