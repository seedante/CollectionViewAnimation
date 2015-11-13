//
//  SDEFlowLayout.swift
//  LayoutAnimationSample
//
//  Created by seedante on 15/11/8.
//  Copyright © 2015年 seedante. All rights reserved.
//

import UIKit

class SDEFlowLayoutWithAnimation: UICollectionViewFlowLayout {

    var insertedItemsToAnimate: Set<NSIndexPath> = []
    var deletedItemsToAnimate: Set<NSIndexPath> = []
    //The default move animation is good, simple, refactor animation is not good for move, I recommend you use default move animation.
    var movedItemsToAnimate: Set<UICollectionViewUpdateItem> = []

    override func initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let attr = self.layoutAttributesForItemAtIndexPath(itemIndexPath)
        //If you don't want this move effect, remove the code.
        if movedItemsToAnimate.count > 0 && isInAfterMoveSet(movedItemsToAnimate, withIndexPath: itemIndexPath){
            let oldIndexPath = getOldIndexPathInMoveSet(movedItemsToAnimate, withIndexPath: itemIndexPath)
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
        if deletedItemsToAnimate.count > 0 && haveIdenticalIndexPathInSet(deletedItemsToAnimate, withIndexPath: itemIndexPath){
            attr?.alpha = 0
        }

        //If you don't want this mvoe effect, remove the code.
        if movedItemsToAnimate.count > 0 && isInBeforeMoveSet(movedItemsToAnimate, withIndexPath: itemIndexPath){
            attr?.alpha = 0
        }

        return attr
    }

    func haveIdenticalIndexPathInSet(indexPathSet: Set<NSIndexPath>, withIndexPath indexPath: NSIndexPath) -> Bool{
        let filteredResult = indexPathSet.filter({
            element in

            return element.section == indexPath.section && element.item == indexPath.item
        })

        if filteredResult.count > 0{
            return true
        }else{
            return false
        }
    }

    func isInAfterMoveSet(moveSet: Set<UICollectionViewUpdateItem>, withIndexPath indexPath: NSIndexPath) -> Bool{
        let filteredResult = moveSet.filter({
            element in

            let newIndexPath = element.indexPathAfterUpdate
            return newIndexPath.section == indexPath.section && newIndexPath.item == indexPath.item
        })

        if filteredResult.count > 0{
            return true
        }else{
            return false
        }
    }

    func isInBeforeMoveSet(moveSet: Set<UICollectionViewUpdateItem>, withIndexPath indexPath: NSIndexPath) -> Bool{
        let filteredResult = moveSet.filter({
            element in

            let newIndexPath = element.indexPathBeforeUpdate
            return newIndexPath.section == indexPath.section && newIndexPath.item == indexPath.item
        })

        if filteredResult.count > 0{
            return true
        }else{
            return false
        }
    }

    func getOldIndexPathInMoveSet(moveSet: Set<UICollectionViewUpdateItem>, withIndexPath indexPath: NSIndexPath) -> NSIndexPath{
        let filteredResult = moveSet.filter({
            element in

            let newIndexPath = element.indexPathAfterUpdate
            return newIndexPath.section == indexPath.section && newIndexPath.item == indexPath.item
        })

        return filteredResult.first!.indexPathBeforeUpdate
    }

    override func prepareForCollectionViewUpdates(updateItems: [UICollectionViewUpdateItem]) {
        super.prepareForCollectionViewUpdates(updateItems)
        for updateItem in updateItems{
            switch updateItem.updateAction{
            case .Insert:
                insertedItemsToAnimate.insert(updateItem.indexPathAfterUpdate)
            case .Delete:
                deletedItemsToAnimate.insert(updateItem.indexPathBeforeUpdate)
            case .Move:
                movedItemsToAnimate.insert(updateItem)
            default: break
            }
        }
    }

    override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
        insertedItemsToAnimate.removeAll()
        deletedItemsToAnimate.removeAll()
        movedItemsToAnimate.removeAll()
    }

}
