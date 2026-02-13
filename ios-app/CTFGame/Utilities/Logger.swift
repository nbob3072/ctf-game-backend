import Foundation
import os.log

struct Logger {
    private static let subsystem = "com.ctfgame.app"
    
    private static let generalLog = OSLog(subsystem: subsystem, category: "General")
    private static let networkLog = OSLog(subsystem: subsystem, category: "Network")
    private static let locationLog = OSLog(subsystem: subsystem, category: "Location")
    private static let uiLog = OSLog(subsystem: subsystem, category: "UI")
    
    // MARK: - General Logging
    
    static func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        os_log(.debug, log: generalLog, "%{public}@ [%{public}@:%d] %{public}@", fileName, function, line, message)
        #endif
    }
    
    static func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        os_log(.info, log: generalLog, "%{public}@ [%{public}@:%d] %{public}@", fileName, function, line, message)
    }
    
    static func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        os_log(.error, log: generalLog, "%{public}@ [%{public}@:%d] %{public}@", fileName, function, line, message)
    }
    
    static func fault(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        os_log(.fault, log: generalLog, "%{public}@ [%{public}@:%d] %{public}@", fileName, function, line, message)
    }
    
    // MARK: - Category-Specific Logging
    
    static func network(_ message: String) {
        #if DEBUG
        os_log(.debug, log: networkLog, "%{public}@", message)
        #endif
    }
    
    static func location(_ message: String) {
        #if DEBUG
        os_log(.debug, log: locationLog, "%{public}@", message)
        #endif
    }
    
    static func ui(_ message: String) {
        #if DEBUG
        os_log(.debug, log: uiLog, "%{public}@", message)
        #endif
    }
}
