import 'package:pdf/pdf.dart';

class PDFConfig {
  final String? headerText;
  final String? companyName;
  final String? companyLogo;
  final String? customHeader;
  final String? customFooter;
  final bool includeDateRange;
  final bool includePageNumbers;
  final PdfPageFormat pageFormat;

  PDFConfig({
    this.headerText,
    this.companyName,
    this.companyLogo,
    this.customHeader,
    this.customFooter,
    this.includeDateRange = true,
    this.includePageNumbers = true,
    this.pageFormat = PdfPageFormat.a4,
  });
} 