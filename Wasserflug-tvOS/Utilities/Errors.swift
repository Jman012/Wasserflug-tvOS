//
//  Errors.swift
//  Wasserflug-tvOS
//
//  Created by James Linnell on 4/1/23.
//

import Foundation

enum WasserflugError: LocalizedError {
	case http429
	case creatorNotFound
	
	public var errorDescription: String? {
		switch self {
		case .http429:
			return "Too many requests were made. Wait a few minutes and try again."
		case .creatorNotFound:
			return "Something went wrong, that creator was not found."
		}
	}
	
	public var failureReason: String? {
		nil
	}

	public var recoverySuggestion: String? {
		nil
	}

	public var helpAnchor: String? {
		nil
	}
}
