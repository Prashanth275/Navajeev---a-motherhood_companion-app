import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../providers/profile_provider.dart';
import '../../providers/trimester/trimester_provider.dart';
import '../../services/auth_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final babyNameController = TextEditingController();

  DateTime? selectedDate;
  bool isSaving = false;

  String? imageUrl;
  XFile? _localImageFile;
  Uint8List? _imageBytes;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();

    final provider = context.read<ProfileProvider>();
    final data = provider.userData;
    final baby = provider.babyData;

    nameController.text = data?['name'] ?? "";
    imageUrl = data?['photoUrl'];

    if (data?['stage'] == 'pregnancy') {
      if (data?['pregnancy']?['edd'] != null) {
        selectedDate = DateTime.parse(data!['pregnancy']['edd']);
      }
    } else {
      babyNameController.text = baby?['name'] ?? "";
      if (baby?['dob'] != null) {
        selectedDate = DateTime.parse(baby!['dob']);
      }
    }
  }

  Future<void> pickAndUploadImage(
      ImageSource source,
      ) async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 75,
    );

    if (pickedFile == null) return;

    final bytes = await pickedFile.readAsBytes();

    setState(() {
      _localImageFile = pickedFile;
      _imageBytes = bytes;
      _isUploadingImage = true;
    });

    try {
      const cloudName = "mu0oqkpd";
      const uploadPreset = "profile_upload";

      final uri = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
      );

      final request = http.MultipartRequest("POST", uri);

      request.fields["upload_preset"] = uploadPreset;

      if (kIsWeb) {
        request.files.add(
          http.MultipartFile.fromBytes(
            "file",
            bytes,
            filename: pickedFile.name,
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath(
            "file",
            pickedFile.path,
          ),
        );
      }

      final response = await request.send();

      final responseData =
      jsonDecode(await response.stream.bytesToString());

      if (response.statusCode == 200) {
        setState(() {
          imageUrl = responseData["secure_url"];

          _imageBytes = null;
          _localImageFile = null;

          _isUploadingImage = false;
        });

        debugPrint("Cloudinary URL: $imageUrl");
      } else {
        throw Exception(responseData["error"]["message"]);
      }
    } catch (e) {
      setState(() {
        _localImageFile = null;
        _imageBytes = null;
        _isUploadingImage = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Image upload failed: $e"),
          ),
        );
      }
    }
  }

  Future<void> pickDate() async {
    final provider = context.read<ProfileProvider>();
    final data = provider.userData;
    final stage = data?['stage'];

    DateTime firstDate;
    DateTime lastDate;
    DateTime initialDate;

    if (stage == 'pregnancy') {
      firstDate = DateTime.now().subtract(const Duration(days: 280));
      lastDate = DateTime.now().add(const Duration(days: 300));
      initialDate = selectedDate ?? DateTime.now().add(const Duration(days: 90));
    } else {
      firstDate = DateTime.now().subtract(const Duration(days: 730));
      lastDate = DateTime.now();
      initialDate = selectedDate ?? DateTime.now();
    }

    if (initialDate.isBefore(firstDate)) {
      initialDate = firstDate;
    } else if (initialDate.isAfter(lastDate)) {
      initialDate = lastDate;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.pink),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> showImageOptions() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [

              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text("Camera"),
                onTap: () {
                  Navigator.pop(context);
                  pickAndUploadImage(ImageSource.camera);
                },
              ),

              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  pickAndUploadImage(ImageSource.gallery);
                },
              ),

              if (imageUrl != null)
                ListTile(
                  leading: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  title: const Text(
                    "Remove Photo",
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await removePhoto();
                  },
                ),

              ListTile(
                leading: const Icon(Icons.close),
                title: const Text("Cancel"),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isUploadingImage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please wait for image to finish uploading")),
      );
      return;
    }

    setState(() => isSaving = true);

    final user = FirebaseAuth.instance.currentUser;
    final provider = context.read<ProfileProvider>();
    final data = provider.userData;
    final stage = data?['stage'];

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
        'name': nameController.text.trim(),
        if (imageUrl != null) 'photoUrl': imageUrl,
      });

      if (stage == 'pregnancy') {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'pregnancy.edd': selectedDate?.toIso8601String(),
        });
      } else {
        final babyId = data?['active_baby_id'];
        await FirebaseFirestore.instance
            .collection('babies')
            .doc(babyId)
            .update({
          'name': babyNameController.text.trim(),
          'dob': selectedDate?.toIso8601String(),
        });
      }

      await provider.fetchUserData(user.uid);
      if (mounted) {
        FocusScope.of(context).unfocus();
      }
      await context.read<AuthService>().reloadUser();
      await context.read<TrimesterProvider>().initialize();

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save profile: $e")),
        );
      }
    }

    if (mounted) setState(() => isSaving = false);
  }

  Future<void> removePhoto() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .update({
      "photoUrl": FieldValue.delete(),
    });

    setState(() {
      imageUrl = null;
      _imageBytes = null;
      _localImageFile = null;
    });

    await context
        .read<ProfileProvider>()
        .fetchUserData(user.uid);
  }

  ImageProvider? get _displayImage {
    if (_imageBytes != null) {
      return MemoryImage(_imageBytes!);
    }

    if (imageUrl != null) {
      return NetworkImage(imageUrl!);
    }

    return null;
  }

  String formatDate() {
    if (selectedDate == null) return "Select date";
    return DateFormat('dd MMM yyyy').format(selectedDate!);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    final data = provider.userData;
    final stage = data?['stage'];

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [

              Center(
                child: GestureDetector(
                  onTap: _isUploadingImage
                      ? null
                      : showImageOptions,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _displayImage,
                        child: _displayImage == null
                            ? const Icon(Icons.person, size: 40)
                            : null,
                      ),

                      if (_isUploadingImage)
                        const Positioned.fill(
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.black38,
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                        ),

                      if (!_isUploadingImage)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.pinkAccent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt,
                                size: 16, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (v) =>
                v == null || v.isEmpty ? "Enter name" : null,
              ),

              const SizedBox(height: 16),

              if (stage == 'pregnancy') ...[
                ListTile(
                  title: const Text("Due Date"),
                  subtitle: Text(formatDate()),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: pickDate,
                ),
              ],

              if (stage == 'postpartum') ...[
                TextFormField(
                  controller: babyNameController,
                  decoration: const InputDecoration(labelText: "Baby Name"),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text("Baby DOB"),
                  subtitle: Text(formatDate()),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: pickDate,
                ),
              ],

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: (isSaving || _isUploadingImage) ? null : saveProfile,
                child: isSaving
                    ? const CircularProgressIndicator()
                    : const Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}