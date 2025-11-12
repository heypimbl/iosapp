//
//  ContentView.swift
//  heypimbl
//
//  Created by Macbook Pro on 11/11/25.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @State private var showCamera = true
    @State private var capturedImage: UIImage?
    @State private var showPreview = false
    @StateObject private var locationManager = LocationManager()

    // Development flag - set to true to skip actual API calls
    private let isTestMode = false

    var body: some View {
        ZStack {
            if showCamera && capturedImage == nil {
                CameraView { image in
                    capturedImage = image
                    showPreview = true
                    showCamera = false

                    // Request location permission if not yet determined
                    let status = CLLocationManager.authorizationStatus()
                    if status == .notDetermined {
                        locationManager.requestLocationPermission()
                    }
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
        // Check location permission status
        let status = CLLocationManager.authorizationStatus()

        switch status {
        case .denied, .restricted:
            // User has denied permission, submit without location
            submitToAPIWithLocation(image, location: nil)
        case .authorizedWhenInUse, .authorizedAlways:
            // We have permission, get current location
            locationManager.requestCurrentLocation { location in
                submitToAPIWithLocation(image, location: location)
            }
        default:
            // For notDetermined, submit without location (permission will be requested)
            submitToAPIWithLocation(image, location: nil)
        }
    }

    private func submitToAPIWithLocation(_ image: UIImage, location: CLLocationCoordinate2D?) {
        let timestamp = ISO8601DateFormatter().string(from: Date())

        print("[\(timestamp)] API Request Starting")
        print("Image size: \(image.size)")
        if let location = location {
            print("Location: \(location.latitude), \(location.longitude)")
        } else {
            print("Location: Not available")
        }

        if isTestMode {
            // Test mode - just log the data without making actual API call
            print("=== TEST MODE - NOT POSTING TO SERVER ===")
            print("=====================================")
            return
        }

        // Convert image to JPEG data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to JPEG")
            return
        }

        // Create the request URL
        guard let url = URL(string: "http://10.100.1.161:4000/problem") else {
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
        let timestampField = "--\(boundary)\r\nContent-Disposition: form-data; name=\"timestamp\"\r\n\r\n\(timestamp)\r\n"
        body.append(timestampField.data(using: .utf8) ?? Data())

        // Add location data if available
        if let location = location {
            let latitude = String(location.latitude)
            let longitude = String(location.longitude)
            let latField = "--\(boundary)\r\nContent-Disposition: form-data; name=\"latitude\"\r\n\r\n\(latitude)\r\n"
            let lonField = "--\(boundary)\r\nContent-Disposition: form-data; name=\"longitude\"\r\n\r\n\(longitude)\r\n"
            body.append(latField.data(using: .utf8) ?? Data())
            body.append(lonField.data(using: .utf8) ?? Data())
        }

        // Add image data
        let imageField = "--\(boundary)\r\nContent-Disposition: form-data; name=\"image[] \"; filename=\"photo.jpg\"\r\nContent-Type: image/jpeg\r\n\r\n"
        body.append(imageField.data(using: .utf8) ?? Data())
        body.append(imageData)
        body.append("\r\n".data(using: .utf8) ?? Data())

        // Add closing boundary
        let closingBoundary = "--\(boundary)--\r\n"
        body.append(closingBoundary.data(using: .utf8) ?? Data())

        request.httpBody = body

        // Send the request
        print("[\(timestamp)] Sending POST request to API")
        let requestStartTime = Date()

        URLSession.shared.dataTask(with: request) { data, response, error in
            let elapsed = Date().timeIntervalSince(requestStartTime)

            if let error = error {
                print("[\(timestamp)] API Error after \(String(format: "%.2f", elapsed))s: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("[\(timestamp)] API Response Status: \(httpResponse.statusCode) (after \(String(format: "%.2f", elapsed))s)")
            }

            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("[\(timestamp)] API Response Body: \(responseString)")
            }
        }.resume()

        print("[\(timestamp)] API Request queued (non-blocking)")
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
