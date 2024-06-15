

import UIKit
import CoreData

class GridViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private let collectionView: UICollectionView
    private let context: NSManagedObjectContext
    private var models: [ToDoListItem]

    init(models: [ToDoListItem], context: NSManagedObjectContext) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.models = models
        self.context = context
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Grid View"
        view.addSubview(collectionView)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "gridCell")
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self

        // Add long press gesture recognizer
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        collectionView.addGestureRecognizer(longPressGesture)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gridCell", for: indexPath)
            let item = models[indexPath.item]
            cell.backgroundColor = .white
            // Clear previous subviews
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }
            // Add task name label
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: cell.contentView.bounds.width, height: cell.contentView.bounds.height))
            label.text = item.name
            label.textAlignment = .center
            label.numberOfLines = 0
            cell.contentView.addSubview(label)

            return cell
    }



    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }

        let point = gesture.location(in: collectionView)
        if let indexPath = collectionView.indexPathForItem(at: point) {
            let selectedItem = models[indexPath.item]
            promptCompletion(selectedItem)
        }
    }

    func promptCompletion(_ task: ToDoListItem) {
        let alertController = UIAlertController(title: "Task Completion", message: "Have you completed this task?", preferredStyle: .alert)
        
        let markAsCompletedAction = UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
            self?.completeTask(task)
        }
        
        let notCompletedAction = UIAlertAction(title: "No", style: .default) { [weak self] _ in
            self?.markAsNotCompleted(task)
        }
        
        alertController.addAction(markAsCompletedAction)
        alertController.addAction(notCompletedAction)
        
        present(alertController, animated: true, completion: nil)
    }

    
    func markAsNotCompleted(_ task: ToDoListItem) {
        task.completed = false
        saveContext()
        
        if let index = models.firstIndex(where: { $0 == task }) {
            if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) {
                cell.backgroundColor = .red
            }
        }
        
        let alertController = UIAlertController(title: "Pending Task", message: "This task is still pending.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }



    func completeTask(_ task: ToDoListItem) {
        task.completed = true
        saveContext()
        
        if let index = models.firstIndex(where: { $0 == task }) {
            if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) {
                cell.backgroundColor = .green
            }
        }
        
        showCompletionMessage()
    }


    func showCompletionMessage() {
        let alertController = UIAlertController(title: "Congratulations!", message: "Task completed successfully.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    func saveContext() {
        do {
            try context.save()
        } catch {
            // Handle error
        }
    }
}
