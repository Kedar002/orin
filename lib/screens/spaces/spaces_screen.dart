import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/security_colors.dart';
import '../../models/space_model.dart';
import 'space_detail_screen.dart';

/// Spaces Screen - Premium UI for managing camera spaces
/// YouTube-style feed with modern Google/Apple design
class SpacesScreen extends StatefulWidget {
  const SpacesScreen({super.key});

  @override
  State<SpacesScreen> createState() => _SpacesScreenState();
}

class _SpacesScreenState extends State<SpacesScreen> {
  List<SpaceItem> _spaces = [
    SpaceItem(
      id: 'SPACE-001',
      name: 'Hospital A',
      icon: Icons.local_hospital,
      color: const Color(0xFF6B4CE6),
      level: 0,
      cameras: [
        CameraItem(
          id: 'CAM-001',
          name: 'Main Entrance',
          location: 'Hospital A',
          streamUrl: 'https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_adv_example_hevc/master.m3u8',
        ),
      ],
    ),
    SpaceItem(
      id: 'SPACE-002',
      name: 'Hospital B',
      icon: Icons.local_hospital,
      color: const Color(0xFF0EA5E9),
      level: 0,
      cameras: [
        CameraItem(
          id: 'CAM-002',
          name: 'Reception',
          location: 'Hospital B',
          streamUrl: 'https://cph-p2p-msl.akamaized.net/hls/live/2000341/test/master.m3u8',
        ),
      ],
    ),
    SpaceItem(
      id: 'SPACE-003',
      name: 'Hospital C',
      icon: Icons.local_hospital,
      color: const Color(0xFF10B981),
      level: 0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SecurityColors.primaryBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),

            // Featured Space (if any)
            if (_spaces.isNotEmpty)
              SliverToBoxAdapter(
                child: _buildFeaturedSpace(),
              ),

            // Quick Stats
            SliverToBoxAdapter(
              child: _buildQuickStats(),
            ),

            // All Spaces Grid
            SliverToBoxAdapter(
              child: _buildSectionHeader('All Spaces'),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return _buildSpaceCard(_spaces[index]);
                  },
                  childCount: _spaces.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 100), // Space for FAB
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSpaceDialog,
        backgroundColor: SecurityColors.accent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Space',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ORIN',
                      style: GoogleFonts.orbitron(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                        color: SecurityColors.accent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Spaces',
                      style: TextStyle(
                        color: SecurityColors.primaryText,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Organize cameras by location',
                      style: TextStyle(
                        color: SecurityColors.secondaryText,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // Profile or settings icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: SecurityColors.secondarySurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: SecurityColors.divider,
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.tune,
                    size: 20,
                    color: SecurityColors.primaryText,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedSpace() {
    if (_spaces.isEmpty) return const SizedBox.shrink();
    final featured = _spaces.first;

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            featured.color,
            featured.color.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: featured.color.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToSpace(featured),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        featured.icon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            color: Colors.white,
                            size: 8,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'ACTIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      featured.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${featured.totalCameraCount} cameras monitoring',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    final totalCameras = _spaces.fold<int>(
      0,
      (sum, space) => sum + space.totalCameraCount,
    );
    final activeSpaces = _spaces.where((s) => s.status == 'active').length;

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.videocam,
              label: 'Total Cameras',
              value: totalCameras.toString(),
              color: SecurityColors.accent,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              icon: Icons.location_on,
              label: 'Active Spaces',
              value: activeSpaces.toString(),
              color: SecurityColors.statusOnline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SecurityColors.secondarySurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SecurityColors.divider,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: SecurityColors.primaryText,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: SecurityColors.secondaryText,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Text(
        title,
        style: const TextStyle(
          color: SecurityColors.primaryText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSpaceCard(SpaceItem space) {
    return GestureDetector(
      onTap: () => _navigateToSpace(space),
      child: Container(
        decoration: BoxDecoration(
          color: SecurityColors.secondarySurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: SecurityColors.divider,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon header
            Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    space.color.withOpacity(0.2),
                    space.color.withOpacity(0.05),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Icon(
                  space.icon,
                  color: space.color,
                  size: 40,
                ),
              ),
            ),

            // Space info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          space.name,
                          style: const TextStyle(
                            color: SecurityColors.primaryText,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${space.totalCameraCount} camera${space.totalCameraCount == 1 ? '' : 's'}',
                          style: const TextStyle(
                            color: SecurityColors.secondaryText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: space.status == 'active'
                                ? SecurityColors.statusOnline
                                : SecurityColors.statusOffline,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          space.status == 'active' ? 'Active' : 'Inactive',
                          style: TextStyle(
                            color: space.status == 'active'
                                ? SecurityColors.statusOnline
                                : SecurityColors.statusOffline,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToSpace(SpaceItem space) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SpaceDetailScreen(
          space: space,
        ),
      ),
    );
  }

  void _showAddSpaceDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddSpaceBottomSheet(
        onAdd: (name, icon, color) {
          setState(() {
            _spaces.add(
              SpaceItem(
                id: 'SPACE-${DateTime.now().millisecondsSinceEpoch}',
                name: name,
                icon: icon,
                color: color,
                level: 0,
              ),
            );
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Space "$name" created successfully'),
              backgroundColor: SecurityColors.statusOnline,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }
}

/// Beautiful Add Space Bottom Sheet - Google/Apple style
class _AddSpaceBottomSheet extends StatefulWidget {
  final Function(String name, IconData icon, Color color) onAdd;

  const _AddSpaceBottomSheet({required this.onAdd});

  @override
  State<_AddSpaceBottomSheet> createState() => _AddSpaceBottomSheetState();
}

class _AddSpaceBottomSheetState extends State<_AddSpaceBottomSheet> {
  final _nameController = TextEditingController();

  IconData _selectedIcon = Icons.local_hospital;
  Color _selectedColor = const Color(0xFF6B4CE6);

  final List<IconData> _availableIcons = [
    Icons.local_hospital,
    Icons.apartment,
    Icons.business,
    Icons.store,
    Icons.warehouse,
    Icons.factory,
    Icons.domain,
    Icons.house,
    Icons.villa,
    Icons.location_city,
    Icons.corporate_fare,
    Icons.holiday_village,
  ];

  final List<Color> _availableColors = [
    const Color(0xFF6B4CE6), // Purple
    const Color(0xFF0EA5E9), // Blue
    const Color(0xFF10B981), // Green
    const Color(0xFFF59E0B), // Orange
    const Color(0xFFEF4444), // Red
    const Color(0xFF8B5CF6), // Violet
    const Color(0xFF06B6D4), // Cyan
    const Color(0xFFEC4899), // Pink
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
              // Drag handle
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

              // Header
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Text(
                  'Create New Space',
                  style: TextStyle(
                    color: SecurityColors.primaryText,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Text(
                  'Create a top-level space (max 10 levels deep)',
                  style: TextStyle(
                    color: SecurityColors.secondaryText,
                    fontSize: 14,
                  ),
                ),
              ),

              // Space Name
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
                      style: const TextStyle(color: SecurityColors.primaryText),
                      decoration: InputDecoration(
                        hintText: 'e.g., Hospital A, Building 1',
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

              // Choose Icon
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

              // Choose Color
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
                                color: isSelected ? Colors.white : Colors.transparent,
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

              // Action Buttons
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
                          'Create Space',
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
