//
//  ContentView.swift
//  ImgCrop
//
//  Created by Homing Lau on 2023-04-03.
//

import SwiftUI

struct ContentView: View {
    
    @State private var selectedImage: UIImage?
    @State private var showImagePicker: Bool = false
    @State private var showCropImg: Bool = false
    @State private var showResults: Bool = false
    var body: some View {
        VStack {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                Button(action: {
                    self.showCropImg = true
                }){
                    Text("Crop")
                }
            } else {
                Button("Import Image") {
                    self.showImagePicker = true
                }
            }
        }
        .sheet(isPresented: $showCropImg, content: {
            CropView(result: {result in
                self.showCropImg = false
                if !result.isEmpty{
                    self.showResults = true
                    
                }
                
            }, image: selectedImage)
        })
        .sheet(isPresented: $showImagePicker) {
            ImportView(result: {result in
                self.selectedImage = result
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


