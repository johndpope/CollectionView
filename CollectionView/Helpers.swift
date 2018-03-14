//
//  CollectionViewConstants.swift
//  Lingo
//
//  Created by Wesley Byrne on 1/27/16.
//  Copyright © 2016 The Noun Project. All rights reserved.
//

import Foundation



func delay(_ delay: TimeInterval, block: @escaping (()->Void)) {
    let mDelay = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: mDelay, execute: {
        block()
    })
}

struct Logger {

    static let logFiles = Set<String>([
//        "CollectionView",
//        "CollectionViewDocumentView",
//        "CollectionReusableView"
        ])
    
    static func verbose(_ message: Any, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, type: "Verbose", file: file, funtion: function, line: line)
    }
    static func debug(_ message: Any, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, type: "Debug", file: file, funtion: function, line: line)
    }
    static func error(_ message: Any, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, type: "Error", file: file, funtion: function, line: line)
    }
    
    private static func log(_ message: Any, type: String, file: String, funtion: String, line: Int) {
        let fileName = file.components(separatedBy: "/").last!.components(separatedBy: ".").first!
        guard logFiles.count == 0 || logFiles.contains(fileName) else {
            return;
        }
        print("\(fileName) @ \(line) \(type): \(message)")
    }
}

typealias log = Logger


/**
 Provides support for OSX < 10.11 and provides some helpful additions
*/
public extension IndexPath {

    /**
     Create an index path with a given item and section
     
     - Parameter item: An item
     - Parameter section: A section

     - Returns: An initialized index path with the item and section
     
     - Note: item and section must be >= 0

    */
    public static func `for`(item: Int = 0, section: Int) -> IndexPath {
        precondition(item >= 0, "Attempt to create an indexPath with negative item")
        precondition(section >= 0, "Attempt to create an indexPath with negative section")
        return IndexPath(indexes: [section, item])
    }

    
    public static var zero : IndexPath { return IndexPath.for(item: 0, section: 0) }
    
    
    /**
     Returns the item of the index path
    */
    public var _item: Int { return self[1] }
    
    /**
     Returns the section of the index path
     */
    public var _section: Int { return self[0] }
    public static func inRange(_ range: CountableRange<Int>, section: Int) -> [IndexPath] {
        var ips = [IndexPath]()
        for idx in range {
            ips.append(IndexPath.for(item: idx, section: section))
        }
        return ips
    }
    
    public var previous : IndexPath? {
        guard self._item >= 1 else { return nil }
        return IndexPath.for(item: self._item - 1, section: self._section)
    }
    public var next : IndexPath {
        return IndexPath.for(item: self._item + 1, section: self._section)
    }
    public var nextSection : IndexPath {
        return IndexPath.for(item: 0, section: self._section + 1)
    }
    
    var sectionCopy : IndexPath {
        return IndexPath.for(item: 0, section: self._section)
    }
    
    func with(item: Int) -> IndexPath {
        return IndexPath.for(item: item, section: self._section)
    }
    func with(section: Int) -> IndexPath {
        return IndexPath.for(item: self._item, section: section)
    }
    
    func adjustingItem(by: Int) -> IndexPath {
        return IndexPath.for(item: self._item + by, section: section)
    }
    func adjustingSection(by: Int) -> IndexPath {
        return IndexPath.for(item: self._item, section: section + by)
    }
    
    func isBetween(_ start: IndexPath, end:IndexPath) -> Bool {
        if self == start { return true }
        if self == end { return true }
        let _start = Swift.min(start, end)
        let _end = Swift.max(start, end)
        return (_start..<_end).contains(self)
    }
}



/// :nodoc:
extension Comparable {
    func compare(_ other: Self) -> ComparisonResult {
        if self == other { return .orderedSame }
        if self < other { return .orderedAscending }
        return .orderedDescending
    }
}



extension Dictionary {
    func union(_ other: Dictionary<Key, Value>, overwrite: Bool = true) -> Dictionary<Key, Value> {
        var new = self
        for element in other {
            if overwrite || new[element.key] == nil {
                new[element.key] = element.value
            }
        }
        return new
    }
}


extension Set {
    
    mutating func removeOne() -> Element? {
        guard self.count > 0 else { return nil }
        return self.removeFirst()
    }
    
    /**
     Remove elements shared by both sets, returning the removed items
     
     - parameter set: The set of elements to remove from the receiver
     - returns: A new set of removed elements
     */
     @discardableResult mutating func remove<C : Collection>(_ set: C) -> Set<Element> where C.Iterator.Element == Element {
        var removed = Set(minimumCapacity: self.count)
        for item in set {
            if let r = self.remove(item) {
                removed.insert(r)
            }
        }
        return removed
    }
    
    /**
     Create a new set by removing the elements shared by both sets
     
     - parameter set: The set of elements to remove from the receiver
     - returns: A new set with the shared elements removed
     */
    func removing<C : Collection>(_ set: C) -> Set<Element> where C.Iterator.Element == Element {
        var copy = self
        for item in set {
            copy.remove(item)
        }
        return copy
    }
}

extension CGPoint {
    
    var integral : CGPoint {
        return CGPoint(x: round(self.x), y: round(self.y))
    }
    
    public var maxAbsVelocity : CGFloat {
        return max(abs(self.x), abs(self.y))
    }
    
    func maxVelocity(_ other: CGPoint) -> CGPoint {
        let _x = abs(self.x) > abs(other.x) ? self.x : other.x
        let _y = abs(self.y) > abs(other.y) ? self.y : other.y
        return CGPoint(x: _x, y: _y)
    }
    
    func unionMax(_ other: CGPoint) -> CGPoint {
        return CGPoint(x: max(self.x, other.x), y: max(self.y, other.y))
    }
    func maxX(_ other: CGPoint) -> CGPoint {
        return CGPoint(x: max(self.x, other.x), y: self.y)
    }
    func maxY(_ other: CGPoint) -> CGPoint {
        return CGPoint(x: self.x, y: max(self.y, other.y))
    }
    
    func distance(to other: CGPoint) -> CGFloat {
        let xDist = self.x - other.x
        let yDist = self.y - other.y
        return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
    }
}

extension CGRect {
    var center : CGPoint {
        get { return CGPoint(x: self.midX, y: self.midY) }
        set {
            self.origin.x = newValue.x - (self.size.width/2)
            self.origin.y = newValue.y - (self.size.height/2)
        }
    }
    
    func sharedArea(with other: CGRect) -> CGFloat {
        let intersect = self.intersection(other)
        if intersect.isEmpty { return 0 }
        return intersect.height * intersect.width
    }
    
    func scaled(by scale: CGFloat) -> CGRect {
        var rect = CGRect()
        rect.origin.x = self.origin.x * scale
        rect.origin.y = self.origin.y * scale
        rect.size.width = self.size.width * scale
        rect.size.height = self.size.height * scale
        return rect
    }
    
    /**
     Subtract r2 from r1 along
     
     ## Discussion:
     
     ```
     |-------------|
     |---- r1 -----|
     |-------------|
     |             |
     |   overlap   |
     |_____________| v MaxYEdge
     |*************|
     |**** r2 *****|
     |*************|
     ```
     
     - Parameters:
        - other: The rect to subtract from the target
        - edge: The edge to subtract along
      - Returns: The rect remaining from the target after subtracting the given rect
     */
    
    func subtracting(_ other: CGRect, edge: CGRectEdge) -> CGRect {
        if other.contains(self) { return CGRect.zero }
        if other.isEmpty { return self }
        if !self.intersects(other) { return self }
        
        switch edge {
        case .minXEdge:
            let origin = CGPoint(x: other.maxX, y: self.origin.y)
            let size = CGSize(width: self.maxX - origin.x , height: self.size.height)
            return CGRect(origin: origin, size: size)
            
        case .maxXEdge:
            return CGRect(origin: self.origin, size: CGSize(width: other.origin.x - self.origin.x, height: self.size.height))
            
        case .minYEdge:
            let origin = CGPoint(x: self.origin.x, y: other.maxY)
            let size = CGSize(width: self.size.width, height: self.maxY - origin.y)
            return CGRect(origin: origin, size: size)
            
        case .maxYEdge:
            return CGRect(origin: self.origin, size: CGSize(width: self.size.width, height: other.origin.y - self.origin.y))
        }
    }
}



extension NSEdgeInsets {
    static var zero : NSEdgeInsets { return NSEdgeInsetsZero }
    init(_ all: CGFloat) {
        self.init(top: all, left: all, bottom: all, right: all)
    }
    var height: CGFloat {
        return self.top + self.bottom
    }
    var width: CGFloat {
        return self.left + self.right
    }
}


public extension NSView {
    @discardableResult func addConstraintsToMatchParent(_ insets: NSEdgeInsets? = nil) -> (top: NSLayoutConstraint, right: NSLayoutConstraint, bottom: NSLayoutConstraint, left: NSLayoutConstraint)? {
        if let sv = self.superview {
            let top = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: sv, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: insets == nil ? 0 : insets!.top)
            let right = NSLayoutConstraint(item: sv, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1, constant: insets?.right ?? 0)
            let bottom = NSLayoutConstraint(item: sv, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: insets?.bottom ?? 0)
            let left = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: sv, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1, constant: insets == nil ? 0 : insets!.left)
            sv.addConstraints([top, bottom, right, left])
            self.translatesAutoresizingMaskIntoConstraints = false
            return (top, right, bottom, left)
        }
        else {
            debugPrint("Toolkit Warning: Attempt to add contraints to match parent but the view had not superview.")
        }
        return nil
    }
}



