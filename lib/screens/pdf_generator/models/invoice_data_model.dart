
/// Invoice Data Model for PDF generation
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

/// Treatment Item Model for PDF invoice
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
