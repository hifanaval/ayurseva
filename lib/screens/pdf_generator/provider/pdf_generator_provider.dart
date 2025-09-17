import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ayurseva/screens/pdf_generator/models/invoice_data_model.dart';
import 'package:ayurseva/screens/pdf_generator/widgets/pdf_generator_widget.dart';

/// Provider for managing PDF generation state and operations
class PdfGeneratorProvider extends ChangeNotifier {
  bool _isGenerating = false;
  bool _isDownloading = false;
  String? _lastGeneratedFilePath;
  String? _errorMessage;

  // Getters
  bool get isGenerating => _isGenerating;
  bool get isDownloading => _isDownloading;
  String? get lastGeneratedFilePath => _lastGeneratedFilePath;
  String? get errorMessage => _errorMessage;

  /// Request storage permissions for PDF download
  Future<bool> requestPermissions() async {
    debugPrint('PdfGeneratorProvider: Requesting storage permissions');
    
    try {
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
        
        debugPrint('PdfGeneratorProvider: Storage permission status: $storageStatus');
        return storageStatus == PermissionStatus.granted;
      }
      
      // For iOS, request photos permission
      if (Platform.isIOS) {
        var photosStatus = await Permission.photos.request();
        debugPrint('PdfGeneratorProvider: iOS photos permission status: $photosStatus');
        return photosStatus == PermissionStatus.granted;
      }
      
      return true; // For other platforms
    } catch (e) {
      debugPrint('PdfGeneratorProvider: Error requesting permissions: $e');
      _errorMessage = 'Failed to request permissions: $e';
      notifyListeners();
      return false;
    }
  }

  /// Save PDF to device storage
  Future<String> savePDF(Uint8List pdfData, String fileName) async {
    debugPrint('PdfGeneratorProvider: Saving PDF with filename: $fileName');
    
    try {
      _isDownloading = true;
      _errorMessage = null;
      notifyListeners();

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
          debugPrint('PdfGeneratorProvider: Failed to access Downloads directory: $e');
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
      
      _lastGeneratedFilePath = filePath;
      debugPrint('PdfGeneratorProvider: PDF saved successfully to: $filePath');
      
      return filePath;
      
    } catch (e) {
      debugPrint('PdfGeneratorProvider: Error saving PDF: $e');
      _errorMessage = 'Failed to save PDF: $e';
      rethrow;
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }

  /// Generate and show invoice with download and close options
  Future<void> generateAndShowInvoice(
    BuildContext context,
    InvoiceData data,
  ) async {
    try {
      debugPrint('PdfGeneratorProvider: Starting PDF generation with download options');
      
      _isGenerating = true;
      _errorMessage = null;
      notifyListeners();

      // Show loading dialog
      _showLoadingDialog(context);

      // Generate PDF using the widget
      final pdfData = await PdfGeneratorWidget.generateInvoicePDF(data);
      
      // Close loading dialog
      Navigator.pop(context);
      
      // Show PDF with custom actions
      await _showPDFWithActions(context, pdfData, data);
      
    } catch (e) {
      debugPrint('PdfGeneratorProvider: Error generating invoice - $e');
      _errorMessage = 'Failed to generate invoice: $e';
      Navigator.pop(context);
      _showErrorDialog(context, 'Error generating invoice: $e');
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  /// Show loading dialog
  void _showLoadingDialog(BuildContext context) {
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
  }

  /// Show PDF with download and close actions in full screen
  Future<void> _showPDFWithActions(
    BuildContext context,
    Uint8List pdfData,
    InvoiceData data,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfGeneratorWidget.createFullScreenViewer(
          pdfData: pdfData,
          data: data,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  /// Show error dialog
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

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset all state
  void reset() {
    _isGenerating = false;
    _isDownloading = false;
    _lastGeneratedFilePath = null;
    _errorMessage = null;
    notifyListeners();
  }
}
