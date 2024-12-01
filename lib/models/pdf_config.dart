import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PDFConfig {
  final String? headerText;
  final String? companyName;
  final String? companyLogo;
  final String? customHeader;
  final String? customFooter;
  final bool includeDateRange;
  final bool includePageNumbers;
  final PdfPageFormat pageFormat;
  final pw.Font font;
  final pw.Font boldFont;

  PDFConfig({
    this.headerText,
    this.companyName,
    this.companyLogo,
    this.customHeader,
    this.customFooter,
    this.includeDateRange = true,
    this.includePageNumbers = true,
    this.pageFormat = PdfPageFormat.a4,
    required this.font,
    required this.boldFont,
  });

  PDFConfig copyWith({
    String? headerText,
    String? companyName,
    String? companyLogo,
    String? customHeader,
    String? customFooter,
    bool? includeDateRange,
    bool? includePageNumbers,
    PdfPageFormat? pageFormat,
    pw.Font? font,
    pw.Font? boldFont,
  }) {
    return PDFConfig(
      headerText: headerText ?? this.headerText,
      companyName: companyName ?? this.companyName,
      companyLogo: companyLogo ?? this.companyLogo,
      customHeader: customHeader ?? this.customHeader,
      customFooter: customFooter ?? this.customFooter,
      includeDateRange: includeDateRange ?? this.includeDateRange,
      includePageNumbers: includePageNumbers ?? this.includePageNumbers,
      pageFormat: pageFormat ?? this.pageFormat,
      font: font ?? this.font,
      boldFont: boldFont ?? this.boldFont,
    );
  }
} 