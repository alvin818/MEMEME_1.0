//
//  ViewController.swift
//  MemeMe_1.0
//
//  Created by Alvin Vanegas on 1/20/20.
//  Copyright © 2020 Alvin Vanegas. All rights reserved.
//
import UIKit

class ViewController: UIViewController,UIImagePickerControllerDelegate ,UINavigationControllerDelegate,UITextFieldDelegate{

    struct Meme {
        var topText: String
        var bottomText: String
        var originalImage: UIImage
        var memedImage: UIImage
    }
    
    
    let INIT_TOP_TEXT = "TOP"
    let INIT_BOTTOM_TEXT = "BOTTOM"
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth: -3.0,
    ]
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var navigatonBar: UINavigationBar!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    override func viewWillAppear(_ animated: Bool) {
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
      }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Set default values for launch of home page
        topTextField.text = INIT_TOP_TEXT
        bottomTextField.text = INIT_BOTTOM_TEXT
        topTextField.isEnabled = false
        bottomTextField.isEnabled = false
        setDefaultView(topTextField)
        setDefaultView(bottomTextField)
        shareButton.isEnabled = false
    }
    
    func setDefaultView(_ textField: UITextField) -> Void {
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        textField.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillHide(_:)) , name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self,name: UIResponder.keyboardWillHideNotification,object: nil)
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func save() {
        // Create the meme
        _ = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: generateMemedImage())
    }
    
    func generateMemedImage() -> UIImage {
        
        // Hide top and bottom bars
        navigatonBar.isHidden=true
        toolbar.isHidden=true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Show top and bottom bars
        navigatonBar.isHidden=false
        toolbar.isHidden=false
        return memedImage
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePickerView.image = image
            shareButton.isEnabled = true
            topTextField.isEnabled = true
            bottomTextField.isEnabled = true
        }
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) { // clear the default text
        if (topTextField == textField && topTextField.text == INIT_TOP_TEXT) {
            topTextField.text = ""
        }
        if (bottomTextField == textField && bottomTextField.text == INIT_BOTTOM_TEXT) {
            bottomTextField.text = ""
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
          if (topTextField.text != INIT_TOP_TEXT) && (bottomTextField.text != INIT_BOTTOM_TEXT ) {
              topTextField.isEnabled = true
              bottomTextField.isEnabled = true
          }
      }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { // Hide the keybord when RETURN is pressed
        textField.resignFirstResponder()
    }
    
    // function resets values to default
    func reset(){
        topTextField.text=INIT_TOP_TEXT
        bottomTextField.text=INIT_BOTTOM_TEXT
        imagePickerView!.image=nil
        shareButton.isEnabled=false
        topTextField.isEnabled = false
        bottomTextField.isEnabled = false
        topTextField.alpha = 0.5
        bottomTextField.alpha = 0.5
    }
    
    @IBAction func shareMeme(_ sender: Any) {
        if let  _ = imagePickerView.image{
            let vc = UIActivityViewController(activityItems: [generateMemedImage()], applicationActivities: nil)
            vc.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
                if !completed{
                    return
                }
                self.save()
                self.reset()
            }
            present(vc, animated: true)
        }
    }
    
    @IBAction func cancelChanges(_ sender: Any) {
        reset()
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        imagePicker.sourceType =  .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickImageFromAlbum(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        imagePicker.sourceType =  .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomTextField.isEditing{  // move the view up only when the user edits the bottom text field. If we move up while editing the top field, it will not be vissible.
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        
        view.frame.origin.y = 0
    }
}

