import UIKit
import Firebase
class ChatViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    let db = Firestore.firestore()
    
    var messages =  [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = K.appName
        
        navigationItem.hidesBackButton = true
        
        tableView.dataSource = self
        tableView.register(UINib(nibName: K.cellNibName, bundle: .main), forCellReuseIdentifier: K.cellIdentifier)
        
        loadMessages()
    }
    
    func loadMessages() {
        db.collection(K.FStore.collectionName)
            .order(by: K.FStore.dateField)
            .addSnapshotListener { (querysnapshot, error) in
                self.messages = []
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    guard  let snapshotDocuments = querysnapshot?.documents else  { return }
                    for snapshot in snapshotDocuments {
                        let data = snapshot.data()
                        guard let sender = data[K.FStore.senderField] as? String, let messageBody = data[K.FStore.bodyField] as? String else { return }
                        let message = Message(sender: sender, body: messageBody)
                        self.messages.append(message)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                        }
                    }
                }
            }
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        if  let messageBody = messageTextfield.text,  let sender = Auth.auth().currentUser?.email {
            db.collection(K.FStore.collectionName).addDocument(data: [K.FStore.senderField:
                                                                        sender,K.FStore.bodyField: messageBody,
                                                                      K.FStore.dateField: Date().timeIntervalSince1970]) { (error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("Successfully saved!")
                    self.messageTextfield.text = ""
                    self.messageTextfield.endEditing(true)
                }
            }
        }
    }
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        
        do {
            try  Auth.auth().signOut()
            navigationController?.popViewController(animated: true)
            
        } catch let sigOuntError as NSError {
            print("Error signing out: %@",sigOuntError)
        }
    }
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath)  as! MessageCell
        cell.label.text = message.body
        
        if message.sender == Auth.auth().currentUser?.email {
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.MessageBubble.backgroundColor = UIColor(named: K.BrandColors.lighBlue)
            cell.label.textColor = UIColor(named: K.BrandColors.purple)
        } else {
            cell.leftImageView.isHidden = false
            cell.rightImageView.isHidden = true
            cell.MessageBubble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
            cell.label.textColor = UIColor(named: K.BrandColors.blue)
        }
        
        
        return cell
    }
}
