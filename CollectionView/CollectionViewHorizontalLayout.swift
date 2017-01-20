//
//  CollectionViewHorizontalLayout.swift
//  Lingo
//
//  Created by Wesley Byrne on 3/1/16.
//  Copyright © 2016 The Noun Project. All rights reserved.
//

import Foundation


@objc public protocol CollectionViewDelegateHorizontalListLayout: CollectionViewDelegate {
    @objc optional func collectionView (_ collectionView: CollectionView,layout collectionViewLayout: CollectionViewLayout,
        widthForItemAtIndexPath indexPath: IndexPath) -> CGFloat
}


open class CollectionViewHorizontalListLayout : CollectionViewLayout {
    
    override open var scrollDirection : CollectionViewScrollDirection {
        return CollectionViewScrollDirection.horizontal
    }
    
    open var delegate: CollectionViewDelegateHorizontalListLayout? {
        return self.collectionView?.delegate as? CollectionViewDelegateHorizontalListLayout
    }
    
    open var sectionInsets = EdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    open var itemWidth: CGFloat = 100
    open var itemSpacing: CGFloat = 8
    
    var cache : [CGRect] = []
    var contentWidth: CGFloat = 0
    
    open override func prepareLayout() {
        super.prepareLayout()
        cache = []
        
        guard let cv = self.collectionView else { return }
        
        let numSections = cv.numberOfSections()
        assert(numSections <= 1, "Horizontal collection view cannot have more than 1 section")
        
        if numSections == 0 { return }
        let numRows = cv.numberOfItems(in: 0)
        if numRows == 0 { return }
        
        var xPos: CGFloat = sectionInsets.left - self.itemSpacing
        
        for row in 0...numRows-1 {
            let ip = IndexPath.for(item: row, section: 0)
            var height = cv.bounds.height 
            height = height - sectionInsets.top - sectionInsets.bottom
            
            let width = self.delegate?.collectionView?(cv, layout: self, widthForItemAtIndexPath: ip) ?? itemWidth
            
            var x = xPos
            x += self.itemSpacing
            
            let frame = CGRect(x: x, y: sectionInsets.top, width: width, height: height)
            
            cache.append(frame)
            xPos = x + width
        }
        
        contentWidth = xPos + sectionInsets.right
    }
    
    var _size = CGSize.zero
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if !newBounds.size.equalTo(_size) {
            self._size = newBounds.size
            return true
        }
        return false
    }
    
    open override var collectionViewContentSize : CGSize {
        let numberOfSections = self.collectionView!.numberOfSections()
        if numberOfSections == 0{
            return CGSize.zero
        }
        var contentSize = self.collectionView!.bounds.size as CGSize
        contentSize.width = contentWidth
        return  contentSize
    }
    
    open override func scrollRectForItem(at indexPath: IndexPath, atPosition: CollectionViewScrollPosition) -> CGRect? {
        return layoutAttributesForItem(at: indexPath)?.frame
    }
    
    
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> CollectionViewLayoutAttributes? {
        let attrs = CollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        attrs.alpha = 1
        attrs.zIndex = 1000
        
        let frame = cache[indexPath._item]
        attrs.frame = frame
        return attrs
    }
}


open class HorizontalCollectionView : CollectionView {
    
    override public init() {
        super.init()
        self.hasVerticalScroller = false
        self.hasHorizontalScroller = false
    }
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.hasVerticalScroller = false
        self.hasHorizontalScroller = false
    }
    
//    override func scrollWheel(theEvent: NSEvent) {
//        super.scrollWheel(theEvent)
//        if (fabs(theEvent.deltaX) > fabs(theEvent.deltaY) || theEvent.deltaY == 0) == false {
//            self.nextResponder?.scrollWheel(theEvent)
//        }
//    }
}