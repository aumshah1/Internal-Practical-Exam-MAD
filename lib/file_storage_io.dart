import 'dart:convert';
import 'dart:io';

class FileStorageService {
  static final FileStorageService _instance = FileStorageService._internal();

  factory FileStorageService() => _instance;

  FileStorageService._internal();

  late Directory _appDir;

  Future<void> init() async {
    _appDir = Directory('${Directory.current.path}/gym_data');
    if (!await _appDir.exists()) {
      await _appDir.create(recursive: true);
    }
  }

  File _fileFor(String filename) => File('${_appDir.path}/$filename');

  Future<List<Map<String, dynamic>>> readList(String filename) async {
    try {
      final file = _fileFor(filename);
      if (!await file.exists()) return <Map<String, dynamic>>[];
      final contents = await file.readAsString();
      final decoded = jsonDecode(contents);
      if (decoded is List) {
        return decoded.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return <Map<String, dynamic>>[];
    } catch (e) {
      return <Map<String, dynamic>>[];
    }
  }

  Future<void> writeList(String filename, List<Map<String, dynamic>> data) async {
    final file = _fileFor(filename);
    final tmp = _fileFor('$filename.tmp');
    final encoded = const JsonEncoder.withIndent('  ').convert(data);
    await tmp.writeAsString(encoded);
    if (await file.exists()) {
      await file.delete();
    }
    await tmp.rename(file.path);
  }

  Future<String> getDirectoryPath() async {
    return _appDir.path;
  }
}
