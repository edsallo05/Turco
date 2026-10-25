import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/stylist.dart';
import '../../viewmodels/agenda_view_model.dart';
import '../../viewmodels/stylists_view_model.dart';
import '../../widgets/app_chip.dart';
import '../../widgets/initial_avatar.dart';

class StylistsScreen extends StatelessWidget {
  const StylistsScreen({super.key, required this.stylistsVm, required this.agendaVm});
  final StylistsViewModel stylistsVm;
  final AgendaViewModel agendaVm;

  void _openAgenda(BuildContext context, Stylist s) {
    agendaVm.setStylist(s.id);
    // El identificador viaja como parámetro de consulta.
    context.go('/agenda?estilista=${s.id}');
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (cs.brightness == Brightness.dark ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light)
          .copyWith(statusBarColor: kTransparent),
      child: Scaffold(
        body: ListenableBuilder(
          listenable: stylistsVm,
          builder: (context, _) {
            final list = stylistsVm.stylists;
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 170,
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  surfaceTintColor: kTransparent,
                  automaticallyImplyLeading: false,
                  flexibleSpace: _StylistsHeader(
                    count: list.length,
                    scheduledToday: stylistsVm.totalScheduledToday,
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      childCount: list.length,
                      (context, i) {
                        final s = list[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _StylistCard(
                            stylist: s,
                            categories: stylistsVm.categoriesOf(s).map((c) => c.label).toList(),
                            today: stylistsVm.scheduledToday(s),
                            onTap: () => _openAgenda(context, s),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Cabecera plegable: icono + título + resumen al expandirse; solo el título al plegarse.
class _StylistsHeader extends StatelessWidget {
  const _StylistsHeader({required this.count, required this.scheduledToday});
  final int count;
  final int scheduledToday;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final settings = context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    final top = MediaQuery.of(context).padding.top;
    double t = 0; // 0 = expandido, 1 = plegado
    if (settings != null) {
      final range = settings.maxExtent - settings.minExtent;
      if (range > 0) t = (1 - (settings.currentExtent - settings.minExtent) / range).clamp(0.0, 1.0);
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        Opacity(
          opacity: 1 - t,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, top + 8, 20, 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(AppIcons.contact, size: 28, color: cs.onPrimary),
                const SizedBox(height: 4),
                Text('Estilistas', style: context.ts(28, FontWeight.w600, color: cs.onPrimary)),
                const SizedBox(height: 4),
                Text(
                  '${plural(count, 'profesional', 'profesionales')} · ${plural(scheduledToday, 'turno programado', 'turnos programados')} hoy',
                  style: context.ts(13, FontWeight.w400, color: cs.onPrimary.withValues(alpha: 0.85)),
                ),
              ],
            ),
          ),
        ),
        Opacity(
          opacity: t,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, top, 20, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(AppIcons.contact, size: 22, color: cs.onPrimary),
                  const SizedBox(width: 10),
                  Text('Estilistas', style: context.ts(20, FontWeight.w600, color: cs.onPrimary)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StylistCard extends StatelessWidget {
  const _StylistCard({
    required this.stylist,
    required this.categories,
    required this.today,
    required this.onTap,
  });

  final Stylist stylist;
  final List<String> categories;
  final int today;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));
    return Material(
      color: cs.surfaceContainer,
      shape: shape,
      child: InkWell(
        customBorder: shape,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              StylistAvatar(stylist: stylist, size: 56),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stylist.name, style: context.ts(16, FontWeight.w600)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [for (final c in categories) AppChip(label: c)],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      today == 0 ? 'Sin turnos hoy' : '${plural(today, 'turno', 'turnos')} hoy',
                      style: context.ts(12, FontWeight.w500, color: today == 0 ? cs.onSurfaceVariant : cs.primary),
                    ),
                  ],
                ),
              ),
              Icon(AppIcons.chevronRight, size: 22, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
