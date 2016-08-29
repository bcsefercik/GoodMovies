import Foundation
import Alamofire

class SearchNetwork: Network{
    var requestMethod: RequestMethod = RequestMethod.GET


    
    func searchWithPage(text: String, page: Int, completion: (NetworkResult, [[String: String]], Int)->Void){
        Alamofire.request(
            .GET,
            "http://www.omdbapi.com/?",
            parameters: ["s": text, "page": "\(page)"]
            )
            .responseJSON { response in
                guard response.result.isSuccess else {
                    completion(NetworkResult.error, [[String:String]](), 0)
                    return
                }
                guard let responseJSON = response.result.value as? [String: AnyObject],
                    responseResult = responseJSON["Response"] as? String,
                    results = responseJSON["Search"] as? [[String: String]],
                    totalResutls = responseJSON["totalResults"] as? String
                    else {
                        completion(NetworkResult.error, [[String:String]](), 0)
                        return
                }
                if(responseResult != "True"){
                    completion(NetworkResult.error, [[String:String]](), 0)
                }
                
                completion(NetworkResult.success, results, Int(totalResutls)!)
                return
        }

    }
}