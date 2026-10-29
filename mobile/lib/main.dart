import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'models.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'theme.dart';
import 'widgets/responsive_frame.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const WoolulApp());
}

class WoolulApp extends StatelessWidget {
  const WoolulApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Woolu AI',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      locale: const Locale('fr', 'FR'),
      supportedLocales: const [Locale('fr', 'FR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => ResponsiveFrame(child: child!),
      home: const RootShell(),
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(onOpenHistory: () => setState(() => _index = 1)),
          const HistoryScreen(),
        ],
      ),
      bottomNavigationBar: ListenableBuilder(
        listenable: Session.instance,
        builder: (context, _) => Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            border: Border(top: BorderSide(color: AppColors.line)),
          ),
          child: NavigationBar(
            height: 68,
            backgroundColor: AppColors.white,
            surfaceTintColor: Colors.transparent,
            indicatorColor: AppColors.primarySoft,
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: [
              const NavigationDestination(
                icon: Icon(PhosphorIconsRegular.house),
                selectedIcon: Icon(PhosphorIconsFill.house, color: AppColors.primary),
                label: 'Accueil',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: Session.instance.items.isNotEmpty,
                  label: Text('${Session.instance.items.length}'),
                  backgroundColor: AppColors.accent,
                  child: const Icon(PhosphorIconsRegular.clockCounterClockwise),
                ),
                selectedIcon: const Icon(PhosphorIconsFill.clockCounterClockwise, color: AppColors.primary),
                label: 'Mes incidents',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
