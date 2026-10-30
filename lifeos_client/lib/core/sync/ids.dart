import 'package:uuid/uuid.dart';

const _uuid = Uuid();

// Fixed namespace for ids derived from content (uuid v5).
const _namespace = '6f1c2a54-3c9e-4f7b-9a43-2f0d8e5b7c11';

/// A new random record id.
String newId() => _uuid.v4();

/// The id of a habit's entry for one day. Every device derives the same id,
/// so checking a habit on two devices offline yields one entry, and
/// unchecking then re-checking reuses it.
String habitEntryId(String habitId, String date) =>
    _uuid.v5(_namespace, 'habit_entry:$habitId:$date');
