# HeyPimbl

An iOS app for reporting cars parked in bike lanes to 311 with photo evidence and location data.

## Overview

HeyPimbl makes it quick and easy to report parking violations in bike lanes by:
- Taking a photo of the violating car
- Capturing your GPS location automatically
- Submitting both to your city's 311 service in seconds

## Features

- **Quick Photo Capture**: Take photos with a single tap using the device camera
- **Automatic Location Tracking**: GPS coordinates are captured right after you take a photo
- **Live Feedback**:
  - Yellow warning banner showing the violation you're about to report
  - Yellow-green "Sending..." banner while your report is being submitted
  - Green success screen confirming the report was submitted
- **Graceful Fallback**: Works even if location permission is denied or GPS is unavailable

## How to Use

1. **Take a Photo**: Open the app and tap the camera button to capture an image of the parked car
2. **Review**: The preview screen shows your photo with a warning message
3. **Send**: Tap the green send button to submit the report
4. **Confirm**: A success message appears, and you're ready to report another violation

## Technical Details

- **Platform**: iOS 16.0+
- **Language**: SwiftUI
- **Permissions Required**: Camera, Location (When In Use)
- **API**: Posts to a 311 backend service with multipart form data

### Architecture

- `CameraView.swift` - Camera capture using AVFoundation
- `LocationManager.swift` - GPS location tracking with CoreLocation
- `PreviewView.swift` - Image preview and submission UI
- `ContentView.swift` - Main app orchestration and API submission

## Development

The app includes a test mode that can be enabled by setting `isTestMode = true` in `ContentView.swift` to test functionality without making API calls.

## Data Submitted

When you submit a report, the following information is sent to the 311 service:
- Photo (JPEG)
- GPS Latitude/Longitude (if location permission granted)
- Timestamp (ISO 8601 format)
