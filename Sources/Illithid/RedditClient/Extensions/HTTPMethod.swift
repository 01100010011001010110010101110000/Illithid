import Foundation
import Alamofire
import OAuthSwift

public extension Alamofire.HTTPMethod {

  var oauth: OAuthSwiftHTTPRequest.Method {
    return OAuthSwiftHTTPRequest.Method(rawValue: self.rawValue)!
  }

}

public extension OAuthSwiftHTTPRequest.Method {

  var alamofire: Alamofire.HTTPMethod {
    return Alamofire.HTTPMethod(rawValue: self.rawValue)!
  }

}
