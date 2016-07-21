//
//  CollectionViewController.swift
//  LayoutAnimationSample
//
//  Created by seedante on 15/11/10.
//  Copyright © 2015年 seedante. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class CollectionViewController: UICollectionViewController {

    var sectionCount = 3
    var itemCountInSection: [Int] = [8, 8, 8]
    var animationLayout: SDEFlowLayoutWithAnimation?

    override func viewDidLoad() {
        super.viewDidLoad()

        //the temple code will make cell unvisible. You should delete this line code.
        // Register cell classes
        //self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        animationLayout = SDEFlowLayoutWithAnimation()
        animationLayout?.itemSize = CGSize(width: 150, height: 150)
        animationLayout?.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10)
        self.collectionView?.collectionViewLayout = animationLayout!

        // Do any additional setup after loading the view.
        let insertItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(CollectionViewController.insertItem))
        let deleteItem = UIBarButtonItem(barButtonSystemItem: .Trash, target: self, action: #selector(CollectionViewController.deleteItem))
        let moveItem = UIBarButtonItem(title: "Move", style: .Plain, target: self, action: #selector(CollectionViewController.moveItem))
        self.navigationItem.rightBarButtonItems = [moveItem, deleteItem, insertItem]
    }

    func insertItem(){
        let randomSection = Int(arc4random_uniform(UInt32(sectionCount)))
        let previousCount = itemCountInSection[randomSection]
        itemCountInSection[randomSection] = previousCount + 1
        let randomItem = Int(arc4random_uniform(UInt32(previousCount)))
        self.collectionView?.insertItemsAtIndexPaths([NSIndexPath(forItem: randomItem, inSection: randomSection)])
    }

    func deleteItem(){
        let randomSection = Int(arc4random_uniform(UInt32(sectionCount)))
        let previousCount = itemCountInSection[randomSection]
        if previousCount > 0{
            let randomItem = Int(arc4random_uniform(UInt32(previousCount)))
            let deletedIndexPath = NSIndexPath(forItem: randomItem, inSection: randomSection)
            let visibleIndexPaths = self.collectionView?.indexPathsForVisibleItems()
            let filteredIndexPaths = visibleIndexPaths?.filter({$0.isEqualTo(deletedIndexPath)})
            if filteredIndexPaths?.count > 0{
                let deletedCell = self.collectionView?.cellForItemAtIndexPath(deletedIndexPath)
                let animationTime: NSTimeInterval = 0.5
                deletedCell?.destructWithTime(animationTime)
                self.navigationItem.rightBarButtonItems?[1].enabled = false
                self.performSelector(#selector(CollectionViewController.deleteCell(atIndexPath:)), withObject: deletedIndexPath, afterDelay: animationTime)
            }else{
                self.itemCountInSection[randomSection] = previousCount - 1
                self.collectionView?.deleteItemsAtIndexPaths([deletedIndexPath])
            }
        }
    }
    
    func deleteCell(atIndexPath indexPath: NSIndexPath){
        self.itemCountInSection[indexPath.section] -= 1
        self.collectionView?.deleteItemsAtIndexPaths([indexPath])
        self.navigationItem.rightBarButtonItems?[1].enabled = true
    }

    func moveItem(){
        let randomSection = Int(arc4random_uniform(UInt32(sectionCount)))
        let itemCount = itemCountInSection[randomSection]
        if itemCount > 2{
            let fromItem = Int(arc4random_uniform(UInt32(itemCount)))
            var toItem = Int(arc4random_uniform(UInt32(itemCount)))
            while fromItem == toItem{
                toItem = Int(arc4random_uniform(UInt32(itemCount)))
            }

            let fromIndexPath = NSIndexPath(forItem: fromItem, inSection: randomSection)
            let toIndexPath = NSIndexPath(forItem: toItem, inSection: randomSection)

            self.collectionView?.moveItemAtIndexPath(fromIndexPath, toIndexPath: toIndexPath)
        }else{
            print("NO ENOUGHT ITEM. TRY AGAIN.")
        }
    }


    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sectionCount
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return itemCountInSection[section]
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
    
        // Configure the cell
        var backgroundColor: UIColor
        if indexPath.section == 0{
            backgroundColor = UIColor.redColor()
        }else if indexPath.section == 1{
            backgroundColor = UIColor.greenColor()
        }else{
            backgroundColor = UIColor.yellowColor()
        }
        //when you test move animation, this confif is better.
//        let relativeItem = indexPath.item % 8
//        if relativeItem == 0{
//            backgroundColor = UIColor.whiteColor()
//        }else if relativeItem == 1{
//            backgroundColor = UIColor.redColor()
//        }else if relativeItem == 2{
//            backgroundColor = UIColor.greenColor()
//        }else if relativeItem == 3{
//            backgroundColor = UIColor.blueColor()
//        }else if relativeItem == 4{
//            backgroundColor = UIColor.yellowColor()
//        }else if relativeItem == 5{
//            backgroundColor = UIColor.orangeColor()
//        }else if relativeItem == 6{
//            backgroundColor = UIColor.brownColor()
//        }else if relativeItem == 7{
//            backgroundColor = UIColor.magentaColor()
//        }else{
//            backgroundColor = UIColor.purpleColor()
//        }

        cell.backgroundColor = backgroundColor
        return cell
    }

    // MARK: UICollectionViewDelegate
    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {

        if animationLayout != nil{
            let filteredItems = animationLayout!.insertedItemsToAnimate.filter({
                element in
                return element.section == indexPath.section && element.item == indexPath.item
            })
            if filteredItems.count > 0{
                cell.refactor()
            }
        }
    }


}
