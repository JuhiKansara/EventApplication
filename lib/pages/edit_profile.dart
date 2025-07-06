// import 'package:eventbooking/services/database.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class EditProfilePage extends StatefulWidget {
//   final String currentName;
//   final String currentEmail;
//   final String currentImageUrl;

//   const EditProfilePage({
//     super.key,
//     required this.currentName,
//     required this.currentEmail,
//     required this.currentImageUrl,
//   });

//   @override
//   State<EditProfilePage> createState() => _EditProfilePageState();
// }

// class _EditProfilePageState extends State<EditProfilePage> {
//   final _formKey = GlobalKey<FormState>();

//   late TextEditingController nameController;
//   late TextEditingController emailController;
//   late TextEditingController phoneController;
//   late TextEditingController collegeController;
//   String selectedGender = "";

//   String? uploadedImageUrl;
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     nameController = TextEditingController();
//     emailController = TextEditingController();
//     phoneController = TextEditingController();
//     collegeController = TextEditingController();

//     fetchUserData(); // Fetch latest user info from Firebase
//   }

//   Future<void> fetchUserData() async {
//     final uid = FirebaseAuth.instance.currentUser!.uid;
//     final userData = await DatabaseMethods().getUserDetails(uid);

//     if (userData != null) {
//       setState(() {
//         nameController.text = userData['Name'] ?? widget.currentName;
//         emailController.text = userData['Email'] ?? widget.currentEmail;
//         phoneController.text = userData['Phone'] ?? '';
//         collegeController.text = userData['College'] ?? '';
//         selectedGender = userData['Gender'] ?? '';
//         uploadedImageUrl = userData['Image'] ?? widget.currentImageUrl;
//         isLoading = false;
//       });
//     } else {
//       setState(() {
//         nameController.text = widget.currentName;
//         emailController.text = widget.currentEmail;
//         uploadedImageUrl = widget.currentImageUrl;
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> saveProfile() async {
//     if (!_formKey.currentState!.validate()) return;

//     final uid = FirebaseAuth.instance.currentUser!.uid;
//     final updatedData = {
//       'Name': nameController.text.trim(),
//       'Email': emailController.text.trim(),
//       'Phone': phoneController.text.trim(),
//       'College': collegeController.text.trim(),
//       'Gender': selectedGender,
//       'Image': uploadedImageUrl ?? '',
//     };

//     await DatabaseMethods().updateUserProfile(uid, updatedData);
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Profile updated successfully')),
//     );
//     Navigator.pop(context, true);
//   }

//   @override
//   void dispose() {
//     nameController.dispose();
//     emailController.dispose();
//     phoneController.dispose();
//     collegeController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : SingleChildScrollView(
//                 child: Container(
//                   margin: const EdgeInsets.all(20.0),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             GestureDetector(
//                               onTap: () => Navigator.pop(context),
//                               child: const Icon(Icons.arrow_back_ios_new_outlined),
//                             ),
//                             SizedBox(width: MediaQuery.of(context).size.width / 6),
//                             const Text(
//                               "Edit Profile",
//                               style: TextStyle(
//                                 color: Color(0xff6351ec),
//                                 fontSize: 25.0,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 20.0),
//                         Center(
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(10),
//                             child: Image.network(
//                               uploadedImageUrl ?? '',
//                               height: 100,
//                               width: 100,
//                               fit: BoxFit.cover,
//                               errorBuilder: (_, __, ___) => const Icon(Icons.error),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 20.0),
//                         _buildLabel("Name"),
//                         const SizedBox(height: 10.0),
//                         _buildTextField(nameController, "Enter Your Name", true),
//                         const SizedBox(height: 20.0),
//                         _buildLabel("Email"),
//                         const SizedBox(height: 10.0),
//                         _buildTextField(emailController, "Enter Your Email", true),
//                         const SizedBox(height: 20.0),
//                         _buildLabel("Phone Number"),
//                         const SizedBox(height: 10.0),
//                         _buildTextField(phoneController, "Enter Phone Number", false),
//                         const SizedBox(height: 20.0),
//                         _buildLabel("Department"),
//                         const SizedBox(height: 10.0),
//                         _buildTextField(collegeController, "Enter College or Department", false),
//                         const SizedBox(height: 20.0),
//                         _buildLabel("Gender"),
//                         const SizedBox(height: 10.0),
//                         _buildGenderDropdown(),
//                         const SizedBox(height: 30.0),
//                         Center(
//                           child: GestureDetector(
//                             onTap: saveProfile,
//                             child: Container(
//                               height: 45,
//                               width: 200,
//                               decoration: BoxDecoration(
//                                 color: const Color(0xff6351ec),
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               child: const Center(
//                                 child: Text(
//                                   "Save",
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 22.0,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 40.0),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//       ),
//     );
//   }

//   Widget _buildLabel(String text) {
//     return Text(
//       text,
//       style: const TextStyle(
//         color: Colors.black,
//         fontSize: 20.0,
//         fontWeight: FontWeight.w500,
//       ),
//     );
//   }

//   Widget _buildTextField(TextEditingController controller, String hint, bool isRequired) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 20.0),
//       width: MediaQuery.of(context).size.width,
//       decoration: BoxDecoration(
//         color: const Color(0xffececf8),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: TextFormField(
//         controller: controller,
//         validator: (value) {
//           if (isRequired && (value == null || value.trim().isEmpty)) {
//             return "This field is required";
//           }
//           return null;
//         },
//         decoration: InputDecoration(border: InputBorder.none, hintText: hint),
//       ),
//     );
//   }

//   Widget _buildGenderDropdown() {
//     const genders = ["Male", "Female", "Other"];
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 20.0),
//       width: MediaQuery.of(context).size.width,
//       decoration: BoxDecoration(
//         color: const Color(0xffececf8),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           hint: const Text("Select Gender"),
//           value: selectedGender.isEmpty ? null : selectedGender,
//           items: genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
//           onChanged: (val) => setState(() => selectedGender = val ?? ""),
//         ),
//       ),
//     );
//   }
// }






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

  /// 🔄 Fetch department list from Firestore
  Future<void> fetchDepartments() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('Departments').get();

    final depts = querySnapshot.docs.map((doc) => doc['name'].toString()).toList();

    setState(() {
      departmentList = depts;
    });
  }

  /// 👤 Fetch user data and initialize form
  Future<void> fetchUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userData = await DatabaseMethods().getUserDetails(uid);

    const validGenders = ["Male", "Female", "Other"];

    setState(() {
      emailController.text = userData?['Email'] ?? widget.currentEmail;
      phoneController.text = userData?['Phone'] ?? '';
      selectedGender = validGenders.contains(userData?['Gender']) ? userData!['Gender'] : '';
      selectedDepartment = departmentList.contains(userData?['College']) ? userData!['College'] : null;
      uploadedImageUrl = userData?['Image'] ?? widget.currentImageUrl;
      isLoading = false;
    });
  }

  /// 💾 Save updated profile
  Future<void> saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = FirebaseAuth.instance.currentUser!.uid;

    final updatedData = {
      'Email': emailController.text.trim(),
      'Phone': phoneController.text.trim(),
      'College': selectedDepartment ?? '',
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
                child: Container(
                  margin: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Icon(Icons.arrow_back_ios_new_outlined),
                            ),
                            SizedBox(width: MediaQuery.of(context).size.width / 6),
                            const Text(
                              "Edit Profile",
                              style: TextStyle(
                                color: Color(0xff6351ec),
                                fontSize: 25.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20.0),
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              uploadedImageUrl ?? '',
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.error),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20.0),
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
                        Center(
                          child: GestureDetector(
                            onTap: saveProfile,
                            child: Container(
                              height: 45,
                              width: 200,
                              decoration: BoxDecoration(
                                color: const Color(0xff6351ec),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: Text(
                                  "Save",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.bold,
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
          items: departmentList.map((dept) => DropdownMenuItem(
            value: dept,
            child: Text(dept),
          )).toList(),
          onChanged: (val) => setState(() => selectedDepartment = val),
        ),
      ),
    );
  }
}
