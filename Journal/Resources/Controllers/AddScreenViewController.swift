//
//  AddScreenViewController.swift
//  Journal
//
//  Created by Cagri Sahan on 4/28/18.
//  Copyright © 2018 Cagri Sahan. All rights reserved.
//

import UIKit
import Foundation
import Photos
import JournalEntry
import CoreLocation


class AddScreenViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var imageCover: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tagsView: UICollectionView!
    @IBOutlet weak var cameraIcon: UIImageView!
    @IBOutlet weak var addTagImage: UIImageView!
    
    // MARK: IBActions
    @IBAction func coverTapped(_ sender: Any) {
        
        if PHPhotoLibrary.authorizationStatus() != .authorized {
            PHPhotoLibrary.requestAuthorization() { [unowned self] status in
                if status == .authorized {
                    self.showImagePicker()
                }
            }
        }
        else { showImagePicker() }
    }
    
    @IBAction func addTagButtonTapped(_ sender: Any) {
        showAddTagDialogue()
    }
    
    
    // MARK: Variables
    var homeScreenVC: HomeViewController?
    var editingEntry: Entry?
    
    var date: Date? {
        didSet {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM d, yyyy"
            dateLabel.text = dateFormatter.string(from: date!)
        }
    }
    
    var entry: Entry? {
        didSet {
            image = entry!.image
            date = entry!.date
            tags = entry!.tags
            textView.text = entry!.text
        }
    }
    
    var image: UIImage = UIImage() {
        didSet {
            imageCover.isHidden = true
            imageCover.isUserInteractionEnabled = false
            imageView.image = image
        }
    }
    
    var tags: [String] = [] {
        didSet {
            DispatchQueue.main.async { [unowned self] in
                self.tagsView.reloadData()
            }
        }
    }
    
    let imagePicker = UIImagePickerController()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up depending on add or edit
        if editingEntry == nil {
            let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveEntry))
            self.navigationItem.rightBarButtonItem  = saveButton
        }
        else {
            self.navigationItem.rightBarButtonItem = editButtonItem
            entry = editingEntry
            textView.isEditable = false
        }
        
        addTagImage.isHidden = true
        
        // Set up image picker
        imagePicker.delegate = self
        
        // Add shadow to camera icon
        cameraIcon.layer.shadowColor = UIColor.black.cgColor
        cameraIcon.layer.shadowOffset = CGSize(width: 0, height: -1)
        cameraIcon.layer.shadowOpacity = 1
        cameraIcon.layer.shadowRadius = 1.0
        cameraIcon.clipsToBounds = false
        
        // Initialize Date label
        date = Date()
        
        // Initialize collection view
        tagsView.register(UINib(nibName: "TagCell", bundle: nil), forCellWithReuseIdentifier: "TagCell")
        tagsView.dataSource = self
        tagsView.delegate = self
        
        textView.delegate = self
        
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        addTagImage.isHidden = !editing
        let indexPaths = tagsView.indexPathsForVisibleItems
        for path in indexPaths {
            let cell = tagsView.cellForItem(at: path) as! TagCell
            cell.isEditing = editing
            textView.isEditable = editing
        }
        
        if !editing {
            saveEntry()
        }
    }
    
    // MARK: Functions
    @objc func saveEntry() {
        if let entry = entry {
            
            entry.text = textView.text
            JournalUtilities.saveToDisk(entry)
            
            if editingEntry != nil {
                CloudUtilities.modifyEntry(entry)
                // Remove the entry being edited
                let newEntries = self.homeScreenVC?.entries.filter {$0.recordName != entry.recordName}
                self.homeScreenVC?.entries = newEntries!
            }
            else {
                CloudUtilities.addEntry(entry)
            }
            self.homeScreenVC?.entries.append(entry)
            self.homeScreenVC?.searchFilter = self.homeScreenVC!.entries
            
            navigationController?.popViewController(animated: true)
        }
    }
    
    func showImagePicker() {
        self.imagePicker.allowsEditing = false
        self.imagePicker.sourceType = .photoLibrary
        imagePicker.modalPresentationStyle = .popover
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    func showAddTagDialogue() {
        let dialogue = AddTagDialogueViewController(nibName: "AddTagDialogueViewController", bundle: nil)
        dialogue.delegate = self
        dialogue.modalPresentationStyle = .popover
        let popoverController = dialogue.popoverPresentationController!
        
        popoverController.sourceView = self.view
        popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        popoverController.permittedArrowDirections = []
        popoverController.delegate = self
        
        self.present(dialogue, animated: true, completion: nil)
    }
}

// MARK: Extensions
extension AddScreenViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let asset = info[UIImagePickerControllerPHAsset] as? PHAsset else { return }
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        guard asset.location != nil else {
            let alert = UIAlertController(title: "Location not found", message: "Please pick an image with location data", preferredStyle: .alert)
            let actionOK = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(actionOK)
            picker.present(alert, animated: true, completion: nil)
            return
        }
        
        self.entry = Entry(fromPHAsset: asset, image: JournalUtilities.adjustOrientation(image), text: textView.text)
        self.image = image
        self.addTagImage.isHidden = false
        
        dismiss(animated: true, completion: nil)
    }
}

extension AddScreenViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath) as! TagCell
        cell.tagText.text = tags[indexPath.row]
        cell.delegate = self
        cell.isEditing = !self.addTagImage.isHidden
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = tags[indexPath.row].size(withAttributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17)])
        size.width += 20
        return size
    }
}

extension AddScreenViewController: TagCellDelegate {
    func deleteCell(_ cell: TagCell) {
        entry!.tags = tags.filter {$0 != cell.tagText.text}
        tags = entry!.tags
        tagsView.reloadData()
    }
}

extension AddScreenViewController: AddTagDialogueDelegate {
    func addTag(_ tag: String) {
        entry!.tags.append(tag)
        tags = entry!.tags
        tagsView.reloadData()
    }
}

extension AddScreenViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}

extension AddScreenViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        moveTextField(textView, moveDistance: -250, up: true)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        moveTextField(textView, moveDistance: -250, up: false)
    }
    
    // Attribution: https://stackoverflow.com/questions/32281651/how-to-dismiss-keyboard-when-touching-anywhere-outside-uitextfield-in-swift
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Move the text field in a pretty animation!
    func moveTextField(_ textField: UITextView, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
}
