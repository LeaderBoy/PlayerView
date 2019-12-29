//
//  WaterFallLayout.swift
//  PlayerView
//
//  Created by 杨志远 on 2019/12/29.
//  Copyright © 2019 BaQiWL. All rights reserved.
//

import UIKit


/// https://developer.apple.com/documentation/uikit/uicollectionview/customizing_collection_view_layouts
class WaterFallLayout: UICollectionViewLayout {
    var contentBounds : CGRect = .zero
    var cachedAttributes : [UICollectionViewLayoutAttributes] = []
    
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
        cachedAttributes.removeAll()
        contentBounds = CGRect(origin: .zero, size: collectionView.bounds.size)
        
        let count = collectionView.numberOfItems(inSection: 0)
        let cvWidth = collectionView.bounds.width
        var currentIndex = 0
        var lastFrame = CGRect.zero
        
        let sectionInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        let horInsets = sectionInsets.left + sectionInsets.right
        let verInsets = sectionInsets.top + sectionInsets.bottom
        
        let columns = 2
        let itemSpacing : CGFloat = 2
        let itemWidth = ((cvWidth - itemSpacing - horInsets) / CGFloat(columns))
            // .rounded(.down)
        
        var itemHeights : [CGFloat] = []

        for _ in 0..<count {
            let height = CGFloat(Int.random(in: 300...400))
            itemHeights.append(height)
        }
        
        let itemHeight : CGFloat = 400
        var lastRow = 0
        
        while currentIndex < count {
            let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: currentIndex, section: 0))
//            let itemHeight = itemHeights[currentIndex]
            let column = currentIndex % 2
            let row = currentIndex / 2
            
            var x : CGFloat = 0
            var y : CGFloat = 0
            
            if column == 0 {
                x = 0 + sectionInsets.left
            }else {
                x = itemWidth + itemSpacing + sectionInsets.left
            }
            
            if lastRow == row {
                y = lastFrame.minY
            } else {
                y = lastFrame.maxY + itemSpacing
                lastRow = row
            }
            
            
            let frame = CGRect(x: x, y: y, width: itemWidth, height: itemHeight)
            attributes.frame = frame
            cachedAttributes.append(attributes)
            contentBounds = contentBounds.union(lastFrame)
            
            currentIndex += 1
            lastFrame = frame
        }
        
    }
    
    override var collectionViewContentSize: CGSize {
        return contentBounds.size
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else { return false }
        return !newBounds.size.equalTo(collectionView.bounds.size)
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cachedAttributes[indexPath.item]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributesArray = [UICollectionViewLayoutAttributes]()
        
        // Find any cell that sits within the query rect.
        guard let lastIndex = cachedAttributes.indices.last,
              let firstMatchIndex = binSearch(rect, start: 0, end: lastIndex) else { return attributesArray }
        
        // Starting from the match, loop up and down through the array until all the attributes
        // have been added within the query rect.
        for attributes in cachedAttributes[..<firstMatchIndex].reversed() {
            guard attributes.frame.maxY >= rect.minY else { break }
            attributesArray.append(attributes)
        }
        
        for attributes in cachedAttributes[firstMatchIndex...] {
            guard attributes.frame.minY <= rect.maxY else { break }
            attributesArray.append(attributes)
        }
        
        return attributesArray
    }
    
    // Perform a binary search on the cached attributes array.
    func binSearch(_ rect: CGRect, start: Int, end: Int) -> Int? {
        if end < start { return nil }
        
        let mid = (start + end) / 2
        let attr = cachedAttributes[mid]
        
        if attr.frame.intersects(rect) {
            return mid
        } else {
            if attr.frame.maxY < rect.minY {
                return binSearch(rect, start: (mid + 1), end: end)
            } else {
                return binSearch(rect, start: start, end: (mid - 1))
            }
        }
    }
}
