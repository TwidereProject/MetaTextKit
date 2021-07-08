//
//  File.swift
//  
//
//  Created by Cirno MainasuK on 2021-6-26.
//

import Foundation
import Meta

extension Meta {

    public static var metaLinkScheme = "meta-link-scheme"

    public init?(url: URL) {
        guard let scheme = url.scheme?.lowercased() else { return nil }
        guard scheme == Meta.metaLinkScheme else {
            self = .url("", trimmed: "", url: url.absoluteString, userInfo: nil)
            return
        }

        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let parameters = components.queryItems else { return nil }
        let userInfo: [AnyHashable: Any] = {
            var dict: [AnyHashable: Any] = [:]
            for queryItem in parameters {
                guard let stringValue = queryItem.value,
                      let value = String(base64Encoded: stringValue) else { continue }
                dict[queryItem.name] = value
            }
            return dict
        }()

        if let hashtag = parameters.first(where: { $0.name == "hashtag" }), let encoded = hashtag.value, let value = String(base64Encoded: encoded) {
            self = .hashtag("#\(value)", hashtag: value, userInfo: userInfo)
            return
        }

        if let mention = parameters.first(where: { $0.name == "mention" }), let encoded = mention.value, let value = String(base64Encoded: encoded) {
            self = .mention("@\(mention)", mention: value, userInfo: userInfo)
            return
        }
        
        return nil
    }

    public var uri: URL? {
        switch self {
        case .url(_, _, let url, _):
            return URL(string: url)
        case .hashtag(_, let hashtag, let userInfo):
            let components = Meta.createURLComponents(key: "hashtag", value: hashtag, userInfo: userInfo)
            return components.url
        case .mention(_, let mention, let userInfo):
            let components = Meta.createURLComponents(key: "mention", value: mention, userInfo: userInfo)
            return components.url
        default:
            return nil
        }
    }

    static func createURLComponents(key: String, value: String, userInfo: [AnyHashable: Any]?) -> URLComponents {
        var components = URLComponents(string: "\(Meta.metaLinkScheme)://meta")!

        var items: [URLQueryItem] = [URLQueryItem(name: key, value: value.base64Encoded)]
        for (key, value) in userInfo ?? [:] {
            guard let stringKey = key as? String,
                  let stringValue = value as? String else { continue }
            let item = URLQueryItem(name: stringKey, value: stringValue.base64Encoded)
            items.append(item)
        }
        components.queryItems = items

        return components
    }

}

extension String {
    fileprivate var base64Encoded: String {
        return Data(self.utf8).base64EncodedString()
    }

    init?(base64Encoded: String) {
        guard let data = Data(base64Encoded: base64Encoded),
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        self = string
    }
}
