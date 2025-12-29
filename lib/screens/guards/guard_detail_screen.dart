import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/widgets/clean_card.dart';
import '../../core/theme/app_colors.dart';

/// Guard detail screen
/// Think like Steve Jobs: A Guard is your AI assistant for security.
/// You chat with it. It watches cameras. It tells you what matters.
/// This is a conversation, not a settings page.
class GuardDetailScreen extends StatefulWidget {
  final String guardName;
  final String guardSpace;
  final String guardDescription;
  final bool isActive;

  const GuardDetailScreen({
    super.key,
    required this.guardName,
    required this.guardSpace,
    required this.guardDescription,
    required this.isActive,
  });

  @override
  State<GuardDetailScreen> createState() => _GuardDetailScreenState();
}

class _GuardDetailScreenState extends State<GuardDetailScreen> {
  late bool _isActive;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _isActive = widget.isActive;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Mock cameras where this guard is watching
  List<Map<String, dynamic>> _getCameras() {
    return [
      {
        'name': 'Main Entrance',
        'id': 'CAM-001',
        'status': 'online',
      },
      {
        'name': 'Driveway',
        'id': 'CAM-002',
        'status': 'online',
      },
      {
        'name': 'Front Door',
        'id': 'CAM-003',
        'status': 'online',
      },
    ];
  }

  // Mock recent catches
  List<Map<String, String>> _getRecentCatches() {
    return [
      {'title': 'Package delivered', 'time': '2 hours ago'},
      {'title': 'Person detected', 'time': '4 hours ago'},
      {'title': 'Motion detected', 'time': 'Yesterday'},
    ];
  }

  // Mock chat messages
  List<Map<String, dynamic>> _getMessages() {
    return [
      {
        'text': 'Hi! I\'m watching your front door area. I\'ll let you know if I see any packages or visitors.',
        'isGuard': true,
        'time': '10:30 AM',
      },
      {
        'text': 'What did you catch today?',
        'isGuard': false,
        'time': '2:15 PM',
      },
      {
        'text': 'I detected a package delivery at 2:10 PM and a person at the door at 11:45 AM.',
        'isGuard': true,
        'time': '2:15 PM',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final messages = _getMessages();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.guardName),
            Text(
              _isActive ? 'Active' : 'Paused',
              style: theme.textTheme.bodySmall?.copyWith(
                color: _isActive ? AppColors.success : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showGuardInfo(context);
            },
          ),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return _buildMessageBubble(
                  context,
                  message['text'] as String,
                  message['isGuard'] as bool,
                  isDark,
                );
              },
            ),
          ),

          // Message input
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.06),
                  width: 0.5,
                ),
              ),
            ),
            padding: EdgeInsets.only(
              left: AppSpacing.md,
              right: AppSpacing.md,
              top: AppSpacing.sm,
              bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.sm,
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Message',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.05),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        isDense: true,
                      ),
                      maxLines: null,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_upward, color: Colors.white),
                      onPressed: () {
                        // Send message logic
                        _messageController.clear();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showGuardInfo(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cameras = _getCameras();
    final catches = _getRecentCatches();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              const SizedBox(height: AppSpacing.md),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiaryLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  children: [
                    // Guard name and status
                    Text(
                      widget.guardName,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _isActive ? AppColors.success : AppColors.textSecondaryLight,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          _isActive ? 'Active' : 'Paused',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          value: _isActive,
                          onChanged: (value) {
                            setState(() {
                              _isActive = value;
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Cameras section
                    Text(
                      'Cameras',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: cameras.length,
                        itemBuilder: (context, index) {
                          final camera = cameras[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              right: index < cameras.length - 1 ? AppSpacing.sm : 0,
                            ),
                            child: _buildCameraCard(context, camera, isDark),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Recent catches
                    Text(
                      'Recent catches',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ...catches.map((catch_) => _buildCatchRow(context, catch_, isDark, catch_ == catches.last)),

                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCatchRow(BuildContext context, Map<String, String> catch_, bool isDark, bool isLast) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLast
                ? Colors.transparent
                : (isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.06)),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              catch_['title']!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            catch_['time']!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraCard(BuildContext context, Map<String, dynamic> camera, bool isDark) {
    final isOnline = camera['status'] == 'online';

    return CleanCard(
      onTap: () {},
      padding: EdgeInsets.zero,
      enablePressAnimation: true,
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Camera preview
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
                    Center(
                      child: Icon(
                        Icons.videocam_outlined,
                        size: 32,
                        color: isDark
                            ? Colors.white.withOpacity(0.3)
                            : Colors.black.withOpacity(0.2),
                      ),
                    ),
                    if (isOnline)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Camera name
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Text(
                camera['name'] as String,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, String text, bool isGuard, bool isDark) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: isGuard ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isGuard) ...[
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm + 2,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                text,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ] else ...[
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm + 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

}
