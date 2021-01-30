//
//  PhotoManager.swift
//  PhotoKit
//
//  Created by Pedro Contine on 30/01/21.
//

import UIKit

public enum MediaType: String {
    case image = "public.image"
}

extension MediaType {
    var originalName: String {
        self.rawValue
    }
}

public struct MediaSource {
    var type: UIImagePickerController.SourceType
    var title: String
    
    public init(type: UIImagePickerController.SourceType, title: String) {
        self.type = type
        self.title = title
    }
}

public protocol ImagePickerDelegate: class {
    func didSelect(image: UIImage)
}

public class ImagePicker: NSObject, UINavigationControllerDelegate {

    private let pickerController: UIImagePickerController = UIImagePickerController()
    private weak var presentationController: UIViewController?
    
    // Delegate
    public weak var delegate: ImagePickerDelegate?

    // Controls
    private var canEditMedia: Bool
    private var mediaSources: [MediaSource]
    private var cancelButtonTitle: String
    
    public init(mediaSources: [MediaSource],
                mediaTypes: [MediaType],
                canEditMedia: Bool = true,
                cancelButtonTitle: String = "Cancel") {
        
        self.mediaSources = mediaSources
        self.canEditMedia = canEditMedia
        self.cancelButtonTitle = cancelButtonTitle
        
        super.init()

        self.pickerController.delegate = self
        self.pickerController.allowsEditing = canEditMedia
        self.pickerController.mediaTypes = mediaTypes.map({ $0.originalName })
    }

    public func present(in viewController: UIViewController) {
        presentationController = viewController

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        for mediaSource in mediaSources {
            alertController.addActionIfAvailable(createAction(for: mediaSource))
        }

        alertController.addAction(UIAlertAction(title: cancelButtonTitle, style: .cancel, handler: nil))

        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = viewController.view
            alertController.popoverPresentationController?.sourceRect = viewController.view.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }

        presentationController?.present(alertController, animated: true)
    }
    
    private func createAction(for source: MediaSource) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(source.type) else {
            return nil
        }

        return UIAlertAction(title: source.title, style: .default) { [unowned self] _ in
            self.pickerController.sourceType = source.type
            self.presentationController?.present(self.pickerController, animated: true)
        }
    }
}

extension ImagePicker: UIImagePickerControllerDelegate {

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        let mediaInfo: Any? = canEditMedia ? info[.editedImage] : info[.originalImage]
        
        if let image = mediaInfo as? UIImage {
            delegate?.didSelect(image: image)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}

extension UIAlertController {
    func addActionIfAvailable(_ action: UIAlertAction?) {
        if let action = action {
            addAction(action)
        }
    }
}
