import 'dart:typed_data';
import 'package:ayurseva/screens/pdf_generator/widgets/full_screen_pdf_viewer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:ayurseva/screens/pdf_generator/models/invoice_data_model.dart';
import 'package:ayurseva/constants/string_class.dart';
import 'package:ayurseva/constants/icon_class.dart';
import 'package:ayurseva/constants/color_class.dart';
import 'package:ayurseva/constants/textstyle_class.dart';

/// PDF Generator Widget containing all PDF generation logic
class PdfGeneratorWidget {
  
  /// Load logo image from assets
  static Future<pw.ImageProvider> _loadLogoImage() async {
    try {
      final logoData = await rootBundle.load(IconClass.logo);
      return pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (e) {
      debugPrint('PdfGeneratorWidget: Error loading logo - $e');
      // Fallback to a simple text-based logo if image loading fails
      return pw.MemoryImage(Uint8List(0));
    }
  }

  /// Convert Flutter TextStyle to PDF TextStyle
  static pw.TextStyle _convertToPdfTextStyle(TextStyle flutterStyle) {
    return pw.TextStyle(
      fontSize: flutterStyle.fontSize,
      fontWeight: _convertFontWeight(flutterStyle.fontWeight),
      color: _convertColor(flutterStyle.color),
      font: pw.Font.helvetica(), // Using helvetica as fallback since Poppins might not be available in PDF
    );
  }

  /// Convert Flutter FontWeight to PDF FontWeight
  static pw.FontWeight _convertFontWeight(FontWeight? fontWeight) {
    if (fontWeight == null) return pw.FontWeight.normal;
    
    switch (fontWeight) {
      case FontWeight.w100:
      case FontWeight.w200:
      case FontWeight.w300:
        return pw.FontWeight.normal; // PDF doesn't have light, using normal
      case FontWeight.w400:
        return pw.FontWeight.normal;
      case FontWeight.w500:
        return pw.FontWeight.normal; // PDF doesn't have medium, using normal
      case FontWeight.w600:
        return pw.FontWeight.normal; // PDF doesn't have semiBold, using normal
      case FontWeight.w700:
      case FontWeight.w800:
      case FontWeight.w900:
        return pw.FontWeight.bold;
      default:
        return pw.FontWeight.normal; // Default fallback
    }
  }

  /// Convert Flutter Color to PDF Color
  static PdfColor _convertColor(Color? color) {
    if (color == null) return PdfColors.black;
    return PdfColor.fromInt(color.value);
  }

  /// Generate PDF from invoice data
  static Future<Uint8List> generateInvoicePDF(InvoiceData data) async {
    debugPrint('PdfGeneratorWidget: Starting PDF generation');
    
    final pdf = pw.Document();
    
    // Load logo image
    final logoImage = await _loadLogoImage();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeader(data, logoImage),
              pw.SizedBox(height: 20),
              
              // Patient Details
              _buildPatientDetails(data),
              pw.SizedBox(height: 20),
              
              // Treatment Table
              _buildTreatmentTable(data),
              pw.SizedBox(height: 20),
              
              // Amount Summary
              _buildAmountSummary(data),
              pw.SizedBox(height: 20),
              
              // Thank You Section
              _buildThankYouSection(data),
              pw.SizedBox(height: 20),
              
              // Footer
              _buildFooter(data),
            ],
          );
        },
      ),
    );

    debugPrint('PdfGeneratorWidget: PDF generation completed');
    return pdf.save();
  }

  /// Build header section
  static pw.Widget _buildHeader(InvoiceData data, pw.ImageProvider logoImage) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  data.companyName,
                  style: _convertToPdfTextStyle(
                    TextStyleClass.heading1(ColorClass.primaryColor),
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Container(
                  width: 60,
                  height: 60,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      color: _convertColor(ColorClass.primaryColor), 
                      width: 2,
                    ),
                    borderRadius: pw.BorderRadius.circular(30),
                  ),
                  child: pw.Center(
                    child: pw.Image(
                      logoImage,
                      width: 50,
                      height: 50,
                      fit: pw.BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  data.branchName,
                  style: _convertToPdfTextStyle(
                    TextStyleClass.heading3(ColorClass.primaryColor),
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  data.address, 
                  style: _convertToPdfTextStyle(
                    TextStyleClass.bodySmall(ColorClass.primaryText),
                  ),
                ),
                pw.Text(
                  'e-mail: ${data.email}', 
                  style: _convertToPdfTextStyle(
                    TextStyleClass.bodySmall(ColorClass.primaryText),
                  ),
                ),
                pw.Text(
                  'Mob: ${data.phone}', 
                  style: _convertToPdfTextStyle(
                    TextStyleClass.bodySmall(ColorClass.primaryText),
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'GST No: ${data.gstNumber}',
                  style: _convertToPdfTextStyle(
                    TextStyleClass.bodySmall(ColorClass.primaryColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// Build patient details section
  static pw.Widget _buildPatientDetails(InvoiceData data) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _convertColor(ColorClass.grey)),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            StringClass.patientDetails,
            style: _convertToPdfTextStyle(
              TextStyleClass.heading4(ColorClass.primaryColor),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(StringClass.name, data.patientName),
                    _buildDetailRow(StringClass.address, data.patientAddress),
                    _buildDetailRow(StringClass.whatsappNumber, data.patientWhatsApp),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(StringClass.bookedOn, data.bookedOn),
                    _buildDetailRow(StringClass.treatmentDate, data.treatmentDate),
                    _buildDetailRow(StringClass.treatmentTime, data.treatmentTime),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build detail row
  static pw.Widget _buildDetailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: _convertToPdfTextStyle(
                TextStyleClass.bodySmall(ColorClass.primaryText),
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: _convertToPdfTextStyle(
                TextStyleClass.bodySmall(ColorClass.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build treatment table
  static pw.Widget _buildTreatmentTable(InvoiceData data) {
    return pw.Table(
      border: pw.TableBorder.all(color: _convertColor(ColorClass.grey)),
      children: [
        // Header
        pw.TableRow(
          decoration: pw.BoxDecoration(color: _convertColor(ColorClass.primaryColor.withValues(alpha: 0.1))),
          children: [
            _buildTableCell(StringClass.treatment, isHeader: true),
            _buildTableCell(StringClass.price, isHeader: true),
            _buildTableCell(StringClass.male, isHeader: true),
            _buildTableCell(StringClass.female, isHeader: true),
            _buildTableCell(StringClass.total, isHeader: true),
          ],
        ),
        // Data rows
        ...data.treatments.map((treatment) => pw.TableRow(
          children: [
            _buildTableCell(treatment.name),
            _buildTableCell(treatment.price.toStringAsFixed(0)),
            _buildTableCell(treatment.maleCount.toString()),
            _buildTableCell(treatment.femaleCount.toString()),
            _buildTableCell(treatment.total.toStringAsFixed(0)),
          ],
        )),
      ],
    );
  }

  /// Build table cell
  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: _convertToPdfTextStyle(
          isHeader 
            ? TextStyleClass.bodyMedium(ColorClass.primaryColor)
            : TextStyleClass.bodySmall(ColorClass.black),
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  /// Build amount summary
  static pw.Widget _buildAmountSummary(InvoiceData data) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 250,
        child: pw.Column(
          children: [
            _buildAmountRow(StringClass.totalAmount, data.totalAmount.toStringAsFixed(0)),
            _buildAmountRow(StringClass.discount, data.discount.toStringAsFixed(0)),
            _buildAmountRow(StringClass.advance, data.advance.toStringAsFixed(0)),
            pw.Divider(color: _convertColor(ColorClass.grey)),
            _buildAmountRow(
              StringClass.balance,
              data.balance.toStringAsFixed(0),
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  /// Build amount row
  static pw.Widget _buildAmountRow(String label, String amount, {bool isTotal = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: _convertToPdfTextStyle(
              isTotal 
                ? TextStyleClass.bodyLarge(ColorClass.primaryText)
                : TextStyleClass.bodyMedium(ColorClass.primaryText),
            ),
          ),
          pw.Text(
            amount,
            style: _convertToPdfTextStyle(
              isTotal 
                ? TextStyleClass.bodyLarge(ColorClass.primaryColor)
                : TextStyleClass.bodyMedium(ColorClass.black),
            ),
          ),
        ],
      ),
    );
  }

  /// Build thank you section
  static pw.Widget _buildThankYouSection(InvoiceData data) {
    return pw.Column(
      children: [
        pw.Text(
          data.thankYouMessage,
          style: _convertToPdfTextStyle(
            TextStyleClass.heading3(ColorClass.primaryColor),
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          StringClass.thankYouMessage,
          style: _convertToPdfTextStyle(
            TextStyleClass.bodySmall(ColorClass.primaryText),
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 15),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Container(
            width: 150,
            height: 40,
            child: pw.Column(
              children: [
                pw.SizedBox(height: 15),
                pw.Container(
                  width: 150,
                  height: 1,
                  color: _convertColor(ColorClass.black),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  StringClass.signature,
                  style: _convertToPdfTextStyle(
                    TextStyleClass.bodySmall(ColorClass.primaryText),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build footer
  static pw.Widget _buildFooter(InvoiceData data) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _convertColor(ColorClass.grey)),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Text(
        data.footerNote,
        style: _convertToPdfTextStyle(
          TextStyleClass.caption(ColorClass.primaryText),
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  /// Create full screen PDF viewer
  static Widget createFullScreenViewer({
    required Uint8List pdfData,
    required InvoiceData data,
  }) {
    return FullScreenPDFViewer(
      pdfData: pdfData,
      data: data,
    );
  }
}

/// Full Screen PDF Viewer Widget

