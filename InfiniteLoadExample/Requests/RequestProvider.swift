import Foundation
import Moya_ModelMapper
import Moya

private let fixedNumberOfItems = 24

enum WebAPIService {
    case category(identifier: String, page: Int)
}

extension WebAPIService: TargetType {

    var baseURL: URL { return URL(string: "http://demo9276819.mockable.io")! }

    var path: String {
        switch self {
            case .category(_, let page):
            return "/products/\(page)"            
        }
    }

    var method: Moya.Method {
        return .get
    }

    var parameters: [String: Any]? {
        return [:]
    }

    var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }

    var task: Task {
        return .request
    }

    var sampleData: Data {
        return "{\"id\": \(100), \"first_name\": \"Harry\", \"last_name\": \"Potter\"}".utf8Encoded
    }
}
