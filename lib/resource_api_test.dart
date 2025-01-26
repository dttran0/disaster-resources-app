// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// void main() async {
//   // RapidAPI host and key
//   const String baseUrl = "https://homeless-shelters-and-foodbanks-api.p.rapidapi.com/resources";
//   const Map<String, String> headers = {
//     "X-RapidAPI-Host": "homeless-shelters-and-foodbanks-api.p.rapidapi.com",
//     "X-RapidAPI-Key": "45b6753dc3msh875b1817bb6971ep1ee567jsn8ff80b3880a3",
//   };
//
//   // Query parameters
//   const String city = "Los Angeles"; // Replace with the desired city
//   const String state = "CA";         // Replace with the desired state
//
//   final Uri apiUrl = Uri.parse(baseUrl).replace(queryParameters: {
//     "city": city,
//     "state": state,
//   });
//
//   try {
//     // Make the HTTP GET request
//     final response = await http.get(apiUrl, headers: headers);
//
//     // Check the response status
//     if (response.statusCode == 200) {
//       // Parse and pretty-print the JSON response
//       final jsonResponse = json.decode(response.body);
//       print("JSON Response:");
//       print(JsonEncoder.withIndent('  ').convert(jsonResponse));
//     } else {
//       print("Failed to fetch data: ${response.statusCode}");
//     }
//   } catch (e) {
//     print("Error: $e");
//   }
// }