import Foundation
import Logging
import struct Logging.Logger
import os

public struct OSLoggingLogger: LogHandler {
	public var logLevel: Logger.Level = .trace
	public let label: String
	private let osLogger: os.Logger
	
	public init(label: String, category: String) {
		self.label = label
		self.osLogger = os.Logger(subsystem: label, category: category)
	}
	
	public func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, source: String, file: String, function: String, line: UInt) {
		let prettyMetadata = metadata?.isEmpty ?? true
			? self.prettyMetadata
			: self.prettify(self.metadata.merging(metadata!, uniquingKeysWith: { _, new in new }))
		
		var formedMessage = "[\(level.rawValue)] [\(source)] \(message.description)"
		if let prettyMetadata = prettyMetadata {
			formedMessage += " -- " + prettyMetadata
		}
		self.osLogger.log(level: OSLogType.from(loggerLevel: level), "\(formedMessage)")
	}
	
	private var prettyMetadata: String?
	public var metadata = Logger.Metadata() {
		didSet {
			self.prettyMetadata = self.prettify(self.metadata)
		}
	}
	
	/// Add, remove, or change the logging metadata.
	/// - parameters:
	///    - metadataKey: the key for the metadata item.
	public subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
		get {
			return self.metadata[metadataKey]
		}
		set {
			self.metadata[metadataKey] = newValue
		}
	}
	
	private func prettify(_ metadata: Logger.Metadata) -> String? {
		return !metadata.isEmpty
			? metadata.lazy.sorted(by: { $0.key < $1.key }).map { "\($0)=\($1)" }.joined(separator: " ")
			: nil
	}
}

extension OSLogType {
	static func from(loggerLevel: Logger.Level) -> Self {
		switch loggerLevel {
		case .trace:
			/// `OSLog` doesn't have `trace`, so use `debug`
			return .debug
		case .debug:
			return .debug
		case .info:
			return .info
		case .notice:
			/// `OSLog` doesn't have `notice`, so use `info`
			return .info
		case .warning:
			/// `OSLog` doesn't have `warning`, so use `info`
			return .info
		case .error:
			return .error
		case .critical:
			return .fault
		}
	}
}
