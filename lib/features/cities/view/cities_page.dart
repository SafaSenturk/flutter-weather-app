import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/format.dart';
import '../../../core/widgets/sky_background.dart';
import '../../../core/widgets/weather_icon.dart';
import '../../../data/api/weather_api.dart';
import '../../../data/models/city.dart';
import '../../../data/repositories/city_repository.dart';
import '../../../data/repositories/weather_repository.dart';
import '../../settings/settings_cubit.dart';
import '../bloc/city_search_bloc.dart';
import '../cubit/cities_cubit.dart';

/// Saved cities (reorder, swipe to remove) with a city search on top.
class CitiesPage extends StatefulWidget {
  const CitiesPage({super.key});

  static Route<void> route() => PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, _, _) => BlocProvider(
          create: (context) => CitySearchBloc(context.read<CityRepository>()),
          child: const CitiesPage(),
        ),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween(begin: const Offset(0, .04), end: Offset.zero)
                .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
      );

  @override
  State<CitiesPage> createState() => _CitiesPageState();
}

class _CitiesPageState extends State<CitiesPage> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  String get _lang => Localizations.localeOf(context).languageCode;

  void _onChanged(String text) {
    setState(() {});
    context.read<CitySearchBloc>().add(SearchQueryChanged(text, language: _lang));
  }

  void _clear() {
    _search.clear();
    _onChanged('');
    FocusScope.of(context).unfocus();
  }

  Future<void> _pick(City city) async {
    await context.read<CitiesCubit>().add(city);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _useLocation() async {
    final cubit = context.read<CitiesCubit>();
    await cubit.useCurrentLocation(language: _lang, fallbackName: context.l.myLocation);
    if (!mounted) return;
    final failure = cubit.state.locationFailure;
    if (failure == null) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(failure.kind == FailureKind.timeout ? context.l.locationTimeout : context.failure(failure)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<SettingsCubit>();
    final searching = _search.text.trim().isNotEmpty;
    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(context.l.cities, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 26)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _search,
              onChanged: _onChanged,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: context.l.searchHint,
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: .5)),
                prefixIcon: Icon(Icons.search_rounded, color: Colors.white.withValues(alpha: .7)),
                suffixIcon: searching
                    ? IconButton(onPressed: _clear, icon: const Icon(Icons.close_rounded, color: Colors.white70))
                    : null,
                filled: true,
                fillColor: Colors.white.withValues(alpha: .09),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: searching
                  ? _SearchResults(onPick: _pick)
                  : _SavedCities(onUseLocation: _useLocation),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.onPick});

  final ValueChanged<City> onPick;

  @override
  Widget build(BuildContext context) {
    final muted = TextStyle(color: Colors.white.withValues(alpha: .65), fontSize: 15);
    return BlocBuilder<CitySearchBloc, CitySearchState>(
      builder: (context, state) => switch (state.status) {
        SearchStatus.idle => Center(child: Text(context.l.searchPrompt, style: muted)),
        SearchStatus.loading when state.results.isEmpty =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
        SearchStatus.empty => Center(child: Text(context.l.searchEmpty(state.query), style: muted)),
        SearchStatus.failure => Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(context.failure(state.failure!), style: muted, textAlign: TextAlign.center),
            ),
          ),
        _ => ListView.separated(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 24),
            itemCount: state.results.length,
            separatorBuilder: (_, _) => Divider(color: Colors.white.withValues(alpha: .08), height: 1),
            itemBuilder: (context, i) {
              final city = state.results[i];
              return ListTile(
                onTap: () => onPick(city),
                leading: CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: .1),
                  child: Text(
                    _flag(city.countryCode),
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                title: Text(city.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                subtitle: Text(city.subtitle, style: TextStyle(color: Colors.white.withValues(alpha: .6))),
                trailing: Icon(Icons.add_circle_outline_rounded, color: Colors.white.withValues(alpha: .7)),
              );
            },
          ),
      },
    );
  }

  /// "TR" -> 🇹🇷 using regional indicator symbols.
  static String _flag(String? code) {
    if (code == null || code.length != 2) return '🌍';
    return String.fromCharCodes(code.toUpperCase().codeUnits.map((c) => c - 65 + 0x1F1E6));
  }
}

class _SavedCities extends StatelessWidget {
  const _SavedCities({required this.onUseLocation});

  final VoidCallback onUseLocation;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CitiesCubit, CitiesState>(
      builder: (context, state) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: state.isLocating ? null : onUseLocation,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: .25)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: state.isLocating
                    ? const SizedBox.square(
                        dimension: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.my_location_rounded),
                label: Text(state.isLocating ? context.l.locating : context.l.useMyLocation),
              ),
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: state.cities.length,
              onReorderItem: context.read<CitiesCubit>().reorder,
              proxyDecorator: (child, _, _) => Material(color: Colors.transparent, child: child),
              itemBuilder: (context, i) {
                final city = state.cities[i];
                return Padding(
                  key: ValueKey(city.id),
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Dismissible(
                    key: ValueKey('dismiss-${city.id}'),
                    direction: state.cities.length > 1 ? DismissDirection.endToStart : DismissDirection.none,
                    onDismissed: (_) => context.read<CitiesCubit>().remove(city),
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5484D),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                    ),
                    child: _CityCard(
                      city: city,
                      onTap: () {
                        context.read<CitiesCubit>().select(i);
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// A small card painted with the city's current sky.
class _CityCard extends StatefulWidget {
  const _CityCard({required this.city, required this.onTap});

  final City city;
  final VoidCallback onTap;

  @override
  State<_CityCard> createState() => _CityCardState();
}

class _CityCardState extends State<_CityCard> {
  late final _future = context.read<WeatherRepository>().load(widget.city);

  @override
  Widget build(BuildContext context) => FutureBuilder<ForecastResult>(
        future: _future,
        builder: (context, snap) {
          final f = snap.data?.forecast;
          final colors = f == null
              ? [const Color(0xFF26324A), const Color(0xFF3B4A66)]
              : skyGradient(f.current.condition.sky, f.current.isDay);
          return Material(
            borderRadius: BorderRadius.circular(24),
            clipBehavior: Clip.antiAlias,
            child: Ink(
              decoration: BoxDecoration(gradient: LinearGradient(colors: [colors.first, colors.last])),
              child: InkWell(
                onTap: widget.onTap,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (widget.city.isCurrentLocation) ...[
                                  const Icon(Icons.near_me_rounded, size: 16, color: Colors.white),
                                  const SizedBox(width: 4),
                                ],
                                Flexible(
                                  child: Text(
                                    widget.city.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              f == null
                                  ? (widget.city.subtitle.isEmpty ? ' ' : widget.city.subtitle)
                                  : context.l.localTime(context.hourMinute(f.cityNow())),
                              style: TextStyle(color: Colors.white.withValues(alpha: .8), fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              f == null ? '' : context.condition(f.current.condition),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      if (f != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                WeatherIcon(condition: f.current.condition, isDay: f.current.isDay, size: 34),
                                const SizedBox(width: 6),
                                Text(
                                  context.temp(f.current.temperature),
                                  style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w300),
                                ),
                              ],
                            ),
                            Text(
                              context.l.highLow(context.temp(f.today.max), context.temp(f.today.min)),
                              style: TextStyle(color: Colors.white.withValues(alpha: .85), fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        )
                      else if (snap.hasError)
                        const Icon(Icons.cloud_off_rounded, color: Colors.white70)
                      else
                        const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
}
