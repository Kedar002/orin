import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/guard_model.dart';
import '../../repositories/guards_repository.dart';

/// 3-Step Guard Creation Wizard
/// Step 1: Name your guard
/// Step 2: Choose guard type (visual selection)
/// Step 3: Select cameras
class CreateGuardScreen extends StatefulWidget {
  const CreateGuardScreen({super.key});

  @override
  State<CreateGuardScreen> createState() => _CreateGuardScreenState();
}

class _CreateGuardScreenState extends State<CreateGuardScreen> {
  final GuardsRepository _repository = GuardsRepository();
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();

  int _currentStep = 0;
  GuardType? _selectedType;
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
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _createGuard() async {
    if (_nameController.text.isEmpty || _selectedType == null || _selectedCameras.isEmpty) {
      return;
    }

    await _repository.create(
      name: _nameController.text,
      description: _selectedType!.defaultDescription,
      type: _selectedType!,
      cameraIds: _selectedCameras,
      notifyOnDetection: _notifyOnDetection,
    );

    if (mounted) {
      Navigator.pop(context, true); // Return true to indicate success
    }
  }

  bool get _canProceed {
    switch (_currentStep) {
      case 0:
        return _nameController.text.trim().isNotEmpty;
      case 1:
        return _selectedType != null;
      case 2:
        return _selectedCameras.isNotEmpty;
      default:
        return false;
    }
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
          'New Guard',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(context, isDark),

          // Step content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1(context, isDark),
                _buildStep2(context, isDark),
                _buildStep3(context, isDark),
              ],
            ),
          ),

          // Bottom navigation
          _buildBottomNavigation(context, isDark),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;

          return Expanded(
            child: Container(
              height: 3,
              margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
              decoration: BoxDecoration(
                color: isCompleted || isActive
                    ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                    : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  // Step 1: Name your guard
  Widget _buildStep1(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Name your guard',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Give it a meaningful name that describes its purpose.',
            style: TextStyle(
              fontSize: 15,
              color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _nameController,
            autofocus: true,
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
        ],
      ),
    );
  }

  // Step 2: Choose guard type
  Widget _buildStep2(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'What should it watch for?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose the type of activity to monitor.',
            style: TextStyle(
              fontSize: 15,
              color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: GuardType.values.map((type) {
                final isSelected = _selectedType == type;
                return _buildTypeCard(type, isSelected, isDark);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeCard(GuardType type, bool isSelected, bool isDark) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
              : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type.icon,
              size: 48,
              color: isSelected
                  ? (isDark ? AppColors.backgroundDark : AppColors.backgroundLight)
                  : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
            ),
            const SizedBox(height: 12),
            Text(
              type.displayName,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? (isDark ? AppColors.backgroundDark : AppColors.backgroundLight)
                    : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Step 3: Select cameras
  Widget _buildStep3(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Select cameras',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose which cameras this guard will monitor.',
            style: TextStyle(
              fontSize: 15,
              color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              children: [
                ..._availableCameras.map((camera) {
                  final isSelected = _selectedCameras.contains(camera['id']);
                  return _buildCameraItem(
                    camera['id']!,
                    camera['name']!,
                    isSelected,
                    isDark,
                  );
                }),

                const SizedBox(height: 24),

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
                      const SizedBox(width: 12),
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
              ],
            ),
          ),
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
        margin: const EdgeInsets.only(bottom: 12),
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
              Icons.videocam_outlined,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              size: 24,
            ),
            const SizedBox(width: 12),
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

  Widget _buildBottomNavigation(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).padding.bottom + 20,
        top: 20,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  side: BorderSide(color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: _currentStep > 0 ? 1 : 1,
            child: ElevatedButton(
              onPressed: _canProceed
                  ? (_currentStep == 2 ? _createGuard : _nextStep)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                foregroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                disabledBackgroundColor: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                disabledForegroundColor: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                _currentStep == 2 ? 'Create Guard' : 'Continue',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
