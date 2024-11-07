//
//  ZLogs.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 06/11/24.
//

import Foundation

/// Log level enumeration to define the type of log messages
enum LogLevel: String {
    case info = "ℹ️ INFO"
    case warning = "⚠️ WARNING"
    case error = "❌ ERROR"
}

/// Logger class to handle logging messages with different log levels
class ZLogs {
    
    /// Shared instance for global access
    static let shared = ZLogs()
    
    /// Private initializer to enforce singleton pattern
    private init() {}
    
    /// Log a message with a specific log level
    ///
    /// - Parameters:
    ///   - level: The level of the log (info, warning, error)
    ///   - message: The message to log
    ///   - file: The file from which the log is being sent (defaulted to the current file)
    ///   - function: The function from which the log is being sent (defaulted to the current function)
    ///   - line: The line number where the log is being sent (defaulted to the current line)
    func log(_ level: LogLevel, message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        print("[\(level.rawValue)] \(fileName):\(line) \(function) -> \(message)")
    }
    
    /// Convenience methods for specific log levels
    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(.info, message: message, file: file, function: function, line: line)
    }
    
    func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(.warning, message: message, file: file, function: function, line: line)
    }
    
    func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(.error, message: message, file: file, function: function, line: line)
    }
}

