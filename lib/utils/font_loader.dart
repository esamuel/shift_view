import 'package:pdf/widgets.dart' as pw;

class FontPair {
  final pw.Font regular;
  final pw.Font bold;
  
  FontPair(this.regular, this.bold);
}

class FontLoader {
  static Future<FontPair> loadFonts() async {
    try {
      // Use Times Roman as primary font - better Unicode support than Helvetica
      return FontPair(
        pw.Font.times(),
        pw.Font.timesBold(),
      );
    } catch (e) {
      print('Error loading Times font: $e');
      // Fallback to Helvetica if Times fails
      return FontPair(
        pw.Font.helvetica(),
        pw.Font.helveticaBold(),
      );
    }
  }
} 