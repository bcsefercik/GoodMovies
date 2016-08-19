import Foundation
import Alamofire


enum RequestMethod{
    case GET
    case POST
}
enum NetworkResult{
    case success
    case error
    case empty
}
protocol Network{
    var requestMethod: RequestMethod { get }
}