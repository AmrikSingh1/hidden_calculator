import 'dart:io';

enum VaultItemType {
  photo,
  video,
  document,
  note
}

class VaultItem {
  final String id;
  final String fileName;
  final String filePath;
  final DateTime dateAdded;
  final VaultItemType type;
  final String? thumbnailPath;
  final Map<String, dynamic>? metadata;

  VaultItem({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.dateAdded,
    required this.type,
    this.thumbnailPath,
    this.metadata,
  });

  File get file => File(filePath);
  
  bool get exists => file.existsSync();
  
  Future<int> get fileSize async => file.length();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'filePath': filePath,
      'dateAdded': dateAdded.toIso8601String(),
      'type': type.toString(),
      'thumbnailPath': thumbnailPath,
      'metadata': metadata,
    };
  }

  factory VaultItem.fromJson(Map<String, dynamic> json) {
    return VaultItem(
      id: json['id'],
      fileName: json['fileName'],
      filePath: json['filePath'],
      dateAdded: DateTime.parse(json['dateAdded']),
      type: VaultItemType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => VaultItemType.document,
      ),
      thumbnailPath: json['thumbnailPath'],
      metadata: json['metadata'],
    );
  }
} 