/// ANSI styling for the console output.
///
/// Every helper is a no-op when colors are off, so the same format strings
/// work in a terminal that renders escape codes and in one that does not.
class ConsolePalette {
  const ConsolePalette({this.enabled = true});

  final bool enabled;

  String dim(String text) => _wrap('2', text);

  String bold(String text) => _wrap('1', text);

  String red(String text) => _wrap('31', text);

  String green(String text) => _wrap('32', text);

  String yellow(String text) => _wrap('33', text);

  String blue(String text) => _wrap('34', text);

  String magenta(String text) => _wrap('35', text);

  String cyan(String text) => _wrap('36', text);

  /// Colors an HTTP method the same way the inspector list does.
  String method(String text, String httpMethod) {
    return switch (httpMethod.toUpperCase()) {
      'GET' => green(text),
      'POST' => yellow(text),
      'PUT' => blue(text),
      'PATCH' => magenta(text),
      'DELETE' => red(text),
      _ => cyan(text),
    };
  }

  /// Colors a status code by its class.
  String status(String text, int? statusCode) {
    if (statusCode == null) return red(text);
    if (statusCode >= 500) return red(text);
    if (statusCode >= 400) return yellow(text);
    if (statusCode >= 300) return cyan(text);
    return green(text);
  }

  String _wrap(String code, String text) =>
      enabled ? '\x1B[${code}m$text\x1B[0m' : text;
}
