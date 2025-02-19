import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task/Logic/ApiServices/getTasksData.dart';
import 'package:task/Logic/ApiServices/sendTaskService.dart';
import 'package:task/core/utils/customElavatedButton.dart';
import 'package:task/features/HomePage/logOutbody.dart';

class SendTasksPage extends StatefulWidget {
  const SendTasksPage({Key? key}) : super(key: key);

  @override
  State<SendTasksPage> createState() => _SendTasksPageState();
}
class _SendTasksPageState extends State<SendTasksPage> {
  bool _isFileDownloaded = false; 
  String _downloadedFilePath = ''; 

  Future<void> _downloadFile(
    BuildContext context, String fileUrl, String fileName) async {
    var status = await Permission.manageExternalStorage.request();

    if (status.isGranted) {
      try {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        String? token = prefs.getString("token");

        if (token == null || token.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("❌ فشل تحميل الملف! لم يتم العثور على التوكن.")),
          );
          return;
        }

        // الحصول على المسار الصحيح لمجلد التنزيلات
        final downloadDir = Directory('/storage/emulated/0/Download');
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }

        final savePath = "${downloadDir.path}/$fileName"; // حفظ الملف في مجلد التنزيلات

        Dio dio = Dio();
        await dio.download(
          fileUrl,
          savePath,
          options: Options(headers: {
            "Authorization": "Bearer $token",
          }),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ تم تحميل الملف بنجاح!")),
        );

        setState(() {
          _isFileDownloaded = true; // تم تحميل الملف بنجاح
          _downloadedFilePath = savePath; // حفظ المسار
        });

        print("📥 تم تحميل الملف: $savePath");
      } catch (e) {
        print("❌ خطأ أثناء التحميل: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ فشل تحميل الملف!")),
        );
      }
    } else {
      print("❌ تم رفض إذن التخزين!");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ يجب السماح بإذن التخزين!")),
      );
    }
  }

  Future<void> _openFile() async {
    if (_isFileDownloaded) {
      final result = await OpenFile.open(_downloadedFilePath);
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ فشل فتح الملف")),
        );
      } else {
        print('تم فتح الملف: $_downloadedFilePath');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ يجب تحميل الملف أولاً")),
      );
    }
  }
  String _getFileType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    if (["jpg", "jpeg", "png", "gif"].contains(ext)) return "image";
    if (["mp4", "avi", "mov", "mkv"].contains(ext)) return "video";
    if (["pdf"].contains(ext)) return "pdf";
    if (["doc", "docx"].contains(ext)) return "word";
    return "other";
  }

  IconData _getFileIcon(String fileType) {
    switch (fileType) {
      case "image":
        return Icons.image;
      case "video":
        return Icons.videocam;
      case "pdf":
        return Icons.picture_as_pdf;
      case "word":
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {Logoutbody.logoutt(context);} ,
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
        title: Text(
          "📚 مهام الطالب",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<Map<String, Map<String, List>>>(
        future: Gettasksdata.fetchStudentTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError ||
              snapshot.data == null ||
              snapshot.data!.isEmpty) {
            return Center(child: Text("❌ لا توجد مهام متاحة حاليًا"));
          }

          final groupedTasks = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.all(8.0),
            itemCount: groupedTasks.length,
            itemBuilder: (context, subjectIndex) {
              final subjectName = groupedTasks.keys.elementAt(subjectIndex);
              final lectures = groupedTasks[subjectName]!;

              return Card(
                margin: EdgeInsets.only(bottom: 12),
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  title: Text(
                    "📘 المادة: $subjectName",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  children: lectures.keys.map((lectureName) {
                    final tasks = lectures[lectureName]!;

                    return Card(
                      margin: EdgeInsets.all(8),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: ExpansionTile(
                        title: Text(
                          "📖 المحاضرة: $lectureName",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 8.0,
                                mainAxisSpacing: 8.0,
                                childAspectRatio: 0.9,
                              ),
                              itemCount: tasks.length,
                              itemBuilder: (context, taskIndex) {
                                final task = tasks[taskIndex];
                                      final taskTitle = task["name"] ?? "بدون عنوان";
                                  final fileType = _getFileType(taskTitle);
                              final fileIcon = _getFileIcon(fileType);
                                final deadline = task["deadline"] ?? "غير محدد";
                                final fileName = task["name"] ?? "";
                                final baseUrl =
                                    "https://www.ain.purple-stingray-51320.zap.cloud";
                                final taskPath = snapshot.data!["task_path"] ??
                                    "lectures-tasks";
                                final fileUrl = "$baseUrl/$taskPath/$fileName";

                                return Container(
                                  height: MediaQuery.of(context).size.height,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 6,
                                        offset: Offset(2, 4),
                                      ),
                                    ],
                                  ),
                                  child: ListView(
                                    children: [
                                      Center(
                                        child: Icon(
                                          fileIcon,
                                          size: 35,
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(Icons.access_time,
                                                    size: 18,
                                                    color: Colors.red),
                                                SizedBox(width: 4),
                                                Text(
                                                  deadline,
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 12),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 8),
                                            Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                 CustomElevatedButton(
  label: "تحميل",
  icon: Icons.download,
  backgroundColor: Colors.green,
  foregroundColor: Colors.white,
  onPressed: () async {
    if (fileName.isNotEmpty) {
      await _downloadFile(context, fileUrl, fileName);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ لا يوجد ملف متاح للتحميل")),
      );
    }
  },
),

                                                  SizedBox(height: 10),
                                                 CustomElevatedButton(
  label: "فتح الملف",
  icon: Icons.open_in_browser,
  backgroundColor: Colors.orange,
  foregroundColor: Colors.white,
  onPressed: _isFileDownloaded ? _openFile : null,  // Disable if file not downloaded
),

                                                 CustomElevatedButton(
  label: "رفع",
  icon: Icons.upload_file,
  backgroundColor: Colors.blueAccent,
  foregroundColor: Colors.white,
  onPressed: () async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ لم يتم اختيار أي ملف!")),
      );
      return;
    }

    File file = File(result.files.single.path!);

    if (!task.containsKey("id") || !task.containsKey("lecture_id")) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ خطأ في البيانات: لا يوجد Task ID أو Lecture ID")),
      );
      return;
    }

    int taskId = task["id"];
    int lectureId = task["lecture_id"];

    print("✅ رفع الملف Task ID: $taskId, Lecture ID: $lectureId");

    try {
      Map<String, dynamic> response = await Sendtaskservice.uploadTaskAnswer(
        file: file,
        taskId: taskId,
        lectureId: lectureId,
        onProgress: (progress) {
          print("📤 التقدم: ${progress.toStringAsFixed(2)}%");
        },
      );

      String message = response["success"] == true
          ? "✅ تم رفع الحل بنجاح!"
          : "❌ فشل الرفع: ${response["error"] ?? "حدث خطأ غير معروف"}";

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ حدث خطأ أثناء رفع الملف!")),
      );
    }
  },
),

                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
