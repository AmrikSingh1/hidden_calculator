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
      
      // Show upload options menu
      showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.background,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                _selectedType == VaultItemType.photo ? Icons.camera_alt : 
                _selectedType == VaultItemType.video ? Icons.videocam : 
                Icons.create_new_folder,
                color: AppColors.primary,
              ),
              title: Text('Capture ${_getNameForType(_selectedType).toLowerCase()}'),
              onTap: () {
                Navigator.pop(context);
                _captureNewMedia();
              },
            ),
            ListTile(
              leading: Icon(
                _selectedType == VaultItemType.photo ? Icons.photo_library : 
                _selectedType == VaultItemType.video ? Icons.video_library : 
                Icons.folder_open,
                color: AppColors.primary,
              ),
              title: Text('Upload from device'),
              onTap: () {
                Navigator.pop(context);
                _uploadFromDevice();
              },
            ),
            ListTile(
              leading: const Icon(Icons.note_add, color: AppColors.primary),
              title: const Text('Create sample file (for testing)'),
              onTap: () {
                Navigator.pop(context);
                _addSampleFile();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding file: $e')),
      );
    }
  }
  
  Future<void> _captureNewMedia() async {
    try {
      await _checkPermissions();
      
      // Show a message about the implementation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('In a full implementation, this would open the camera to capture ${_getNameForType(_selectedType).toLowerCase()}.'),
          duration: const Duration(seconds: 3),
        ),
      );
      
      // For demonstration, add a sample file instead
      _addSampleFile();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
  
  Future<void> _uploadFromDevice() async {
    try {
      await _checkPermissions();
      
      // Show a message about the implementation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('In a full implementation, this would open a file picker to select ${_getNameForType(_selectedType).toLowerCase()} files.'),
          duration: const Duration(seconds: 3),
        ),
      );
      
      // For demonstration, add a sample file instead
      _addSampleFile();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
  
  Future<void> _checkPermissions() async {
    if (_selectedType == VaultItemType.photo || _selectedType == VaultItemType.video) {
      final cameraStatus = await Permission.camera.request();
      final storageStatus = await Permission.storage.request();
      
      if (cameraStatus.isDenied || storageStatus.isDenied) {
        throw 'Camera or storage permission denied';
      }
    } else {
      final storageStatus = await Permission.storage.request();
      
      if (storageStatus.isDenied) {
        throw 'Storage permission denied';
      }
    }
  }
  
  Future<void> _addSampleFile() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final directory = await getTemporaryDirectory();
      late File sampleFile;
      late String fileName;
      
      // Create different sample files based on type
      switch (_selectedType) {
        case VaultItemType.photo:
          // Create a text file that simulates an image file
          fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
          sampleFile = File('${directory.path}/$fileName');
          await sampleFile.writeAsString('This is a sample image file created on ${DateTime.now()}');
          break;
          
        case VaultItemType.video:
          // Create a text file that simulates a video file
          fileName = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
          sampleFile = File('${directory.path}/$fileName');
          await sampleFile.writeAsString('This is a sample video file created on ${DateTime.now()}');
          break;
          
        case VaultItemType.document:
          // Create a text file with some sample content
          fileName = 'document_${DateTime.now().millisecondsSinceEpoch}.txt';
          sampleFile = File('${directory.path}/$fileName');
          await sampleFile.writeAsString('''
Sample Document
Created on: ${DateTime.now()}

This is a sample document file for the Hidden Calculator app vault.
In a real app, this would be an actual document that was encrypted and stored securely.

Features of this app:
- Secure storage of files
- Encryption of sensitive data
- Hidden behind a calculator interface
- Multiple file type support
          ''');
          break;
          
        case VaultItemType.note:
          // Notes are handled separately via _showNoteDialog
          setState(() {
            _isLoading = false;
          });
          return;
      }
      
      // Add the file to the vault
      await _vaultService.addFile(
        sampleFile,
        _selectedType,
        customName: fileName,
        metadata: {
          'dateCreated': DateTime.now().toIso8601String(),
          'isDemo': true,
        },
      );
      
      // Clean up the temporary file
      if (await sampleFile.exists()) {
        await sampleFile.delete();
      }
      
      _loadItems();
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added new ${_getNameForType(_selectedType).toLowerCase()} to vault'),
            backgroundColor: Colors.green,
          ),
        );
      }
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
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.onBackground.withOpacity(0.7),
          tabs: const [
            Tab(icon: Icon(Icons.photo), text: 'Photos'),
            Tab(icon: Icon(Icons.video_library), text: 'Videos'),
            Tab(icon: Icon(Icons.description), text: 'Documents'),
            Tab(icon: Icon(Icons.note), text: 'Notes'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Show a snackbar message for now
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search functionality would be implemented here')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              _showSortOptions();
            },
          ),
        ],
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
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomAppBar(
        color: AppColors.surface,
        shape: const CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.settings),
                    tooltip: 'Settings',
                    onPressed: () {
                      _showSettingsMenu(context);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.shield),
                    tooltip: 'Security',
                    onPressed: () {
                      _showSecurityOptions(context);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_sweep),
                    tooltip: 'Trash',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Trash functionality would be implemented here')),
                      );
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.grid_view),
                    tooltip: 'Change view',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('View toggle functionality would be implemented here')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
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
  
  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListTile(
            title: Text('Sort By', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today, color: AppColors.primary),
            title: const Text('Date (newest first)'),
            onTap: () {
              Navigator.pop(context);
              // Implementation would go here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sort by date functionality would be implemented here')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.sort_by_alpha, color: AppColors.primary),
            title: const Text('Name (A to Z)'),
            onTap: () {
              Navigator.pop(context);
              // Implementation would go here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sort by name functionality would be implemented here')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart, color: AppColors.primary),
            title: const Text('Size (largest first)'),
            onTap: () {
              Navigator.pop(context);
              // Implementation would go here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sort by size functionality would be implemented here')),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  
  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListTile(
            title: Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.lock_reset, color: AppColors.primary),
            title: const Text('Change Passcode'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Change passcode functionality would be implemented here')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.fingerprint, color: AppColors.primary),
            title: const Text('Biometric Authentication'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Biometric authentication settings would be implemented here')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.storage, color: AppColors.primary),
            title: const Text('Storage Settings'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Storage settings would be implemented here')),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  
  void _showSecurityOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListTile(
            title: Text('Security Options', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.lock, color: AppColors.primary),
            title: const Text('Lock Vault'),
            onTap: () {
              Navigator.pop(context);
              // Navigate back to calculator
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: const Icon(Icons.backup, color: AppColors.primary),
            title: const Text('Backup Vault'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Backup functionality would be implemented here')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.restore, color: AppColors.primary),
            title: const Text('Restore from Backup'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Restore functionality would be implemented here')),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
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
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share functionality would be implemented here')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showFileInfo(context);
            },
          ),
        ],
      ),
      body: Center(
        child: _buildFilePreview(context),
      ),
    );
  }
  
  Widget _buildFilePreview(BuildContext context) {
    switch (type) {
      case VaultItemType.photo:
        return _buildPhotoPreview(context);
      case VaultItemType.video:
        return _buildVideoPreview(context);
      case VaultItemType.document:
        return _buildDocumentPreview(context);
      case VaultItemType.note:
        return const SizedBox(); // Should not happen
    }
  }

  Widget _buildPhotoPreview(BuildContext context) {
    try {
      return InteractiveViewer(
        minScale: 0.5,
        maxScale: 3.0,
        child: Image.file(
          file, 
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Could not display image', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          },
        ),
      );
    } catch (e) {
      // For sample images that aren't real images
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.image, size: 100, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              fileName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sample image file',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildVideoPreview(BuildContext context) {
    // In a real app, you'd use a video player package
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.width * 0.5,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Icon(Icons.play_circle_fill, size: 80, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            fileName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap play to start video',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentPreview(BuildContext context) {
    try {
      // Try to read the text content of the file
      String content = file.readAsStringSync();
      
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.description, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fileName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${content.length} characters',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.onBackground.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(content),
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
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
            const SizedBox(height: 8),
            Text(
              'Error reading file: $e',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }
  
  void _showFileInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final fileStats = file.statSync();
        final fileSize = fileStats.size;
        final fileModified = fileStats.modified;
        
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'File Information',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildInfoRow('Name', fileName),
              _buildInfoRow('Type', _getTypeString()),
              _buildInfoRow('Size', _formatFileSize(fileSize)),
              _buildInfoRow('Modified', '${fileModified.day}/${fileModified.month}/${fileModified.year}'),
              _buildInfoRow('Location', 'Secure Vault'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.onBackground.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
  
  String _getTypeString() {
    switch (type) {
      case VaultItemType.photo:
        return 'Image';
      case VaultItemType.video:
        return 'Video';
      case VaultItemType.document:
        return 'Document';
      case VaultItemType.note:
        return 'Note';
    }
  }
  
  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      final kb = bytes / 1024;
      return '${kb.toStringAsFixed(1)} KB';
    } else {
      final mb = bytes / (1024 * 1024);
      return '${mb.toStringAsFixed(1)} MB';
    }
  }
} 