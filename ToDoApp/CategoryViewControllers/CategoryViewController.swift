//
//  CategoryViewController.swift
//  ToDoApp
//
//  Created by Vakhtang on 30.04.2023.
//

import UIKit
import CoreData

class CategoryViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var categoryArray = [Category]()
    
    var indexPathforhendler: IndexPath?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(CategoryCollectionViewCell.nib(), forCellWithReuseIdentifier: CategoryCollectionViewCell.indetifier)
        collectionView.dataSource = self
        loadCategories()
        setupGestureLongRecognizer()
        setupTapsGesture()
    }
    //MARK: - Data Manipulation Methods
    
    func saveCategories() {
        
        do {
            try context.save()
        } catch {
            print("Error saving category \(error)")
        }
       
        collectionView.reloadData()
    }
    
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        do {
            categoryArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context category \(error)")
        }
        collectionView.reloadData()
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add category", style: .default) { (action) in
            
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            newCategory.isSelected = false
            self.categoryArray.append(newCategory)
            
            self.saveCategories()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in}
        
        alert.addTextField{ (alertTextfield) in
            alertTextfield.placeholder = "Create a new category"
            textField = alertTextfield
        }
        alert.addAction(cancel)
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
//    // MARK: - Setup LongPress Gestur recognizer
    private func setupGestureLongRecognizer() {
        let gesturLongPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        gesturLongPress.minimumPressDuration = 0.5
        gesturLongPress.delaysTouchesBegan = true
        gesturLongPress.delegate = self

        self.collectionView.addGestureRecognizer(gesturLongPress)
    }

    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {

        guard gestureRecognizer.state != .began else { return }
        let point = gestureRecognizer.location(in: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: point)
        if indexPath != nil {
            
            let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
            let delete = UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
//                self.gesture.deleteItems(at: indexPath!.row)
            })
            alert.addAction(delete)
            present(alert, animated: true, completion: nil)
            print("long press")
        } else {
            print("Could not work long press")
        }
    }

    // MARK: - Setup Tap and Double Gesture
    func setupTapsGesture() {

        // Single Tap
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleOneTap))
        singleTap.numberOfTapsRequired = 1
        collectionView.addGestureRecognizer(singleTap)

        // Double Tap
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        collectionView.addGestureRecognizer(doubleTap)

        singleTap.require(toFail: doubleTap)
        singleTap.delaysTouchesBegan = true
        doubleTap.delaysTouchesBegan = true

    }

    @objc func handleOneTap(gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer.state != .began else { return }
        let point = gestureRecognizer.location(in: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: point)
        if indexPath != nil {
            print("one tap")
            let vc = storyboard?.instantiateViewController(withIdentifier: "ItemVC") as! ItemTableViewController
            self.navigationController?.pushViewController(vc, animated: true)
            vc.selectedCategory = categoryArray[indexPath!.row]
            
            collectionView.reloadData()
        } else {
            print("Could not work one tap")
        }
    }

    @objc func handleDoubleTap(gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer.state != .began else { return }
        let point = gestureRecognizer.location(in: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: point)
        if indexPath != nil {
            categoryArray[indexPath!.row].isSelected.toggle()
            collectionView.reloadData()
            print("double tap")
  
        } else {
            print("Could not work double tap")
        }
    }
}

// MARK: - TableView DataSource Methods

extension CategoryViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.indetifier, for: indexPath) as! CategoryCollectionViewCell
        
        cell.category = categoryArray[indexPath.row]
        cell.congigure()
        
        
        return cell
    }
    
    
}



