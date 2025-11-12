//
//  ContentView.swift
//  heypimbl
//
//  Created by Macbook Pro on 11/11/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showCamera = true
    @State private var capturedImage: UIImage?
    @State private var showPreview = false

    var body: some View {
        ZStack {
            if showCamera && capturedImage == nil {
                CameraView { image in
                    capturedImage = image
                    showPreview = true
                    showCamera = false
                }
                .ignoresSafeArea()
            } else if showPreview, let image = capturedImage {
                PreviewView(
                    image: image,
                    onSend: {
                        // Handle send action
                        submitImageToAPI(image)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            resetCamera()
                        }
                    },
                    onCancel: {
                        // Handle cancel action
                        resetCamera()
                    }
                )
            }
        }
    }

    private func resetCamera() {
        capturedImage = nil
        showPreview = false
        showCamera = true
    }

    private func submitImageToAPI(_ image: UIImage) {
        // Convert image to JPEG data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to JPEG")
            return
        }

        // Create the request URL
        guard let url = URL(string: "API_STRING_TODO") else {
            print("Invalid API URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // Create multipart form data
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        // Add current timestamp
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let timestampField = "--\(boundary)\r\nContent-Disposition: form-data; name=\"timestamp\"\r\n\r\n\(timestamp)\r\n"
        body.append(timestampField.data(using: .utf8) ?? Data())

        // Add image data
        let imageField = "--\(boundary)\r\nContent-Disposition: form-data; name=\"image\"; filename=\"photo.jpg\"\r\nContent-Type: image/jpeg\r\n\r\n"
        body.append(imageField.data(using: .utf8) ?? Data())
        body.append(imageData)
        body.append("\r\n".data(using: .utf8) ?? Data())

        // Add closing boundary
        let closingBoundary = "--\(boundary)--\r\n"
        body.append(closingBoundary.data(using: .utf8) ?? Data())

        request.httpBody = body

        // Send the request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("API Error: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("API Response Status: \(httpResponse.statusCode)")
            }

            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("API Response: \(responseString)")
            }
        }.resume()
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
