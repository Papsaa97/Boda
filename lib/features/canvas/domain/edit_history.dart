/// Historie úprav plánu pro zpět/znovu (FR-P6). Drží posledních
/// [limit] kroků; nový krok smaže větev „znovu“.
class EditHistory<T> {
  EditHistory(this._present, {this.limit = 20});

  final int limit;
  final List<T> _past = [];
  final List<T> _future = [];
  T _present;

  T get present => _present;
  bool get canUndo => _past.isNotEmpty;
  bool get canRedo => _future.isNotEmpty;

  void push(T next) {
    if (next == _present) return;
    _past.add(_present);
    if (_past.length > limit) _past.removeAt(0);
    _future.clear();
    _present = next;
  }

  /// Nahradí současný stav bez nového kroku (rozpracovaný tah uzlem).
  void replace(T next) => _present = next;

  /// Uzavře tah uzlem jako jeden krok: zpět vrátí stav [before].
  void commitFrom(T before) {
    if (before == _present) return;
    _past.add(before);
    if (_past.length > limit) _past.removeAt(0);
    _future.clear();
  }

  T undo() {
    if (_past.isEmpty) return _present;
    _future.add(_present);
    _present = _past.removeLast();
    return _present;
  }

  T redo() {
    if (_future.isEmpty) return _present;
    _past.add(_present);
    _present = _future.removeLast();
    return _present;
  }
}
