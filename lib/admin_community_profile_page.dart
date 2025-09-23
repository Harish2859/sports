import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'admin_community_page.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class AdminCommunityProfilePage extends StatefulWidget {
  final Community community;

  const AdminCommunityProfilePage({super.key, required this.community});

  @override
  State<AdminCommunityProfilePage> createState() => _AdminCommunityProfilePageState();
}

class _AdminCommunityProfilePageState extends State<AdminCommunityProfilePage>
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
    final primaryColor = Color(0xFF2563EB);
    final onlineCount = widget.community.members.where((m) => m.isOnline ?? false).length;

    return Scaffold(
      backgroundColor: isDarkMode ? Color(0xFF111827) : Color(0xFFFAFBFC),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.community.name,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? Colors.white : Color(0xFF111827),
                              height: 1.2,
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'ADMIN',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
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
                            _buildStat("${widget.community.posts.length}", "Posts", isDarkMode),
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
                            Icon(Icons.edit_outlined, size: 18),
                            SizedBox(width: 12),
                            Text('Edit Community'),
                          ]
                        ),
                        value: 'edit',
                      ),
                      PopupMenuItem<String>(
                        child: Row(
                          children: [
                            Icon(Icons.person_add_outlined, size: 18),
                            SizedBox(width: 12),
                            Text('Add'),
                          ]
                        ),
                        value: 'add_members',
                      ),
                      PopupMenuItem<String>(
                        child: Row(
                          children: [
                            Icon(Icons.settings_outlined, size: 18),
                            SizedBox(width: 12),
                            Text('Community Settings'),
                          ]
                        ),
                        value: 'settings',
                      ),
                      PopupMenuDivider(),
                      PopupMenuItem<String>(
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 18, color: Colors.red),
                            SizedBox(width: 12),
                            Text('Delete Community', style: TextStyle(color: Colors.red)),
                          ]
                        ),
                        value: 'delete',
                      ),
                    ],
                    icon: Icon(Icons.more_vert_outlined),
                    onSelected: (value) {
                      _handleAdminAction(value, context);
                    },
                  ),
                ),
              ],
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildPrimaryButton(
                            'Add Members',
                            Icons.person_add_outlined,
                            primaryColor,
                            () => _handleAdminAction('add_members', context),
                          ),
                        ),
                        SizedBox(width: 16),
                        _buildSecondaryButton(
                          'Edit',
                          Icons.edit_outlined,
                          isDarkMode,
                          () => _handleAdminAction('edit', context),
                        ),
                        SizedBox(width: 16),
                        _buildSecondaryButton(
                          'Settings',
                          Icons.settings_outlined,
                          isDarkMode,
                          () => _handleAdminAction('settings', context),
                        ),
                      ],
                    ),
                    SizedBox(height: 32),

                    _buildAboutSection(isDarkMode, primaryColor),
                    SizedBox(height: 32),

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
                  child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 16),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Admin Announcement",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : Color(0xFF111827),
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "You have full admin privileges for this community.",
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
                  "Admin",
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
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
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _showEditDescriptionDialog(),
                          child: Icon(
                            Icons.edit,
                            color: primaryColor,
                            size: 18,
                          ),
                        ),
                        SizedBox(width: 12),
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
                  ],
                ),
                SizedBox(height: 12),
                AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  child: Text(
                    _isAboutExpanded 
                      ? "${widget.community.description}\n\nAs an admin, you can manage members, moderate content, and customize community settings. Use your privileges responsibly to maintain a positive environment."
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.community.members.length} participants',
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Color(0xFF8696A0) : Color(0xFF667781),
                ),
              ),
              GestureDetector(
                onTap: () => _handleAdminAction('add_members', context),
                child: Text(
                  'Add Members',
                  style: TextStyle(
                    fontSize: 14,
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
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
      'Swimming 🏊♂️',
      'Running 🏃♂️',
      'Cycling 🚴♂️'
    ];
    final aboutText = aboutTexts[member.name.hashCode % aboutTexts.length];
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
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
          if (member.role != 'Admin')
            PopupMenuButton<String>(
              onSelected: (value) => _handleMemberAction(value, member),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'make_admin',
                  child: Row(
                    children: [
                      Icon(Icons.admin_panel_settings, size: 18),
                      SizedBox(width: 8),
                      Text('Make Admin'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'remove',
                  child: Row(
                    children: [
                      Icon(Icons.person_remove, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Remove', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              child: Icon(
                Icons.more_vert,
                color: isDarkMode ? Color(0xFF8696A0) : Color(0xFF667781),
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  void _handleAdminAction(String action, BuildContext context) {
    String message;
    Color backgroundColor;
    
    switch (action) {
      case 'edit':
        message = 'Edit community feature';
        backgroundColor = Color(0xFF2563EB);
        break;
      case 'add_members':
        message = 'Add members feature';
        backgroundColor = Color(0xFF2563EB);
        break;
      case 'settings':
        message = 'Community settings';
        backgroundColor = Color(0xFF6B7280);
        break;
      case 'delete':
        _showDeleteCommunityDialog();
        return;
      default:
        message = 'Admin action: $action';
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

  void _handleMemberAction(String action, Member member) {
    String message;
    switch (action) {
      case 'make_admin':
        message = '${member.name} is now an admin';
        break;
      case 'remove':
        message = '${member.name} removed from community';
        break;
      default:
        message = 'Action performed on ${member.name}';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Color(0xFF2563EB),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _showEditDescriptionDialog() {
    final controller = TextEditingController(text: widget.community.description);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Description'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Community description...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Description updated')),
              );
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteCommunityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Community'),
        content: Text('Are you sure you want to delete "${widget.community.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Community deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}

extension MemberExtension on Member {
  bool? get isOnline => [true, false, null].elementAt(name.hashCode % 3);
}