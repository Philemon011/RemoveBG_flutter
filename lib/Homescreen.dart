import 'dart:io';
import 'dart:typed_data';

import 'package:removebg/api.dart';
import 'package:removebg/dashed_border.dart';
import 'package:before_after_image_slider_nullsafty/before_after_image_slider_nullsafty.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  var loaded = false;
  var removedbg = false;
  Uint8List? image;
  String? imagePath = '';
  var isLoading = false;

  ScreenshotController screenshotController = ScreenshotController();

  pickImage() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 100);
    if (img != null) {
      imagePath = img.path;
      loaded = true;
      setState(() {});
    } else {}
  }

  downloadImage() async {
    var perm = await Permission.manageExternalStorage.request();
    var folderName = "BGRemover";
    var fileName = "${DateTime.now().millisecondsSinceEpoch}.png";

    if (perm.isGranted) {
      // Utilisation du répertoire "Downloads"
      Directory? directory;

      // Vérifiez si vous êtes sur Android
      if (Platform.isAndroid) {
        directory =
            await getExternalStorageDirectory(); // Obtenez le répertoire externe
        // Si l'appareil est sous Android 10+ (API 29 et plus), utilisez MediaStore
        directory = Directory('/storage/emulated/0/Download');
      } else {
        // Pour iOS ou autres plateformes, on peut utiliser les documents de l'application
        directory = await getApplicationDocumentsDirectory();
      }

      // Créer le répertoire "BGRemover" dans le dossier Downloads
      String folderPath = "${directory.path}/$folderName";
      final folder = Directory(folderPath);

      if (!await folder.exists()) {
        await folder.create(
            recursive: true); // Créer le dossier s'il n'existe pas
      }

      // Sauvegarde de l'image capturée dans le répertoire choisi
      await screenshotController.captureAndSave(
        folder.path,
        delay: Duration(milliseconds: 100),
        fileName: fileName,
        pixelRatio: 1.0,
      );

      // Afficher un message de succès avec le chemin du fichier sauvegardé
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "Votre fichier a été sauvegardé dans ${folder.path}",
            style:
                GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      );
    } else {
      // Afficher un message d'erreur si la permission est refusée
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Permission non accordée pour l'accès au stockage",
            style:
                GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

//   downloadImage() async {
//   // Demande la permission d'accès au stockage
//   var status = await Permission.storage.request();

//   if (status.isGranted) {
//     // La permission est accordée, continuer avec l'enregistrement de l'image
//     var fileName = "${DateTime.now().millisecondsSinceEpoch}.png";
//     Directory? directory = await getExternalStorageDirectory();
//     var folderPath = "${directory!.path}/BGRemover";

//     final folder = Directory(folderPath);
//     if (!await folder.exists()) {
//       await folder.create(recursive: true);
//     }

//     await screenshotController.captureAndSave(
//       folder.path,
//       delay: Duration(milliseconds: 100),
//       fileName: fileName,
//       pixelRatio: 1.0,
//     );

//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Text(
//         "Votre fichier a été sauvegardé dans $folderPath",
//         style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
//       ),
//     ));
//   } else if (status.isDenied) {
//     // Permission refusée
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Text(
//         "Permission non accordée pour l'accès au stockage",
//         style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
//       ),
//     ));
//     await Permission.storage.request();
//     openAppSettings();
//   } else if (status.isPermanentlyDenied) {
//     // Si la permission est définitivement refusée, vous pouvez ouvrir les paramètres pour l'activer
//     openAppSettings();
//   }
// }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                downloadImage();
              },
              icon: Icon(
                Icons.download,
                color: Colors.white,
                size: 32,
              ))
        ],
        leading: const Icon(
          Icons.sort_rounded,
          color: Colors.white,
          size: 32,
        ),
        backgroundColor: Colors.black,
        title: Text(
          "AI Background Remover",
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: removedbg
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: BeforeAfter(
                  thumbColor: Colors.white,
                  beforeImage: Image.file(File(imagePath!)),
                  afterImage: Screenshot(
                      controller: screenshotController,
                      child: Image.memory(image!)),
                ),
              )
            : loaded
                ? GestureDetector(
                    onTap: () {
                      pickImage();
                    },
                    child: Image.file(File(imagePath!)))
                : DashedBorder(
                    color: Colors.grey,
                    radius: 12,
                    padding: const EdgeInsets.all(40),
                    child: Container(
                        child: SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                8), // Réduire le rayon ici (par exemple à 8)
                          ),
                        ),
                        onPressed: () {
                          pickImage();
                        },
                        child: Text(
                          "Choisir l'image",
                          style: GoogleFonts.poppins(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )),
                  ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
            child: SizedBox(
          width: double.infinity - 10,
          height: 58,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    8), // Réduire le rayon ici (par exemple à 8)
              ),
            ),
            onPressed: loaded
                ? () async {
                    setState(() {
                      isLoading = true;
                    });

                    image = await Api.removebg(imagePath!);
                    if (image != null) {
                      debugPrint(
                          "Image sans arrière-plan obtenue avec succès.");
                      debugPrint(
                          "Taille de l'image traitée : ${image?.length}");
                      removedbg = true;
                      isLoading = false;
                      setState(() {});
                    } else {
                      isLoading = false;
                      removedbg = false;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        backgroundColor: Colors.red,
                        content: Text(
                          "Erreur : Erreur de connexion au serveur ! ",
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ));
                      debugPrint(
                          "Erreur : L'image sans arrière-plan est nulle.");
                    }
                  }
                : null,
            child: isLoading
                ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                : Text(
                    "Supprimer l'arrière plan",
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
          ),
        )),
      ),
    );
  }
}
