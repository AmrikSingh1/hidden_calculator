import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hidden_calculator/constants/app_constants.dart';
import 'package:hidden_calculator/models/vault_item.dart';
import 'package:hidden_calculator/services/vault_service.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({Key? key}) : super(key: key);

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> with SingleTickerProviderStateMixin {
  final VaultService _vaultService = VaultService();
  VaultItemType _selectedType = VaultItemType.photo;
  bool _isLoading = true;
  List<VaultItem> _items = [];
  
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadItems();
  }
  
  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }
  
  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        switch (_tabController.index) {
          case 0:
            _selectedType = VaultItemType.photo;
            break;
          case 1:
            _selectedType = VaultItemType.video;
            break;
          case 2:
            _selectedType = VaultItemType.document;
            break;
          case 3:
            _selectedType = VaultItemType.note;
            break;
        }
      });
      _loadItems();
    }
  }
  
  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
    });
    
    await Future.delayed(const Duration(milliseconds: 300)); // For UI transition
    
    setState(() {
      _items = _vaultService.getItemsByType(_selectedType);
      _isLoading = false;
    });
  }
  
  Future<void> _addFile() async {
    try {
      if (_selectedType == VaultItemType.note) {
        _showNoteDialog();
        return;
      }
      
      // Since we can't pick files without file_picker, we'll show a dialog explaining the limitation
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Feature Unavailable'),
          content: Text(
            'The file picker functionality has been removed for compatibility reasons.\n\n'
            'In a production app, this would use the proper file picking functionality.\n\n'
            'For now, you can add notes or test with sample files.'
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // For testing purposes, we can add a dummy file
                _addSampleFile();
              },
              child: const Text('Add Sample File'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding file: $e')),
      );
    }
  }
  
  Future<void> _addSampleFile() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Create a temporary file for demonstration
      final directory = await getTemporaryDirectory();
      final sampleFile = File('${directory.path}/sample_${DateTime.now().millisecondsSinceEpoch}.txt');
      
      // Write some sample content
      await sampleFile.writeAsString('This is a sample file created on ${DateTime.now()}');
      
      // Add it to the vault
      await _vaultService.addFile(
        sampleFile,
        _selectedType,
        customName: 'Sample ${_getNameForType(_selectedType).toLowerCase()} ${DateTime.now().millisecondsSinceEpoch}',
      );
      
      // Clean up the temporary file
      if (await sampleFile.exists()) {
        await sampleFile.delete();
      }
      
      _loadItems();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating sample file: $e')),
      );
    }
  }
  
  Future<void> _deleteItem(VaultItem item) async {
    final bool confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete ${item.fileName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;
    
    if (confirmed) {
      setState(() {
        _isLoading = true;
      });
      
      final result = await _vaultService.deleteItem(item.id);
      
      if (!result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete item')),
        );
      }
      
      _loadItems();
    }
  }
  
  void _viewItem(VaultItem item) async {
    try {
      if (_selectedType == VaultItemType.note) {
        // Handle notes separately
        return;
      }
      
      setState(() {
        _isLoading = true;
      });
      
      final decryptedFile = await _vaultService.decryptFile(item);
      
      setState(() {
        _isLoading = false;
      });
      
      if (!mounted) return;
      
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => _FileViewerScreen(
            file: decryptedFile,
            fileName: item.fileName,
            type: item.type,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error viewing file: $e')),
      );
    }
  }
  
  void _showNoteDialog({String? id, String title = '', String content = ''}) {
    final titleController = TextEditingController(text: title);
    final contentController = TextEditingController(text: content);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(id == null ? 'Add Note' : 'Edit Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final content = contentController.text.trim();
              
              if (title.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Title cannot be empty')),
                );
                return;
              }
              
              Navigator.of(context).pop();
              
              setState(() {
                _isLoading = true;
              });
              
              if (id == null) {
                await _vaultService.addNote(title, content);
              } else {
                // Handle edit note
              }
              
              _loadItems();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Vault'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.photo), text: 'Photos'),
            Tab(icon: Icon(Icons.video_library), text: 'Videos'),
            Tab(icon: Icon(Icons.description), text: 'Documents'),
            Tab(icon: Icon(Icons.note), text: 'Notes'),
          ],
        ),
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _items.isEmpty
                  ? _buildEmptyState()
                  : _buildContent(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFile,
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getIconForType(_selectedType),
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No ${_getNameForType(_selectedType)} Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add a ${_getNameForType(_selectedType).toLowerCase()}',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContent() {
    if (_selectedType == VaultItemType.photo) {
      return MasonryGridView.count(
        crossAxisCount: 2,
        itemCount: _items.length,
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        mainAxisSpacing: AppDimensions.paddingMedium,
        crossAxisSpacing: AppDimensions.paddingMedium,
        itemBuilder: (context, index) {
          return _buildImageItem(_items[index]);
        },
      );
    } else {
      return ListView.builder(
        itemCount: _items.length,
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        itemBuilder: (context, index) {
          return _buildListItem(_items[index]);
        },
      );
    }
  }
  
  Widget _buildImageItem(VaultItem item) {
    return GestureDetector(
      onTap: () => _viewItem(item),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        child: Container(
          color: AppColors.surface,
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.image,
                        size: 60,
                        color: AppColors.primary.withOpacity(0.7),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.onBackground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.error),
                  onPressed: () => _deleteItem(item),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildListItem(VaultItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
      child: ListTile(
        leading: Icon(_getIconForType(item.type)),
        title: Text(item.fileName),
        subtitle: Text(
          'Added on: ${_formatDate(item.dateAdded)}',
          style: TextStyle(
            color: AppColors.onBackground.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: AppColors.error),
          onPressed: () => _deleteItem(item),
        ),
        onTap: () => _viewItem(item),
      ),
    );
  }
  
  IconData _getIconForType(VaultItemType type) {
    switch (type) {
      case VaultItemType.photo:
        return Icons.photo;
      case VaultItemType.video:
        return Icons.video_library;
      case VaultItemType.document:
        return Icons.description;
      case VaultItemType.note:
        return Icons.note;
    }
  }
  
  String _getNameForType(VaultItemType type) {
    switch (type) {
      case VaultItemType.photo:
        return 'Photos';
      case VaultItemType.video:
        return 'Videos';
      case VaultItemType.document:
        return 'Documents';
      case VaultItemType.note:
        return 'Notes';
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _FileViewerScreen extends StatelessWidget {
  final File file;
  final String fileName;
  final VaultItemType type;
  
  const _FileViewerScreen({
    Key? key,
    required this.file,
    required this.fileName,
    required this.type,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fileName),
      ),
      body: Center(
        child: _buildFilePreview(),
      ),
    );
  }
  
  Widget _buildFilePreview() {
    switch (type) {
      case VaultItemType.photo:
        return Image.file(file);
      case VaultItemType.video:
        // For simplicity, just showing a placeholder
        // In a real app, you'd use a video player package
        return const Center(
          child: Icon(Icons.play_circle_fill, size: 80),
        );
      case VaultItemType.document:
        // For simplicity, just showing the file name
        // In a real app, you'd use a PDF/document viewer
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.description, size: 80),
              const SizedBox(height: 16),
              Text(
                fileName,
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
        );
      case VaultItemType.note:
        return const SizedBox(); // Should not happen
    }
  }
} 