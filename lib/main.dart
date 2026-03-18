import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  File? imageFile;
  final picker = ImagePicker();

  late Interpreter interpreter;
  List<String> labels = [];

  String result = "Belum ada hasil";

  @override
  void initState() {
    super.initState();
    loadModel();
    loadLabels();
  }

  // LOAD MODEL
  Future<void> loadModel() async {
    interpreter = await Interpreter.fromAsset('assets/model_unquant.tflite');
    print("Model Loaded");
  }

  // LOAD LABEL
  Future<void> loadLabels() async {
    final data = await rootBundle.loadString('assets/labels.txt');
    labels = data.split('\n');
  }

  // PILIH GAMBAR DARI GALERI
  Future<void> pickFromGallery() async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      processImage(File(pickedFile.path));
    }
  }

  // AMBIL FOTO DARI KAMERA
  Future<void> pickFromCamera() async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      processImage(File(pickedFile.path));
    }
  }

  // PROSES GAMBAR
  Future<void> processImage(File file) async {
    setState(() {
      imageFile = file;
      result = "Memproses...";
    });

    await classifyImage(file);
  }

  // PREPROCESS + INFERENCE
  Future<void> classifyImage(File file) async {

    // baca bytes
    Uint8List bytes = await file.readAsBytes();

    // decode image
    img.Image? oriImage = img.decodeImage(bytes);

    // resize ke 224x224
    img.Image resized = img.copyResize(oriImage!, width: 224, height: 224);

    // buat input tensor
    var input = List.generate(
      1,
      (_) => List.generate(
        224,
        (y) => List.generate(
          224,
          (x) {
            var pixel = resized.getPixel(x, y);

            return [
              pixel.r / 255.0,
              pixel.g / 255.0,
              pixel.b / 255.0,
            ];
          },
        ),
      ),
    );

    // output
    var output = List.filled(labels.length, 0.0).reshape([1, labels.length]);

    interpreter.run(input, output);

    var scores = output[0];

    double maxScore = 0;
    int maxIndex = 0;

    for (int i = 0; i < scores.length; i++) {
      if (scores[i] > maxScore) {
        maxScore = scores[i];
        maxIndex = i;
      }
    }

    setState(() {
      result =
          "${labels[maxIndex]} (${(maxScore * 100).toStringAsFixed(2)}%)";
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Object Detection AI"),
      ),

      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              imageFile == null
                  ? const Text("Belum ada gambar")
                  : Image.file(imageFile!, height: 250),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: pickFromGallery,
                child: const Text("Pilih dari Galeri"),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: pickFromCamera,
                child: const Text("Ambil dari Kamera"),
              ),

              const SizedBox(height: 20),

              Text(
                result,
                style: const TextStyle(fontSize: 18),
              )
            ],
          ),
        ),
      ),
    );
  }
}