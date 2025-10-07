import 'dart:convert';
import 'dart:html' as html;

class FileStorageService {
  static final FileStorageService _instance = FileStorageService._internal();

  factory FileStorageService() => _instance;

  FileStorageService._internal();

  // No directory on web; use a prefix for keys
  final String _prefix = 'gym_data_';

  Future<void> init() async {
    // nothing to initialize for web localStorage
    return;
  }

  Future<List<Map<String, dynamic>>> readList(String filename) async {
    try {
      final key = '$_prefix$filename';
      final val = html.window.localStorage[key];
      if (val == null) return <Map<String, dynamic>>[];
      final decoded = jsonDecode(val);
      if (decoded is List) {
        return decoded.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return <Map<String, dynamic>>[];
    } catch (e) {
      return <Map<String, dynamic>>[];
    }
  }

  Future<void> writeList(String filename, List<Map<String, dynamic>> data) async {
    final key = '$_prefix$filename';
    final encoded = const JsonEncoder.withIndent('  ').convert(data);
    html.window.localStorage[key] = encoded;
  }

  Future<String> getDirectoryPath() async {
    return 'localStorage';
  }
}
