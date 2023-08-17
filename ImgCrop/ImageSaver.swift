//
//  ImageSaver.swift
//  ImgCrop
//
//  Created by Homing Lau on 2023-04-04.
//

import Foundation
import UIKit

class ImageSaver: NSObject {
    var successHandler: (() -> Void)?
    var errorHandler: ((Error) -> Void)?

    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }
    

    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print(#function, error.localizedDescription)
            errorHandler?(error)
        } else {
            print(#function, "Saved")
            successHandler?()
        }
    }
}
