import 'package:flutter/material.dart';
import 'package:generate_schedule_app/Core/Helper/database_helper.dart';
import 'package:intl/intl.dart'; 
 import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
 class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> scheduleList = [];

  @override
  void initState() {
    super.initState();
    fetchSchedule();
  }

  Future<void> fetchSchedule() async {
    List<Map<String, dynamic>> schedules = await dbHelper.getSchedules();
    setState(() {
      scheduleList = schedules;
    });
  }

  Future<void> _pickDate(BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      setState(() {
        controller.text = DateFormat('EEEE', 'ar').format(pickedDate);
      });
    }
  }

  Future<void> _pickTime(BuildContext context, TextEditingController controller) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        controller.text = pickedTime.format(context);
      });
    }
  }

  void openScheduleForm({Map<String, dynamic>? schedule}) {
    TextEditingController courseController = TextEditingController(text: schedule?['course'] ?? '');
    TextEditingController instructorController = TextEditingController(text: schedule?['instructor'] ?? '');
    TextEditingController dayController = TextEditingController(text: schedule?['day'] ?? '');
    TextEditingController startTimeController = TextEditingController(text: schedule?['startTime'] ?? '');
    TextEditingController endTimeController = TextEditingController(text: schedule?['endTime'] ?? '');
    TextEditingController placeController = TextEditingController(text: schedule?['place'] ?? '');
    TextEditingController typeController = TextEditingController(text: schedule?['type'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(schedule == null ? "إضافة محاضرة جديدة" : "تعديل المحاضرة"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: courseController, decoration: InputDecoration(labelText: "المقرر")),
                TextField(controller: instructorController, decoration: InputDecoration(labelText: "القائم بالتدريس")),
                TextField(
                  controller: dayController,
                  decoration: InputDecoration(labelText: "اليوم"),
                  readOnly: true,
                  onTap: () => _pickDate(context, dayController),
                ),
                TextField(
                  controller: startTimeController,
                  decoration: InputDecoration(labelText: "من"),
                  readOnly: true,
                  onTap: () => _pickTime(context, startTimeController),
                ),
                TextField(
                  controller: endTimeController,
                  decoration: InputDecoration(labelText: "إلى"),
                  readOnly: true,
                  onTap: () => _pickTime(context, endTimeController),
                ),
                TextField(controller: placeController, decoration: InputDecoration(labelText: "المكان")),
                TextField(controller: typeController, decoration: InputDecoration(labelText: "النوع")),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("إلغاء"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text(schedule == null ? "إضافة" : "تحديث"),
              onPressed: () async {
                Map<String, dynamic> newSchedule = {
                  "course": courseController.text,
                  "instructor": instructorController.text,
                  "day": dayController.text,
                  "startTime": startTimeController.text,
                  "endTime": endTimeController.text,
                  "place": placeController.text,
                  "type": typeController.text,
                };

                if (schedule == null) {
                  await dbHelper.insertSchedule(newSchedule);
                } else {
                  await dbHelper.updateSchedule(schedule['id'], newSchedule);
                }

                fetchSchedule();
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> exportToPDF() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("الجدول الدراسي", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              // ignore: deprecated_member_use
              pw.Table.fromTextArray(
                headers: ["المقرر", "المحاضر", "اليوم", "من", "إلى", "المكان", "النوع"],
                data: scheduleList.map((schedule) => [
                  schedule['course'],
                  schedule['instructor'],
                  schedule['day'],
                  schedule['startTime'],
                  schedule['endTime'],
                  schedule['place'],
                  schedule['type'],
                ]).toList(),
                border: pw.TableBorder.all(),
                cellAlignment: pw.Alignment.center,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ],
          );
        },
      ),
    );

    Directory? directory = await getExternalStorageDirectory();
    String path = "${directory!.path}/جدول_الدراسة.pdf";
    File file = File(path);

    await file.writeAsBytes(await pdf.save());

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("تم حفظ الجدول في: $path")));

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("الجدول الدراسي"),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: exportToPDF,
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: scheduleList.map((schedule) {
          return Card(
            elevation: 3,
            margin: EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text("${schedule['course']} - ${schedule['instructor']}"),
              subtitle: Text("${schedule['day']} | ${schedule['startTime']} - ${schedule['endTime']} | ${schedule['place']} | ${schedule['type']}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: Icon(Icons.edit, color: Colors.blue), onPressed: () => openScheduleForm(schedule: schedule)),
                  IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () async {
                    await dbHelper.deleteSchedule(schedule['id']);
                    fetchSchedule();
                  }),
                ],
              ),
            ),
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => openScheduleForm(),
      ),
    );
  }
}
