import 'package:flutter/material.dart';
import 'package:task_8/modules/pdf/Pdfview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Viewer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff5669FF)),
        useMaterial3: true,
      ),
      home: PdfView(),
    );
  }
}
