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

    init?(url: URL) {
        guard let scheme = url.scheme?.lowercased() else { return nil }
        guard scheme == Meta.metaLinkScheme else {
            self = .url("", trimmed: "", url: url.absoluteString, userInfo: nil)
            return
        }

        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let parameters = components.queryItems else { return nil }

        if let hashtag = parameters.first(where: { $0.name == "hashtag" }), let encoded = hashtag.value, let value = String(base64Encoded: encoded) {
            self = .hashtag("#\(value)", hashtag: value, userInfo: nil)
            return
        }

        if let mention = parameters.first(where: { $0.name == "mention" }), let encoded = mention.value, let value = String(base64Encoded: encoded) {
            self = .mention("@\(mention)", mention: value, userInfo: nil)
            return
        }
        
        return nil
    }

    var uri: URL? {
        switch self {
        case .url(_, _, let url, _):
            return URL(string: url)
        case .hashtag(_, let hashtag, _):
            return URL(string: "\(Meta.metaLinkScheme)://meta?hashtag=\(hashtag.base64Encoded)")
        case .mention(_, let mention, _):
            return URL(string: "\(Meta.metaLinkScheme)://meta?mention=\(mention.base64Encoded)")
        default:
            return nil
        }
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
