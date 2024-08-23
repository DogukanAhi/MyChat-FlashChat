import UIKit
import FirebaseAuth
class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    @IBAction func registerPressed(_ sender: UIButton) {
        guard let email = emailTextfield.text, let password = passwordTextfield.text  else { return }
        Auth.auth().createUser(withEmail: email, password: password) { (authresult, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.performSegue(withIdentifier: K.registerSegue, sender: self)
            }
        }
    }
    
}
