import Foundation
import Alamofire

class MovieSearchNetwork: Network{
    var requestMethod: RequestMethod = RequestMethod.GET


    
    func searchWithPage(text: String, page: Int, completion: (NetworkResult, [[String: String]])->Void){
        Alamofire.request(
            .GET,
            "http://www.omdbapi.com/?",
            parameters: ["s": text, "page": "\(page)"]
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    completion(NetworkResult.error, [[String:String]]())
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: AnyObject],
                    responseResult = responseJSON["Response"] as? String,
                    results = responseJSON["Search"] as? [[String: String]]
                    else {
                        completion(NetworkResult.error, [[String:String]]())
                        return
                }
                
                if(responseResult != "True"){
                    completion(NetworkResult.error, [[String:String]]())
                }
                
                completion(NetworkResult.success, results)
                return
        }

    }
}