// import 'dart:convert';
import 'dart:convert';
import 'dart:io';
import 'package:eventbooking/services/admin_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';
import 'package:intl/intl.dart';

class AddEvent extends StatefulWidget {
  const AddEvent({super.key});

  @override
  State<AddEvent> createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  final TextEditingController namecontroller = TextEditingController();
  final TextEditingController pricecontroller = TextEditingController();
  final TextEditingController detailcontroller = TextEditingController();
  final TextEditingController locationcontroller = TextEditingController();

  final AdminDatabase adminDb = AdminDatabase();

  List<String> departmentList = [];
  List<String> selectedDepartments = [];
  bool isAllSelected = false;

  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  bool isUploading = false;

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);

  static const cloudName = 'dlbqnh3lx';
  static const uploadPreset = 'flutter_eventbooking';

  @override
  void initState() {
    super.initState();
    fetchDepartmentsFromFirebase();
  }

  Future<void> fetchDepartmentsFromFirebase() async {
    final departments = await adminDb.getDepartments();
    setState(() {
      departmentList = departments;
    });
  }

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
      final jsonRes = json.decode(resStr);
      return jsonRes['secure_url'];
    } else {
      return null;
    }
  }

  Future<void> getImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage = File(image.path);
      setState(() {});
    }
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() => selectedDate = pickedDate);
    }
  }

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (pickedTime != null) {
      setState(() => selectedTime = pickedTime);
    }
  }

  String formatTimeofDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('hh:mm a').format(dt);
  }

  void _showDepartmentDialog() {
    showDialog(
      context: context,
      builder: (context) {
        List<String> tempList = List.from(selectedDepartments);
        return AlertDialog(
          title: const Text(
            "Select Departments",
            style: TextStyle(color: Color(0xFF003B49)),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    CheckboxListTile(
                      title: const Text(
                        "All Departments",
                        style: TextStyle(color: Color(0xFF003B49)),
                      ),
                      value: isAllSelected,
                      onChanged: (value) {
                        setState(() {
                          isAllSelected = value!;
                          if (isAllSelected) {
                            tempList = List.from(departmentList);
                          } else {
                            tempList.clear();
                          }
                        });
                      },
                    ),
                    const Divider(),
                    ...departmentList.map(
                      (dept) => CheckboxListTile(
                        title: Text(
                          dept,
                          style: const TextStyle(color: Color(0xFF003B49)),
                        ),
                        value: tempList.contains(dept),
                        onChanged: (value) {
                          setState(() {
                            if (value!) {
                              tempList.add(dept);
                            } else {
                              tempList.remove(dept);
                              isAllSelected = false;
                            }
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
              child: const Text(
                "CANCEL",
                style: TextStyle(color: Color(0xFF003B49)),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003B49),
              ),
              child: const Text("OK"),
              onPressed: () {
                setState(() {
                  selectedDepartments = tempList;
                  isAllSelected =
                      selectedDepartments.length == departmentList.length;
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF3F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios_new_outlined,
                      color: Color(0xFF003B49),
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Text(
                    "Add Event",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF003B49),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              selectedImage != null
                  ? Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        selectedImage!,
                        height: 140,
                        width: 140,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                  : Center(
                    child: GestureDetector(
                      onTap: getImage,
                      child: Container(
                        height: 140,
                        width: 140,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Color(0xFF003B49),
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          color: Color(0xFF003B49),
                        ),
                      ),
                    ),
                  ),
              const SizedBox(height: 30),
              _buildTextLabel("Event Name"),
              _buildTextField(namecontroller, "Enter Event Name"),
              _buildTextLabel("Price"),
              _buildTextField(pricecontroller, "Enter Price"),
              _buildTextLabel("Location"),
              _buildTextField(locationcontroller, "Enter Location"),
              _buildTextLabel("Select Departments"),
              InkWell(
                onTap: _showDepartmentDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Color(0xFF003B49)),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    selectedDepartments.isEmpty
                        ? "Select Departments"
                        : selectedDepartments.join(', '),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF003B49),
                    ),
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
                          color: Color(0xFF003B49),
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('yyyy-MM-dd').format(selectedDate),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF003B49),
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
                          color: Color(0xFF003B49),
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formatTimeofDay(selectedTime),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF003B49),
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
                detailcontroller,
                "What will be on that event...",
                maxLines: 5,
              ),
              const SizedBox(height: 20),
              isUploading
                  ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF003B49)),
                  )
                  : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: uploadEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF003B49),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: const Text(
                          "Add Event",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

  Widget _buildTextLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Color(0xFF003B49),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0xFF003B49)),
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Color(0xFF003B49)),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Future<void> uploadEvent() async {
    if (selectedImage == null ||
        namecontroller.text.isEmpty ||
        pricecontroller.text.isEmpty ||
        locationcontroller.text.isEmpty ||
        detailcontroller.text.isEmpty ||
        selectedDepartments.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => isUploading = true);
    final imageUrl = await uploadImageToCloudinary(selectedImage!);
    if (imageUrl == null) {
      setState(() => isUploading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Image upload failed")));
      return;
    }

    final String id = randomAlphaNumeric(10);
    final Map<String, dynamic> eventData = {
      "Image": imageUrl,
      "Name": namecontroller.text,
      "Price": pricecontroller.text,
      "Departments": selectedDepartments,
      "Location": locationcontroller.text,
      "Detail": detailcontroller.text,
      "Date": DateFormat('yyyy-MM-dd').format(selectedDate),
      "Time": formatTimeofDay(selectedTime),
    };

    await adminDb.addEvent(eventData, id);

    setState(() {
      isUploading = false;
      namecontroller.clear();
      pricecontroller.clear();
      detailcontroller.clear();
      locationcontroller.clear();
      selectedImage = null;
      selectedDepartments.clear();
      isAllSelected = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Event added successfully"),
        backgroundColor: Colors.green,
      ),
    );
  }
}
