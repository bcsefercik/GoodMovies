//
//  StorageAdapter.swift
//  GoodMovies
//
//  Created by Bugra Sefercik on 07/09/2016.
//  Copyright © 2016 Bugra Sefercik. All rights reserved.
//

import Foundation
import Firebase

class StorageAdapter{
    let uid = FIRAuth.auth()?.currentUser?.uid
    let base = FIRStorage.storage().reference()
    
    func upload(path: String, fileName: String, data: NSData, completion: ((DBResponse,String) -> Void)?){
        let storageRef = self.base.child(path).child("\(fileName)")
        storageRef.putData(data, metadata: nil, completion: { (metadata, error) in
            
            if error != nil {
                completion?(.fail("storage"),"")
                return
            }
            
            if let dataUrl = metadata?.downloadURL()?.absoluteString {
                completion?(.success,dataUrl)
            }
        })
    }
}