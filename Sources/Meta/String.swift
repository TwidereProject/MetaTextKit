//
//  String.swift
//  
//
//  Created by MainasuK on 2023-07-26.
//

import Foundation

extension String {
    public var rawRepresent: String {
        self.unicodeScalars.map { $0.escaped(asASCII: true) }.joined()
    }
}

extension Substring {
    public var rawRepresent: String {
        String(self).rawRepresent
    }
}
