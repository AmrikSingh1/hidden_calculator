import 'dart:convert';
import 'dart:io';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/vault_item.dart';
import '../models/note.dart';

class VaultService {
  static const String _secureStorageKey = 'vault_encryption_key';
  static const String _vaultItemsKey = 'vault_items';
  static const String _notesKey = 'vault_notes';
  static const String _vaultDirName = 'hidden_vault';
  
  late Directory _vaultDirectory;
  late encrypt.Key _encryptionKey;
  late encrypt.IV _iv;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Uuid _uuid = const Uuid();
  
  List<VaultItem> _items = [];
  List<Note> _notes = [];
  
  // Singleton pattern
  static final VaultService _instance = VaultService._internal();
  
  factory VaultService() {
    return _instance;
  }
  
  VaultService._internal();
  
  Future<void> initialize() async {
    await _requestPermissions();
    await _initEncryption();
    await _initVaultDirectory();
    await _loadVaultItems();
    await _loadNotes();
  }
  
  Future<void> _requestPermissions() async {
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
  }
  
  Future<void> _initEncryption() async {
    String? storedKey = await _secureStorage.read(key: _secureStorageKey);
    
    if (storedKey == null) {
      // Generate a new key if none exists
      final key = encrypt.Key.fromSecureRandom(32);
      await _secureStorage.write(
        key: _secureStorageKey,
        value: base64Encode(key.bytes),
      );
      storedKey = base64Encode(key.bytes);
    }
    
    _encryptionKey = encrypt.Key(base64Decode(storedKey));
    _iv = encrypt.IV.fromLength(16);
  }
  
  Future<void> _initVaultDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    _vaultDirectory = Directory('${appDir.path}/$_vaultDirName');
    
    if (!_vaultDirectory.existsSync()) {
      _vaultDirectory.createSync(recursive: true);
    }
  }
  
  Future<void> _loadVaultItems() async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = prefs.getString(_vaultItemsKey);
    
    if (itemsJson != null) {
      final List<dynamic> decodedItems = jsonDecode(itemsJson);
      _items = decodedItems.map((item) => VaultItem.fromJson(item)).toList();
      
      // Filter out items that no longer exist
      _items = _items.where((item) => item.exists).toList();
      await _saveVaultItems();
    }
  }
  
  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getString(_notesKey);
    
    if (notesJson != null) {
      final List<dynamic> decodedNotes = jsonDecode(notesJson);
      _notes = decodedNotes.map((note) => Note.fromJson(note)).toList();
    }
  }
  
  Future<void> _saveVaultItems() async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = jsonEncode(_items.map((item) => item.toJson()).toList());
    await prefs.setString(_vaultItemsKey, itemsJson);
  }
  
  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = jsonEncode(_notes.map((note) => note.toJson()).toList());
    await prefs.setString(_notesKey, notesJson);
  }
  
  encrypt.Encrypter get _encrypter => encrypt.Encrypter(encrypt.AES(_encryptionKey));
  
  Future<VaultItem> addFile(File sourceFile, VaultItemType type, {String? customName, Map<String, dynamic>? metadata}) async {
    final fileName = customName ?? sourceFile.path.split('/').last;
    final String id = _uuid.v4();
    final targetPath = '${_vaultDirectory.path}/$id${_getExtension(fileName)}';
    
    // Encrypt and copy the file
    final fileBytes = await sourceFile.readAsBytes();
    final encryptedBytes = _encrypter.encrypt(base64Encode(fileBytes), iv: _iv).bytes;
    await File(targetPath).writeAsBytes(encryptedBytes);
    
    final vaultItem = VaultItem(
      id: id,
      fileName: fileName,
      filePath: targetPath,
      dateAdded: DateTime.now(),
      type: type,
      metadata: metadata,
    );
    
    _items.add(vaultItem);
    await _saveVaultItems();
    
    return vaultItem;
  }
  
  Future<File> decryptFile(VaultItem item) async {
    final encryptedBytes = await File(item.filePath).readAsBytes();
    final decryptedBase64 = _encrypter.decrypt64(base64Encode(encryptedBytes), iv: _iv);
    final decryptedBytes = base64Decode(decryptedBase64);
    
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/${item.fileName}');
    await tempFile.writeAsBytes(decryptedBytes);
    
    return tempFile;
  }
  
  Future<bool> deleteItem(String id) async {
    final itemIndex = _items.indexWhere((item) => item.id == id);
    
    if (itemIndex == -1) {
      return false;
    }
    
    final item = _items[itemIndex];
    
    // Delete the file
    try {
      if (item.exists) {
        await item.file.delete();
      }
      
      _items.removeAt(itemIndex);
      await _saveVaultItems();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<Note> addNote(String title, String content, {List<String>? tags}) async {
    final note = Note(
      id: _uuid.v4(),
      title: title,
      content: content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      tags: tags,
    );
    
    _notes.add(note);
    await _saveNotes();
    
    return note;
  }
  
  Future<bool> updateNote(Note note) async {
    final noteIndex = _notes.indexWhere((n) => n.id == note.id);
    
    if (noteIndex == -1) {
      return false;
    }
    
    _notes[noteIndex] = note;
    await _saveNotes();
    
    return true;
  }
  
  Future<bool> deleteNote(String id) async {
    final noteIndex = _notes.indexWhere((note) => note.id == id);
    
    if (noteIndex == -1) {
      return false;
    }
    
    _notes.removeAt(noteIndex);
    await _saveNotes();
    
    return true;
  }
  
  String _getExtension(String fileName) {
    final parts = fileName.split('.');
    if (parts.length > 1) {
      return '.${parts.last}';
    }
    return '';
  }
  
  List<VaultItem> getItemsByType(VaultItemType type) {
    return _items.where((item) => item.type == type).toList();
  }
  
  List<Note> getAllNotes() {
    return List.from(_notes);
  }
  
  List<VaultItem> getAllItems() {
    return List.from(_items);
  }
  
  Future<void> clearVault() async {
    for (var item in _items) {
      if (item.exists) {
        await item.file.delete();
      }
    }
    
    _items.clear();
    _notes.clear();
    
    await _saveVaultItems();
    await _saveNotes();
  }
} 