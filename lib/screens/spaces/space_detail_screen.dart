import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/clean_card.dart';
import '../../core/theme/app_colors.dart';
import '../../models/space_model.dart';
import '../cameras/camera_viewer_screen.dart';

/// Space Detail Screen - Clean Apple-style hierarchical navigation
class SpaceDetailScreen extends StatefulWidget {
  final SpaceItem space;
  final List<String> breadcrumbs;

  const SpaceDetailScreen({
    super.key,
    required this.space,
    this.breadcrumbs = const [],
  });

  @override
  State<SpaceDetailScreen> createState() => _SpaceDetailScreenState();
}

class _SpaceDetailScreenState extends State<SpaceDetailScreen> {
  late SpaceItem _currentSpace;

  @override
  void initState() {
    super.initState();
    _currentSpace = widget.space;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_currentSpace.name),
            if (widget.breadcrumbs.isNotEmpty)
              Text(
                widget.breadcrumbs.join(' › '),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
          ],
        ),
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: _currentSpace.itemCount == 0
          ? _buildEmptyState(context)
          : CustomScrollView(
              slivers: [
                // Info
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    child: Text(
                      'Level ${_currentSpace.level + 1} • ${_currentSpace.totalCameraCount} cameras',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                ),

                // Sub-spaces
                if (_currentSpace.subSpaces.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.md,
                        AppSpacing.lg,
                        AppSpacing.sm,
                      ),
                      child: Text(
                        'SPACES',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: _buildSubSpaceRow(context, _currentSpace.subSpaces[index]),
                          );
                        },
                        childCount: _currentSpace.subSpaces.length,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.lg),
                  ),
                ],

                // Cameras
                if (_currentSpace.cameras.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.md,
                        AppSpacing.lg,
                        AppSpacing.md,
                      ),
                      child: Text(
                        'CAMERAS',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: AppSpacing.md,
                        mainAxisSpacing: AppSpacing.md,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return _buildCameraGridCard(context, _currentSpace.cameras[index]);
                        },
                        childCount: _currentSpace.cameras.length,
                      ),
                    ),
                  ),
                ],

                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOptions(context),
        child: const Icon(CupertinoIcons.add),
      ),
    );
  }

  Widget _buildSubSpaceRow(BuildContext context, SpaceItem subSpace) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CleanCard(
      onTap: () => _navigateToSubSpace(subSpace),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.folder,
              size: 20,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subSpace.name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${subSpace.totalCameraCount} cameras',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          Icon(
            CupertinoIcons.chevron_right,
            size: 20,
            color: isDark
                ? AppColors.textTertiaryDark
                : AppColors.textTertiaryLight,
          ),
        ],
      ),
    );
  }

  Widget _buildCameraRow(BuildContext context, CameraItem camera) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isOnline = camera.status == 'online';

    return CleanCard(
      onTap: () => _navigateToCamera(camera),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.videocam,
              size: 20,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        camera.name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isOnline ? AppColors.success : AppColors.warning,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  camera.id,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          Icon(
            CupertinoIcons.chevron_right,
            size: 20,
            color: isDark
                ? AppColors.textTertiaryDark
                : AppColors.textTertiaryLight,
          ),
        ],
      ),
    );
  }

  Widget _buildCameraGridCard(BuildContext context, CameraItem camera) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isOnline = camera.status == 'online';

    return CleanCard(
      onTap: () => _navigateToCamera(camera),
      padding: EdgeInsets.zero,
      enablePressAnimation: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Camera preview area
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.03),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Stack(
                children: [
                  // Camera icon in center
                  Center(
                    child: Icon(
                      CupertinoIcons.videocam,
                      size: 48,
                      color: isDark
                          ? Colors.white.withOpacity(0.3)
                          : Colors.black.withOpacity(0.2),
                    ),
                  ),

                  // Status indicator in top-right
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isOnline
                            ? AppColors.success.withOpacity(0.9)
                            : AppColors.warning.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isOnline ? 'LIVE' : 'OFF',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Camera info
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  camera.name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  camera.id,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.folder_open,
            size: 64,
            color: isDark
                ? AppColors.textTertiaryDark
                : AppColors.textTertiaryLight,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Empty Space',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Add spaces or cameras to get started',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToSubSpace(SpaceItem subSpace) {
    final newBreadcrumbs = [...widget.breadcrumbs, _currentSpace.name];
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SpaceDetailScreen(
          space: subSpace,
          breadcrumbs: newBreadcrumbs,
        ),
      ),
    );
  }

  void _navigateToCamera(CameraItem camera) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CameraViewerScreen(
          cameraId: camera.id,
          cameraName: camera.name,
          location: camera.location,
          streamUrl: camera.streamUrl,
        ),
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.md),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiaryDark,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            if (_currentSpace.canAddSubSpace())
              ListTile(
                leading: const Icon(CupertinoIcons.folder_badge_plus),
                title: const Text('Add Sub-space'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddSubSpaceDialog();
                },
              ),

            ListTile(
              leading: const Icon(CupertinoIcons.videocam),
              title: const Text('Add Camera'),
              onTap: () {
                Navigator.pop(context);
                _showAddCameraDialog();
              },
            ),

            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  void _showAddSubSpaceDialog() {
    if (!_currentSpace.canAddSubSpace()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum nesting level (10) reached'),
        ),
      );
      return;
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final icons = [
      CupertinoIcons.folder,
      CupertinoIcons.building_2_fill,
      CupertinoIcons.house,
      CupertinoIcons.building_2_fill,
      CupertinoIcons.bag,
      CupertinoIcons.building_2_fill,
    ];

    IconData selectedIcon = CupertinoIcons.folder;
    final nameController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiaryLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                Text(
                  'New Sub-space',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'e.g., Floor 1',
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                Text(
                  'Icon',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: icons.map((icon) {
                    final isSelected = selectedIcon == icon;
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: InkWell(
                        onTap: () {
                          setModalState(() {
                            selectedIcon = icon;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1))
                                : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            icon,
                            color: isDark ? Colors.white70 : Colors.black54,
                            size: 22,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.xl),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      final name = nameController.text.trim();
                      if (name.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a name')),
                        );
                        return;
                      }

                      // Add the new sub-space
                      setState(() {
                        // Pure monochrome - no color
                        final newSubSpace = SpaceItem(
                          id: 'SPACE-${DateTime.now().millisecondsSinceEpoch}',
                          name: name,
                          icon: selectedIcon,
                          level: _currentSpace.level + 1,
                        );
                        _currentSpace.subSpaces.add(newSubSpace);
                      });

                      Navigator.of(context).pop();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Sub-space "$name" added')),
                      );
                    },
                    child: const Text('Create Sub-space'),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddCameraDialog() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final nameController = TextEditingController();
    final urlController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              Text(
                'New Camera',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'e.g., Main Entrance',
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'Stream URL',
                  hintText: 'rtsp:// or https://',
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final url = urlController.text.trim();

                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a name')),
                      );
                      return;
                    }

                    if (url.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a stream URL')),
                      );
                      return;
                    }

                    // Add the new camera
                    setState(() {
                      final newCamera = CameraItem(
                        id: 'CAM-${DateTime.now().millisecondsSinceEpoch}',
                        name: name,
                        location: _currentSpace.name,
                        streamUrl: url,
                        status: 'online',
                      );
                      _currentSpace.cameras.add(newCamera);
                    });

                    Navigator.of(context).pop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Camera "$name" added')),
                    );
                  },
                  child: const Text('Add Camera'),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
