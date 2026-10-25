const _weekdays = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];
const _weekdaysShort = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
const _months = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
  'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
];

String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
String _two(int n) => n.toString().padLeft(2, '0');

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

/// "Lun", "Mar"... (weekday de DateTime: 1 = lunes).
String weekdayShort(DateTime d) => _weekdaysShort[d.weekday - 1];

/// "Octubre 2026".
String monthYear(DateTime d) => '${_cap(_months[d.month - 1])} ${d.year}';

/// "Miércoles 21 de octubre de 2026".
String fullDate(DateTime d) =>
    '${_cap(_weekdays[d.weekday - 1])} ${d.day} de ${_months[d.month - 1]} de ${d.year}';

/// "mié 21 de octubre".
String shortDate(DateTime d) =>
    '${_weekdaysShort[d.weekday - 1].toLowerCase()} ${d.day} de ${_months[d.month - 1]}';

/// "19/10".
String dayMonth(DateTime d) => '${_two(d.day)}/${_two(d.month)}';

/// "15/10/2026".
String numericDate(DateTime d) => '${_two(d.day)}/${_two(d.month)}/${d.year}';

/// "09:30".
String hhmm(DateTime d) => '${_two(d.hour)}:${_two(d.minute)}';
String minutesToHhmm(int minutes) => '${_two(minutes ~/ 60)}:${_two(minutes % 60)}';

/// "1 h 30 min", "45 min", "2 h".
String durationText(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h > 0 && m > 0) return '$h h $m min';
  if (h > 0) return '$h h';
  return '$m min';
}

String money(int amount) => '\$ $amount';

/// "52345678" -> "52 345 678".
String phoneDisplay(String digits) {
  if (digits.length != 8) return digits;
  return '${digits.substring(0, 2)} ${digits.substring(2, 5)} ${digits.substring(5)}';
}

String plural(int n, String singular, String pluralForm) => '$n ${n == 1 ? singular : pluralForm}';

/// Minúsculas y sin acentos, para búsquedas.
String normalizeText(String s) {
  const from = 'áàäâãéèëêíìïîóòöôõúùüûñç';
  const to = 'aaaaaeeeeiiiiooooouuuunc';
  final lower = s.toLowerCase().trim();
  final b = StringBuffer();
  for (final ch in lower.split('')) {
    final i = from.indexOf(ch);
    b.write(i >= 0 ? to[i] : ch);
  }
  return b.toString();
}

String initialOf(String name) => name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
