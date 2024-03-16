//
//  APIConfiguration.swift
//  TalkShop
//
//  Created by V!jay on 13/03/24.
//

import Foundation

protocol APIConfiguration {
    var method : String { get }
    var path : String { get }
    var parameters: [String: Any]? { get }
}
