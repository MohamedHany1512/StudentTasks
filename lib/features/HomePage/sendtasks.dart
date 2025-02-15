
import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';


import 'package:task/Logic/ApiServices/getTasksData.dart';
import 'package:task/features/HomePage/logOutbody.dart';

class SendTasksPage extends StatelessWidget {
  const SendTasksPage({Key? key}) : super(key: key);

  Future<void> requestPermissions() async {
    if (await Permission.storage.request().isGranted) {
      print("✅ تم منح إذن التخزين!");
    } else {
      print("❌ تم رفض إذن التخزين!");
    }
  }

  Future<Map<String, Map<String, List>>> _fetchGroupedTasks() async {
    return await Gettasksdata.fetchStudentTasks();
  }

  Future<void> _downloadFile(BuildContext context, String fileUrl, String fileName) async {
    var status = await Permission.manageExternalStorage.request();

    if (status.isGranted) {
      try {
        requestPermissions();
        final dir = await getExternalStorageDirectory();
        final savePath = "${dir!.path}/$fileName";

        Dio dio = Dio();
        await dio.download(fileUrl, savePath);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ تم تحميل الملف بنجاح!")),
        );

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        actions: [
          IconButton(
            onPressed: (){Logoutbody.logoutt(context);},
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
        backgroundColor: Colors.blue,
        title: const Text(
          '📘📘مهام الطالب ',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 4,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<Map<String, Map<String, List>>>(
        future: _fetchGroupedTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(child: Text("❌ لا توجد مهام متاحة حاليًا"));
          }

          final subjects = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.all(8.0),
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final subjectName = subjects.keys.elementAt(index);
              final lectures = subjects[subjectName]!;

              return Card(
                margin: EdgeInsets.only(bottom: 12),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  title: Text(
                    "📘 المادة: $subjectName",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  children: lectures.keys.map((lectureName) {
                    final tasks = lectures[lectureName]!;

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: ExpansionTile(
                        title: Text("📖 المحاضرة: $lectureName"),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 8.0,
                                mainAxisSpacing: 8.0,
                                childAspectRatio: 0.9,
                              ),
                              itemCount: tasks.length,
                              itemBuilder: (context, taskIndex) {
                                final task = tasks[taskIndex];
                                final taskTitle = task["name"] ?? "بدون عنوان";
                                final deadline = task["deadline"] ?? "غير محدد";
                                final fileType = _getFileType(taskTitle);
                                final fileIcon = _getFileIcon(fileType);

                                final baseUrl = "https://www.ain.purple-stingray-51320.zap.cloud";
                                final taskPath = "lectures-tasks"; 
                                final fileName = task["name"] ?? "";
                                final fileUrl = "$baseUrl/$taskPath/$fileName";

                                return Container(
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
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Center(
                                          child: Icon(
                                            fileIcon,
                                            size: 50,
                                            color: Colors.blueAccent,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              taskTitle,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              maxLines: 1,
                                            ),
                                            SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(Icons.access_time, size: 18, color: Colors.red),
                                                SizedBox(width: 4),
                                                Text(
                                                  deadline,
                                                  style: TextStyle(color: Colors.red, fontSize: 12),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                ElevatedButton.icon(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.green,
                                                    foregroundColor: Colors.white,
                                                  ),
                                                  icon: Icon(Icons.download),
                                                  label: Text("تحميل"),
                                                  onPressed: () async {
                                                    if (fileName.isNotEmpty) {
                                                      await _downloadFile(context, fileUrl, fileName);
                                                    }
                                                  },
                                                ),
                                              ],
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
