import Flutter
import UIKit
import Photos

public class ImageGallerySaverPlusPlugin: NSObject, FlutterPlugin {
    let errorMessage = "Failed to save, please check whether the permission is enabled"

    var result: FlutterResult?

    public static func register(with registrar: FlutterPluginRegistrar) {
      let channel = FlutterMethodChannel(name: "image_gallery_saver_plus", binaryMessenger: registrar.messenger())
      let instance = ImageGallerySaverPlusPlugin()
      registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      self.result = result
      if call.method == "saveImageToGallery" {
        let arguments = call.arguments as? [String: Any] ?? [String: Any]()
        guard let imageData = (arguments["imageBytes"] as? FlutterStandardTypedData)?.data,
            let image = UIImage(data: imageData),
            let quality = arguments["quality"] as? Int,
            let _ = arguments["name"],
            let isReturnImagePath = arguments["isReturnImagePathOfIOS"] as? Bool
            else { return }
        let creationDate = parseCreationDate(arguments["creationDate"])
        let newImage = image.jpegData(compressionQuality: CGFloat(quality / 100))!
        saveImage(UIImage(data: newImage) ?? image, isReturnImagePath: isReturnImagePath, creationDate: creationDate)
      } else if (call.method == "saveFileToGallery") {
        guard let arguments = call.arguments as? [String: Any],
              let path = arguments["file"] as? String,
              let _ = arguments["name"],
              let isReturnFilePath = arguments["isReturnPathOfIOS"] as? Bool else { return }
        let creationDate = parseCreationDate(arguments["creationDate"])
        if (isImageFile(filename: path)) {
            saveImageAtFileUrl(path, isReturnImagePath: isReturnFilePath, creationDate: creationDate)
        } else {
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path)) {
                saveVideo(path, isReturnImagePath: isReturnFilePath, creationDate: creationDate)
            } else {
                self.saveResult(isSuccess: false, error: self.errorMessage)
            }
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    /// Convert the incoming milliseconds-since-epoch value (sent from Dart) into a Date.
    func parseCreationDate(_ value: Any?) -> Date? {
        guard let millis = value as? NSNumber else { return nil }
        return Date(timeIntervalSince1970: millis.doubleValue / 1000.0)
    }

    func saveVideo(_ path: String, isReturnImagePath: Bool, creationDate: Date?) {
        // The legacy UISaveVideoAtPathToSavedPhotosAlbum API cannot set a creation
        // date, so fall back to it only when neither a path return nor a custom
        // creation date is requested.
        if !isReturnImagePath && creationDate == nil {
            UISaveVideoAtPathToSavedPhotosAlbum(path, self, #selector(didFinishSavingVideo(videoPath:error:contextInfo:)), nil)
            return
        }
        var videoIds: [String] = []

        PHPhotoLibrary.shared().performChanges( {
            let req = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: path))
            if let creationDate = creationDate {
                req?.creationDate = creationDate
            }
            if let videoId = req?.placeholderForCreatedAsset?.localIdentifier {
                videoIds.append(videoId)
            }
        }, completionHandler: { [unowned self] (success, error) in
            DispatchQueue.main.async {
                guard success && videoIds.count > 0 else {
                    self.saveResult(isSuccess: false, error: error?.localizedDescription ?? self.errorMessage)
                    return
                }
                if !isReturnImagePath {
                    self.saveResult(isSuccess: true)
                    return
                }
                let assetResult = PHAsset.fetchAssets(withLocalIdentifiers: videoIds, options: nil)
                if (assetResult.count > 0) {
                    let videoAsset = assetResult[0]
                    PHImageManager().requestAVAsset(forVideo: videoAsset, options: nil) { (avurlAsset, audioMix, info) in
                        if let urlStr = (avurlAsset as? AVURLAsset)?.url.absoluteString {
                            self.saveResult(isSuccess: true, filePath: urlStr)
                        }
                    }
                }
            }
        })
    }

    func saveImage(_ image: UIImage, isReturnImagePath: Bool, creationDate: Date?) {
        if !isReturnImagePath && creationDate == nil {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(didFinishSavingImage(image:error:contextInfo:)), nil)
            return
        }

        var imageIds: [String] = []

        PHPhotoLibrary.shared().performChanges( {
            let req = PHAssetChangeRequest.creationRequestForAsset(from: image)
            if let creationDate = creationDate {
                req.creationDate = creationDate
            }
            if let imageId = req.placeholderForCreatedAsset?.localIdentifier {
                imageIds.append(imageId)
            }
        }, completionHandler: { [unowned self] (success, error) in
            DispatchQueue.main.async {
                guard success && imageIds.count > 0 else {
                    self.saveResult(isSuccess: false, error: error?.localizedDescription ?? self.errorMessage)
                    return
                }
                if !isReturnImagePath {
                    self.saveResult(isSuccess: true)
                    return
                }
                let assetResult = PHAsset.fetchAssets(withLocalIdentifiers: imageIds, options: nil)
                if (assetResult.count > 0) {
                    let imageAsset = assetResult[0]
                    let options = PHContentEditingInputRequestOptions()
                    options.canHandleAdjustmentData = { (adjustmeta)
                        -> Bool in true }
                    imageAsset.requestContentEditingInput(with: options) { [unowned self] (contentEditingInput, info) in
                        if let urlStr = contentEditingInput?.fullSizeImageURL?.absoluteString {
                            self.saveResult(isSuccess: true, filePath: urlStr)
                        }
                    }
                }
            }
        })
    }

    func saveImageAtFileUrl(_ url: String, isReturnImagePath: Bool, creationDate: Date?) {
        if !isReturnImagePath && creationDate == nil {
            if let image = UIImage(contentsOfFile: url) {
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(didFinishSavingImage(image:error:contextInfo:)), nil)
            }
            return
        }

        var imageIds: [String] = []

        PHPhotoLibrary.shared().performChanges( {
            let req = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: URL(fileURLWithPath: url))
            if let creationDate = creationDate {
                req?.creationDate = creationDate
            }
            if let imageId = req?.placeholderForCreatedAsset?.localIdentifier {
                imageIds.append(imageId)
            }
        }, completionHandler: { [unowned self] (success, error) in
            DispatchQueue.main.async {
                guard success && imageIds.count > 0 else {
                    self.saveResult(isSuccess: false, error: error?.localizedDescription ?? self.errorMessage)
                    return
                }
                if !isReturnImagePath {
                    self.saveResult(isSuccess: true)
                    return
                }
                let assetResult = PHAsset.fetchAssets(withLocalIdentifiers: imageIds, options: nil)
                if (assetResult.count > 0) {
                    let imageAsset = assetResult[0]
                    let options = PHContentEditingInputRequestOptions()
                    options.canHandleAdjustmentData = { (adjustmeta)
                        -> Bool in true }
                    imageAsset.requestContentEditingInput(with: options) { [unowned self] (contentEditingInput, info) in
                        if let urlStr = contentEditingInput?.fullSizeImageURL?.absoluteString {
                            self.saveResult(isSuccess: true, filePath: urlStr)
                        }
                    }
                }
            }
        })
    }

    /// finish saving，if has error, parameters error will not be nil
    @objc func didFinishSavingImage(image: UIImage, error: NSError?, contextInfo: UnsafeMutableRawPointer?) {
        saveResult(isSuccess: error == nil, error: error?.description)
    }

    @objc func didFinishSavingVideo(videoPath: String, error: NSError?, contextInfo: UnsafeMutableRawPointer?) {
        saveResult(isSuccess: error == nil, error: error?.description)
    }

    func saveResult(isSuccess: Bool, error: String? = nil, filePath: String? = nil) {
        var saveResult = SaveResultModel()
        saveResult.isSuccess = error == nil
        saveResult.errorMessage = error?.description
        saveResult.filePath = filePath
        result?(saveResult.toDic())
    }

    func isImageFile(filename: String) -> Bool {
        return filename.hasSuffix(".jpg")
            || filename.hasSuffix(".png")
            || filename.hasSuffix(".jpeg")
            || filename.hasSuffix(".JPEG")
            || filename.hasSuffix(".JPG")
            || filename.hasSuffix(".PNG")
            || filename.hasSuffix(".gif")
            || filename.hasSuffix(".GIF")
            || filename.hasSuffix(".heic")
            || filename.hasSuffix(".HEIC")
    }
}

public struct SaveResultModel: Encodable {
    var isSuccess: Bool!
    var filePath: String?
    var errorMessage: String?

    func toDic() -> [String:Any]? {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(self) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
    }
}
