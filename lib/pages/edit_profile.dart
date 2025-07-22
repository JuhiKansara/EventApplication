import 'package:eventbooking/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  final String currentEmail;
  final String currentImageUrl;

  const EditProfilePage({
    super.key,
    required this.currentEmail,
    required this.currentImageUrl,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController emailController;
  late TextEditingController phoneController;

  String selectedGender = "";
  String? selectedDepartment;

  List<String> departmentList = [];
  String? uploadedImageUrl;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    phoneController = TextEditingController();

    fetchDepartments().then((_) => fetchUserData());
  }

  Future<void> fetchDepartments() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('Departments').get();
    final depts = querySnapshot.docs.map((doc) => doc['name'].toString()).toList();
    setState(() {
      departmentList = depts;
    });
  }

  Future<void> fetchUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userData = await DatabaseMethods().getUserDetails(uid);

    const validGenders = ["Male", "Female", "Other"];

    setState(() {
      emailController.text = userData?['Email'] ?? widget.currentEmail;
      phoneController.text = userData?['Phone'] ?? '';
      selectedGender = validGenders.contains(userData?['Gender']) ? userData!['Gender'] : '';
      selectedDepartment = departmentList.contains(userData?['Department']) ? userData!['Department'] : null;
      uploadedImageUrl = userData?['Image'] ?? widget.currentImageUrl;
      isLoading = false;
    });
  }

  Future<void> saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = FirebaseAuth.instance.currentUser!.uid;

    final updatedData = {
      'Email': emailController.text.trim(),
      'Phone': phoneController.text.trim(),
      'Department': selectedDepartment ?? '',
      'Gender': selectedGender,
      'Image': uploadedImageUrl ?? '',
    };

    await DatabaseMethods().updateUserProfile(uid, updatedData);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xffa18cd1), Color(0xfffbc2eb)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Column(
                        children: [
                          const Text(
                            "Edit Profile",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.white,
                              backgroundImage: uploadedImageUrl != null && uploadedImageUrl!.isNotEmpty
                                  ? NetworkImage(uploadedImageUrl!)
                                  : null,
                              child: uploadedImageUrl == null || uploadedImageUrl!.isEmpty
                                  ? const Icon(Icons.person, size: 30, color: Colors.grey)
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Email"),
                            const SizedBox(height: 10.0),
                            _buildTextField(emailController, "Enter Your Email", true, readOnly: true),
                            const SizedBox(height: 20.0),
                            _buildLabel("Phone Number"),
                            const SizedBox(height: 10.0),
                            _buildTextField(phoneController, "Enter Phone Number", true),
                            const SizedBox(height: 20.0),
                            _buildLabel("Department"),
                            const SizedBox(height: 10.0),
                            _buildDepartmentDropdown(),
                            const SizedBox(height: 20.0),
                            _buildLabel("Gender"),
                            const SizedBox(height: 10.0),
                            _buildGenderDropdown(),
                            const SizedBox(height: 30.0),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              child: SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: GestureDetector(
                                  onTap: saveProfile,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      gradient: const LinearGradient(
                                        colors: [Color(0xff6351ec), Color.fromARGB(255, 147, 128, 192)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "Save Profile",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 40.0),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 20.0,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    bool isRequired, {
    bool readOnly = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: readOnly ? Colors.grey.shade200 : const Color(0xffececf8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        validator: (value) {
          if (!readOnly && isRequired && (value == null || value.trim().isEmpty)) {
            return "This field is required";
          }
          return null;
        },
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
        ),
        style: TextStyle(
          color: readOnly ? Colors.grey : Colors.black,
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    const genders = ["Male", "Female", "Other"];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: const Color(0xffececf8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: const Text("Select Gender"),
          value: selectedGender.isEmpty ? null : selectedGender,
          items: genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
          onChanged: (val) => setState(() => selectedGender = val ?? ""),
        ),
      ),
    );
  }

  Widget _buildDepartmentDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: const Color(0xffececf8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: const Text("Select Department"),
          value: selectedDepartment,
          items: departmentList
              .map((dept) => DropdownMenuItem(
                    value: dept,
                    child: Text(dept),
                  ))
              .toList(),
          onChanged: (val) => setState(() => selectedDepartment = val),
        ),
      ),
    );
  }
}
