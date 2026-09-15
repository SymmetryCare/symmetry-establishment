import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:symmetry_establishment/app/constants/app_config.dart';

class HtmlPostRequiest{
  void makePostRequest(String endpoint, String data) async {
    // Log the string
    print("Endpoint: $endpoint");
    // Base URL
    String baseUrl = "${AppConfig.endpoint}";
    // Full endpoint (dynamically changing based on the passed string)
    String fullUrl = "$baseUrl$endpoint";

    try {
      // Create Dio instance for making API requests
      Dio dio = Dio();

      // POST request
      Response response = await dio.post(
        fullUrl,
        data: jsonEncode({"data": data}), // Send the string data in the request body
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );
      if(response.statusCode == 200 || response.statusCode == 201){
        print("Requiest triggered");
      }else{
        print("Error");
      }
      // Print the response
      print("Response: ${response.data}");
    } catch (e) {
      // Handle errors
      print("Error: $e");
    }
  }
}