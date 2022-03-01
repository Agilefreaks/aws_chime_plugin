import 'attendee.dart';

class Attendees {
  final List<Attendee> _attendees = List<Attendee>.empty(growable: true);

  get length => _attendees.length;

  Attendee operator [](int index) => _attendees[index];

  void add(Attendee attendee) => _attendees.add(attendee);

  void remove(Attendee attendee) => _attendees.remove(attendee);

  Attendee? getByTileId(int tileId) {
    for (int index = 0; index < _attendees.length; index++) {
      if (_attendees[index].tileId == tileId) return _attendees[index];
    }

    return null;
  }
}
