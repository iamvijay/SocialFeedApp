//
//  Extensions.swift
//  TalkShop
//
//  Created by V!jay on 16/03/24.
//

import Foundation
import UIKit

extension UIApplication {
    var currentWindow : UIWindow? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return nil
        }
        
        guard let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return nil
        }
        return window
    }
}

extension UIViewController {
    class func initNib(setStyle: Bool = true, presentationStyle: UIModalPresentationStyle? = nil) -> Self {
        let controller = Self.init(nibName: Self.className, bundle: Bundle(for: Self.self))
        if setStyle {
            controller.hidesBottomBarWhenPushed = true
            controller.modalPresentationStyle = .fullScreen
        }
        if let presentationStyle = presentationStyle {
            controller.modalPresentationStyle = presentationStyle
        }
        return controller // Add this line
    }
    
    class func initStoryboard(_ storyboard: String, setStyle: Bool = true) -> Self {
        guard let controller = UIStoryboard(name: storyboard, bundle: Bundle(for: Self.self)).instantiateViewController(withIdentifier: className) as? Self else {
            fatalError("Could not find `\(className)` in \(storyboard).storyboard")
        }
        if setStyle {
            controller.hidesBottomBarWhenPushed = true
            controller.modalPresentationStyle = .fullScreen
        }
        return controller
    }
}

public protocol ClassNameProtocol {
    static var className: String { get }
    var className: String { get }
}

public extension ClassNameProtocol {
    static var className: String {
        return String(describing: self)
    }

    var className: String {
        return type(of: self).className
    }
}

extension NSObject: ClassNameProtocol {
    func logInit() {
        print(String(describing: type(of: self)), "Initialized")
    }
    
    func logDeinit(_ message: String = "") {
        print("deinit".uppercased(), String(describing: type(of: self)), message)
    }
}
