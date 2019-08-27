//
//  File.swift
//
//
//  Created by Tyler Gregory on 8/27/19.
//

import Foundation

import Willow

extension Logger {
  public static let debugLogger: Logger = {
    let consoleWriter = ConsoleWriter(modifiers: [EmojiModifier(), TimestampModifier()])
    return Logger(logLevels: [.all], writers: [consoleWriter],
                  executionMethod: .synchronous(lock: NSRecursiveLock()))
  }()
}

extension Logger {
  public static let releaseLogger: Logger = {
    let writer = OSLogWriter(subsystem: "com.illithid.illithid",
                             category: "release", modifiers: [LevelLabelModifier(), TimestampModifier()])
    return Logger(logLevels: [.event], writers: [writer],
                  executionMethod: .asynchronous(queue: DispatchQueue(label: "com.illithis.illithid.log", qos: .utility)))
  }()
}

struct EmojiModifier: LogModifier {
  /**
   Prepends the `message` with an emoji depending on `logLevel` at the start of the line.

   - parameter message: The message to log
   - parameter logLevel: The severity of `message`
   - returns: The modified `message`
   */
  func modifyMessage(_ message: String, with logLevel: LogLevel) -> String {
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

struct LevelLabelModifier: LogModifier {
  /**
   Prepends `message` with a text label denoting the severity of `logLevel`

   - parameter message: The message to log
   - parameter logLevel: The severity of `message`
   - returns: The modified `message`
   */
  func modifyMessage(_ message: String, with logLevel: LogLevel) -> String {
    return "[\(logLevel.description.uppercased())] => \(message)"
  }
}
