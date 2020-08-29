// Copyright (C) 2020 Tyler Gregory (@01100010011001010110010101110000)
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of  MERCHANTABILITY or FITNESS FOR
// A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <http://www.gnu.org/licenses/>.

protocol MirrorableEnum {}

extension MirrorableEnum {
  var mirror: (route: String, parameters: [String: Any]) {
    let reflection = Mirror(reflecting: self)
    guard reflection.displayStyle == .enum, let associated = reflection.children.first else {
      return ("\(self)", [:])
    }
    let values = Mirror(reflecting: associated.value).children
    var params: [String: Any] = [:]
    for case let param in values {
      guard let label = param.label else { continue }
      params[label] = param.value
    }
    return ("\(self)", params)
  }
}
