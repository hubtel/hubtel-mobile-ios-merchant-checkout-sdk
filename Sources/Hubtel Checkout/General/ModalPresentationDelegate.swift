//
//  File.swift
//  
//
//  Created by Mark Amoah on 6/22/23.
//

import Foundation
import UIKit


class ModalPresentationDelegate: NSObject{
    
    private override init(){
        
    }
    
    static let shared = ModalPresentationDelegate()
    
}

extension ModalPresentationDelegate: UIAdaptivePresentationControllerDelegate{
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return false
    }
}
