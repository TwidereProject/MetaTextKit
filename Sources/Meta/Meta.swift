//
//  Meta.swift
//  
//
//  Created by MainasuK Cirno on 2021-6-7.
//

import Foundation

public enum Meta {
    case url(_ text: String, trimmed: String, url: String, userInfo: [AnyHashable: Any]? = nil)
    case hashtag(_ text: String, hashtag: String, userInfo: [AnyHashable: Any]? = nil)
    case mention(_ text: String, mention: String, userInfo: [AnyHashable: Any]? = nil)
    case email(_ text: String, userInfo: [AnyHashable: Any]? = nil)
    case emoji(_ text: String, shortcode: String, url: String, userInfo: [AnyHashable: Any]? = nil)
}
