import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';
import '../../models/guard_model.dart';
import '../../repositories/guards_repository.dart';

/// Edit Guard Screen
/// "Simplicity is the ultimate sophistication" - Steve Jobs
/// Clean, focused editing experience
class EditGuardScreen extends StatefulWidget {
  final Guard guard;

  const EditGuardScreen({
    super.key,
    required this.guard,
  });

  @override
  State<EditGuardScreen> createState() => _EditGuardScreenState();
}

class _EditGuardScreenState extends State<EditGuardScreen> {
  final GuardsRepository _repository = GuardsRepository();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _selectedCameras = [];
  bool _notifyOnDetection = true;

  // Mock camera data - in production this would come from a camera repository
  final List<Map<String, String>> _availableCameras = [
    {'id': 'CAM-001', 'name': 'Front Door'},
    {'id': 'CAM-002', 'name': 'Backyard Pool'},
    {'id': 'CAM-003', 'name': 'Driveway'},
    {'id': 'CAM-004', 'name': 'Garage'},
    {'id': 'CAM-005', 'name': 'Side Entrance'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.guard.name;
    _instructionsController.text = widget.guard.description;
    _selectedCameras.addAll(widget.guard.cameraIds);
    _notifyOnDetection = widget.guard.notifyOnDetection;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _instructionsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_nameController.text.trim().isEmpty) {
      return;
    }

    final updated = widget.guard.copyWith(
      name: _nameController.text.trim(),
      description: _instructionsController.text.trim(),
      cameraIds: _selectedCameras,
      notifyOnDetection: _notifyOnDetection,
    );

    await _repository.update(updated);

    if (mounted) {
      Navigator.pop(context, true); // Return true to indicate changes were saved
    }
  }

  bool get _hasChanges {
    return _nameController.text.trim() != widget.guard.name ||
        _instructionsController.text.trim() != widget.guard.description ||
        !_listsEqual(_selectedCameras, widget.guard.cameraIds) ||
        _notifyOnDetection != widget.guard.notifyOnDetection;
  }

  bool _listsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (!b.contains(a[i])) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Guard',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _hasChanges ? _saveChanges : null,
            child: Text(
              'Save',
              style: TextStyle(
                color: _hasChanges
                    ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                    : (isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight),
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Name section
          Text(
            'Name',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _nameController,
            style: TextStyle(
              fontSize: 17,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
            decoration: InputDecoration(
              hintText: 'e.g., Package Watch, Pool Safety',
              hintStyle: TextStyle(
                color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
              ),
              filled: true,
              fillColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Instructions section
          Text(
            'Instructions',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Tell your guard what to watch for and when to alert you.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _instructionsController,
            maxLines: 6,
            style: TextStyle(
              fontSize: 17,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
            decoration: InputDecoration(
              hintText: 'E.g., Alert me when packages are delivered to the front door. Only during daytime hours.',
              hintStyle: TextStyle(
                color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
              ),
              filled: true,
              fillColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
              alignLabelWithHint: true,
            ),
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Cameras section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cameras',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              Text(
                '${_selectedCameras.length} selected',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Choose which cameras this guard will monitor.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Camera list
          ..._availableCameras.map((camera) {
            final isSelected = _selectedCameras.contains(camera['id']);
            return _buildCameraItem(
              camera['id']!,
              camera['name']!,
              isSelected,
              isDark,
            );
          }),

          const SizedBox(height: AppSpacing.md),

          // Notification toggle
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notify me',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Get notified when this guard detects an event',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _notifyOnDetection,
                  onChanged: (value) {
                    setState(() {
                      _notifyOnDetection = value;
                    });
                  },
                  activeColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Delete guard button
          OutlinedButton(
            onPressed: () => _showDeleteConfirmation(context, isDark),
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              side: BorderSide(
                color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Delete Guard',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildCameraItem(String id, String name, bool isSelected, bool isDark) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedCameras.remove(id);
          } else {
            _selectedCameras.add(id);
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.videocam,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              size: 24,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                      : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, bool isDark) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        title: Text(
          'Delete Guard?',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        content: Text(
          'This will permanently delete "${widget.guard.name}" and cannot be undone.',
          style: TextStyle(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: TextStyle(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      await _repository.delete(widget.guard.id);
      if (mounted) {
        Navigator.pop(context, true); // Return to guards list
      }
    }
  }
}
