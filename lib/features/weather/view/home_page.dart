import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/format.dart';
import '../../cities/cubit/cities_cubit.dart';
import '../../cities/view/cities_page.dart';
import '../../settings/settings_cubit.dart';
import '../../settings/settings_sheet.dart';
import 'city_weather_view.dart';

/// Swipeable carousel of the saved cities, like the system weather apps.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final _pages = PageController(initialPage: context.read<CitiesCubit>().state.selectedIndex);

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild every page when units or language change.
    context.watch<SettingsCubit>();
    return BlocConsumer<CitiesCubit, CitiesState>(
      listenWhen: (a, b) => a.selectedIndex != b.selectedIndex || a.cities.length != b.cities.length,
      listener: (context, state) {
        if (_pages.hasClients && _pages.page?.round() != state.selectedIndex) {
          _pages.jumpToPage(state.selectedIndex);
        }
      },
      builder: (context, state) => Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            PageView.builder(
              controller: _pages,
              // Builds the neighbouring city too, so its forecast is ready on swipe.
              allowImplicitScrolling: true,
              itemCount: state.cities.length,
              onPageChanged: context.read<CitiesCubit>().select,
              itemBuilder: (_, i) => CityWeatherView(
                key: ValueKey(state.cities[i].id),
                city: state.cities[i],
              ),
            ),
            // Soft shade so scrolled cards never fight with the buttons.
            IgnorePointer(
              child: Container(
                height: MediaQuery.paddingOf(context).top + 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withValues(alpha: .35), Colors.transparent],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    _RoundButton(
                      icon: Icons.format_list_bulleted_rounded,
                      tooltip: context.l.cities,
                      onTap: () => Navigator.of(context).push(CitiesPage.route()),
                    ),
                    const Spacer(),
                    _RoundButton(
                      icon: Icons.tune_rounded,
                      tooltip: context.l.settings,
                      onTap: () => showSettingsSheet(context),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _PageDots(
                    count: state.cities.length,
                    index: state.selectedIndex,
                    firstIsLocation: state.cities.isNotEmpty && state.cities.first.isCurrentLocation,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.tooltip, required this.onTap});

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        style: IconButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: .16),
          foregroundColor: Colors.white,
          fixedSize: const Size(46, 46),
        ),
        icon: Icon(icon),
      );
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.index, required this.firstIsLocation});

  final int count;
  final int index;
  final bool firstIsLocation;

  @override
  Widget build(BuildContext context) {
    if (count < 2) return const SizedBox.shrink();
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: .22),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < count; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: i == 0 && firstIsLocation
                    ? Icon(
                        Icons.near_me_rounded,
                        size: 11,
                        color: Colors.white.withValues(alpha: i == index ? 1 : .45),
                      )
                    : AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: i == index ? 18 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: i == index ? 1 : .45),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
