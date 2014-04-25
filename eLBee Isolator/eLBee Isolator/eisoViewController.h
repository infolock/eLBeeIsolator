//
//  eisoViewController.h
//  eLBee Isolator
//
//  Created by Jonathon Hibbard on 4/24/14.
//  Copyright (c) 2014 Integrated Events, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^configureCellCompletion)(UITableViewCell *cell, NSIndexPath *indexPath, id item);

@interface eisoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end
