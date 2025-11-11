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
                        print("Image sent!")
                        resetCamera()
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
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
