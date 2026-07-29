import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../theme/app_colors.dart';
import '../../services/ai_service.dart';
import '../../providers/wardrobe_provider.dart';
import '../../models/wardrobe_item.dart';
import '../../services/supabase_service.dart';

class AddItemScreen extends ConsumerStatefulWidget {
  const AddItemScreen({super.key});

  @override
  ConsumerState<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends ConsumerState<AddItemScreen> {
  File? _selectedImage;
  bool _isAnalyzing = false;
  bool _isSaving = false;
  Map<String, String>? _aiResult;
  final _nameController = TextEditingController();
  final _colorController = TextEditingController();
  String _selectedCategory = 'tops';

  final _categories = [
    {'key': 'tops', 'label': 'Tops', 'icon': Icons.checkroom},
    {'key': 'bottoms', 'label': 'Bottoms', 'icon': Icons.checkroom},
    {'key': 'shoes', 'label': 'Shoes', 'icon': Icons.directions_walk},
    {'key': 'outerwear', 'label': 'Outerwear', 'icon': Icons.ac_unit},
    {'key': 'accessories', 'label': 'Accessories', 'icon': Icons.diamond},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Camera permission is required'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }
    }

    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _aiResult = null;
      });
      await _analyzeImage();
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    setState(() => _isAnalyzing = true);

    try {
      final result = await AIService.instance.analyzeClothing(
        _selectedImage!.path,
      );

      setState(() {
        _aiResult = result;
        _selectedCategory = result['category'] ?? 'tops';
        _nameController.text = result['brand'] ?? '';
        _colorController.text = result['color'] ?? '';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI analysis failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _saveItem() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an item name'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = SupabaseService.instance.client.auth.currentUser;
      if (user == null) throw Exception('Not authenticated');

      String imageUrl = '';
      String? transparentImageUrl;

      // Upload image to Supabase Storage
      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

        await SupabaseService.instance.client.storage
            .from('wardrobe-images')
            .uploadBinary('$user.id/$fileName', bytes);

        imageUrl = SupabaseService.instance.client.storage
            .from('wardrobe-images')
            .getPublicUrl('$user.id/$fileName');
      }

      final item = WardrobeItem(
        userId: user.id,
        name: name,
        category: ClothingCategory.values.firstWhere((c) => c.name == _selectedCategory),
        color: _colorController.text.trim().isNotEmpty ? _colorController.text.trim() : (_aiResult?['color'] ?? 'Unknown'),
        material: _aiResult?['material'],
        brand: _aiResult?['brand'],
        style: _aiResult?['style'] != null
            ? ClothingStyle.values.firstWhere(
                (s) => s.name == _aiResult!['style'],
                orElse: () => ClothingStyle.casual,
              )
            : null,
        imageUrl: imageUrl,
        transparentImageUrl: transparentImageUrl,
        suitableSeasons: const [Season.spring, Season.summer, Season.autumn, Season.winter],
        warmthRating: 5,
      );

      await ref.read(wardrobeProvider.notifier).addItem(item);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item added to wardrobe!'), backgroundColor: AppColors.success),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
        actions: [
          if (_selectedImage != null)
            TextButton(
              onPressed: _isSaving ? null : _saveItem,
              child: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.electricBlue),
                    )
                  : const Text('Save', style: TextStyle(color: AppColors.electricBlue)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_selectedImage == null) ...[
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: AppColors.darkGray,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.electricBlue.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(Icons.add_a_photo, size: 48, color: AppColors.electricBlue),
                    ),
                    const SizedBox(height: 24),
                    const Text('Add a photo of your clothing',
                        style: TextStyle(color: AppColors.mediumGray, fontSize: 16)),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt, color: AppColors.matteBlack),
                        label: const Text('Take Photo'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Choose from Gallery'),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Image preview
              Center(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(_selectedImage!, height: 240, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _selectedImage = null;
                          _aiResult = null;
                          _nameController.clear();
                          _colorController.clear();
                        }),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.matteBlack.withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: AppColors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // AI analysis status
              if (_isAnalyzing) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.darkGray,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: AppColors.electricBlue, strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text('AI analyzing your item...', style: TextStyle(color: AppColors.mediumGray)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // AI result badge
              if (_aiResult != null && !_isAnalyzing) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'AI detected: ${_aiResult!['category'] ?? ''} - ${_aiResult!['color'] ?? ''}',
                          style: const TextStyle(color: AppColors.success),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Name
              const Text('Name', style: TextStyle(color: AppColors.mediumGray, fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'e.g. Blue Nike Hoodie'),
              ),
              const SizedBox(height: 16),

              // Color
              const Text('Color', style: TextStyle(color: AppColors.mediumGray, fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: _colorController,
                decoration: const InputDecoration(hintText: 'e.g. Navy Blue'),
              ),
              const SizedBox(height: 20),

              // Category
              const Text('Category', style: TextStyle(color: AppColors.mediumGray, fontSize: 14)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat['key'];
                  return ChoiceChip(
                    selected: isSelected,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(cat['icon'] as IconData, size: 16),
                        const SizedBox(width: 4),
                        Text(cat['label'] as String),
                      ],
                    ),
                    onSelected: (_) => setState(() => _selectedCategory = cat['key'] as String),
                    selectedColor: AppColors.electricBlue,
                    backgroundColor: AppColors.darkGray,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.matteBlack : AppColors.white,
                    ),
                    side: BorderSide.none,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // AI-detected extras
              if (_aiResult != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.darkGray,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('AI Detection Results',
                          style: TextStyle(color: AppColors.electricBlue, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      if (_aiResult!['material'] != null) _DetailRow('Material', _aiResult!['material']!),
                      if (_aiResult!['brand'] != null) _DetailRow('Brand', _aiResult!['brand']!),
                      if (_aiResult!['style'] != null) _DetailRow('Style', _aiResult!['style']!),
                      if (_aiResult!['warmth_rating'] != null) _DetailRow('Warmth', _aiResult!['warmth_rating']!),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Background removal
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    if (_selectedImage == null) return;
                    try {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Removing background...')),
                      );
                      // TODO: Upload image first, then call API with URL
                      await AIService.instance.removeBackground(
                        _selectedImage!.path,
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Background removed!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.error),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.content_cut),
                  label: const Text('Remove Background'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.mediumGray, fontSize: 13)),
          Text(value, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w500, fontSize: 13)),
        ],
      ),
    );
  }
}
