//
//  eisoViewController.m
//  eLBee Isolator
//
//  Created by Jonathon Hibbard on 4/24/14.
//  Copyright (c) 2014 Integrated Events, LLC. All rights reserved.
//

#import "eisoViewController.h"
#import "eLBeeIsolator.h"

@interface eisoViewController()

@property (nonatomic, strong) eLBeeIsolator *isolator;
@property (nonatomic, strong) NSArray *items;

@property (nonatomic, copy) configureCellCompletion configureCellBlock;

@property (nonatomic, weak) IBOutlet UIButton *hideBtn;

@end

@implementation eisoViewController

-(void)viewDidLoad {
    [super viewDidLoad];

    // Just for convenience..
    [self initIsolator];

    // Setup some dummy stuff..
    self.items = @[ @"Item 1", @"Item 2", @"Item 3", @"Item 4" ];
    [self setupCellCompletion];

    // Using a longpress listener - could use anything really ( button click, custom event, etc. )
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(transitionToSnapshotViews:)];
    [self.tableView addGestureRecognizer:longPressRecognizer];
}

#pragma mark -
#pragma mark - eLBeeIsolator
#pragma mark -

-(void)initIsolator {

    // NOTE: below is the manual form of just using:
    // initWithParentView:havingTableView:willAnimateCompletion:didAnimateCompletion:withCompletion

    self.isolator = [[eLBeeIsolator alloc] initWithParentView:self.view
                                              havingTableView:self.tableView];

    __weak typeof(self) weakSelf = self;

    __block CGFloat toAlpha = 0.1;
    self.isolator.willAnimateBlock = ^( BOOL itemIsBeingIsolated ) {

        NSLog( @"will animate isolated view" );

        if( !itemIsBeingIsolated ) {
            toAlpha = 1.0;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{
                weakSelf.tableView.alpha = toAlpha;
            }];
        });

    };

    self.isolator.didAnimateBlock = ^( BOOL itemIsBeingIsolated ) {

        NSLog( @"did animate isolated view" );

        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.hideBtn.hidden = !itemIsBeingIsolated;
        });
    };

    self.isolator.didIsolateBlock = ^(BOOL itemIsBeingIsolated) {
        NSLog( @"View Isolated!" );
    };
}


#pragma mark Isolate View on LongPress

-(void)transitionToSnapshotViews:(UIGestureRecognizer *)gestureRecognizer {
    
    if( gestureRecognizer.state == UIGestureRecognizerStateBegan ) {
        
        CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        [self.isolator isolateCell:cell atIndexPath:indexPath];
    }
}

#pragma mark Deisolate View on Button Tap

-(IBAction)hideBtnTapped:(id)sender {
    if( self.isolator ) {
        [self.isolator deisolateCurrentItem];
    }
}


#pragma mark -
#pragma mark - TableView
#pragma mark -

-(void)setupCellCompletion {
    
    self.configureCellBlock = ^( UITableViewCell *cell, NSIndexPath *indexPath, NSString *item ) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UILabel *label = (UILabel *)[cell viewWithTag:1];
            label.text = item;
            
        });
    };
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.items count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"isolateCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if( self.configureCellBlock != nil ) {
        self.configureCellBlock( cell, indexPath, [self.items objectAtIndex:indexPath.row ] );
    }
    
    return cell;
}


@end
