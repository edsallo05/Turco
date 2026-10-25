import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../../data/salon_repository.dart';
import '../../models/client.dart';
import '../../models/enums.dart';
import '../../viewmodels/clients_view_model.dart';
import '../../widgets/form_fields.dart';
import '../../widgets/sheet_handle.dart';

/// Hoja inferior (showModalBottomSheet + isScrollControlled) con el formulario
/// de cliente. La usan la pantalla Clientes y el formulario de turno.
/// Devuelve el cliente guardado, o null si se cancela.
Future<Client?> showClientFormSheet(
  BuildContext context, {
  required ClientsViewModel vm,
  Client? editing,
}) {
  return showModalBottomSheet<Client>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => ClientFormSheet(vm: vm, editing: editing),
  );
}

class ClientFormSheet extends StatefulWidget {
  const ClientFormSheet({super.key, required this.vm, this.editing});
  final ClientsViewModel vm;
  final Client? editing;

  @override
  State<ClientFormSheet> createState() => _ClientFormSheetState();
}

class _ClientFormSheetState extends State<ClientFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name = TextEditingController(text: widget.editing?.name ?? '');
  late final TextEditingController _phone = TextEditingController(text: widget.editing?.phone ?? '');
  late final TextEditingController _email = TextEditingController(text: widget.editing?.email ?? '');
  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _genderFocus = FocusNode();
  final _emailFocus = FocusNode();
  late Gender? _gender = widget.editing?.gender;

  ClientsViewModel get vm => widget.vm;
  int? get _editingId => widget.editing?.id;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _genderFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      // El foco va al primer campo con error.
      if (vm.validateName(_name.text) != null) {
        _nameFocus.requestFocus();
      } else if (vm.validatePhone(_phone.text, excludeId: _editingId) != null) {
        _phoneFocus.requestFocus();
      } else if (vm.validateGender(_gender) != null) {
        _genderFocus.requestFocus();
      } else {
        _emailFocus.requestFocus();
      }
      return;
    }
    try {
      final saved = vm.save(
        id: _editingId,
        name: _name.text,
        phone: _phone.text,
        gender: _gender!,
        email: _email.text,
      );
      Navigator.of(context).pop(saved);
    } on BusinessRuleException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.editing != null;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(child: SheetHandle()),
              const SizedBox(height: 14),
              Text(isEdit ? 'Editar cliente' : 'Nuevo cliente', style: context.ts(18, FontWeight.w600)),
              const SizedBox(height: 14),
              LabeledTextFormField(
                label: 'Nombre',
                controller: _name,
                focusNode: _nameFocus,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _phoneFocus.requestFocus(),
                validator: vm.validateName,
              ),
              const SizedBox(height: 14),
              LabeledTextFormField(
                label: 'Teléfono',
                controller: _phone,
                focusNode: _phoneFocus,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(8)],
                onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                validator: (v) => vm.validatePhone(v, excludeId: _editingId),
              ),
              const SizedBox(height: 14),
              TurcoFormField(
                label: 'Género',
                check: () => vm.validateGender(_gender),
                builder: (state, hasError) => Focus(
                  focusNode: _genderFocus,
                  child: SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<Gender>(
                      emptySelectionAllowed: true,
                      showSelectedIcon: true,
                      segments: [
                        for (final g in Gender.values) ButtonSegment(value: g, label: Text(g.label)),
                      ],
                      selected: _gender == null ? <Gender>{} : {_gender!},
                      onSelectionChanged: (s) {
                        setState(() => _gender = s.isEmpty ? null : s.first);
                        state.didChange(null);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              LabeledTextFormField(
                label: 'Correo (opcional)',
                controller: _email,
                focusNode: _emailFocus,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _save(),
                validator: vm.validateEmail,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(onPressed: _save, child: const Text('Guardar cliente')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
