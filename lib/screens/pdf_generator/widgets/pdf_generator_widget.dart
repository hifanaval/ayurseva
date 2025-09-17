import 'dart:typed_data';
import 'package:ayurseva/screens/pdf_generator/widgets/full_screen_pdf_viewer_widget.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:ayurseva/screens/pdf_generator/models/invoice_data_model.dart';
import 'package:ayurseva/constants/string_class.dart';

/// PDF Generator Widget containing all PDF generation logic
class PdfGeneratorWidget {
  
  /// Generate PDF from invoice data
  static Future<Uint8List> generateInvoicePDF(InvoiceData data) async {
    debugPrint('PdfGeneratorWidget: Starting PDF generation');
    
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeader(data),
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
  static pw.Widget _buildHeader(InvoiceData data) {
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
                  style: pw.TextStyle(
                    fontSize: 24, 
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Container(
                  width: 60,
                  height: 60,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.green, width: 2),
                    borderRadius: pw.BorderRadius.circular(30),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      StringClass.logoText,
                      style: pw.TextStyle(color: PdfColors.green),
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
                  style: pw.TextStyle(
                    fontSize: 18, 
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  data.address, 
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.Text(
                  'e-mail: ${data.email}', 
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.Text(
                  'Mob: ${data.phone}', 
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'GST No: ${data.gstNumber}',
                  style: pw.TextStyle(
                    fontSize: 12, 
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green,
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
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            StringClass.patientDetails,
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green,
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
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }

  /// Build treatment table
  static pw.Widget _buildTreatmentTable(InvoiceData data) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.green100),
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
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.green : PdfColors.black,
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
            pw.Divider(color: PdfColors.grey400),
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
            style: pw.TextStyle(
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          pw.Text(
            amount,
            style: pw.TextStyle(
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
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
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.green,
          ),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          StringClass.thankYouMessage,
          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
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
                  color: PdfColors.black,
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  StringClass.signature,
                  style: const pw.TextStyle(fontSize: 12),
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
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Text(
        data.footerNote,
        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
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

