import Alamofire
import Foundation
import OAuthSwift

public extension Alamofire.HTTPMethod {
  var oauth: OAuthSwiftHTTPRequest.Method {
    OAuthSwiftHTTPRequest.Method(rawValue: rawValue)!
  }
}

public extension OAuthSwiftHTTPRequest.Method {
  var alamofire: Alamofire.HTTPMethod {
    Alamofire.HTTPMethod(rawValue: rawValue)!
  }
}
