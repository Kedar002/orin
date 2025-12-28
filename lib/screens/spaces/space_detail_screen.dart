import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/security_colors.dart';
import '../../models/space_model.dart';
import '../cameras/camera_viewer_screen.dart';

/// Space Detail Screen - Hierarchical folder structure (like Windows Explorer)
/// Shows sub-spaces and cameras with breadcrumb navigation
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
    return Scaffold(
      backgroundColor: SecurityColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: SecurityColors.primaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: SecurityColors.primaryText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _currentSpace.name,
              style: const TextStyle(
                color: SecurityColors.primaryText,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (widget.breadcrumbs.isNotEmpty)
              Text(
                widget.breadcrumbs.join(' › '),
                style: TextStyle(
                  color: SecurityColors.secondaryText,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.more_vert,
              color: SecurityColors.primaryText,
            ),
            onPressed: () => _showOptionsMenu(),
          ),
        ],
      ),
      body: _currentSpace.itemCount == 0
          ? _buildEmptyState()
          : CustomScrollView(
              slivers: [
                // Header with stats
                SliverToBoxAdapter(
                  child: _buildHeader(),
                ),

                // Sub-spaces section
                if (_currentSpace.subSpaces.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: _buildSectionHeader(
                      'Sub-spaces',
                      _currentSpace.subSpaces.length,
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return _buildSubSpaceCard(
                            _currentSpace.subSpaces[index],
                          );
                        },
                        childCount: _currentSpace.subSpaces.length,
                      ),
                    ),
                  ),
                ],

                // Cameras section
                if (_currentSpace.cameras.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: _buildSectionHeader(
                      'Cameras',
                      _currentSpace.cameras.length,
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return _buildCameraCard(_currentSpace.cameras[index]);
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
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _currentSpace.color.withOpacity(0.2),
            _currentSpace.color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _currentSpace.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _currentSpace.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _currentSpace.icon,
              color: _currentSpace.color,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentSpace.name,
                  style: const TextStyle(
                    color: SecurityColors.primaryText,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Level ${_currentSpace.level + 1} • ${_currentSpace.totalCameraCount} total cameras',
                  style: const TextStyle(
                    color: SecurityColors.secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: SecurityColors.primaryText,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: SecurityColors.accent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: SecurityColors.accent,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubSpaceCard(SpaceItem subSpace) {
    return GestureDetector(
      onTap: () => _navigateToSubSpace(subSpace),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: SecurityColors.secondarySurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: SecurityColors.divider,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: subSpace.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                subSpace.icon,
                color: subSpace.color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.folder,
                        color: SecurityColors.accent,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          subSpace.name,
                          style: const TextStyle(
                            color: SecurityColors.primaryText,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${subSpace.subSpaces.length} spaces • ${subSpace.totalCameraCount} cameras',
                    style: const TextStyle(
                      color: SecurityColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: SecurityColors.secondaryText,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraCard(CameraItem camera) {
    final isOnline = camera.status == 'online';

    return GestureDetector(
      onTap: () => _navigateToCamera(camera),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: SecurityColors.secondarySurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: SecurityColors.divider,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isOnline
                      ? [
                          const Color(0xFF1a1a1a),
                          const Color(0xFF2d2d2d),
                        ]
                      : [
                          SecurityColors.secondarySurface,
                          SecurityColors.secondarySurface,
                        ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isOnline ? Icons.videocam : Icons.videocam_off,
                color: isOnline
                    ? SecurityColors.accent
                    : SecurityColors.secondaryText,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    camera.name,
                    style: const TextStyle(
                      color: SecurityColors.primaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isOnline
                              ? SecurityColors.statusOnline
                              : SecurityColors.statusOffline,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          color: isOnline
                              ? SecurityColors.statusOnline
                              : SecurityColors.statusOffline,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        camera.id,
                        style: const TextStyle(
                          color: SecurityColors.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: SecurityColors.secondaryText,
            ),
          ],
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
            Icons.folder_open_outlined,
            size: 80,
            color: SecurityColors.secondaryText.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'Empty Space',
            style: TextStyle(
              color: SecurityColors.primaryText,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add sub-spaces or cameras to get started',
            style: TextStyle(
              color: SecurityColors.secondaryText,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_currentSpace.canAddSubSpace())
                ElevatedButton.icon(
                  onPressed: _showAddSubSpaceDialog,
                  icon: const Icon(Icons.create_new_folder, size: 20),
                  label: const Text('Add Sub-space'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SecurityColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _showAddCameraDialog,
                icon: const Icon(Icons.videocam, size: 20),
                label: const Text('Add Camera'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SecurityColors.secondarySurface,
                  foregroundColor: SecurityColors.primaryText,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_currentSpace.canAddSubSpace())
          FloatingActionButton(
            heroTag: 'add_subspace',
            onPressed: _showAddSubSpaceDialog,
            backgroundColor: SecurityColors.accent,
            child: const Icon(Icons.create_new_folder, color: Colors.white),
          ),
        if (_currentSpace.canAddSubSpace()) const SizedBox(height: 12),
        FloatingActionButton(
          heroTag: 'add_camera',
          onPressed: _showAddCameraDialog,
          backgroundColor: SecurityColors.secondaryAccent,
          child: const Icon(Icons.videocam, color: Colors.white),
        ),
      ],
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

  void _showAddSubSpaceDialog() {
    if (!_currentSpace.canAddSubSpace()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum nesting level (10) reached'),
          backgroundColor: SecurityColors.statusOffline,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddSubSpaceBottomSheet(
        currentLevel: _currentSpace.level,
        onAdd: (name, icon, color) {
          setState(() {
            _currentSpace.subSpaces.add(
              SpaceItem(
                id: 'SPACE-${DateTime.now().millisecondsSinceEpoch}',
                name: name,
                icon: icon,
                color: color,
                level: _currentSpace.level + 1,
              ),
            );
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sub-space "$name" created'),
              backgroundColor: SecurityColors.statusOnline,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  void _showAddCameraDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddCameraBottomSheet(
        spaceName: _currentSpace.name,
        onAdd: (name, streamUrl) {
          setState(() {
            _currentSpace.cameras.add(
              CameraItem(
                id: 'CAM-${DateTime.now().millisecondsSinceEpoch}',
                name: name,
                location: _currentSpace.name,
                streamUrl: streamUrl,
                status: 'online',
              ),
            );
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Camera "$name" added'),
              backgroundColor: SecurityColors.statusOnline,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: SecurityColors.primaryBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: SecurityColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.edit, color: SecurityColors.primaryText),
            title: const Text(
              'Rename Space',
              style: TextStyle(color: SecurityColors.primaryText),
            ),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement rename
            },
          ),
          ListTile(
            leading: const Icon(Icons.palette, color: SecurityColors.primaryText),
            title: const Text(
              'Change Color',
              style: TextStyle(color: SecurityColors.primaryText),
            ),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement color change
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: SecurityColors.statusOffline),
            title: const Text(
              'Delete Space',
              style: TextStyle(color: SecurityColors.statusOffline),
            ),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement delete
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// Add Sub-space Bottom Sheet
class _AddSubSpaceBottomSheet extends StatefulWidget {
  final int currentLevel;
  final Function(String name, IconData icon, Color color) onAdd;

  const _AddSubSpaceBottomSheet({
    required this.currentLevel,
    required this.onAdd,
  });

  @override
  State<_AddSubSpaceBottomSheet> createState() =>
      _AddSubSpaceBottomSheetState();
}

class _AddSubSpaceBottomSheetState extends State<_AddSubSpaceBottomSheet> {
  final _nameController = TextEditingController();
  IconData _selectedIcon = Icons.folder;
  Color _selectedColor = const Color(0xFF6B4CE6);

  final List<IconData> _availableIcons = [
    Icons.folder,
    Icons.living,
    Icons.door_front_door,
    Icons.yard,
    Icons.garage,
    Icons.bedroom_parent,
    Icons.kitchen,
    Icons.balcony,
    Icons.stairs,
    Icons.meeting_room,
    Icons.store,
    Icons.apartment,
  ];

  final List<Color> _availableColors = [
    const Color(0xFF6B4CE6),
    const Color(0xFF0EA5E9),
    const Color(0xFF10B981),
    const Color(0xFFF59E0B),
    const Color(0xFFEF4444),
    const Color(0xFF8B5CF6),
    const Color(0xFF06B6D4),
    const Color(0xFFEC4899),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: SecurityColors.primaryBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: SecurityColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Create Sub-space',
                        style: const TextStyle(
                          color: SecurityColors.primaryText,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: SecurityColors.accent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Level ${widget.currentLevel + 2}',
                        style: const TextStyle(
                          color: SecurityColors.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Text(
                  'Create a nested folder structure',
                  style: TextStyle(
                    color: SecurityColors.secondaryText,
                    fontSize: 14,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Space Name',
                      style: TextStyle(
                        color: SecurityColors.primaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      autofocus: true,
                      style: const TextStyle(color: SecurityColors.primaryText),
                      decoration: InputDecoration(
                        hintText: 'e.g., Floor 2, Wing A',
                        hintStyle: TextStyle(
                          color: SecurityColors.secondaryText.withOpacity(0.5),
                        ),
                        filled: true,
                        fillColor: SecurityColors.secondarySurface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: SecurityColors.divider,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: SecurityColors.divider,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: SecurityColors.accent,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Choose Icon',
                      style: TextStyle(
                        color: SecurityColors.primaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _availableIcons.map((icon) {
                        final isSelected = icon == _selectedIcon;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedIcon = icon;
                            });
                          },
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? SecurityColors.accent
                                  : SecurityColors.secondarySurface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? SecurityColors.accent
                                    : SecurityColors.divider,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Icon(
                              icon,
                              color: isSelected
                                  ? Colors.white
                                  : SecurityColors.primaryText,
                              size: 24,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Choose Color',
                      style: TextStyle(
                        color: SecurityColors.primaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _availableColors.map((color) {
                        final isSelected = color == _selectedColor;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedColor = color;
                            });
                          },
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 24,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(
                            color: SecurityColors.divider,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: SecurityColors.primaryText,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_nameController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a space name'),
                                backgroundColor: SecurityColors.statusOffline,
                              ),
                            );
                            return;
                          }
                          widget.onAdd(
                            _nameController.text.trim(),
                            _selectedIcon,
                            _selectedColor,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SecurityColors.accent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Create Sub-space',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

/// Add Camera Bottom Sheet
class _AddCameraBottomSheet extends StatefulWidget {
  final String spaceName;
  final Function(String name, String streamUrl) onAdd;

  const _AddCameraBottomSheet({
    required this.spaceName,
    required this.onAdd,
  });

  @override
  State<_AddCameraBottomSheet> createState() => _AddCameraBottomSheetState();
}

class _AddCameraBottomSheetState extends State<_AddCameraBottomSheet> {
  final _nameController = TextEditingController();
  final _streamUrlController = TextEditingController(
    text: 'https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_adv_example_hevc/master.m3u8',
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: SecurityColors.primaryBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: SecurityColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Text(
                  'Add Camera',
                  style: TextStyle(
                    color: SecurityColors.primaryText,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Text(
                  'Add a camera to ${widget.spaceName}',
                  style: const TextStyle(
                    color: SecurityColors.secondaryText,
                    fontSize: 14,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Camera Name',
                      style: TextStyle(
                        color: SecurityColors.primaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      autofocus: true,
                      style: const TextStyle(color: SecurityColors.primaryText),
                      decoration: InputDecoration(
                        hintText: 'e.g., Main Entrance Camera',
                        hintStyle: TextStyle(
                          color: SecurityColors.secondaryText.withOpacity(0.5),
                        ),
                        filled: true,
                        fillColor: SecurityColors.secondarySurface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: SecurityColors.divider,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: SecurityColors.divider,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: SecurityColors.accent,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Stream URL (HLS)',
                      style: TextStyle(
                        color: SecurityColors.primaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _streamUrlController,
                      style: const TextStyle(
                        color: SecurityColors.primaryText,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'https://...',
                        hintStyle: TextStyle(
                          color: SecurityColors.secondaryText.withOpacity(0.5),
                        ),
                        filled: true,
                        fillColor: SecurityColors.secondarySurface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: SecurityColors.divider,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: SecurityColors.divider,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: SecurityColors.accent,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(
                            color: SecurityColors.divider,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: SecurityColors.primaryText,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_nameController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a camera name'),
                                backgroundColor: SecurityColors.statusOffline,
                              ),
                            );
                            return;
                          }
                          widget.onAdd(
                            _nameController.text.trim(),
                            _streamUrlController.text.trim(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SecurityColors.accent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Add Camera',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _streamUrlController.dispose();
    super.dispose();
  }
}
