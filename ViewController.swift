//
//  ViewController.swift
//  CoreDataExample
//
//  Created by Prapti on 29/03/24.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "collectionCell")
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private var models = [ToDoListItem]()
    var isGridViewVisible = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("hello World")
        title = "ToDo List"
        
        view.addSubview(tableView)
        view.addSubview(collectionView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        collectionView.delegate = self
        collectionView.dataSource = self

        
        getAllItems()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        
        let viewButton = UIBarButtonItem(title: "View", style: .plain, target: self, action: #selector(didTapView))
        navigationItem.leftBarButtonItem = viewButton
        
        // Initially hide the collectionView
        collectionView.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        collectionView.frame = view.bounds
    }
    
    @objc private func didTapAdd() {
        let alert = UIAlertController(title: "New Item", message: "Enter new item", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak self] _ in
            guard let field = alert.textFields?.first, let text = field.text, !text.isEmpty else {
                return
            }
            self?.createItem(name: text)
        }))
        present(alert, animated: true)
    }

    
    @objc private func didTapView() {
        let gridViewController = GridViewController(models: models, context: context)
        navigationController?.pushViewController(gridViewController, animated: true)
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = models[indexPath.row]
        let sheet = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)
        
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        sheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: { [weak self] _ in
            self?.editItem(item: item)
        }))
        
        sheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.deleteItem(item: item)
        }))
        present(sheet, animated: true)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath)
        cell.backgroundColor = models[indexPath.item].completed ? .green : .red // Set background color based on completion
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = models[indexPath.item]
        let alertController = UIAlertController(title: "Task Completed", message: "Have you completed this task?", preferredStyle: .alert)
        
        let markAsCompletedAction = UIAlertAction(title: "Completed", style: .default) { _ in
            // Mark the task as completed
            self.markAsCompleted(item)
            collectionView.reloadData() // Reload collectionView to update cell color
            self.showCompletionMessage()
        }
        
        let notCompletedAction = UIAlertAction(title: "Not Completed", style: .default, handler: nil)
        
        alertController.addAction(markAsCompletedAction)
        alertController.addAction(notCompletedAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    // CORE DATA methods
    
    func getAllItems() {
        do {
            models = try context.fetch(ToDoListItem.fetchRequest())
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.collectionView.reloadData()
            }
        } catch {
            // Handle error
        }
    }
    
    func createItem(name: String) {
        let newItem = ToDoListItem(context: context)
        newItem.name = name
        newItem.createdAt = Date()
        
        do {
            try context.save()
            getAllItems()
        } catch {
            // Handle error
        }
    }
    
    func editItem(item: ToDoListItem) {
        let alert = UIAlertController(title: "Edit Item", message: "Enter new name", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak self] _ in
            guard let field = alert.textFields?.first, let newName = field.text, !newName.isEmpty else {
                return
            }
            item.name = newName
            self?.saveContext()
        }))
        present(alert, animated: true)
    }
    
    func deleteItem(item: ToDoListItem) {
        context.delete(item)
        saveContext()
    }
    
    func saveContext() {
        do {
            try context.save()
            getAllItems()
        } catch {
            // Handle error
        }
    }
    
    func markAsCompleted(_ item: ToDoListItem) {
        // Mark item as completed
        item.completed = true
        saveContext()
    }
    
    func showCompletionMessage() {
        let alertController = UIAlertController(title: "Congratulations!", message: "Task completed successfully.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
