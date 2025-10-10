class Habit {
  final String name;
  final String description;
  bool completed;

  Habit({
    required this.name,
    required this.description,
    this.completed = false,
  });
}
