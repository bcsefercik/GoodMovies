import Foundation

struct User: Equatable {
    
    private let kUsername = "username"
    private let kName = "name"
    private let kPhoto = "url"
    
    var username = ""
    var name: String?
    var id: String?
    var endpoint: String {
        return "users"
    }
    var jsonValue: [String: AnyObject] {
        var json: [String: AnyObject] = [kUsername: username]
        
        if let name = name {
            json.updateValue(name, forKey: kName)
        }
        if let name = name {
            json.updateValue(name, forKey: kName)
        }
        
        
        return json
    }
    
    init?(json: [String: AnyObject], id: String) {
        
        guard let username = json[kUsername] as? String else { return nil }
        
        self.username = username
        self.name = json[kName] as? String
        self.id = id
    }
    
    init(username: String, id: String, name: String? = nil) {
        
        self.username = username
        self.name = name
        self.id = id
    }
}

func ==(lhs: User, rhs: User) -> Bool {
    
    return (lhs.username == rhs.username) && (lhs.id == rhs.id)
}