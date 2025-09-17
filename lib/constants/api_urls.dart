class ApiUrls {
  static const String baseUrl = 'https://flutter-amr.noviindus.in/api/';

  static String verifyLogin() {
    return '${baseUrl}Login';
  }

  static String getPatientsData() {
    return '${baseUrl}PatientList';
  }
}