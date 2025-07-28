import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventbooking/services/admin_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class EditEventPage extends StatefulWidget {
  final String eventId;
  final Map<String, dynamic> eventData;

  const EditEventPage({
    super.key,
    required this.eventId,
    required this.eventData,
  });

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  static const Color backgroundColor = Color(0xFFEAF3F5);
  static const Color primaryColor = Color(0xFF003B49);
  static const Color fieldColor = Color(0xffe0ebee);

  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController detailController;
  late TextEditingController locationController;

  List<String> departmentList = [];
  List<String> selectedDepartments = [];
  bool isAllSelected = false;

  File? selectedImage;
  final picker = ImagePicker();
  bool isUpdating = false;

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 00);

  static const cloudName = 'ds6irznel';
  static const uploadPreset = 'flutter_eventbooking';

  Future<String?> uploadImageToCloudinary(File imageFile) async {
    final url = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );
    final request =
        http.MultipartRequest('POST', url)
          ..fields['upload_preset'] = uploadPreset
          ..files.add(
            await http.MultipartFile.fromPath('file', imageFile.path),
          );

    final response = await request.send();
    if (response.statusCode == 200) {
      final resStr = await response.stream.bytesToString();
      return json.decode(resStr)['secure_url'];
    }
    return null;
  }

  Future<void> getImage() async {
    var image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage = File(image.path);
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
      text: widget.eventData['Name'] ?? '',
    );
    priceController = TextEditingController(
      text: widget.eventData['Price'] ?? '',
    );
    detailController = TextEditingController(
      text: widget.eventData['Detail'] ?? '',
    );
    locationController = TextEditingController(
      text: widget.eventData['Location'] ?? '',
    );
    selectedDepartments = List<String>.from(
      widget.eventData['Departments'] ?? [],
    );
    selectedDate =
        DateTime.tryParse(widget.eventData['Date'] ?? '') ?? DateTime.now();
    selectedTime = _parseTime(widget.eventData['Time'] ?? '10:00 AM');

    fetchDepartments();
  }

  Future<void> fetchDepartments() async {
    List<String> departments = await AdminDatabase().getDepartments();
    setState(() {
      departmentList = departments;
      isAllSelected = selectedDepartments.length == departments.length;
    });
  }

  TimeOfDay _parseTime(String timeStr) {
    try {
      final dt = DateFormat.jm().parse(timeStr);
      return TimeOfDay.fromDateTime(dt);
    } catch (_) {
      return const TimeOfDay(hour: 10, minute: 0);
    }
  }

  String formatTimeofDay(TimeOfDay time) {
    final now = DateTime.now();
    return DateFormat(
      'hh:mm a',
    ).format(DateTime(now.year, now.month, now.day, time.hour, time.minute));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) setState(() => selectedTime = picked);
  }

  void _showDepartmentDialog() {
    List<String> tempList = List.from(selectedDepartments);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Departments"),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    CheckboxListTile(
                      title: const Text("All Departments"),
                      value: tempList.length == departmentList.length,
                      onChanged: (value) {
                        setStateDialog(() {
                          tempList = value! ? List.from(departmentList) : [];
                        });
                      },
                    ),
                    const Divider(),
                    ...departmentList.map(
                      (dept) => CheckboxListTile(
                        title: Text(dept),
                        value: tempList.contains(dept),
                        onChanged: (value) {
                          setStateDialog(() {
                            value! ? tempList.add(dept) : tempList.remove(dept);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              child: const Text("CANCEL"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              child: const Text("OK", style: TextStyle(color: Colors.white)),
              onPressed: () {
                setState(() => selectedDepartments = List.from(tempList));
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> updateEvent() async {
    setState(() => isUpdating = true);
    String? imageUrl = widget.eventData['Image'];

    if (selectedImage != null) {
      final uploaded = await uploadImageToCloudinary(selectedImage!);
      if (uploaded != null) imageUrl = uploaded;
    }

    await FirebaseFirestore.instance
        .collection("Event")
        .doc(widget.eventId)
        .update({
          "Name": nameController.text,
          "Price": priceController.text,
          "Detail": detailController.text,
          "Location": locationController.text,
          "Departments": selectedDepartments,
          "Date": DateFormat('yyyy-MM-dd').format(selectedDate),
          "Time": formatTimeofDay(selectedTime),
          "Image": imageUrl ?? '',
        });

    setState(() => isUpdating = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Event Updated Successfully")));
    Navigator.pop(context);
  }

  Widget _buildTextLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
    ),
  );

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: fieldColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(border: InputBorder.none, hintText: hint),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios_new_outlined,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Text(
                    "Edit Event",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: getImage,
                  child:
                      selectedImage != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              selectedImage!,
                              height: 140,
                              width: 140,
                              fit: BoxFit.cover,
                            ),
                          )
                          : Image.network(
                            widget.eventData['Image'] ?? '',
                            height: 140,
                            width: 140,
                            fit: BoxFit.cover,
                          ),
                ),
              ),
              const SizedBox(height: 30),
              _buildTextLabel("Event Name"),
              _buildTextField(nameController, "Enter Event Name"),
              const SizedBox(height: 20),
              _buildTextLabel("Price"),
              _buildTextField(priceController, "Enter Price"),
              const SizedBox(height: 20),
              _buildTextLabel("Location"),
              _buildTextField(locationController, "Enter Location"),
              const SizedBox(height: 20),
              _buildTextLabel("Departments"),
              GestureDetector(
                onTap: _showDepartmentDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  height: 60,
                  decoration: BoxDecoration(
                    color: fieldColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    selectedDepartments.isEmpty
                        ? "Select Departments"
                        : selectedDepartments.join(', '),
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: _pickDate,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_month,
                          color: primaryColor,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('yyyy-MM-dd').format(selectedDate),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _pickTime,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: primaryColor,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formatTimeofDay(selectedTime),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildTextLabel("Event Detail"),
              _buildTextField(
                detailController,
                "What will be on that event...",
                maxLines: 6,
              ),
              const SizedBox(height: 20),
              isUpdating
                  ? const Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  )
                  : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: updateEvent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: const Text(
                        "Update",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
