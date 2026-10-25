import 'package:flutter/material.dart';

import '../../core/theme/app_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/client.dart';
import '../../viewmodels/clients_view_model.dart';
import '../../widgets/initial_avatar.dart';
import '../../widgets/sheet_handle.dart';
import '../../widgets/status_badge.dart';

enum ClientAction { newAppointment, edit, delete }

/// Hoja con los datos del cliente, su historial y las opciones.
Future<ClientAction?> showClientDetailSheet(
  BuildContext context, {
  required ClientsViewModel vm,
  required Client client,
}) {
  return showModalBottomSheet<ClientAction>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) {
      final cs = ctx.cs;
      final history = vm.historyOf(client);
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: SheetHandle()),
            const SizedBox(height: 14),
            Row(
              children: [
                InitialAvatar(name: client.name, gender: client.gender, size: 56),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(client.name, style: ctx.ts(18, FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Row(children: [
                        Icon(AppIcons.phone, size: 13, color: cs.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(phoneDisplay(client.phone), style: ctx.ts(13, FontWeight.w400, color: cs.onSurfaceVariant)),
                      ]),
                      if (client.email != null) ...[
                        const SizedBox(height: 2),
                        Row(children: [
                          Icon(AppIcons.mail, size: 13, color: cs.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(client.email!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: ctx.ts(13, FontWeight.w400, color: cs.onSurfaceVariant)),
                          ),
                        ]),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text('Historial de turnos · ${history.length}', style: ctx.ts(13, FontWeight.w600)),
            const SizedBox(height: 8),
            if (history.isEmpty)
              Text('Todavía no tiene turnos.', style: ctx.ts(13, FontWeight.w400, color: cs.onSurfaceVariant))
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: history.length,
                  itemBuilder: (_, i) {
                    final a = history[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text('${dayMonth(a.start)} · ${a.servicesLabel}',
                                maxLines: 1, overflow: TextOverflow.ellipsis, style: ctx.ts(13, FontWeight.w400)),
                          ),
                          const SizedBox(width: 8),
                          StatusBadge(status: a.status),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => Navigator.of(ctx).pop(ClientAction.newAppointment),
                    icon: const Icon(AppIcons.plus, size: 18),
                    label: const FittedBox(fit: BoxFit.scaleDown, child: Text('Nuevo turno')),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(ctx).pop(ClientAction.edit),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 18)),
                  icon: const Icon(AppIcons.pencil, size: 16),
                  label: const Text('Editar'),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 46,
                  height: 46,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(ClientAction.delete),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(46, 46),
                      foregroundColor: cs.error,
                      side: BorderSide(color: cs.outlineVariant),
                    ),
                    child: Icon(AppIcons.trash, size: 18, color: cs.error),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
