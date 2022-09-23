//
//  ViewController.swift
//  Project10
//
//  Created by Lucas Rocha on 23/09/22.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var people = [Person]()
    var clickedPerson = -1

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Lista de contatos"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
        
        let defaults = UserDefaults.standard
        
        if let savedPeolpe = defaults.object(forKey: "people") as? Data{
            let jsonDecoder = JSONDecoder()
            
            do{
                people = try jsonDecoder.decode([Person].self, from: savedPeolpe)
            }catch{
                print("failed to reload")
            }
        }
    }

    @objc func addNewPerson(){
        let picker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(picker.sourceType) {
            print("entrou: \(UIImagePickerController.isSourceTypeAvailable(picker.sourceType))")
        }
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else{ return }
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentDocumentDirectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8){
            try? jpegData.write(to: imagePath)
        }
        
        let person = Person("Unknown", imageName)
        people.append(person)
        collectionView.reloadData()
        
        dismiss(animated: true)
        clickedPerson = people.count - 1
        renamePerson(UIAlertAction())
    }
    
    func renamePerson(_ action: UIAlertAction){
        let person = people[clickedPerson]
        
        let ac = UIAlertController(title: "Rename person", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submition = UIAlertAction(title: "Ok", style: .default){
            [weak self, weak ac] action in
            guard let userInput = ac?.textFields?[0].text else {return}
            person.name = userInput
            self?.save()
            self?.collectionView.reloadData()
        }
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(submition)
        present(ac,animated: true)
        clickedPerson = -1
    }
    
    func deletePerson(_ action: UIAlertAction){
        let ac = UIAlertController(title: "Are you sure delete this person?", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: confirmDelete))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(ac,animated: true)
    }
    
    func confirmDelete(_ action: UIAlertAction){
        people.remove(at: clickedPerson)
        collectionView.reloadData()
        clickedPerson = -1
        save()
    }
    
    func save(){
        let jsonEncoder = JSONEncoder()
        
        if let savedData = try? jsonEncoder.encode(people){
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "people")
        } else{
            print("failed to save people")
        }
    }
    
    func getDocumentDocumentDirectory() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else{ fatalError("unable to dequeue a personcell") }

        let person = people[indexPath.item]
        
        cell.name.text = person.name

        let path = getDocumentDocumentDirectory().appendingPathComponent(person.image)
        cell.imageView.image = UIImage(contentsOfFile: path.path)
        
        cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        clickedPerson = indexPath.item
        
        let ac = UIAlertController(title: "Choose an option bellow", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Delete", style: .default, handler: deletePerson))
        ac.addAction(UIAlertAction(title: "Rename", style: .default, handler: renamePerson))
        
        present(ac,animated: true)
    }
}

