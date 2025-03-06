extension StringExtension on String {
  String get capFirst => isEmpty ? '' : '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
}