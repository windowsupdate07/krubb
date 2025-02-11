import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class FileUploadWidget extends StatefulWidget {
  final Function(File?) onFileSelected;

  const FileUploadWidget({Key? key, required this.onFileSelected})
      : super(key: key);

  @override
  _FileUploadWidgetState createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  File? _selectedFile;

  /// 🔹 เลือกรูปภาพจากแกลเลอรีหรือกล้อง
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedFile = File(image.path);
      });
      widget.onFileSelected(_selectedFile);
    }
  }

  /// 🔹 เลือกไฟล์ PDF
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
      widget.onFileSelected(_selectedFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_selectedFile != null)
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blueAccent),
              borderRadius: BorderRadius.circular(10),
            ),
            child: _selectedFile!.path.endsWith('.pdf')
                ? Row(
                    children: [
                      Icon(Icons.picture_as_pdf, color: Colors.red, size: 40),
                      SizedBox(width: 10),
                      Expanded(child: Text("📄 ${_selectedFile!.path.split('/').last}", style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  )
                : Image.file(_selectedFile!, width: 100, height: 100, fit: BoxFit.cover),
          ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.image),
              label: Text("เลือกรูป"),
            ),
            SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: Icon(Icons.attach_file),
              label: Text("เลือกไฟล์"),
            ),
          ],
        ),
      ],
    );
  }
}