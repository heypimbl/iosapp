//
//  CameraView.swift
//  heypimbl
//
//  Created by Macbook Pro on 11/11/25.
//

import SwiftUI
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    var onCapture: (UIImage) -> Void

    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.onCapture = onCapture
        return controller
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var photoOutput: AVCapturePhotoOutput?
    var onCapture: ((UIImage) -> Void)?
    var currentCameraPosition: AVCaptureDevice.Position = .back
    var currentInput: AVCaptureDeviceInput?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    func setupCamera() {
        let session = AVCaptureSession()
        session.sessionPreset = .high

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            // Fallback: use front camera if back is not available
            guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
                showNoCamera()
                return
            }
            currentCameraPosition = .front
            setupWithCamera(frontCamera, session: session)
            return
        }

        setupWithCamera(camera, session: session)
    }

    func setupWithCamera(_ camera: AVCaptureDevice, session: AVCaptureSession) {
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            session.addInput(input)
            self.currentInput = input

            let photoOutput = AVCapturePhotoOutput()
            session.addOutput(photoOutput)
            self.photoOutput = photoOutput

            let preview = AVCaptureVideoPreviewLayer(session: session)
            preview.videoGravity = .resizeAspectFill
            view.layer.addSublayer(preview)
            previewLayer = preview

            captureSession = session

            // Start the session on a background thread to avoid UI blocking
            DispatchQueue.global(qos: .userInitiated).async {
                session.startRunning()
            }

            // Add capture button and flip button
            addCaptureButton()
            addFlipButton()
        } catch {
            showNoCamera()
        }
    }

    func showNoCamera() {
        let label = UILabel()
        label.text = "Camera not available"
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    func addCaptureButton() {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "circle.fill"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)

        view.addSubview(button)

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            button.widthAnchor.constraint(equalToConstant: 140),
            button.heightAnchor.constraint(equalToConstant: 140)
        ])

        // Make button larger for touch
        button.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
    }

    func addFlipButton() {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "camera.rotate.fill"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(flipCamera), for: .touchUpInside)

        view.addSubview(button)

        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.widthAnchor.constraint(equalToConstant: 50),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc func flipCamera() {
        guard let session = captureSession, let currentInput = currentInput else { return }

        let newPosition: AVCaptureDevice.Position = currentCameraPosition == .front ? .back : .front

        guard let newCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition) else {
            return
        }

        do {
            let newInput = try AVCaptureDeviceInput(device: newCamera)
            session.beginConfiguration()
            session.removeInput(currentInput)
            session.addInput(newInput)
            session.commitConfiguration()

            self.currentInput = newInput
            self.currentCameraPosition = newPosition
        } catch {
            // Failed to switch camera
        }
    }

    @objc func capturePhoto() {
        guard let photoOutput = photoOutput else { return }

        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            return
        }

        onCapture?(image)
    }
}
