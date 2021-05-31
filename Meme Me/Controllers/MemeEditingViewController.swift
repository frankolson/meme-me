//
//  ViewController.swift
//  Image Picker
//
//  Created by Will Olson on 4/30/21.
//

import UIKit

// MARK: - MemeEditingViewController

class MemeEditingViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    // MARK: Properties
    
    var activeTextField: UITextField?
    
    // MARK: Outlets

    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var mainToolbar: UIToolbar!
    @IBOutlet weak var pickerToolbar: UIToolbar!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTextFieldAttributes(topTextField, startText: "TOP")
        setTextFieldAttributes(bottomTextField, startText: "BOTTOM")
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: Actions
    
    @IBAction func share(_ sender: Any) {
        let meme = generateAndSaveMeme()
        let controller = UIActivityViewController(activityItems: [meme.memeImage], applicationActivities: nil)
        
        // picked up the following from this site:
        // https://www.swiftdevcenter.com/uiactivityviewcontroller-tutorial-by-example/
        controller.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed: Bool, items: [Any]?, error: Error?) in
            if completed {
                // picked up the following from this site:
                // https://www.hackingwithswift.com/example-code/media/uiimagewritetosavedphotosalbum-how-to-write-to-the-ios-photo-album
                UIImageWriteToSavedPhotosAlbum(meme.memeImage, self, #selector(self.saveResults(_:didFinishSavingWithError:contextInfo:)), nil)
                self.endEditing()
            }
            
            if let error = error {
                print("There was an error: \(error.localizedDescription)")
            }
        }
        present(controller, animated: true, completion: nil)
    }

    @IBAction func cancel(_ sender: Any) {
        self.imagePickerView.image = nil
        self.topTextField.text = "TOP"
        self.bottomTextField.text = "BOTTOM"
        self.activeTextField = nil
        
        self.endEditing()
    }

    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        presentViewController(source: .photoLibrary)
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        presentViewController(source: .camera)
    }
    
    // MARK: Impage Picker Implementation
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePickerView.image = image
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Text Field Implementation
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
        self.activeTextField?.text = ""
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeTextField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func setTextFieldAttributes(_ textField: UITextField, startText: String) {
        let memeTextAttributes: [NSAttributedString.Key: Any] = [
            .strokeColor: UIColor.black,
            .foregroundColor: UIColor.white,
            .font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            .strokeWidth:  -5.0
        ]
        
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.text = startText
        textField.textAlignment = .center
        textField.backgroundColor = UIColor.clear
        textField.borderStyle = .none
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        // got the idea to check for an active field from this post:
        // https://stackoverflow.com/questions/28813339/move-a-view-up-only-when-the-keyboard-covers-an-input-field
        if (view.frame.origin.y == 0) && (self.activeTextField == self.bottomTextField) {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if (view.frame.origin.y != 0) {
            view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
            
        return keyboardSize.cgRectValue.height
    }
    
    func presentViewController(source: UIImagePickerController.SourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = source
        present(pickerController, animated: true, completion: nil)
    }
    
    // MARK: Meme Generation
    
    func generateMemedImage() -> UIImage {
        // Hide toolbar and navbar
        self.mainToolbar.isHidden = true
        self.pickerToolbar.isHidden = true

        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Show toolbar and navbar
        self.mainToolbar.isHidden = false
        self.pickerToolbar.isHidden = false

        return memedImage
    }
    
    // MARK: Saving
    
    func generateAndSaveMeme() -> Meme {
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memeImage: generateMemedImage())
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.memes.append(meme)
        
        return meme
    }
    
    @objc func saveResults(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error != nil {
            print("There was an error when saving the image")
        } else {
            print("Saved successfully")
        }
    }
    
    // MARK: Canceling
    
    func endEditing() {
        self.dismiss(animated: true, completion: nil)
    }
}

