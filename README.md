## Animating insert/delete/move item in UICollectionView

After I create UIView refactor/destruct extension, I think here is a good scene. Thanks for [Animating Collection Views](https://www.objc.io/issues/12-animations/collectionview-animations/), I get a lot of help from this article.

### Installation and Usage
Drag **SDEFlowLayoutWithAnimation.swift** and **UIViewRefactorAndDestructExtension.swift** into your project.

Set UICollectionView's collectionViewLayout to `SDEFlowLayoutWithAnimation` in your storyboard or in your code.

**Insert Animation:**

In CollectionView's delegate, override the follow method, assume that `animationLayout` is collectionView's layout.

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
**Delete Animation:**
	
	......//update the data source.
	let deletedIndexPath = ...
    let deletedCell = self.collectionView?.cellForItemAtIndexPath(deletedIndexPath)
    let animationTime: NSTimeInterval = 0.5
    deletedCell?.destructWithTime(animationTime)
    self.collectionView?.performSelector("deleteItemsAtIndexPaths:", withObject: [deletedIndexPath], afterDelay: animationTime)

**Move Animation:**

Just move, the rest work is done automatically. If you don't like this animation, I like default animation actually, go to **SDEFlowLayoutWithAnimation.swift** and delete the relative code, there are comments to tell you how do it.

### Issue:

Insert animation is interrupted always. It should be like this:


Move animation have the same problem. I don't known why. I guess because of layout animation behind it. I try to use Core Animation instead of UIView block animation. It works. But when you insert several cells, it's also interrupted, at last, animation is totally removed. I try to put refactor method in main queue, it works fine also. But it bring a little trouble: before refactor animation, cells behind it shake, I don't want this. There is no prefect way for now. If you find the way, please pull a request or email me, seedante@gmail.com.

### Multiple Cells Action

In the sample, I just test for single cell action, test for multiple cells action is not completed. There may be something wrong for multiple cells action.

## UICollectionView 插入/删除/移动项目动画
在 UIView refacot/destruct 动画扩展完成之后，我想这个场景是比较合适的。感谢 [Collection View 动画](http://objccn.io/issue-12-5/)，我最初的想法是从这篇文章得到的，虽然我这里的手法其实和文章里的不同，但帮助我解决了一半问题。

### 安装和使用
把 **SDEFlowLayoutWithAnimation.swift** 和 **UIViewRefactorAndDestructExtension.swift** 这两个文件拖进你的项目里就好了。

设置`collectionViewLayout`: 在你的 storyboard 里或代码里设置都行。不会的话，示例工程里是通过代码设置的，还不会不要问我，先去学习吧。

**Insert Animaton:**

在 CollectionView 的代理里，重写下面的方法，假设`animationLayout`是这个 CollectionView 的 layout:

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

**Delete Animation:**

当 cell 不在屏幕上的时候就没必要执行删除动画了，示例里是这么写的。

	......//记得先更新数据源
	let deletedIndexPath = ...
    let deletedCell = self.collectionView?.cellForItemAtIndexPath(deletedIndexPath)
    let animationTime: NSTimeInterval = 0.5
    deletedCell?.destructWithTime(animationTime)
    self.collectionView?.performSelector("deleteItemsAtIndexPaths:", withObject: [deletedIndexPath], afterDelay: animationTime)

**Move Animation:**

移动就好了，剩下的事情会自动完成。如果你不喜欢这个效果，实际上我更喜欢默认的效果，你可以去 **SDEFlowLayoutWithAnimation.swift** 里删除相关代码，我写了注释告诉你删除哪些代码。

### 缺陷：

目前的插入动画有点问题：



这个动画总是被打断，没有按照预期的方式完成。移动动画也有相同的问题，我不知道为什么，猜测是由于后续的布局动画造成的。本来是用 UIView block animation 实现的，我尝试用 Core Animation 来实现，不会被打断，但是在添加几个  cell 后发现，动画也开始被打断，到最后动画根本就不会出现。我后来意识到是不是没有放在主线程里，尝试后发现再也不会被打断了，但是也带来一点点副作用，在重组动画开始前，后面位置的 cells 会晃动，我不是我想要的，当然主要是因为晃动的样子像卡壳了，目前没找到完美的解决办法。如果你找到了方法，麻烦提个请求，或者来介绍这个动画的博客下留言。

### 多 cell 操作

示例里我只针对单个 cell 进行了测试，多个 cells 的操作的测试并不完整，只稍微测试了删除多个 cell，目前工作正常。还有涉及 section 操作时没有测试。如果有这方面的需求，自己尝试下吧。

