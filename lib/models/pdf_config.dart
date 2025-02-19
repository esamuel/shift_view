class PDFConfig {
  final String headerText;
  final bool includeCompanyInfo;
  final bool includePageNumbers;
  final bool includeDateRange;

  PDFConfig({
    this.headerText = '',
    this.includeCompanyInfo = true,
    this.includePageNumbers = true,
    this.includeDateRange = true,
  });
} 