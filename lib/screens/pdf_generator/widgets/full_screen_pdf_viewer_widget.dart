import 'dart:typed_data';

import 'package:ayurseva/constants/color_class.dart';
import 'package:ayurseva/constants/string_class.dart';
import 'package:ayurseva/constants/textstyle_class.dart';
import 'package:ayurseva/screens/home_screen/provider/patients_data_provider.dart';
import 'package:ayurseva/screens/home_screen/treatments_list_screen.dart';
import 'package:ayurseva/screens/pdf_generator/provider/pdf_generator_provider.dart';
import 'package:ayurseva/screens/pdf_generator/models/invoice_data_model.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

class FullScreenPDFViewer extends StatelessWidget {
  final Uint8List pdfData;
  final InvoiceData? data;

  const FullScreenPDFViewer({super.key, 
    required this.pdfData,
     this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorClass.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: ColorClass.primaryText.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${StringClass.invoice} - ${data?.patientName ?? ''}',
                      style: TextStyleClass.poppinsSemiBold(
                        14,
                        ColorClass.white,
                      ),
                    ),
                  ),
                  // Action buttons
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _downloadPDF(context, pdfData, data!),
                        icon: Icon(
                          Icons.download_outlined, 
                          color: ColorClass.primaryText, 
                          size: 30,
                        ),
                        tooltip: StringClass.downloadPdf,
                      ),
                      const SizedBox(width: 4),
                      // Close button
                      IconButton(
                        onPressed: () => _closePDFAndNavigate(context),
                        icon: Icon(
                          Icons.close_rounded, 
                          color: ColorClass.primaryText, 
                          size: 30,
                        ),
                        tooltip: StringClass.close,
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
                scrollViewDecoration: BoxDecoration(
                  color: ColorClass.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Download PDF and show success toast
  Future<void> _downloadPDF(
    BuildContext context,
    Uint8List pdfData,
    InvoiceData data,
  ) async {
    try {
      debugPrint('PdfGeneratorWidget: Starting PDF download from full screen viewer');
      
      final pdfProvider = Provider.of<PdfGeneratorProvider>(context, listen: false);
      
      // Request permissions
      final hasPermission = await pdfProvider.requestPermissions();
      if (!hasPermission) {
        _showErrorDialog(context, StringClass.storagePermissionRequired);
        return;
      }

      // Generate filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${StringClass.invoice}_${data.patientName}_$timestamp.pdf';
      
      // Save PDF
      final filePath = await pdfProvider.savePDF(pdfData, fileName);
      
      debugPrint('PdfGeneratorWidget: PDF downloaded successfully to $filePath');
      
      // Show success toast
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(StringClass.invoiceDownloadedSuccessfully),
          backgroundColor: ColorClass.primaryColor,
          duration: const Duration(seconds: 3),
        ),
      );
      
      // Close PDF and navigate
      _closePDFAndNavigate(context);
      
    } catch (e) {
      debugPrint('PdfGeneratorWidget: Error downloading PDF - $e');
      _showErrorDialog(context, '${StringClass.errorDownloadingPdf}: $e');
    }
  }

  /// Close PDF and navigate to treatment list screen
  void _closePDFAndNavigate(BuildContext context) {
    debugPrint('PdfGeneratorWidget: Closing PDF and navigating to treatment list');
    
    // Navigate to treatment list screen and fetch patient data
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TreatmentsListScreen()),
    );
    
    // Fetch patient data after navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final patientsProvider = Provider.of<PatientsDataProvider>(context, listen: false);
      // Clear any existing search when returning to treatment list
      patientsProvider.clearSearch();
      patientsProvider.fetchPatientsData(context);
      debugPrint('PdfGeneratorWidget: Patient data fetch initiated after navigation with cleared search');
    });
  }

  /// Show error dialog
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(StringClass.error),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(StringClass.ok),
          ),
        ],
      ),
    );
  }
}