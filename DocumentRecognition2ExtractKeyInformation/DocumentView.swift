//
//  DocumentView.swift
//  DocumentRecognition2ExtractKeyInformation
//
//  Created by Quanpeng Yang on 3/17/26.
//

import SwiftUI
import Vision
import DataDetection

struct DocumentView: View {
    @State private var textFound: String = "Recognizing..."
    
    var body: some View {
        VStack {
            ScrollView {
                Text(textFound)
                    .padding()
                    .font(.system(.body, design: .monospaced)) // Makes data easier to read
            }
            Spacer()
        }
        .task {
            // 1. Load from Assets instead of Bundle URL
            guard let uiImage = UIImage(named: "letter"),
                  let cgImage = uiImage.cgImage else {
                textFound = "Image 'letter' not found in assets."
                return
            }
            
            do {
                let request = RecognizeDocumentsRequest()
                
                // 2. Perform the request on the CGImage
                let result = try await request.perform(on: cgImage)
                
                var detectedInfo = ""
                
                if let document = result.first?.document {
                    // 3. Iterate through detected data (Emails, Phones, etc.)
                    for data in document.text.detectedData {
                        switch data.match.details {
                        case .emailAddress(let value):
                            detectedInfo += "📧 Email: \(value.emailAddress)\n"
                        case .phoneNumber(let value):
                            detectedInfo += "📞 Phone: \(value.phoneNumber)\n"
                        case .postalAddress(let value):
                            detectedInfo += "📍 Address: \(value.fullAddress)\n"
                        case .calendarEvent(let value):
                            detectedInfo += "📆 Date: \(value.startDate)\n"
                        default:
                            break
                        }
                    }
                    
                    // Fallback if no specific data was found
                    textFound = detectedInfo.isEmpty ? "No contact info detected." : detectedInfo
                }
            } catch {
                textFound = "Error: \(error.localizedDescription)"
                print("Error performing the request: \(error)")
            }
        }
    }
}
