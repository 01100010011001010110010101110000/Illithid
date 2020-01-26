//
// Loggers.swift
// Copyright (c) 2020 Flayware
// Created by Tyler Gregory (@01100010011001010110010101110000) on 12/24/19
//

import Foundation

import Willow

extension Logger {
  public static func debugLogger() -> Logger {
    let consoleWriter = ConsoleWriter(modifiers: [EmojiModifier(), TimestampModifier()])
    return Logger(logLevels: [.all], writers: [consoleWriter],
                  executionMethod: .synchronous(lock: NSRecursiveLock()))
  }
}

extension Logger {
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
