import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_icons.dart';
import '../core/theme/app_theme.dart';

/// Fila de error del diseño: icono circle-alert + texto 12 en color error.
class FieldErrorRow extends StatelessWidget {
  const FieldErrorRow(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(AppIcons.circleAlert, size: 13, color: cs.error),
          ),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: context.ts(12, FontWeight.w400, color: cs.error))),
        ],
      ),
    );
  }
}

/// Campo de formulario genérico: etiqueta arriba + control + error debajo.
/// El validador lee el estado desde el ViewModel; `state.didChange` dispara
/// la revalidación automática tras la interacción del usuario.
class TurcoFormField extends FormField<Object?> {
  TurcoFormField({
    super.key,
    required String label,
    required Widget Function(FormFieldState<Object?> state, bool hasError) builder,
    required String? Function() check,
    bool sectionTitle = false,
  }) : super(
          initialValue: null,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (_) => check(),
          builder: (state) {
            final context = state.context;
            final cs = context.cs;
            final hasError = state.hasError;
            final labelStyle = sectionTitle
                ? context.ts(14, FontWeight.w600)
                : context.ts(12, FontWeight.w500, color: hasError ? cs.error : cs.onSurfaceVariant);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: labelStyle),
                const SizedBox(height: 4),
                builder(state, hasError),
                if (hasError) FieldErrorRow(state.errorText!),
              ],
            );
          },
        );
}

/// Caja de selección (cliente, estilista, fecha): 52 dp, radio 12, icono + texto + chevron.
class SelectBox extends StatelessWidget {
  const SelectBox({
    super.key,
    required this.icon,
    required this.text,
    required this.isPlaceholder,
    required this.hasError,
    required this.onTap,
    this.focusNode,
  });

  final IconData icon;
  final String text;
  final bool isPlaceholder;
  final bool hasError;
  final VoidCallback onTap;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: hasError ? cs.error : cs.outline, width: hasError ? 2 : 1),
    );
    return Material(
      color: kTransparent,
      shape: shape,
      child: InkWell(
        customBorder: shape,
        focusNode: focusNode,
        onTap: onTap,
        child: SizedBox(
          height: 52,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Icon(icon, size: 18, color: cs.onSurfaceVariant),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.ts(14, FontWeight.w400, color: isPlaceholder ? cs.outline : cs.onSurface),
                  ),
                ),
                Icon(AppIcons.chevronDown, size: 18, color: cs.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// TextFormField con la etiqueta fuera (encima) y el error con icono debajo,
/// como en el diseño. La etiqueta se pone en rojo cuando hay error.
class LabeledTextFormField extends StatefulWidget {
  const LabeledTextFormField({
    super.key,
    required this.label,
    required this.controller,
    this.focusNode,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.onFieldSubmitted,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.onChanged,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final TextCapitalization textCapitalization;

  @override
  State<LabeledTextFormField> createState() => _LabeledTextFormFieldState();
}

class _LabeledTextFormFieldState extends State<LabeledTextFormField> {
  String? _error;

  String? _validate(String? v) {
    final e = widget.validator?.call(v);
    if (e != _error) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _error = e);
      });
    }
    return e;
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final multiline = widget.maxLines != 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label,
            style: context.ts(12, FontWeight.w500, color: _error != null ? cs.error : cs.onSurfaceVariant)),
        const SizedBox(height: 4),
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          validator: _validate,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onFieldSubmitted,
          inputFormatters: widget.inputFormatters,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          onChanged: widget.onChanged,
          textCapitalization: widget.textCapitalization,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: context.ts(14, FontWeight.w400, height: multiline ? 1.3 : null),
          buildCounter: widget.maxLength == null
              ? null
              : (ctx, {required currentLength, required isFocused, maxLength}) => Text(
                    '$currentLength / $maxLength',
                    style: ctx.ts(11, FontWeight.w400, color: ctx.cs.onSurfaceVariant),
                  ),
          // El error se pinta aparte (con icono), aquí solo se oculta su texto nativo.
          decoration: const InputDecoration(errorStyle: TextStyle(fontSize: 0, height: 0)),
        ),
        if (_error != null) FieldErrorRow(_error!),
      ],
    );
  }
}
