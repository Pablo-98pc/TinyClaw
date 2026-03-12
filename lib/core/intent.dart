/// The four intent categories the dispatcher can classify user input into.
enum Intent {
  chat,
  summarize,
  task,
  event;

  /// Convert from string (for JSON/DB round-trips).
  static Intent? fromString(String value) {
    return Intent.values.where((e) => e.name == value).firstOrNull;
  }
}
