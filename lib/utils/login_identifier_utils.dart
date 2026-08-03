import '../data/local_db.dart';

String normalizePhoneDigits(String value) =>
    value.replaceAll(RegExp(r'\D'), '');

bool phonesMatch(String? stored, String input) {
  final a = normalizePhoneDigits(stored ?? '');
  final b = normalizePhoneDigits(input);
  if (a.isEmpty || b.isEmpty) return false;
  if (a == b) return true;
  return a.endsWith(b) || b.endsWith(a);
}

bool emailsMatch(String? stored, String input) {
  final a = (stored ?? '').trim().toLowerCase();
  final b = input.trim().toLowerCase();
  return a.isNotEmpty && a == b;
}

bool usernamesMatch(String? stored, String input) {
  final a = (stored ?? '').trim().toLowerCase();
  final b = input.trim().toLowerCase();
  return a.isNotEmpty && a == b;
}

bool looksLikeEmail(String input) => input.contains('@');

bool looksLikePhone(String input) {
  final digits = normalizePhoneDigits(input);
  return digits.length >= 7 &&
      RegExp(r'^[\d+\s\-().]+$').hasMatch(input.trim());
}

User? findCachedUserByIdentifier(
  List<User> users,
  String rawInput, {
  bool usernameOwnersOnly = true,
}) {
  final input = rawInput.trim();
  if (input.isEmpty) return null;

  User? tryMatch(bool Function(User u) predicate) {
    for (final user in users) {
      if (predicate(user)) return user;
    }
    return null;
  }

  if (looksLikeEmail(input)) {
    return tryMatch((u) => emailsMatch(u.email, input));
  }

  if (looksLikePhone(input)) {
    return tryMatch((u) => phonesMatch(u.phoneNumber, input));
  }

  return tryMatch((u) {
    if (!usernamesMatch(u.name, input)) return false;
    if (!usernameOwnersOnly) return true;
    return u.role.toUpperCase() == 'OWNER';
  });
}
