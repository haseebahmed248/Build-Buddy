import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConsultHomeownersController extends GetxController {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final consultations = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchConsultations();
  }

  void fetchConsultations() async {
    try {
      isLoading.value = true;
      final architectUid = _auth.currentUser?.uid;
      if (architectUid == null) {
        Get.snackbar('Error', 'User not authenticated');
        return;
      }

      final consultationsRef = _database.child('consultations/$architectUid');
      consultationsRef.onValue.listen((event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          final consultationList = <Map<String, dynamic>>[];
          data.forEach((key, value) {
            final consultation = Map<String, dynamic>.from(value);
            consultation['id'] = key;
            consultationList.add(consultation);
          });
          consultations.assignAll(consultationList);
        } else {
          consultations.clear();
        }
        isLoading.value = false;
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch consultations: $e');
      isLoading.value = false;
    }
  }

  Future<void> addConsultation(Map<String, dynamic> consultation) async {
    try {
      final architectUid = _auth.currentUser?.uid;
      if (architectUid == null) return;

      final ref = _database.child('consultations/$architectUid').push();
      await ref.set(consultation);
      Get.snackbar('Success', 'Consultation scheduled successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to schedule consultation: $e');
    }
  }
}

class ConsultHomeownersScreen extends StatefulWidget {
  const ConsultHomeownersScreen({Key? key}) : super(key: key);

  @override
  _ConsultHomeownersScreenState createState() => _ConsultHomeownersScreenState();
}

class _ConsultHomeownersScreenState extends State<ConsultHomeownersScreen> {
  final ConsultHomeownersController _controller = Get.put(ConsultHomeownersController());
  String? _selectedFilter;

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Scheduled':
        return const Color(0xFF2ECC71); // Green
      case 'Pending':
        return const Color(0xFF3498DB); // Blue
      case 'Confirmed':
        return const Color(0xFFE67E22); // Orange
      default:
        return const Color(0xFF95A5A6); // Gray
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Consultations'),
          content: DropdownButtonFormField<String>(
            value: _selectedFilter,
            decoration: const InputDecoration(
              labelText: 'Filter by Status',
              border: OutlineInputBorder(),
            ),
            items: ['All', 'Scheduled', 'Pending', 'Confirmed']
                .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  if (_selectedFilter == 'All' || _selectedFilter == null) {
                    _controller.consultations.refresh();
                  } else {
                    _controller.consultations.value = _controller.consultations
                        .where((consultation) => consultation['status'] == _selectedFilter)
                        .toList();
                  }
                });
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E3799), Color(0xFF4834DF)],
            ),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 2))],
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                                  child: const Icon(Icons.person_outline, color: Colors.white, size: 28),
                                ),
                                const SizedBox(width: 12),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Consultations', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                    Text('Manage Homeowner Meetings', style: TextStyle(color: Colors.white70, fontSize: 14)),
                                  ],
                                ),
                              ],
                            ),
                            IconButton(icon: const Icon(Icons.filter_list, color: Colors.white), onPressed: _showFilterDialog),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF5F6FA),
      body: Stack(
        children: [
          Positioned(top: -100, right: -50, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF4834DF).withOpacity(0.1)))),
          Positioned(bottom: -80, left: -60, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF1E3799).withOpacity(0.1)))),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Obx(() {
              if (_controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              final filteredConsultations = _selectedFilter == 'All' || _selectedFilter == null
                  ? _controller.consultations
                  : _controller.consultations.where((c) => c['status'] == _selectedFilter).toList();
              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: filteredConsultations.length,
                itemBuilder: (context, index) {
                  final consultation = filteredConsultations[index];
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => _showConsultationDetails(context, consultation),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(consultation['status']).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Icon(Icons.meeting_room, color: _getStatusColor(consultation['status']), size: 24),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(consultation['homeownerName'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E3799))),
                                      const SizedBox(height: 4),
                                      Text(consultation['projectTitle'], style: TextStyle(color: Colors.grey[600], fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                                        child: Text('${consultation['date']} ${consultation['time']}', style: TextStyle(color: Colors.grey[700], fontSize: 12, fontWeight: FontWeight.w500)),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(consultation['status']).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(consultation['status'], style: TextStyle(color: _getStatusColor(consultation['status']), fontSize: 12, fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(height: 8),
                                    IconButton(
                                      icon: Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 20),
                                      onPressed: () => _showConsultationDetails(context, consultation),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ScheduleConsultationScreen())),
        icon: const Icon(Icons.add),
        label: const Text('New Consultation'),
        backgroundColor: const Color(0xFF1E3799),
      ),
    );
  }

  void _showConsultationDetails(BuildContext context, Map<String, dynamic> consultation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: _getStatusColor(consultation['status']).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.meeting_room, color: _getStatusColor(consultation['status'])),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(consultation['homeownerName'], style: const TextStyle(color: Color(0xFF1E3799), fontWeight: FontWeight.bold))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Project: ${consultation['projectTitle']}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
            const SizedBox(height: 8),
            Text('Date: ${consultation['date']} at ${consultation['time']}', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text('Notes: ${consultation['notes'] ?? 'None'}', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: _getStatusColor(consultation['status']).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(consultation['status'], style: TextStyle(color: _getStatusColor(consultation['status']), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close', style: TextStyle(color: Color(0xFF4834DF))))],
      ),
    );
  }
}

class ScheduleConsultationScreen extends StatefulWidget {
  @override
  _ScheduleConsultationScreenState createState() => _ScheduleConsultationScreenState();
}

class _ScheduleConsultationScreenState extends State<ScheduleConsultationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _homeownerController = TextEditingController();
  final _projectController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final ConsultHomeownersController _controller = Get.find();

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFF1E3799), onPrimary: Colors.white, surface: Colors.white, onSurface: Colors.black)), child: child!),
    );
    if (picked != null) setState(() => {_selectedDate = picked, _dateController.text = "${picked.day}/${picked.month}/${picked.year}"});
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFF1E3799), onPrimary: Colors.white, surface: Colors.white, onSurface: Colors.black)), child: child!),
    );
    if (picked != null) setState(() => {_selectedTime = picked, _timeController.text = picked.format(context)});
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final consultation = {
        'homeownerName': _homeownerController.text,
        'projectTitle': _projectController.text,
        'date': _dateController.text,
        'time': _timeController.text,
        'status': 'Pending',
        'notes': _notesController.text,
        'homeownerId': 'temp_homeowner_id', // Replace with actual logic to fetch homeowner ID
        'projectId': 'temp_project_id',     // Replace with actual project ID
      };
      _controller.addConsultation(consultation);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1E3799), Color(0xFF4834DF)]),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 2))],
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22), onPressed: () => Navigator.pop(context)),
                      Expanded(
                        child: Row(
                          children: [
                            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.schedule, color: Colors.white, size: 28)),
                            const SizedBox(width: 12),
                            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('Schedule Consultation', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                              Text('Book a meeting with homeowner', style: TextStyle(color: Colors.white70, fontSize: 14)),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(top: -100, right: -50, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF4834DF).withOpacity(0.1)))),
          Positioned(bottom: -80, left: -60, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF1E3799).withOpacity(0.1)))),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildFormField(controller: _homeownerController, label: 'Homeowner Name', icon: Icons.person, validator: (value) => value!.isEmpty ? 'Please enter homeowner name' : null),
                  const SizedBox(height: 16),
                  _buildFormField(controller: _projectController, label: 'Project Description', icon: Icons.work, validator: (value) => value!.isEmpty ? 'Please enter project description' : null),
                  const SizedBox(height: 16),
                  _buildFormField(controller: _dateController, label: 'Date', icon: Icons.calendar_today, readOnly: true, onTap: () => _selectDate(context), validator: (value) => value!.isEmpty ? 'Please select a date' : null),
                  const SizedBox(height: 16),
                  _buildFormField(controller: _timeController, label: 'Time', icon: Icons.access_time, readOnly: true, onTap: () => _selectTime(context), validator: (value) => value!.isEmpty ? 'Please select a time' : null),
                  const SizedBox(height: 16),
                  _buildFormField(controller: _notesController, label: 'Additional Notes', icon: Icons.notes, maxLines: 3),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3799), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 5),
                      child: const Text('Schedule Consultation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

  Widget _buildFormField({required TextEditingController controller, required String label, required IconData icon, String? Function(String?)? validator, bool readOnly = false, VoidCallback? onTap, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: TextFormField(
        controller: controller,
        validator: validator,
        readOnly: readOnly,
        onTap: onTap,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF1E3799)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: maxLines > 1 ? 20 : 0),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _homeownerController.dispose();
    _projectController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}











//////////////////
/////////UI//////////

/*
import 'package:flutter/material.dart';

class ConsultHomeownersScreen extends StatefulWidget {
  const ConsultHomeownersScreen({Key? key}) : super(key: key);

  @override
  _ConsultHomeownersScreenState createState() => _ConsultHomeownersScreenState();
}

class _ConsultHomeownersScreenState extends State<ConsultHomeownersScreen> {
  // Dummy data to simulate consultations
  final List<Map<String, dynamic>> _allConsultations = [
    {
      'homeowner': 'John Doe',
      'project': 'Kitchen Remodel',
      'date': 'December 15, 2024',
      'status': 'Scheduled',
      'icon': Icons.kitchen,
    },
    {
      'homeowner': 'Jane Smith',
      'project': 'Bathroom Renovation',
      'date': 'December 18, 2024',
      'status': 'Pending',
      'icon': Icons.bathroom,
    },
    {
      'homeowner': 'Sam Wilson',
      'project': 'Living Room Overhaul',
      'date': 'December 20, 2024',
      'status': 'Confirmed',
      'icon': Icons.living,
    },
  ];

  List<Map<String, dynamic>> _filteredConsultations = [];
  String? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _filteredConsultations = List.from(_allConsultations);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Scheduled':
        return Color(0xFF2ECC71); // Green
      case 'Pending':
        return Color(0xFF3498DB); // Blue
      case 'Confirmed':
        return Color(0xFFE67E22); // Orange
      default:
        return Color(0xFF95A5A6); // Gray
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Filter Consultations'),
          content: DropdownButtonFormField<String>(
            value: _selectedFilter,
            decoration: const InputDecoration(
              labelText: 'Filter by Status',
              border: OutlineInputBorder(),
            ),
            items: ['All', 'Scheduled', 'Pending', 'Confirmed']
                .map((status) => DropdownMenuItem(
              value: status,
              child: Text(status),
            ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  if (_selectedFilter == 'All' || _selectedFilter == null) {
                    _filteredConsultations = List.from(_allConsultations);
                  } else {
                    _filteredConsultations = _allConsultations
                        .where((consultation) =>
                    consultation['status'] == _selectedFilter)
                        .toList();
                  }
                });
                Navigator.pop(context);
              },
              child: Text('Apply'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1E3799), // Deep Blue
                Color(0xFF4834DF), // Royal Blue
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 22,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.person_outline,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Consultations',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Manage Homeowner Meetings',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(Icons.filter_list, color: Colors.white),
                              onPressed: _showFilterDialog,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Color(0xFFF5F6FA),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF4834DF).withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF1E3799).withOpacity(0.1),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: _filteredConsultations.length,
              itemBuilder: (context, index) {
                final consultation = _filteredConsultations[index];
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: EdgeInsets.only(bottom: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () =>
                            _showConsultationDetails(context, consultation),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(consultation['status'])
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Icon(
                                  consultation['icon'],
                                  color: _getStatusColor(consultation['status']),
                                  size: 24,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      consultation['homeowner'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF1E3799),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      consultation['project'],
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 8),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        consultation['date'],
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(
                                          consultation['status'])
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      consultation['status'],
                                      style: TextStyle(
                                        color: _getStatusColor(
                                            consultation['status']),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  IconButton(
                                    icon: Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.grey[400],
                                      size: 20,
                                    ),
                                    onPressed: () => _showConsultationDetails(
                                        context, consultation),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ScheduleConsultationScreen()),
          );
        },
        icon: Icon(Icons.add),
        label: Text('New Consultation'),
        backgroundColor: Color(0xFF1E3799),
      ),
    );
  }

  void _showConsultationDetails(
      BuildContext context, Map<String, dynamic> consultation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                  _getStatusColor(consultation['status']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  consultation['icon'],
                  color: _getStatusColor(consultation['status']),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  consultation['homeowner'],
                  style: TextStyle(
                    color: Color(0xFF1E3799),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Project: ${consultation['project']}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Date: ${consultation['date']}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(consultation['status'])
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  consultation['status'],
                  style: TextStyle(
                    color: _getStatusColor(consultation['status']),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(color: Color(0xFF4834DF)),
              ),
            ),
          ],
        );
      },
    );
  }
}

///
class ScheduleConsultationScreen extends StatefulWidget {
  @override
  _ScheduleConsultationScreenState createState() =>
      _ScheduleConsultationScreenState();
}

class _ScheduleConsultationScreenState extends State<ScheduleConsultationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form input
  final TextEditingController _homeownerController = TextEditingController();
  final TextEditingController _projectController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF1E3799),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF1E3799),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Here you would typically save the consultation data
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Consultation scheduled successfully!'),
          backgroundColor: Color(0xFF1E3799),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F6FA),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1E3799),
                Color(0xFF4834DF),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 22,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.schedule,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Schedule Consultation',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Book a meeting with homeowner',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF4834DF).withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF1E3799).withOpacity(0.1),
              ),
            ),
          ),
          SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildFormField(
                    controller: _homeownerController,
                    label: 'Homeowner Name',
                    icon: Icons.person,
                    validator: (value) =>
                    value!.isEmpty ? 'Please enter homeowner name' : null,
                  ),
                  SizedBox(height: 16),
                  _buildFormField(
                    controller: _projectController,
                    label: 'Project Description',
                    icon: Icons.work,
                    validator: (value) =>
                    value!.isEmpty ? 'Please enter project description' : null,
                  ),
                  SizedBox(height: 16),
                  _buildFormField(
                    controller: _dateController,
                    label: 'Date',
                    icon: Icons.calendar_today,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    validator: (value) =>
                    value!.isEmpty ? 'Please select a date' : null,
                  ),
                  SizedBox(height: 16),
                  _buildFormField(
                    controller: _timeController,
                    label: 'Time',
                    icon: Icons.access_time,
                    readOnly: true,
                    onTap: () => _selectTime(context),
                    validator: (value) =>
                    value!.isEmpty ? 'Please select a time' : null,
                  ),
                  SizedBox(height: 16),
                  _buildFormField(
                    controller: _notesController,
                    label: 'Additional Notes',
                    icon: Icons.notes,
                    maxLines: 3,
                  ),
                  SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1E3799),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        'Schedule Consultation',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        readOnly: readOnly,
        onTap: onTap,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            color: Color(0xFF1E3799),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: maxLines > 1 ? 20 : 0,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _homeownerController.dispose();
    _projectController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}*/
