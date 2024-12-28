import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inMinutes < 60) {
    return 'hace ${difference.inMinutes} ${difference.inMinutes == 1 ? 'minuto' : 'minutos'}';
  } else if (difference.inHours < 24) {
    return 'hace ${difference.inHours} ${difference.inHours == 1 ? 'hora' : 'horas'}';
  } else if (difference.inDays == 1) {
    return 'hace un día';
  } else if (date.year == now.year) {
    return DateFormat('d MMM, yyyy').format(date);
  } else {
    return DateFormat('MMM yyyy').format(date);
  }
}