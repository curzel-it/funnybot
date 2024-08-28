//    ____                    __        __ 
//   / __/_ _____  ___  __ __/ /  ___  / /_
//  / _// // / _ \/ _ \/ // / _ \/ _ \/ __/
// /_/  \_,_/_//_/_//_/\_, /_.__/\___/\__/ 
//                    /___/                

import Foundation

struct CodableSize: Codable {
    let width: Float
    let height: Float
    
    init(width: Float, height: Float) {
        self.width = width
        self.height = height
    }
    
    init(from size: CGSize) {
        self.init(width: Float(size.width), height: Float(size.height))
    }
    
    func size() -> CGSize {
        CGSize(width: CGFloat(width), height: CGFloat(height))
    }
}

struct CodableRect: Codable {
    let x: Float
    let y: Float
    let width: Float
    let height: Float
    
    init(x: Float, y: Float, width: Float, height: Float) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
    
    init(from rect: CGRect) {
        self.init(
            x: Float(rect.origin.x),
            y: Float(rect.origin.y),
            width: Float(rect.size.width), 
            height: Float(rect.size.height)
        )
    }
    
    func rect() -> CGRect {
        CGRect(
            x: CGFloat(x),
            y: CGFloat(y),
            width: CGFloat(width),
            height: CGFloat(height)
        )
    }
}

struct CodableEdgeInsets: Codable {
    let top: Float
    let leading: Float
    let bottom: Float
    let trailing: Float
    
    init(top: Float, leading: Float, bottom: Float, trailing: Float) {
        self.top = top
        self.leading = leading
        self.bottom = bottom
        self.trailing = trailing
    }
    
    init(from insets: NSEdgeInsets) {
        self.init(
            top: Float(insets.top),
            leading: Float(insets.left),
            bottom: Float(insets.bottom),
            trailing: Float(insets.right)
        )
    }
    
    func edgeInsets() -> NSEdgeInsets {
        NSEdgeInsets(
            top: CGFloat(top),
            left: CGFloat(leading),
            bottom: CGFloat(bottom),
            right: CGFloat(trailing)
        )
    }
}
