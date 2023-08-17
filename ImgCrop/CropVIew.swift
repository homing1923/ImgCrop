//
//  CropVIew.swift
//  ImgCrop
//
//  Created by Homing Lau on 2023-04-03.
//

import SwiftUI
import PhotosUI
import MobileCoreServices
import UniformTypeIdentifiers

enum pSizeDim:String, CaseIterable{
    case A4, USL
    
    var targetSize: CGSize{
        get{
            switch(self){
            case.A4:
                return CGSize(width: 595, height: 842)
            case .USL:
                return CGSize(width: 612, height: 792)
            }
            
        }
    }
    
    var width: Double{
        get{
            switch self{
            case.A4:
                return 210
            case.USL:
                return 216
            }
        }
    }
    var height: Double{
        get{
            switch self{
            case.A4:
                return 297
            case.USL:
                return 280
            }
        }
    }
    var fit: Double{
        get{
            switch self{
            case.A4:
                return 2480
            case.USL:
                return 2550
            }
        }
    }
    var heightFactor: Double{
        get{
            switch self{
            case.A4:
                return Double(self.height/self.width).rounded()
            case.USL:
                return Double(self.height/self.width).rounded()
            }
        }
    }
    
    var WidhtFactor: Double{
        get{
            switch self{
            case.A4:
                return Double(self.width/self.height).rounded()
            case.USL:
                return Double(self.width/self.height).rounded()
            }
        }
    }
}

struct CropView: View {
    
    var result: ([UIImage?]) -> Void
    
    @State var image: UIImage?
    @State var resizedImag: UIImage?
    @State var imageSize: CGSize = .zero
    @State var pre_imageSize: CGSize = .zero
    @State private var targetSize: CGSize = CGSize(width: 595, height: 842)
    private let C_Column_arry: [Int] = Array<Int>(1..<11)
    private let C_Row_arry: [Int] = Array<Int>(1..<11)
    @State var renderer = UIGraphicsImageRenderer(size: CGSize(width: 595, height: 842))
    @State private var P_Size: pSizeDim = .A4
    @State private var C_Column: Int = 1
    @State private var C_Row: Int = 1
    @State private var H_Scaled: Double = 0.0
    @State private var W_Scaled: Double = 0.0
    @State private var aspectRatioMode: ContentMode = .fit
    @State private var Landscape: Bool = false
    @State var croppedImages = [UIImage]()
    @State private var showingDocumentPicker = false
    @State private var documentURL: URL?
    private let documentPickerDelegate = DocumentPickerDelegate()
    
    var body: some View {
        VStack{
            HStack {
                Text("Image Size: W:\(Int(imageSize.width)) x H:\(Int(imageSize.height))")
                    .foregroundColor(.secondary)
                    .font(.footnote)
                Spacer()
            }.padding(.horizontal)
            HStack {
                Text("PreView_Image Size: W:\(Int(resizedImag?.size.width ?? 0)) x H:\(Int(resizedImag?.size.height ?? 0))")
                    .foregroundColor(.secondary)
                    .font(.footnote)
                Spacer()
            }.padding(.horizontal)
            HStack {
                Text("Scaled Size: W:\(W_Scaled) x H:\(H_Scaled))")
                    .foregroundColor(.secondary)
                    .font(.footnote)
                Spacer()
            }.padding(.horizontal)
            HStack {
                Text("Image Count: \(self.croppedImages.count)")
                    .foregroundColor(.secondary)
                    .font(.footnote)
                Spacer()
            }.padding(.horizontal)
            Form{
                Picker("Size", selection: $P_Size, content: {
                    ForEach(pSizeDim.allCases, id: \.self){x in
                        Text(x.rawValue)
                    }
                })
                .pickerStyle(.automatic)
                Picker("Column", selection: $C_Column, content: {
                    ForEach(C_Column_arry, id:\.self){x in
                        Text(String(format:"%d", x))
                    }
                })
                Picker("Row", selection: $C_Row, content: {
                    ForEach(C_Row_arry, id:\.self){x in
                        Text(String(format:"%d", x))
                    }
                })
                Toggle("Landscape", isOn:$Landscape)
                
            }
            if !self.croppedImages.isEmpty {
                Text("Preview")
                GeometryReader{geo in
                    
                    ScrollView(.vertical){
                        LazyVGrid(columns: Array.init(repeating: .init(.adaptive(minimum: Landscape ? targetSize.width : targetSize.height, maximum: .infinity)), count: self.C_Column)){
                            ForEach(croppedImages, id: \.self){img in
                                Image(uiImage: img)
                                
                                    .resizable()
                                    .aspectRatio(CGSize(width: Landscape ? targetSize.height : targetSize.width, height: Landscape ? targetSize.width : targetSize.height), contentMode: .fit)
                                    .border(Color.black, width: 2)
                                
                                
                            }
                        }
                        .padding()
                        .frame(width: geo.size.width)
                    }
                }
            }
            
            
            Spacer()
            HStack {
                Spacer()
                Button(action: {
//                    if !self.croppedImages.isEmpty{
//                        result(self.croppedImages)
//                    }
//                    openDocumentPicker()
                    
                }) {
                    Text("Select")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                Button(action: {
//                    if !self.croppedImages.isEmpty{
//                        result(self.croppedImages)
//                    }
                    
                    showingDocumentPicker = true
                    
                }) {
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .sheet(isPresented: $showingDocumentPicker, onDismiss: saveImage) {
                    
                                if let documentURL = documentURL {
                                    Text("Image will be saved to: \(documentURL.path)")
                                } else {
                                    
                                    Text("Select a directory to save the image")
                                }
                            }
                .padding()
                Spacer()
            }
        }//top
        .onAppear{
            calcSize()
            crop()
        }
        .onChange(of: Landscape, perform: {_ in
            calcSize()
            crop()
        })
        .onChange(of: C_Column, perform: {_ in
            calcSize()
            crop()
        })
        .onChange(of: C_Row, perform: {_ in
            calcSize()
            crop()
        })
        .onChange(of: P_Size, perform: {newSize in
            self.targetSize = newSize.targetSize
            calcSize()
            crop()
        })
        .onDisappear{
            self.result([nil])
        }
        
    }
    
    func saveImage() {
        guard let image = image, let documentURL = documentURL else { return }

        let imageURL = documentURL.appendingPathComponent("myimage.jpg")

        do {
            guard let imageData = image.jpegData(compressionQuality: 1.0) else { return }
            try imageData.write(to: imageURL)
            print("Image saved to: \(imageURL)")
        } catch {
            print("Error saving image: \(error.localizedDescription)")
        }
    }
    
//    func openDocumentPicker() {
//        let documentPicker = UIDocumentPickerViewController(
//        documentPicker.delegate = documentPickerDelegate
//        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
//        guard let rootViewController = window.rootViewController else { return }
//        rootViewController.present(documentPicker, animated: true, completion: nil)
//    }
    
    func crop(){
        self.croppedImages.removeAll()
        guard let img = self.resizedImag else{
            return
        }
        var rect : CGRect? = nil
        var xIncr : Double = 0
        var yIncr : Double = 0
        if(Landscape){
            xIncr = targetSize.height
            yIncr = targetSize.width
        }else{
            xIncr = targetSize.width
            yIncr = targetSize.height
        }
        for loopY in (0..<C_Row) {
            
            for loopX in (0..<C_Column){
                rect = CGRect(x: Double(loopX) * xIncr, y: Double(loopY) * yIncr, width: Landscape ? targetSize.height : targetSize.width, height: Landscape ? targetSize.width : targetSize.height)
                if let croppedImg = img.cropped(to: rect!){
                    self.croppedImages.append(croppedImg)
                }
            }
        }
    }
    
    func calcSize(){
        if let image = image{
            self.imageSize = image.size
            
            var targetImageSizeW = 0.0
            var targetImageSizeH = 0.0
            if(Landscape){
                //Default paper orientation: v i.e. 297x210 h x w
                //|-----|
                //|     |
                //|     | h
                //|     |
                //|-----|
                //   w
                //
                //land
                //    w        w
                //|--------|--------|
                //|        |        | h
                //|--------|--------|
                //
                targetImageSizeW = self.targetSize.height * Double(self.C_Column)
                targetImageSizeH = self.targetSize.width * Double(self.C_Row)
                
            }else{
                //Coloum
                //|-----|-----|
                //|     |     |
                //|     |     | h
                //|     |     |
                //|-----|-----|
                //   w     w
                targetImageSizeW = self.targetSize.width * Double(self.C_Column)
                targetImageSizeH = self.targetSize.height * Double(self.C_Row)
            }
            self.H_Scaled = targetImageSizeH
            self.W_Scaled = targetImageSizeW
            let widthScaleRatio = targetImageSizeW / image.size.width
            let heightScaleRatio = targetImageSizeH / image.size.height
            // To keep the aspect ratio, scale by the smaller scaling ratio
            let scaleFactor = min(widthScaleRatio, heightScaleRatio)
            let bgSize = CGSize(width: targetImageSizeW, height: targetImageSizeH)
            let scaledImageSize = CGSize(
                width: image.size.width * scaleFactor,
                height: image.size.height * scaleFactor
            )
            UIGraphicsBeginImageContextWithOptions(bgSize, false, 0.0)
            UIColor.white.setFill()
            UIRectFill(CGRect(origin: .zero, size: bgSize))
            var Hpad = 0.0
            var Vpad = 0.0
            Hpad = (targetImageSizeW - scaledImageSize.width) / 2
            Vpad = (targetImageSizeH - scaledImageSize.height) / 2
            if(scaleFactor == widthScaleRatio){
                self.image!.draw(in: CGRect(x: 0, y: Vpad, width: scaledImageSize.width, height: scaledImageSize.height))
            }else{
                self.image!.draw(in: CGRect(x: Hpad, y: 0, width: scaledImageSize.width, height: scaledImageSize.height))
            }
            self.resizedImag = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            
        }
    }
    
    
    
}

class DocumentPickerDelegate: NSObject, UIDocumentPickerDelegate {
    var documentURL: URL?

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        documentURL = url
    }
}


struct CropVIew_Previews: PreviewProvider {
    static var previews: some View {
        CropView(result: {result in
            
        }, image: UIImage(systemName: "house") )
    }
}
