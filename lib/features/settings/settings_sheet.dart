import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/format.dart';
import 'settings_cubit.dart';

Future<void> showSettingsSheet(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF141A2B),
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => BlocProvider.value(value: context.read<SettingsCubit>(), child: const _SettingsSheet()),
    );

class _SettingsSheet extends StatelessWidget {
  const _SettingsSheet();

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsCubit>().state;
    final cubit = context.read<SettingsCubit>();
    final lang = Localizations.localeOf(context).languageCode;

    Widget label(String text) => Padding(
          padding: const EdgeInsets.only(top: 18, bottom: 10),
          child: Text(text, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
        );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(context.l.settings,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
            label(context.l.temperatureUnit),
            _Segments<TemperatureUnit>(
              values: TemperatureUnit.values,
              selected: s.temperatureUnit,
              label: (u) => u == TemperatureUnit.celsius ? '°C' : '°F',
              onChanged: cubit.setTemperatureUnit,
            ),
            label(context.l.windUnit),
            _Segments<WindUnit>(
              values: WindUnit.values,
              selected: s.windUnit,
              label: Units.windLabel,
              onChanged: cubit.setWindUnit,
            ),
            label(context.l.language),
            _Segments<String>(
              values: const ['tr', 'en'],
              selected: lang,
              label: (c) => c == 'tr' ? '🇹🇷  Türkçe' : '🇬🇧  English',
              onChanged: (c) => cubit.setLocale(Locale(c)),
            ),
            const SizedBox(height: 22),
            Text(
              '${context.l.about}\n${context.l.dataSource}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 12, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _Segments<T> extends StatelessWidget {
  const _Segments({
    required this.values,
    required this.selected,
    required this.label,
    required this.onChanged,
  });

  final List<T> values;
  final T selected;
  final String Function(T) label;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .07),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            for (final v in values)
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(v),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: v == selected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      label(v),
                      style: TextStyle(
                        color: v == selected ? const Color(0xFF141A2B) : Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
}
