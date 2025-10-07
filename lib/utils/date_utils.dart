String nowIso() => DateTime.now().toUtc().toIso8601String();

DateTime parseIso(String s) => DateTime.parse(s);
