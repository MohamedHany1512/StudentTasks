import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:task/Logic/ApiServices/SendExecuseService.dart';
import 'package:task/Logic/ApiServices/getDataForExcuse.dart';
import 'package:task/features/HomePage/logOutbody.dart';

class SendExcusesPage extends StatefulWidget {
  const SendExcusesPage({super.key});

  @override
  _SendExcusesPageState createState() => _SendExcusesPageState();
}

class _SendExcusesPageState extends State<SendExcusesPage> {
  List<File> _images = [];
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedMaterial;
  List<String> _materials = [];

  String? _selectedDepartment;
  List<String> _departments = [];

  bool _isLoadingData = true;
  bool _isSubmitting = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchExcuseData();
  }

  Future<void> _fetchExcuseData() async {
    try {
      final data = await Getdataforexcuse.fetchExcuseData();
      setState(() {
        _materials = data["materials"];
        _departments = data["departments"];
        _selectedMaterial = _materials.isNotEmpty ? _materials[0] : null;
        _selectedDepartment = _departments.isNotEmpty ? _departments[0] : null;
      });
    } catch (e) {
      print('❌ خطأ أثناء تحميل البيانات: $e');
    } finally {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  /// ✅ اختيار صور متعددة من المعرض
  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _images = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  Future<void> _sendExcuse() async {
    if (_images.isEmpty ||
        _reasonController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _selectedMaterial == null ||
        _selectedDepartment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ يرجى إدخال جميع البيانات المطلوبة')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await Sendexecuseservice.sendExcuse(
        reason: _reasonController.text,
        description: _descriptionController.text,
        material: _selectedMaterial!,
        department: _selectedDepartment!,
        images: _images, // ✅ إرسال الصور كقائمة
      );

      if (response.containsKey('error')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['error']), backgroundColor: Colors.red),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ تم إرسال العذر بنجاح'), backgroundColor: Colors.green),
        );
        setState(() {
          _images.clear();
          _reasonController.clear();
          _descriptionController.clear();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ حدث خطأ أثناء إرسال العذر'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(  appBar: AppBar(
        actions: [
          IconButton(

            onPressed: () {Logoutbody.logoutt(context);} ,
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
        backgroundColor: Colors.blue,
        title: const Text(
          'أعذار الطالب  ',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 4,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              /// ✅ عرض الصور المختارة
              _images.isEmpty
                  ? const Icon(Icons.image, size: 100, color: Colors.grey)
                  : Wrap(
                      spacing: 8,
                      children: _images
                          .map((image) => Image.file(image, width: 100, height: 100, fit: BoxFit.cover))
                          .toList(),
                    ),
      
              const SizedBox(height: 10),
              ElevatedButton(
                style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.blue)),
                onPressed: _pickImages, // ✅ اختيار صور متعددة
                child: const Text("📷 اختيار صور", style: TextStyle(color: Colors.white)),
              ),
      
              const SizedBox(height: 20),
              TextField(
                controller: _reasonController,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "✍️ سبب العذر"),
              ),
      
              const SizedBox(height: 20),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "📝 تفاصيل العذر"),
              ),
      
              const SizedBox(height: 20),
              _isLoadingData
                  ? const CircularProgressIndicator()
                  : _departments.isEmpty
                      ? const Text("⚠️ لا توجد أقسام متاحة")
                      : DropdownButton<String>(
                          value: _selectedDepartment,
                          items: _departments
                              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedDepartment = value!;
                            });
                          },
                        ),
      
              const SizedBox(height: 20),
              _isLoadingData
                  ? const CircularProgressIndicator()
                  : _materials.isEmpty
                      ? const Text("⚠️ لا توجد مواد متاحة")
                      : DropdownButton<String>(
                          value: _selectedMaterial,
                          items: _materials
                              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedMaterial = value!;
                            });
                          },
                        ),
      
              const SizedBox(height: 20),
              _isSubmitting
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _sendExcuse,
                      style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.blue)),
                      child: const Text("📤 إرسال العذر", style: TextStyle(color: Colors.white)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
