import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/appointment.dart';
import '../../models/enums.dart';
import '../../models/service.dart';
import '../../viewmodels/agenda_view_model.dart';
import '../../viewmodels/services_view_model.dart';
import '../../widgets/app_chip.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/responsive_body.dart';
import '../../widgets/turco_app_bar.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key, required this.servicesVm, required this.agendaVm});
  final ServicesViewModel servicesVm;
  final AgendaViewModel agendaVm;

  Future<void> _book(BuildContext context, Service s) async {
    // El servicio viaja con `extra`; el resultado vuelve con pop.
    final r = await context.push<AppointmentSavedResult>(
      '/turno/nuevo',
      extra: AppointmentFormInitial(serviceId: s.id),
    );
    if (r != null && context.mounted) {
      agendaVm.registerSaved(r);
      context.go('/agenda');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const TurcoAppBar(title: 'Servicios', subtitle: 'Toca un servicio para reservar'),
            Expanded(
              child: ListenableBuilder(
                listenable: servicesVm,
                builder: (context, _) => ResponsiveBody(
                  maxWidth: 1000,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                    child: Column(
                      children: [
                        _CategoryChips(vm: servicesVm),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<AudienceFilter>(
                            showSelectedIcon: true,
                            segments: [
                              for (final a in AudienceFilter.values) ButtonSegment(value: a, label: Text(a.label)),
                            ],
                            selected: {servicesVm.audience},
                            onSelectionChanged: (s) => servicesVm.setAudience(s.first),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(child: _buildGrid(context)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    final list = servicesVm.filtered;
    if (list.isEmpty) {
      return const SingleChildScrollView(
        child: Center(
          child: EmptyState(
            imagePath: 'assets/images/illustrations/search_x.png',
            title: 'No hay servicios con esos filtros',
            message: 'Prueba con otra categoría o con otro público.',
          ),
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        // 2 columnas (<600 dp), 3 (600-840 dp) y 4 (>840 dp).
        final columns = ServicesViewModel.columnsFor(MediaQuery.of(context).size.width);
        // La altura fija crece con el tamaño de letra del sistema para evitar overflow.
        final textScale = (MediaQuery.textScalerOf(context).scale(14) / 14).clamp(1.0, 1.8);
        final cardHeight = 196 + (textScale - 1) * 110;
        return GridView.builder(
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: list.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: cardHeight,
          ),
          itemBuilder: (context, i) => _ServiceCard(service: list[i], onTap: () => _book(context, list[i])),
        );
      },
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.vm});
  final ServicesViewModel vm;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          AppChip(label: 'Todas', selected: vm.category == null, onTap: () => vm.setCategory(null)),
          for (final c in ServiceCategory.values) ...[
            const SizedBox(width: 8),
            AppChip(label: c.label, selected: vm.category == c, onTap: () => vm.setCategory(c)),
          ],
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service, required this.onTap});
  final Service service;
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
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 84,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(12)),
                child: Image.asset(
                  service.category.imagePath,
                  width: 36,
                  height: 36,
                  color: cs.primary,
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 6),
              Text(service.name,
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: context.ts(14, FontWeight.w600)),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(AppIcons.clock, size: 12, color: cs.onSurfaceVariant),
                      const SizedBox(width: 3),
                      Text('${service.durationMinutes} min',
                          style: context.ts(12, FontWeight.w400, color: cs.onSurfaceVariant)),
                    ],
                  ),
                  Text(money(service.price), style: context.ts(13, FontWeight.w700, color: cs.primary)),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: cs.secondaryContainer, borderRadius: BorderRadius.circular(8)),
                child: Text(service.audience.label,
                    style: context.ts(11, FontWeight.w600, color: cs.onSecondaryContainer)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
