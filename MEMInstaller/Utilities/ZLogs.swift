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
    
    private let logFilePath: URL = {
        var appCacheDirectory = ZFFileManager.shared.getAppCacheDirectory()
        
        if let infoDictionary = Bundle.main.infoDictionary {
            let appName = infoDictionary["CFBundleName"] as! String
            return appCacheDirectory.appending(component: "ZLog_\(appName).txt")
        }
        
        return appCacheDirectory.appending(component: "ZLog_unknown.txt")
    }()
    
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
        let logMessage = ("[\(level.rawValue)] \(fileName):\(line) \(function) -> \(message)")
        
        print(logMessage)
        
        writeToFile(logMessage)
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
    
    private func writeToFile(_ message: String) {
        // Time stamp
        let timeStamp = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .medium)
        let logEntry = "\(timeStamp) -> \(message)\n"
        
        if let data = logEntry.data(using: .utf8) {
            if FileManager.default.fileExists(atPath: logFilePath.path()) {
                // file exist, append to it
                if let fileHandle = try? FileHandle(forWritingTo: logFilePath) {
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(data)
                    fileHandle.closeFile()
                }
            }else {
                // If file doesn't exist, create it with initial log entry
                try? data.write(to: logFilePath)
            }
        }
    }
    
    /// Exports the log file for external usage
    ///
    /// - Returns: The URL of the log file
    func exportLogFile() -> URL {
        return logFilePath
    }
}

