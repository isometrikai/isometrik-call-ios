//
//  ISM+UIView.swift
//  ISMLiveCall
//
//  Created by Rahul Sharma on 23/09/23.
//

import UIKit
import Foundation

extension UIView {
    func showToast(message: String, duration: TimeInterval = 2.0) {
        let toastView = ISMLKCallToastView(message: message)
        toastView.alpha = 0.0
        
        // Add the toast view to the main view
        self.addSubview(toastView)
        toastView.superview?.bringSubviewToFront(toastView)
        toastView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toastView.heightAnchor.constraint(equalToConstant: 50),
            toastView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            toastView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            toastView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: 20)
        ])
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
            toastView.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, delay: duration, options: .curveEaseIn, animations: {
                toastView.alpha = 0.0
            }, completion: { _ in
                toastView.removeFromSuperview()
            })
        })
    }
}

extension UIViewController{
    
    
   public func showISMCallErrorAlerts(title : String? = nil, message : String){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default,handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
          
    }
    
}


extension UIView {
    func endEditing() {
        self.endEditing(true)
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
