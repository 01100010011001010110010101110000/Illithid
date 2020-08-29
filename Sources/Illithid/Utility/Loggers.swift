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

import Foundation

import Willow

extension Logger {
  public static func debugLogger() -> Logger {
    let consoleWriter = ConsoleWriter(modifiers: [EmojiModifier(), TimestampModifier()])
    return Logger(logLevels: [.all], writers: [consoleWriter],
                  executionMethod: .synchronous(lock: NSRecursiveLock()))
  }

  public static func releaseLogger(subsystem: String, logLevels: LogLevel = .event) -> Logger {
    let writer = OSLogWriter(subsystem: subsystem,
                             category: "release", modifiers: [LevelLabelModifier(), TimestampModifier()])
    return Logger(logLevels: logLevels, writers: [writer],
                  executionMethod: .asynchronous(queue: DispatchQueue(label: "\(subsystem).log", qos: .utility)))
  }
}

public struct EmojiModifier: LogModifier {
  /**
   Prepends the `message` with an emoji depending on `logLevel` at the start of the line.

   - parameter message: The message to log
   - parameter logLevel: The severity of `message`
   - returns: The modified `message`
   */
  public func modifyMessage(_ message: String, with logLevel: LogLevel) -> String {
    switch logLevel {
    case .debug:
      return "🔬🔬🔬 => \(message)"
    case .info:
      return "💡💡💡 => \(message)"
    case .event:
      return "🔵🔵🔵 => \(message)"
    case .warn:
      return "⚠️⚠️⚠️ => \(message)"
    case .error:
      return "🚨💣💥 => \(message)"
    default:
      return " => \(message)"
    }
  }
}

public struct LevelLabelModifier: LogModifier {
  /**
   Prepends `message` with a text label denoting the severity of `logLevel`

   - parameter message: The message to log
   - parameter logLevel: The severity of `message`
   - returns: The modified `message`
   */
  public func modifyMessage(_ message: String, with logLevel: LogLevel) -> String {
    "[\(logLevel.description.uppercased())] => \(message)"
  }
}
