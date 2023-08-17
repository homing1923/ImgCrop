//
//  ImportView.swift
//  ImgCrop
//
//  Created by Homing Lau on 2023-04-03.
//

import SwiftUI

struct ImportView: UIViewControllerRepresentable {
    var result: (UIImage) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(presentationMode: presentationMode, result: result)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var presentationMode: Binding<PresentationMode>
        var result: (UIImage) -> Void
        
        init(presentationMode: Binding<PresentationMode>, result: @escaping (UIImage) -> Void) {
                    self.presentationMode = presentationMode
                    self.result = result
                }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                result(image)
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct ImportView_Previews: PreviewProvider {
    static var previews: some View {
        ImportView(result: {result in
            
        })
    }
}
