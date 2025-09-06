import 'package:flutter/material.dart';
import 'course_data_manager.dart';

class AdminCoursePage extends StatefulWidget {
  @override
  State<AdminCoursePage> createState() => _AdminCoursePageState();
}

class _AdminCoursePageState extends State<AdminCoursePage> {
  final TextEditingController _searchController = TextEditingController();
  final CourseDataManager _courseManager = CourseDataManager();
  String _selectedCategory = 'All';
  
  final List<AdminCourse> _courses = [
    AdminCourse(
      id: '1',
      title: 'Strength Training',
      instructor: 'Dr. Sarah Johnson',
      summary: 'Build muscle strength and power through progressive training',
      rating: 4.8,
      difficulty: 'Intermediate',
      enrolledCount: 1250,
      duration: '12 weeks',
      category: 'Strength Training',
      prerequisites: ['Basic fitness knowledge', 'Gym access'],
      description: 'Comprehensive strength training course covering progressive overload, proper form, and advanced techniques. Build real strength and learn industry best practices.',
      language: 'English',
      lastUpdated: 'December 2024',
      releaseDate: 'January 2024',
      sessionTitles: ['Introduction & Setup', 'Core Concepts', 'Practical Applications', 'Advanced Topics', 'Final Project'],
      faqQuestions: ['How long do I have access to the course?', 'Is there a certificate upon completion?', 'Can I get a refund if I\'m not satisfied?'],
      faqAnswers: ['You have lifetime access to the course materials once enrolled.', 'Yes, you will receive a certificate of completion that you can share on your professional profiles.', 'We offer a 30-day money-back guarantee if you\'re not completely satisfied with the course.'],
      sections: [
        CourseSection(
          id: '1',
          title: 'Section 1: Foundations',
          description: 'Basic strength principles and form',
          units: [
            TrainingUnit(id: '1', name: 'Warm-Up Readiness', description: 'Learn proper activation techniques', objectives: ['Perform movements smoothly', 'Follow demonstrated range'], dos: ['Keep core engaged', 'Breathe naturally'], donts: ['Don\'t rush movements', 'Avoid forcing ranges']),
            TrainingUnit(id: '2', name: 'Movement Efficiency', description: 'Master fundamental lifts', objectives: ['Maintain proper posture', 'Execute with precision'], dos: ['Focus on quality', 'Keep movements symmetrical'], donts: ['Don\'t compensate patterns', 'Avoid excessive speed']),
          ],
        ),
      ],
    ),
  ];

  final List<String> _categories = ['All', 'Strength Training', 'Football', 'Basketball', 'Swimming', 'Yoga', 'Running'];

  List<AdminCourse> get _filteredCourses {
    return _courses.where((course) {
      final matchesSearch = _searchController.text.isEmpty ||
          course.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          course.instructor.toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || course.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Course Management'),
        backgroundColor: Color(0xFF2563EB),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showAddCourseDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search courses...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Color(0xFFF3F4F6),
                  ),
                ),
                SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = category == _selectedCategory;
                      return Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: isSelected,
                          label: Text(category),
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          selectedColor: Color(0xFF2563EB).withOpacity(0.2),
                          checkmarkColor: Color(0xFF2563EB),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _filteredCourses.length,
              itemBuilder: (context, index) {
                final course = _filteredCourses[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: _buildCourseCard(course),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCourseDialog(),
        backgroundColor: Color(0xFF2563EB),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCourseCard(AdminCourse course) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Thumbnail with Admin Menu
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xFFE5E7EB),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.play_circle_outline,
                    size: 48,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _editCourse(course);
                          break;
                        case 'sections':
                          _manageSections(course);
                          break;
                        case 'delete':
                          _deleteCourse(course);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit Course'),
                      ),
                      PopupMenuItem(
                        value: 'sections',
                        child: Text('Manage Sections'),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                    icon: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.more_vert, color: Color(0xFF6B7280)),
                    ),
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
                // Course Title and Category
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        course.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFF2563EB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        course.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 8),
                
                // Instructor
                Text(
                  'by ${course.instructor}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                SizedBox(height: 12),
                
                // Course Summary
                Text(
                  course.summary,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4B5563),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                SizedBox(height: 16),
                
                // Course Stats
                Row(
                  children: [
                    // Rating
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Color(0xFFFBBF24),
                        ),
                        SizedBox(width: 4),
                        Text(
                          course.rating.toString(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(width: 16),
                    
                    // Difficulty Badge
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(course.difficulty).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        course.difficulty,
                        style: TextStyle(
                          fontSize: 12,
                          color: _getDifficultyColor(course.difficulty),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    
                    Spacer(),
                    
                    // Enrolled Count
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 16,
                          color: Color(0xFF6B7280),
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${course.enrolledCount}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                SizedBox(height: 8),
                
                // Additional Info
                Text(
                  '${course.sections.length} sections • ${course.sessionTitles.length} sessions',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
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

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Color(0xFF10B981);
      case 'intermediate':
        return Color(0xFFF59E0B);
      case 'advanced':
        return Color(0xFFEF4444);
      default:
        return Color(0xFF6B7280);
    }
  }

  void _showAddCourseDialog() {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CourseBuilderPage(
        onSave: (course) {
          if (mounted) {
            setState(() {
              _courses.add(course);
              _courseManager.addAdminCourse(course);
            });
          }
        },
      )),
    );
  }

  void _editCourse(AdminCourse course) {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CourseBuilderPage(
        course: course,
        onSave: (updatedCourse) {
          if (mounted) {
            setState(() {
              final index = _courses.indexWhere((c) => c.id == course.id);
              if (index != -1) {
                _courses[index] = updatedCourse;
                _courseManager.updateAdminCourse(updatedCourse);
              }
            });
          }
        },
      )),
    );
  }

  void _manageSections(AdminCourse course) {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SectionManagerPage(course: course)),
    );
  }

  void _deleteCourse(AdminCourse course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Course'),
        content: Text('Are you sure you want to delete "${course.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (mounted) {
                setState(() {
                  _courses.removeWhere((c) => c.id == course.id);
                  _courseManager.removeAdminCourse(course.id);
                });
              }
              Navigator.pop(context);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Course deleted successfully')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class CourseBuilderPage extends StatefulWidget {
  final AdminCourse? course;
  final Function(AdminCourse) onSave;

  CourseBuilderPage({this.course, required this.onSave});

  @override
  State<CourseBuilderPage> createState() => _CourseBuilderPageState();
}

class _CourseBuilderPageState extends State<CourseBuilderPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _instructorController;
  late TextEditingController _summaryController;
  late TextEditingController _descriptionController;
  late TextEditingController _durationController;
  late TextEditingController _languageController;
  late TextEditingController _lastUpdatedController;
  late TextEditingController _releaseDateController;
  String _selectedCategory = 'Strength Training';
  String _selectedDifficulty = 'Beginner';
  double _rating = 4.0;
  List<String> _prerequisites = [];
  List<CourseSection> _sections = [];
  List<String> _sessionTitles = [];
  List<String> _faqQuestions = [];
  List<String> _faqAnswers = [];

  final List<String> _categories = ['Strength Training', 'Football', 'Basketball', 'Swimming', 'Yoga', 'Running'];
  final List<String> _difficulties = ['Beginner', 'Intermediate', 'Advanced'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.course?.title ?? '');
    _instructorController = TextEditingController(text: widget.course?.instructor ?? '');
    _summaryController = TextEditingController(text: widget.course?.summary ?? '');
    _descriptionController = TextEditingController(text: widget.course?.description ?? '');
    _durationController = TextEditingController(text: widget.course?.duration ?? '');
    _languageController = TextEditingController(text: widget.course?.language ?? 'English');
    _lastUpdatedController = TextEditingController(text: widget.course?.lastUpdated ?? 'December 2024');
    _releaseDateController = TextEditingController(text: widget.course?.releaseDate ?? 'January 2024');
    if (widget.course != null) {
      _selectedCategory = widget.course!.category;
      _selectedDifficulty = widget.course!.difficulty;
      _rating = widget.course!.rating;
      _prerequisites = List.from(widget.course!.prerequisites);
      _sections = List.from(widget.course!.sections);
      _sessionTitles = List.from(widget.course!.sessionTitles);
      _faqQuestions = List.from(widget.course!.faqQuestions);
      _faqAnswers = List.from(widget.course!.faqAnswers);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course == null ? 'Create Course' : 'Edit Course'),
        backgroundColor: Color(0xFF2563EB),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _saveCourse,
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicInfo(),
              SizedBox(height: 24),
              _buildPrerequisites(),
              SizedBox(height: 24),
              _buildSessionTitles(),
              SizedBox(height: 24),
              _buildFAQSection(),
              SizedBox(height: 24),
              _buildSections(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFF2563EB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.info_outline, color: Color(0xFF2563EB), size: 20),
                ),
                SizedBox(width: 12),
                Text('Basic Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
              ],
            ),
            SizedBox(height: 24),
            _buildTextField(
              controller: _titleController,
              label: 'Course Title',
              hint: 'Enter course title',
              icon: Icons.school_outlined,
              required: true,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _instructorController,
              label: 'Instructor',
              hint: 'Enter instructor name',
              icon: Icons.person_outline,
              required: true,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _summaryController,
              label: 'Summary',
              hint: 'Brief course summary',
              icon: Icons.description_outlined,
              maxLines: 2,
              required: true,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Detailed course description',
              icon: Icons.article_outlined,
              maxLines: 4,
              required: true,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _durationController,
              label: 'Duration',
              hint: 'e.g., 8 weeks, 3 months',
              icon: Icons.schedule_outlined,
              required: true,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _languageController,
              label: 'Language',
              hint: 'Course language',
              icon: Icons.language_outlined,
              required: true,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _lastUpdatedController,
                    label: 'Last Updated',
                    hint: 'e.g., December 2024',
                    icon: Icons.update_outlined,
                    required: true,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _releaseDateController,
                    label: 'Release Date',
                    hint: 'e.g., January 2024',
                    icon: Icons.calendar_today_outlined,
                    required: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    value: _selectedCategory,
                    label: 'Category',
                    icon: Icons.category_outlined,
                    items: _categories,
                    onChanged: (value) => setState(() => _selectedCategory = value!),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildDropdown(
                    value: _selectedDifficulty,
                    label: 'Difficulty',
                    icon: Icons.trending_up_outlined,
                    items: _difficulties,
                    onChanged: (value) => setState(() => _selectedDifficulty = value!),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star_outline, color: Color(0xFF2563EB), size: 20),
                      SizedBox(width: 8),
                      Text('Rating: ${_rating.toStringAsFixed(1)}', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1F2937))),
                    ],
                  ),
                  SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Color(0xFF2563EB),
                      inactiveTrackColor: Color(0xFFE2E8F0),
                      thumbColor: Color(0xFF2563EB),
                      overlayColor: Color(0xFF2563EB).withOpacity(0.2),
                    ),
                    child: Slider(
                      value: _rating,
                      min: 1.0,
                      max: 5.0,
                      divisions: 40,
                      onChanged: (value) => setState(() => _rating = value),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    bool required = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Color(0xFF6B7280)),
        filled: true,
        fillColor: Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFEF4444)),
        ),
        labelStyle: TextStyle(
          color: Color(0xFF374151),
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
      ),
      validator: required ? (value) => value?.isEmpty == true ? 'This field is required' : null : null,
    );
  }

  Widget _buildDropdown({
    required String value,
    required String label,
    required IconData icon,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xFF6B7280)),
        filled: true,
        fillColor: Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
        labelStyle: TextStyle(
          color: Color(0xFF374151),
          fontWeight: FontWeight.w500,
        ),
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildPrerequisites() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.checklist_outlined, color: Color(0xFF10B981), size: 20),
                ),
                SizedBox(width: 12),
                Text('Prerequisites', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                Spacer(),
                ElevatedButton.icon(
                  onPressed: _addPrerequisite,
                  icon: Icon(Icons.add, size: 18),
                  label: Text('Add'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (_prerequisites.isEmpty)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFF6B7280), size: 20),
                    SizedBox(width: 8),
                    Text('No prerequisites added yet', style: TextStyle(color: Color(0xFF6B7280))),
                  ],
                ),
              )
            else
              ..._prerequisites.map((prereq) => Container(
                margin: EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Color(0xFFBBF7D0)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 18),
                    SizedBox(width: 8),
                    Expanded(child: Text(prereq, style: TextStyle(color: Color(0xFF1F2937)))),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 18),
                      onPressed: () {
                        if (mounted) {
                          setState(() => _prerequisites.remove(prereq));
                        }
                      },
                    ),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionTitles() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFFF59E0B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.video_library_outlined, color: Color(0xFFF59E0B), size: 20),
                ),
                SizedBox(width: 12),
                Text('Session Titles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                Spacer(),
                ElevatedButton.icon(
                  onPressed: _addSessionTitle,
                  icon: Icon(Icons.add, size: 18),
                  label: Text('Add'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF59E0B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (_sessionTitles.isEmpty)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFF6B7280), size: 20),
                    SizedBox(width: 8),
                    Text('No session titles added yet', style: TextStyle(color: Color(0xFF6B7280))),
                  ],
                ),
              )
            else
              ..._sessionTitles.asMap().entries.map((entry) => Container(
                margin: EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Color(0xFFFDE68A)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Color(0xFFF59E0B),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text('${entry.key + 1}', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(child: Text(entry.value, style: TextStyle(color: Color(0xFF1F2937)))),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 18),
                      onPressed: () {
                        if (mounted) {
                          setState(() => _sessionTitles.remove(entry.value));
                        }
                      },
                    ),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('FAQ Section', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addFAQ,
                ),
              ],
            ),
            ...List.generate(_faqQuestions.length, (index) => Card(
              margin: EdgeInsets.symmetric(vertical: 4),
              child: ExpansionTile(
                title: Text(_faqQuestions[index]),
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(_faqAnswers.length > index ? _faqAnswers[index] : ''),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => _editFAQ(index),
                              child: Text('Edit'),
                            ),
                            TextButton(
                              onPressed: () => _deleteFAQ(index),
                              child: Text('Delete', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSections() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Course Sections', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addSection,
                ),
              ],
            ),
            ..._sections.map((section) => Card(
              margin: EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text(section.title),
                subtitle: Text('${section.units.length} units'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _editSection(section),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        if (mounted) {
                          setState(() => _sections.remove(section));
                        }
                      },
                    ),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _addPrerequisite() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text('Add Prerequisite'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: 'Prerequisite'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty && mounted) {
                  setState(() => _prerequisites.add(controller.text));
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addSessionTitle() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text('Add Session Title'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: 'Session Title'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty && mounted) {
                  setState(() => _sessionTitles.add(controller.text));
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addFAQ() {
    if (!mounted) return;
    final questionController = TextEditingController();
    final answerController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add FAQ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: questionController,
                decoration: InputDecoration(labelText: 'Question'),
                maxLines: 2,
              ),
              SizedBox(height: 16),
              TextField(
                controller: answerController,
                decoration: InputDecoration(labelText: 'Answer'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (questionController.text.isNotEmpty && answerController.text.isNotEmpty && mounted) {
                  setState(() {
                    _faqQuestions.add(questionController.text);
                    _faqAnswers.add(answerController.text);
                  });
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _editFAQ(int index) {
    if (!mounted) return;
    final questionController = TextEditingController(text: _faqQuestions[index]);
    final answerController = TextEditingController(text: _faqAnswers.length > index ? _faqAnswers[index] : '');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit FAQ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: questionController,
                decoration: InputDecoration(labelText: 'Question'),
                maxLines: 2,
              ),
              SizedBox(height: 16),
              TextField(
                controller: answerController,
                decoration: InputDecoration(labelText: 'Answer'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (questionController.text.isNotEmpty && answerController.text.isNotEmpty && mounted) {
                  setState(() {
                    _faqQuestions[index] = questionController.text;
                    if (_faqAnswers.length > index) {
                      _faqAnswers[index] = answerController.text;
                    } else {
                      _faqAnswers.add(answerController.text);
                    }
                  });
                  Navigator.pop(context);
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteFAQ(int index) {
    if (!mounted) return;
    setState(() {
      _faqQuestions.removeAt(index);
      if (_faqAnswers.length > index) {
        _faqAnswers.removeAt(index);
      }
    });
  }

  void _addSection() {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SectionBuilderPage(
        onSave: (section) {
          if (mounted) {
            setState(() => _sections.add(section));
          }
        },
      )),
    );
  }

  void _editSection(CourseSection section) {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SectionBuilderPage(
        section: section,
        onSave: (updatedSection) {
          if (mounted) {
            setState(() {
              final index = _sections.indexWhere((s) => s.id == section.id);
              if (index != -1) {
                _sections[index] = updatedSection;
              }
            });
          }
        },
      )),
    );
  }

  void _saveCourse() {
    if (!mounted) return;
    if (_formKey.currentState!.validate()) {
      final course = AdminCourse(
        id: widget.course?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        instructor: _instructorController.text,
        summary: _summaryController.text,
        description: _descriptionController.text,
        rating: _rating,
        difficulty: _selectedDifficulty,
        enrolledCount: widget.course?.enrolledCount ?? 0,
        duration: _durationController.text,
        category: _selectedCategory,
        prerequisites: _prerequisites,
        sections: _sections,
        language: _languageController.text,
        lastUpdated: _lastUpdatedController.text,
        releaseDate: _releaseDateController.text,
        sessionTitles: _sessionTitles,
        faqQuestions: _faqQuestions,
        faqAnswers: _faqAnswers,
      );
      widget.onSave(course);
      Navigator.pop(context);
    }
  }
}

class SectionBuilderPage extends StatefulWidget {
  final CourseSection? section;
  final Function(CourseSection) onSave;

  SectionBuilderPage({this.section, required this.onSave});

  @override
  State<SectionBuilderPage> createState() => _SectionBuilderPageState();
}

class _SectionBuilderPageState extends State<SectionBuilderPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  List<TrainingUnit> _units = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.section?.title ?? '');
    _descriptionController = TextEditingController(text: widget.section?.description ?? '');
    if (widget.section != null) {
      _units = List.from(widget.section!.units);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.section == null ? 'Create Section' : 'Edit Section'),
        backgroundColor: Color(0xFF2563EB),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _saveSection,
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(labelText: 'Section Title'),
                    ),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Training Units', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: _addUnit,
                        ),
                      ],
                    ),
                    ..._units.map((unit) => Card(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(unit.name),
                        subtitle: Text(unit.description),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _editUnit(unit),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                  if (mounted) {
                    setState(() => _units.remove(unit));
                  }
                },
                            ),
                          ],
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addUnit() {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UnitBuilderPage(
        onSave: (unit) {
          if (mounted) {
            setState(() => _units.add(unit));
          }
        },
      )),
    );
  }

  void _editUnit(TrainingUnit unit) {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UnitBuilderPage(
        unit: unit,
        onSave: (updatedUnit) {
          if (mounted) {
            setState(() {
              final index = _units.indexWhere((u) => u.id == unit.id);
              if (index != -1) {
                _units[index] = updatedUnit;
              }
            });
          }
        },
      )),
    );
  }

  void _saveSection() {
    if (!mounted) return;
    if (_titleController.text.isNotEmpty) {
      final section = CourseSection(
        id: widget.section?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        units: _units,
      );
      widget.onSave(section);
      Navigator.pop(context);
    }
  }
}

class UnitBuilderPage extends StatefulWidget {
  final TrainingUnit? unit;
  final Function(TrainingUnit) onSave;

  UnitBuilderPage({this.unit, required this.onSave});

  @override
  State<UnitBuilderPage> createState() => _UnitBuilderPageState();
}

class _UnitBuilderPageState extends State<UnitBuilderPage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  List<String> _objectives = [];
  List<String> _dos = [];
  List<String> _donts = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.unit?.name ?? '');
    _descriptionController = TextEditingController(text: widget.unit?.description ?? '');
    if (widget.unit != null) {
      _objectives = List.from(widget.unit!.objectives);
      _dos = List.from(widget.unit!.dos);
      _donts = List.from(widget.unit!.donts);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.unit == null ? 'Create Unit' : 'Edit Unit'),
        backgroundColor: Color(0xFF2563EB),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _saveUnit,
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Unit Name'),
                    ),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            _buildListSection('Learning Objectives', _objectives),
            SizedBox(height: 16),
            _buildListSection('Do\'s', _dos),
            SizedBox(height: 16),
            _buildListSection('Don\'ts', _donts),
          ],
        ),
      ),
    );
  }

  Widget _buildListSection(String title, List<String> items) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => _addItem(title, items),
                ),
              ],
            ),
            ...items.map((item) => ListTile(
              title: Text(item),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  if (mounted) {
                    setState(() => items.remove(item));
                  }
                },
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _addItem(String title, List<String> items) {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text('Add $title'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: title),
            maxLines: 2,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  if (mounted) {
                    setState(() => items.add(controller.text));
                  }
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _saveUnit() {
    if (!mounted) return;
    if (_nameController.text.isNotEmpty) {
      final unit = TrainingUnit(
        id: widget.unit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        description: _descriptionController.text,
        objectives: _objectives,
        dos: _dos,
        donts: _donts,
      );
      widget.onSave(unit);
      Navigator.pop(context);
    }
  }
}

class SectionManagerPage extends StatelessWidget {
  final AdminCourse course;

  SectionManagerPage({required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${course.title} - Sections'),
        backgroundColor: Color(0xFF2563EB),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: course.sections.length,
        itemBuilder: (context, index) {
          final section = course.sections[index];
          return Card(
            margin: EdgeInsets.only(bottom: 16),
            child: ExpansionTile(
              title: Text(section.title),
              subtitle: Text('${section.units.length} units'),
              children: section.units.map((unit) => ListTile(
                title: Text(unit.name),
                subtitle: Text(unit.description),
                leading: Icon(Icons.play_circle_outline),
              )).toList(),
            ),
          );
        },
      ),
    );
  }
}

// Data Models
class AdminCourse {
  final String id;
  final String title;
  final String instructor;
  final String summary;
  final String description;
  final double rating;
  final String difficulty;
  final int enrolledCount;
  final String duration;
  final String category;
  final List<String> prerequisites;
  final List<CourseSection> sections;
  final String language;
  final String lastUpdated;
  final String releaseDate;
  final List<String> sessionTitles;
  final List<String> faqQuestions;
  final List<String> faqAnswers;

  AdminCourse({
    required this.id,
    required this.title,
    required this.instructor,
    required this.summary,
    required this.description,
    required this.rating,
    required this.difficulty,
    required this.enrolledCount,
    required this.duration,
    required this.category,
    required this.prerequisites,
    required this.sections,
    this.language = 'English',
    this.lastUpdated = 'December 2024',
    this.releaseDate = 'January 2024',
    this.sessionTitles = const [],
    this.faqQuestions = const [],
    this.faqAnswers = const [],
  });
}

class CourseSection {
  final String id;
  final String title;
  final String description;
  final List<TrainingUnit> units;

  CourseSection({
    required this.id,
    required this.title,
    required this.description,
    required this.units,
  });
}

class TrainingUnit {
  final String id;
  final String name;
  final String description;
  final List<String> objectives;
  final List<String> dos;
  final List<String> donts;

  TrainingUnit({
    required this.id,
    required this.name,
    required this.description,
    required this.objectives,
    required this.dos,
    required this.donts,
  });
}