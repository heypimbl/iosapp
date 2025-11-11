//
//  PreviewView.swift
//  heypimbl
//
//  Created by Macbook Pro on 11/11/25.
//

import SwiftUI

struct PreviewView: View {
    let image: UIImage
    var onSend: () -> Void
    var onCancel: () -> Void

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Warning banner
                Text("You're parked in my bike lane!")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.red)

                // Image preview
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea(edges: .top)

                // Action buttons
                HStack(spacing: 60) {
                    // Cancel button (Red X)
                    Button(action: onCancel) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.red)
                    }

                    // Send button (Green Arrow)
                    Button(action: onSend) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
                .background(Color(.systemBackground))
            }
        }
    }
}

#if DEBUG
struct PreviewView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleImage = UIImage(systemName: "photo.fill") ?? UIImage()
        PreviewView(image: sampleImage, onSend: {}, onCancel: {})
    }
}
#endif
