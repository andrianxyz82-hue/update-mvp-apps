import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class MaterialsManagementScreen extends StatelessWidget {
  const MaterialsManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Materials', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () => _showUploadDialog(context),
            icon: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 6,
        itemBuilder: (context, index) {
          return _buildMaterialCard(context, index);
        },
      ),
    );
  }

  void _showUploadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Material'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.video_library, color: AppTheme.primaryPurple),
              title: const Text('Video'),
              onTap: () {
                Navigator.pop(context);
                // Handle video upload
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: AppTheme.primaryPurple),
              title: const Text('PDF Document'),
              onTap: () {
                Navigator.pop(context);
                // Handle PDF upload
              },
            ),
            ListTile(
              leading: const Icon(Icons.image, color: AppTheme.primaryPurple),
              title: const Text('Image'),
              onTap: () {
                Navigator.pop(context);
                // Handle image upload
              },
            ),
            ListTile(
              leading: const Icon(Icons.text_fields, color: AppTheme.primaryPurple),
              title: const Text('Text Content'),
              onTap: () {
                Navigator.pop(context);
                // Handle text upload
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialCard(BuildContext context, int index) {
    final materials = [
      {'title': 'Introduction to Calculus', 'type': 'Video', 'icon': Icons.play_circle_outline, 'size': '45 MB'},
      {'title': 'Physics Chapter 5', 'type': 'PDF', 'icon': Icons.picture_as_pdf, 'size': '2.3 MB'},
      {'title': 'Biology Diagrams', 'type': 'Images', 'icon': Icons.image, 'size': '8.5 MB'},
      {'title': 'English Grammar Rules', 'type': 'Text', 'icon': Icons.text_fields, 'size': '120 KB'},
      {'title': 'Chemistry Experiments', 'type': 'Video', 'icon': Icons.play_circle_outline, 'size': '78 MB'},
      {'title': 'History Timeline', 'type': 'PDF', 'icon': Icons.picture_as_pdf, 'size': '1.8 MB'},
    ];

    final material = materials[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D44),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.lightPurple,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              material['icon'] as IconData,
              color: AppTheme.primaryPurple,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material['title'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      material['type'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• ${material['size']}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: AppTheme.textGrey),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 12),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
