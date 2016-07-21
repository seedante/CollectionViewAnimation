//
//  SDEFlowLayout.swift
//  LayoutAnimationSample
//
//  Created by seedante on 15/11/8.
//  Copyright © 2015年 seedante. All rights reserved.
//

import UIKit

extension NSIndexPath{
    func isEqualTo(indexPath: NSIndexPath) -> Bool{
        return self.section == indexPath.section && self.item == indexPath.item
    }
}

class SDEFlowLayoutWithAnimation: UICollectionViewFlowLayout {

    var insertedItemsToAnimate: Set<NSIndexPath> = []
    var deletedItemsToAnimate: Set<NSIndexPath> = []
    //The default move animation is good, simple, refactor animation is not good for move, I recommend you use default move animation.
    var movedItemsToAnimate: Set<UICollectionViewUpdateItem> = []
    
    override func prepareForCollectionViewUpdates(updateItems: [UICollectionViewUpdateItem]) {
        super.prepareForCollectionViewUpdates(updateItems)
        for updateItem in updateItems{
            switch updateItem.updateAction{
            case .Insert:
                insertedItemsToAnimate.insert(updateItem.indexPathAfterUpdate!)
            case .Delete:
                deletedItemsToAnimate.insert(updateItem.indexPathBeforeUpdate!)
            case .Move:
                movedItemsToAnimate.insert(updateItem)
            default: break
            }
        }
    }

    override func initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let attr = self.layoutAttributesForItemAtIndexPath(itemIndexPath)
        //If you don't want this move effect, remove the code.
        if movedItemsToAnimate.count > 0 && indexPathsAfterUpdate(inMoveItemsSet: movedItemsToAnimate, containIndexPath: itemIndexPath){
            let oldIndexPath = oldIndexPathOf(itemIndexPath, inMoveItemSet: movedItemsToAnimate)
            let cell = collectionView?.cellForItemAtIndexPath(oldIndexPath)
            let assemebleRect = attr?.frame
            let oldAttr = self.layoutAttributesForItemAtIndexPath(oldIndexPath)
            cell?.refactorWithPiecesRegion(oldAttr?.frame, assembleRect: assemebleRect, shiningColor: nil, cellAction: .Move)
        }
        return attr
    }

    override func finalLayoutAttributesForDisappearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let attr = self.layoutAttributesForItemAtIndexPath(itemIndexPath)
        //the follow code to reslove ths issue of delete the last cell in the section.
        if deletedItemsToAnimate.contains(itemIndexPath){
            attr?.alpha = 0
        }

        //If you don't want this mvoe effect, remove the code.
        if movedItemsToAnimate.count > 0 && indexPathsBeforeUpdate(inMoveItemsSet: movedItemsToAnimate, containIndexPath: itemIndexPath){
            attr?.alpha = 0
        }

        return attr
    }

    func indexPathsBeforeUpdate(inMoveItemsSet moveSet: Set<UICollectionViewUpdateItem>, containIndexPath indexPath: NSIndexPath) -> Bool{
        let filteredResult = moveSet.filter({updateItem in
            let newIndexPath = updateItem.indexPathBeforeUpdate
            return (newIndexPath != nil) ? newIndexPath!.isEqualTo(indexPath) : false
        })
        
        return filteredResult.count > 0 ? true : false
    }
    
    func indexPathsAfterUpdate(inMoveItemsSet moveSet: Set<UICollectionViewUpdateItem>, containIndexPath indexPath: NSIndexPath) -> Bool{
        let filteredResult = moveSet.filter({updateItem in
            let newIndexPath = updateItem.indexPathAfterUpdate
            return (newIndexPath != nil) ? newIndexPath!.isEqualTo(indexPath) : false
        })
        
        return filteredResult.count > 0 ? true : false
    }
    
    
    func oldIndexPathOf(indexPath: NSIndexPath, inMoveItemSet moveSet: Set<UICollectionViewUpdateItem>) -> NSIndexPath{
        let filteredResult = moveSet.filter({updateItem in
            let newIndexPath = updateItem.indexPathAfterUpdate
            return (newIndexPath != nil) ? newIndexPath!.isEqualTo(indexPath) : false
        })
        
        return filteredResult[0].indexPathBeforeUpdate!

    }

    override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
        insertedItemsToAnimate.removeAll()
        deletedItemsToAnimate.removeAll()
        movedItemsToAnimate.removeAll()
    }
}
