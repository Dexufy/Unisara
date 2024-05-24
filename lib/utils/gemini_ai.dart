import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'constants.dart';

class GeminiAI {
  static final model = GenerativeModel(
    model: 'gemini-1.5-pro-latest',
    apiKey: Constants.apiKey,
  );

  static bool isFirstMessage = true;
  static String lastResponse = '';
  static Map<String, dynamic> allData = {};

  static Future<Map<String, dynamic>> loadData() async {
    String jsonContent =
        await rootBundle.loadString('assets/UnisaraKnowledge.json');
    List<dynamic> jsonData = jsonDecode(jsonContent);
    Map<String, dynamic> allData = {};

    // Add your logic to read the data here
    for (var item in jsonData) {
      if (item.containsKey('university')) {
        allData[item['university']['name']] = item['university'];
      } else if (item.containsKey('partnerships')) {
        allData.addAll(item['partnerships']);
      } else if (item.containsKey('management_team')) {
        allData.addAll(item['management_team']);
      } else if (item.containsKey('centre_for_quality_assurance')) {
        allData.addAll(item['centre_for_quality_assurance']);
      } else if (item.containsKey('offered_schools_and_programmes')) {
        allData.addAll(item['offered_schools_and_programmes']);
      } else if (item.containsKey('accreditation')) {
        allData.addAll(item['accreditation']);
      } else if (item.containsKey('international_collaborations')) {
        allData.addAll(item['international_collaborations']);
      } else if (item.containsKey('CQI_Plan')) {
        allData.addAll(item['CQI_Plan']);
      } else if (item.containsKey('links')) {
        allData.addAll(item['links']);
      } else if (item.containsKey('CQA_Staff')) {
        allData.addAll(item['CQA_Staff']);
      } else if (item.containsKey('CEPD')) {
        allData.addAll(item['CEPD']);
      } else if (item.containsKey('school_of_foundation_study')) {
        allData['school_of_foundation_study'] =
            item['school_of_foundation_study'];
      } else if (item.containsKey('staff')) {
        allData.addAll(item['staff']);
      } else if (item.containsKey('programme')) {
        allData.addAll(item['programme']);
      } else if (item.containsKey('publications')) {
        allData.addAll(item['publications']);
      } else if (item.containsKey('programs_offered')) {
        allData['programs_offered'] = item['programs_offered'];
      }
    }

    return allData;
  }

  static Future<String> generateResponse(String message) async {
    // Load data if it's not already loaded
    if (allData.isEmpty) {
      await loadData();
    }
    String response = '';

    // Check if it's the first message
    if (isFirstMessage) {
      response =
          "Hello, my name is Sara. Is there anything I can help you with?";
      isFirstMessage = false;
    } else {
      // Check for the abbreviation 'UTS' and map it to 'University of Technology Sarawak'
      if (message.toLowerCase().contains('uts')) {
        message =
            message.replaceAll('uts', 'UTS' 'University of Technology Sarawak');
      }

      // Example: If the user asks for the location, fetch it from data
      if (allData.isNotEmpty) {
        if (allData
            .containsKey('University of Technology Sarawak (UTS) (uts)')) {
          if (message.toLowerCase().contains('location')) {
            response =
                allData['University of Technology Sarawak (UTS)']['location'];
          } else if (message.toLowerCase().contains('established')) {
            response = allData['University of Technology Sarawak (UTS)']
                    ['established']
                .toString();
          }
        }

        // Add logic to handle other user queries
        if (allData.containsKey('School of Foundation Studies')) {
          if (message.toLowerCase().contains('dean of foundation studies')) {
            response =
                allData['School of Foundation Studies']['staff'][0]['name'];
          } else if (message
              .toLowerCase()
              .contains('foundation in arts program')) {
            response = "Foundation in Arts";
          } else if (message
              .toLowerCase()
              .contains('foundation in science program')) {
            response = "Foundation in Science";
          } else if (message
              .toLowerCase()
              .contains('admission requirements for foundation in science')) {
            response =
                "Please check the official university website for detailed admission requirements.";
          } else if (message
              .toLowerCase()
              .contains('admission requirements for foundation in arts')) {
            response =
                "Please check the official university website for detailed admission requirements.";
          } else if (message.toLowerCase().contains('activities')) {
            response =
                "The School of Foundation Studies offers various activities to engage students.";
          }
          // Handle more queries similarly
        }

        if (allData.containsKey('School of Engineering and Technology')) {
          if (message
              .toLowerCase()
              .contains('dean of engineering and technology')) {
            response = allData['School of Engineering and Technology']['staff']
                [0]['name'];
          } else if (message
              .toLowerCase()
              .contains('mechanical engineering program')) {
            response = allData['School of Engineering and Technology']
                ['undergraduate_programmes'][1];
          } else if (message
              .toLowerCase()
              .contains('civil engineering program')) {
            response = allData['School of Engineering and Technology']
                ['undergraduate_programmes'][0];
          }
        }

        if (allData.containsKey('School of Built Environment (SBE)')) {
          if (message.toLowerCase().contains('dean of built environment')) {
            response =
                allData['School of Built Environment (SBE)']['dean']['name'];
          } else if (message.toLowerCase().contains('architecture program')) {
            response = allData['School of Built Environment (SBE)']
                ['undergraduate_programmes'][0];
          } else if (message
              .toLowerCase()
              .contains('quantity surveying program')) {
            response = allData['School of Built Environment (SBE)']
                ['undergraduate_programmes'][1];
          } else if (message
              .toLowerCase()
              .contains('interior design program')) {
            response = allData['School of Built Environment (SBE)']
                ['undergraduate_programmes'][2];
          } else if (message
              .toLowerCase()
              .contains('property management program')) {
            response = allData['School of Built Environment (SBE)']
                ['undergraduate_programmes'][3];
          } else if (message.toLowerCase().contains('master of architecture')) {
            response = allData['School of Built Environment (SBE)']
                ['postgraduate_programmes'][0];
          } else if (message
              .toLowerCase()
              .contains('master of construction management')) {
            response = allData['School of Built Environment (SBE)']
                ['postgraduate_programmes'][1];
          } else if (message.toLowerCase().contains('academic staff')) {
            response = allData['School of Built Environment (SBE)']['team']
                    ['academic_staff']
                .map((staff) => staff['name'])
                .join(', ');
          } else if (message.toLowerCase().contains('administrative staff')) {
            response = allData['School of Built Environment (SBE)']['team']
                    ['administrative_staff']
                .map((staff) => staff['name'])
                .join(', ');
          } else if (message.toLowerCase().contains('technical staff')) {
            response = allData['School of Built Environment (SBE)']['team']
                    ['technical_staff']
                .map((staff) => staff['name'])
                .join(', ');
          }
        }
      }

      // If no specific query matches and it's not a knowledge-based question, use the AI model to generate a response
      if (response.isEmpty &&
          !message.toLowerCase().contains('foundation in') &&
          !message.toLowerCase().contains('location') &&
          !message.toLowerCase().contains('established')) {
        final aiResponse = await model.generateContent([Content.text(message)]);
        response = aiResponse.text ?? "";
      }
    }

    // If the bot couldn't find any information
    if (response.isEmpty) {
      response =
          "Oh, I'm sorry, I could not answer because I am still young to know anything, I just born yesterday hehe. But to answer your question, maybe you should go to https://www.uts.edu.my/ for more detail.";
    }

    // Remove unnecessary symbols from the response
    response = removeUnnecessarySymbols(response);

    // Update lastResponse
    lastResponse = response;

    return response;
  }

  static String removeUnnecessarySymbols(String text) {
    // Define unnecessary symbols/patterns to remove
    List<String> unnecessarySymbols = ['**', '__', '``'];

    // Remove unnecessary symbols from the text
    unnecessarySymbols.forEach((symbol) {
      text = text.replaceAll(symbol, '');
    });

    return text;
  }

  static String handleSubsequentMessages(String message) {
    String responseIf = ''; // Renamed variable to responseIf
    // Check if the message is related to the previous question or response
    if (lastResponse.isNotEmpty && message.toLowerCase().contains("yes")) {
      responseIf = "Great! Is there anything else I can assist you with?";
    } else if (lastResponse.isNotEmpty &&
        message.toLowerCase().contains("no")) {
      responseIf =
          "I'm sorry to hear that. Please let me know if you have any other questions.";
    } else {
      responseIf = "I'm sorry, I didn't catch that. Can you please clarify?";
    }

    return responseIf;
  }
}
