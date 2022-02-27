import Foundation

enum ViewModelState<T> {
	case idle
	case loading
	case failed(Error)
	case loaded(T)
	
	var isIdle: Bool {
		switch self {
		case .idle:
			return true
		default:
			return false
		}
	}
	
	var isLoading: Bool {
		switch self {
		case .loading:
			return true
		default:
			return false
		}
	}
}
