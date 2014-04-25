eLBeeIsolator
=============

Isolate a view by animation


## Overview

##### initWithParentView:havingTableView:willAnimateCompletion:didAnimateCompletion:withCompletion:

Initializes an allocated **eLBeeIsolator** object using a *Parent View* (**required**), a *Table View* that resides in the *Parent View*, alng with the 3 available completion blocks: *willAnimateBlock*, *didAnimateBlock*, *didIsolateBlock*

**Parameters**
*parentView*
> The *UIView* that should be considered the primary parent of the view you want to isolate.  Typeically this is just self.view

*tableView*
> A *UITableView* should be supplied if the view to be isolated is a *UITableViewCell*.  If it is a cell, then this parameter is **required**.  Otherwise, it is optional and be set to *nil*.

*willAnimateBlock*
> A completion block to be called just before the animation of the isolated view begins.  Useufl for when you'd like to prepare other views (animate the navigation hidden for instance) before hand.

*didAnimateBlock*
> A completion block called *after* animating the isolated view.

*didIsolateBlock*
> A completion block to be called once isolation of the view is complete.


*Alternatives of the above*
```objc
-(instancetype)initWithParentView:havingTableView:didAnimateCompletion:withCompletion:
```

```objc
-(instancetype)initWithParentView:havingTableView:withCompletion:
```

```objc
-(instancetype)initWithParentView:havingTableView
```

```objc
-(instancetype)initWithParentView
```
