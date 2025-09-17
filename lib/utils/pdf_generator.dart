import 'dart:io';
import 'dart:typed_data';
import 'package:ayurseva/constants/color_class.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:ayurseva/screens/registration_screen/registration_screen.dart';
import 'package:ayurseva/screens/registration_screen/provider/treatment_type_provider.dart';
import 'package:ayurseva/screens/home_screen/provider/patients_data_provider.dart';
import 'package:ayurseva/screens/home_screen/treatments_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// Invoice Data Model
class InvoiceData {
  final String companyName;
  final String branchName;
  final String address;
  final String email;
  final String phone;
  final String gstNumber;
  
  final String patientName;
  final String patientAddress;
  final String patientWhatsApp;
  final String bookedOn;
  final String treatmentDate;
  final String treatmentTime;
  
  final List<TreatmentItem> treatments;
  final double totalAmount;
  final double discount;
  final double advance;
  final double balance;
  
  final String thankYouMessage;
  final String footerNote;

  InvoiceData({
    required this.companyName,
    required this.branchName,
    required this.address,
    required this.email,
    required this.phone,
    required this.gstNumber,
    required this.patientName,
    required this.patientAddress,
    required this.patientWhatsApp,
    required this.bookedOn,
    required this.treatmentDate,
    required this.treatmentTime,
    required this.treatments,
    required this.totalAmount,
    required this.discount,
    required this.advance,
    required this.balance,
    required this.thankYouMessage,
    required this.footerNote,
  });
}

class TreatmentItem {
  final String name;
  final double price;
  final int maleCount;
  final int femaleCount;
  final double total;

  TreatmentItem({
    required this.name,
    required this.price,
    required this.maleCount,
    required this.femaleCount,
    required this.total,
  });
}

// Invoice Generator Service
class InvoiceGenerator {

  // Request permissions
  static Future<bool> requestPermissions() async {
    print('InvoiceGenerator: Requesting storage permissions');
    
    // For Android 13+ (API 33+), request media permissions
    if (Platform.isAndroid) {
      // Check Android version and request appropriate permissions
      var storageStatus = await Permission.storage.request();
      
      if (storageStatus != PermissionStatus.granted) {
        // Try manage external storage for Android 11+
        storageStatus = await Permission.manageExternalStorage.request();
      }
      
      if (storageStatus != PermissionStatus.granted) {
        // For Android 13+, try media permissions
        var photosStatus = await Permission.photos.request();
        if (photosStatus == PermissionStatus.granted) {
          storageStatus = PermissionStatus.granted;
        }
      }
      
      print('InvoiceGenerator: Storage permission status: $storageStatus');
      return storageStatus == PermissionStatus.granted;
    }
    
    // For iOS, request photos permission
    if (Platform.isIOS) {
      var photosStatus = await Permission.photos.request();
      print('InvoiceGenerator: iOS photos permission status: $photosStatus');
      return photosStatus == PermissionStatus.granted;
    }
    
    return true; // For other platforms
  }

  // Generate PDF
  static Future<Uint8List> generateInvoicePDF(InvoiceData data) async {
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

    return pdf.save();
  }

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
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
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
                      'LOGO',
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
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 5),
                pw.Text(data.address, style: const pw.TextStyle(fontSize: 12)),
                pw.Text('e-mail: ${data.email}', style: const pw.TextStyle(fontSize: 12)),
                pw.Text('Mob: ${data.phone}', style: const pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 10),
                pw.Text(
                  'GST No: ${data.gstNumber}',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

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
            'Patient Details',
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
                    _buildDetailRow('Name', data.patientName),
                    _buildDetailRow('Address', data.patientAddress),
                    _buildDetailRow('WhatsApp Number', data.patientWhatsApp),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Booked On', data.bookedOn),
                    _buildDetailRow('Treatment Date', data.treatmentDate),
                    _buildDetailRow('Treatment Time', data.treatmentTime),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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

  static pw.Widget _buildTreatmentTable(InvoiceData data) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.green100),
          children: [
            _buildTableCell('Treatment', isHeader: true),
            _buildTableCell('Price', isHeader: true),
            _buildTableCell('Male', isHeader: true),
            _buildTableCell('Female', isHeader: true),
            _buildTableCell('Total', isHeader: true),
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

  static pw.Widget _buildAmountSummary(InvoiceData data) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 250,
        child: pw.Column(
          children: [
            _buildAmountRow('Total Amount', data.totalAmount.toStringAsFixed(0)),
            _buildAmountRow('Discount', data.discount.toStringAsFixed(0)),
            _buildAmountRow('Advance', data.advance.toStringAsFixed(0)),
            pw.Divider(color: PdfColors.grey400),
            _buildAmountRow(
              'Balance',
              data.balance.toStringAsFixed(0),
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

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
          'Your well-being is our commitment, and we\'re honored you\'ve entrusted us with your health journey.',
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
                  'Signature',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

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

  // Save PDF to device
  static Future<String> savePDF(Uint8List pdfData, String fileName) async {
    print('InvoiceGenerator: Saving PDF with filename: $fileName');
    
    try {
      Directory directory;
      String filePath;
      
      if (Platform.isAndroid) {
        // For Android, try multiple storage locations
        try {
          // First try Downloads directory
          final externalDir = await getExternalStorageDirectory();
          if (externalDir != null) {
            final downloadsPath = '${externalDir.parent.parent.parent.parent.path}/Download';
            final downloadsDir = Directory(downloadsPath);
            
            if (await downloadsDir.exists()) {
              directory = downloadsDir;
              filePath = '$downloadsPath/$fileName';
            } else {
              await downloadsDir.create(recursive: true);
              directory = downloadsDir;
              filePath = '$downloadsPath/$fileName';
            }
          } else {
            throw Exception('Could not access external storage');
          }
        } catch (e) {
          print('InvoiceGenerator: Failed to access Downloads directory: $e');
          // Fallback to app's external storage directory
          directory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
          filePath = '${directory.path}/$fileName';
        }
      } else if (Platform.isIOS) {
        // For iOS, use documents directory
        directory = await getApplicationDocumentsDirectory();
        filePath = '${directory.path}/$fileName';
      } else {
        // For other platforms
        directory = await getApplicationDocumentsDirectory();
        filePath = '${directory.path}/$fileName';
      }
      
      // Ensure directory exists
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      
      // Write file
      final file = File(filePath);
      await file.writeAsBytes(pdfData);
      
      print('InvoiceGenerator: PDF saved successfully to: $filePath');
      return filePath;
      
    } catch (e) {
      print('InvoiceGenerator: Error saving PDF: $e');
      rethrow;
    }
  }


  // Generate and show invoice with download and close options
  static Future<void> generateAndShowInvoice(
    BuildContext context,
    InvoiceData data,
  ) async {
    try {
      print('InvoiceGenerator: Starting PDF generation with download options');
      
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Generating invoice...'),
            ],
          ),
        ),
      );

      // Generate PDF
      final pdfData = await generateInvoicePDF(data);
      
      // Close loading dialog
      Navigator.pop(context);
      
      // Show PDF with custom actions
      await _showPDFWithActions(context, pdfData, data);
      
    } catch (e) {
      print('InvoiceGenerator: Error generating invoice - $e');
      Navigator.pop(context);
      _showErrorDialog(context, 'Error generating invoice: $e');
    }
  }

  // Show PDF with download and close actions in full screen
  static Future<void> _showPDFWithActions(
    BuildContext context,
    Uint8List pdfData,
    InvoiceData data,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FullScreenPDFViewer(
          pdfData: pdfData,
          data: data,
        ),
        fullscreenDialog: true,
      ),
    );
  }



  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Legacy method for backward compatibility
  static Future<void> generateAndShowReceipt({
    required BuildContext context,
    required String patientName,
    required String address,
    required String whatsappNumber,
    required String treatmentDate,
    required String treatmentTime,
    required List<Treatment> selectedTreatments,
    required TreatmentTypeProvider treatmentProvider,
    required String totalAmount,
    required String discountAmount,
    required String advanceAmount,
    required String balanceAmount,
    required String selectedLocation,
    required String selectedBranch,
  }) async {
    try {
      print('InvoiceGenerator: Starting PDF generation (legacy method)');
      
      // Convert data to new format
      final now = DateTime.now();
      final bookingDate = DateFormat('dd/MM/yyyy').format(now);
      final bookingTime = DateFormat('hh:mm a').format(now);
      
      // Convert treatments to new format
      List<TreatmentItem> treatmentItems = [];
      for (var treatment in selectedTreatments) {
        final apiTreatment = treatmentProvider.treatments.firstWhere(
          (t) => t.name == treatment.name,
          orElse: () => treatmentProvider.treatments.first,
        );
        final price = double.tryParse(apiTreatment.price ?? '0') ?? 0.0;
        final total = price * (treatment.maleCount + treatment.femaleCount);
        
        treatmentItems.add(TreatmentItem(
          name: treatment.name,
          price: price,
          maleCount: treatment.maleCount,
          femaleCount: treatment.femaleCount,
          total: total,
        ));
      }
      
      final invoiceData = InvoiceData(
        companyName: 'Amruta Ayurveda',
        branchName: selectedLocation.toUpperCase(),
        address: 'Cheepunkal P.O. Kumarakom, Kottayam, Kerala - 686563',
        email: 'unknown@gmail.com',
        phone: '+91 9876543210 | +91 9786543210',
        gstNumber: '32AABCU9603R1ZW',
        patientName: patientName,
        patientAddress: address,
        patientWhatsApp: whatsappNumber,
        bookedOn: '$bookingDate | $bookingTime',
        treatmentDate: treatmentDate,
        treatmentTime: treatmentTime,
        treatments: treatmentItems,
        totalAmount: double.tryParse(totalAmount) ?? 0.0,
        discount: double.tryParse(discountAmount) ?? 0.0,
        advance: double.tryParse(advanceAmount) ?? 0.0,
        balance: double.tryParse(balanceAmount) ?? 0.0,
        thankYouMessage: 'Thank you for choosing us',
        footerNote: 'Booking amount is non-refundable, and it\'s important to arrive on the allotted time for your treatment',
      );
      
      // Use new method with download and close options
      await generateAndShowInvoice(context, invoiceData);
      
      print('InvoiceGenerator: PDF generated successfully (legacy method)');
      
    } catch (e) {
      print('InvoiceGenerator: Error generating PDF (legacy method) - $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Full Screen PDF Viewer Widget
class _FullScreenPDFViewer extends StatelessWidget {
  final Uint8List pdfData;
  final InvoiceData data;

  const _FullScreenPDFViewer({
    required this.pdfData,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Invoice - ${data.patientName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
                  // Download button
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _downloadPDF(context, pdfData, data),
                        icon:  Icon(Icons.download_outlined, color: ColorClass.primaryText, size: 30),
                        tooltip: 'Download PDF',
                      ),
                      const SizedBox(width: 4),
                      // Close button
                      IconButton(
                        onPressed: () => _closePDFAndNavigate(context),
                        icon:  Icon(Icons.close_rounded, color: ColorClass.primaryText, size: 30),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // PDF Viewer taking full screen
            Expanded(
              child: PdfPreview(
                build: (format) => pdfData,
                allowPrinting: false,
                allowSharing: false,
                canChangePageFormat: false,
                canChangeOrientation: false,
                canDebug: false,
                scrollViewDecoration: const BoxDecoration(
                  color: Colors.white,
                ),
              ),
            ),
            // Top right action buttons
            
            // Title at top left
            
          ],
        ),
      ),
    );
  }

  // Download PDF and show success toast
  Future<void> _downloadPDF(
    BuildContext context,
    Uint8List pdfData,
    InvoiceData data,
  ) async {
    try {
      print('InvoiceGenerator: Starting PDF download from full screen viewer');
      
      // Request permissions
      final hasPermission = await InvoiceGenerator.requestPermissions();
      if (!hasPermission) {
        _showErrorDialog(context, 'Storage permission required for download');
        return;
      }

      // Generate filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'Invoice_${data.patientName}_$timestamp.pdf';
      
      // Save PDF
      final filePath = await InvoiceGenerator.savePDF(pdfData, fileName);
      
      print('InvoiceGenerator: PDF downloaded successfully to $filePath');
      
      // Show success toast
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invoice downloaded successfully!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
      
      // Close PDF and navigate
      _closePDFAndNavigate(context);
      
    } catch (e) {
      print('InvoiceGenerator: Error downloading PDF - $e');
      _showErrorDialog(context, 'Error downloading PDF: $e');
    }
  }

  // Close PDF and navigate to treatment list screen
  void _closePDFAndNavigate(BuildContext context) {
    print('InvoiceGenerator: Closing PDF and navigating to treatment list');
    
    // Navigate to treatment list screen and fetch patient data
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TreatmentsListScreen()),
    );
    
    // Fetch patient data after navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final patientsProvider = Provider.of<PatientsDataProvider>(context, listen: false);
      patientsProvider.fetchPatientsData(context);
      print('InvoiceGenerator: Patient data fetch initiated after navigation');
    });
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}