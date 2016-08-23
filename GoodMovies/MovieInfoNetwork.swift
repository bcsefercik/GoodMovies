import Foundation
import Firebase
import Alamofire

class MovieInfoNetwork: Network{
    var requestMethod: RequestMethod = RequestMethod.GET
    
    func fetchMovie(imdbID: String, completion: (NetworkResult, [String: String])->Void){
        Alamofire.request(
            .GET,
            "http://www.omdbapi.com/?",
            parameters: ["i": imdbID, "plot": "long", "r": "json"]
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    completion(NetworkResult.error, [String:String]())
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: String] else {
                        completion(NetworkResult.error, [String:String]())
                        return
                }
                let responseResult = responseJSON["Response"]
                if(responseResult != "True"){
                    completion(NetworkResult.error, [String:String]())
                }
                
                completion(NetworkResult.success, responseJSON)
                return
        }
        
    }

}