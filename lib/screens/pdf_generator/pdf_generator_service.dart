import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ayurseva/screens/pdf_generator/models/invoice_data_model.dart';
import 'package:ayurseva/screens/pdf_generator/provider/pdf_generator_provider.dart';
import 'package:ayurseva/screens/registration_screen/models/selected_treatment_model.dart';
import 'package:ayurseva/screens/registration_screen/provider/treatment_type_provider.dart';
import 'package:ayurseva/constants/string_class.dart';

/// Service class for PDF generation operations
class PdfGeneratorService {
  
  /// Generate and show invoice using the new provider-based approach
  static Future<void> generateAndShowInvoice(
    BuildContext context,
    InvoiceData data,
  ) async {
    debugPrint('PdfGeneratorService: Starting invoice generation');
    
    final pdfProvider = Provider.of<PdfGeneratorProvider>(context, listen: false);
    await pdfProvider.generateAndShowInvoice(context, data);
  }

  /// Legacy method for backward compatibility - converts old format to new format
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
      debugPrint('PdfGeneratorService: Starting PDF generation (legacy method)');
      
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
        companyName: StringClass.companyName,
        branchName: selectedLocation.toUpperCase(),
        address: StringClass.companyAddress,
        email: StringClass.companyEmail,
        phone: StringClass.companyPhone,
        gstNumber: StringClass.gstNumber,
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
        thankYouMessage: StringClass.thankYouForChoosingUs,
        footerNote: StringClass.bookingTermsAndConditions,
      );
      
      // Use new method with provider
      await generateAndShowInvoice(context, invoiceData);
      
      debugPrint('PdfGeneratorService: PDF generated successfully (legacy method)');
      
    } catch (e) {
      debugPrint('PdfGeneratorService: Error generating PDF (legacy method) - $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${StringClass.errorGeneratingPdf}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
