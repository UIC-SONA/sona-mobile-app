enum Direction {
  asc("asc"),
  desc("desc");

  final String value;

  const Direction(this.value);

  bool get isAsc => this == Direction.asc;

  bool get isDesc => this == Direction.desc;

  static Direction fromString(String value) {
    return Direction.values.firstWhere((e) => e.value == value);
  }
}
