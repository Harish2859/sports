import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'community_page.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class CommunityProfilePage extends StatefulWidget {
  final Community community;

  const CommunityProfilePage({super.key, required this.community});

  @override
  State<CommunityProfilePage> createState() => _CommunityProfilePageState();
}

class _CommunityProfilePageState extends State<CommunityProfilePage>
    with TickerProviderStateMixin {
  bool _isAboutExpanded = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;
    final theme = Theme.of(context);
    final primaryColor = Color(0xFF2563EB); // Professional blue
    final onlineCount = widget.community.members.where((m) => m.isOnline ?? false).length;

    return Scaffold(
      backgroundColor: isDarkMode ? Color(0xFF111827) : Color(0xFFFAFBFC),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            // Clean, minimal app bar
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              backgroundColor: isDarkMode ? Color(0xFF1F2937) : Colors.white,
              foregroundColor: isDarkMode ? Colors.white : Color(0xFF374151),
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: isDarkMode ? Color(0xFF1F2937) : Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 40),
                      // Clean community avatar
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: primaryColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            widget.community.iconUrl,
                            style: TextStyle(
                              fontSize: 48,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      // Community name with clean typography
                      Text(
                        widget.community.name,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : Color(0xFF111827),
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 16),
                      // Clean stats row
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDarkMode 
                            ? Color(0xFF374151).withOpacity(0.3)
                            : Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildStat("${widget.community.members.length}", "Members", isDarkMode),
                            _buildStatDivider(isDarkMode),
                            _buildStat("$onlineCount", "Online", isDarkMode),
                            _buildStatDivider(isDarkMode),
                            _buildStat("42", "Posts", isDarkMode),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                Container(
                  margin: EdgeInsets.only(right: 16),
                  child: PopupMenuButton<String>(
                    itemBuilder: (context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        child: Row(
                          children: [
                            Icon(Icons.person_add_outlined, size: 18),
                            SizedBox(width: 12),
                            Text('Invite'),
                          ]
                        ),
                        value: 'invite',
                      ),
                      PopupMenuItem<String>(
                        child: Row(
                          children: [
                            Icon(Icons.notifications_off_outlined, size: 18),
                            SizedBox(width: 12),
                            Text('Mute notifications'),
                          ]
                        ),
                        value: 'mute',
                      ),
                      PopupMenuDivider(),
                      PopupMenuItem<String>(
                        child: Row(
                          children: [
                            Icon(Icons.report_outlined, size: 18, color: Colors.orange),
                            SizedBox(width: 12),
                            Text('Report', style: TextStyle(color: Colors.orange)),
                          ]
                        ),
                        value: 'report',
                      ),
                      PopupMenuItem<String>(
                        child: Row(
                          children: [
                            Icon(Icons.exit_to_app_outlined, size: 18, color: Colors.red),
                            SizedBox(width: 12),
                            Text('Leave community', style: TextStyle(color: Colors.red)),
                          ]
                        ),
                        value: 'leave',
                      ),
                    ],
                    icon: Icon(Icons.more_vert_outlined),
                    onSelected: (value) {
                      _handleMenuAction(value, context);
                    },
                  ),
                ),
              ],
            ),

            // Body content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Professional action buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildPrimaryButton(
                            'Invite',
                            Icons.person_add_outlined,
                            primaryColor,
                            () => _handleAction('invite', context),
                          ),
                        ),
                        SizedBox(width: 16),
                        _buildSecondaryButton(
                          'Mute',
                          Icons.notifications_off_outlined,
                          isDarkMode,
                          () => _handleAction('mute', context),
                        ),
                        SizedBox(width: 16),
                        _buildSecondaryButton(
                          'Leave',
                          Icons.exit_to_app_outlined,
                          isDarkMode,
                          () => _handleAction('leave', context),
                          isDestructive: true,
                        ),
                      ],
                    ),
                    SizedBox(height: 32),

                    // About section
                    _buildAboutSection(isDarkMode, primaryColor),
                    SizedBox(height: 32),

                    // Members section
                    _buildMembersSection(isDarkMode, primaryColor),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String value, String label, bool isDarkMode) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Color(0xFF111827),
          ),
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Color(0xFF9CA3AF) : Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider(bool isDarkMode) {
    return Container(
      width: 1,
      height: 24,
      margin: EdgeInsets.symmetric(horizontal: 20),
      color: isDarkMode ? Color(0xFF4B5563) : Color(0xFFE5E7EB),
    );
  }

  Widget _buildPrimaryButton(String label, IconData icon, Color primaryColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(String label, IconData icon, bool isDarkMode, VoidCallback onTap, {bool isDestructive = false}) {
    final color = isDestructive ? Colors.red : (isDarkMode ? Color(0xFF9CA3AF) : Color(0xFF6B7280));
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        height: 48,
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(bool isDarkMode, Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Color(0xFF374151) : Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        children: [
          // Pinned announcement
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(
                bottom: BorderSide(
                  color: isDarkMode ? Color(0xFF374151) : Color(0xFFE5E7EB),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.campaign_outlined, color: Colors.white, size: 16),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Community Admin",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : Color(0xFF111827),
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Welcome to our community! Let's build great things together.",
                        style: TextStyle(
                          color: isDarkMode ? Color(0xFF9CA3AF) : Color(0xFF6B7280),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "2h",
                  style: TextStyle(
                    color: isDarkMode ? Color(0xFF6B7280) : Color(0xFF9CA3AF),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // About content
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'About',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : Color(0xFF111827),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _isAboutExpanded = !_isAboutExpanded),
                      child: Icon(
                        _isAboutExpanded ? Icons.expand_less : Icons.expand_more,
                        color: primaryColor,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  child: Text(
                    _isAboutExpanded 
                      ? "${widget.community.description}\n\nThis community is dedicated to fostering collaboration and innovation. We maintain high standards for discussion and encourage respectful, constructive engagement from all members."
                      : widget.community.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Color(0xFFD1D5DB) : Color(0xFF4B5563),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersSection(bool isDarkMode, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '${widget.community.members.length} participants',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Color(0xFF8696A0) : Color(0xFF667781),
            ),
          ),
        ),
        Container(
          color: isDarkMode ? Color(0xFF0B141A) : Colors.white,
          child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: widget.community.members.length,
            itemBuilder: (context, index) {
              final member = widget.community.members[index];
              return _buildMemberTile(member, isDarkMode, primaryColor);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMemberTile(Member member, bool isDarkMode, Color primaryColor) {
    final isOnline = member.isOnline ?? false;
    final aboutTexts = [
      'Hey there! I am using Sports App.',
      'Available',
      'Busy',
      'At the gym 💪',
      'Playing football ⚽',
      'Swimming 🏊‍♂️',
      'Running 🏃‍♂️',
      'Cycling 🚴‍♂️'
    ];
    final aboutText = aboutTexts[member.name.hashCode % aboutTexts.length];
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          // WhatsApp style circular profile picture
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: Text(
                member.avatarUrl,
                style: TextStyle(
                  fontSize: 22,
                  color: primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      member.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white : Color(0xFF000000),
                      ),
                    ),
                    if (member.role == 'Admin')
                      Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Text(
                          '~ Group Admin',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDarkMode ? Color(0xFF25D366) : Color(0xFF075E54),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 2),
                Text(
                  aboutText,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Color(0xFF8696A0) : Color(0xFF667781),
                    fontWeight: FontWeight.w400,
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

  void _handleMenuAction(String action, BuildContext context) {
    String message;
    Color backgroundColor;
    
    switch (action) {
      case 'invite':
        message = 'Invite feature coming soon';
        backgroundColor = Color(0xFF2563EB);
        break;
      case 'mute':
        message = 'Notifications muted';
        backgroundColor = Color(0xFF6B7280);
        break;
      case 'report':
        message = 'Community reported';
        backgroundColor = Colors.orange;
        break;
      case 'leave':
        message = 'Left community';
        backgroundColor = Colors.red;
        break;
      default:
        message = 'Action: $action';
        backgroundColor = Color(0xFF6B7280);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _handleAction(String action, BuildContext context) {
    _handleMenuAction(action, context);
  }
}

// Extension to add isOnline property to Member class
extension MemberExtension on Member {
  bool? get isOnline => [true, false, null].elementAt(name.hashCode % 3);
}