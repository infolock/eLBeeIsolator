//
//  eisoViewController.m
//  eLBee Isolator
//
//  Created by Jonathon Hibbard on 4/24/14.
//  Copyright (c) 2014 Integrated Events, LLC. All rights reserved.
//

#import "eisoViewController.h"
#import "eLBeeIsolator.h"

static NSString * const OVERLAY_VIEW_NAMETAG = @"isolatorOverlay";

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

    self.isolator = [[eLBeeIsolator alloc] initWithParentView:self.view];

    __weak typeof(self) weakSelf = self;

    self.isolator.willStartBlock = ^( BOOL itemIsBeingIsolated ) {
        NSLog( @"will animate isolated view" );

        dispatch_async(dispatch_get_main_queue(), ^{

            CGFloat toAlpha = 0.1f;

            if( itemIsBeingIsolated ) {

                [weakSelf addOverlay];

            } else {
                [weakSelf.view bringSubviewToFront:weakSelf.tableView];

                toAlpha = 1.0f;
                [weakSelf removeOverlay];
            }

            [UIView animateWithDuration:0.3 animations:^{
                weakSelf.tableView.alpha = toAlpha;
            }];
        });
    };

    self.isolator.didAnimateBlock = ^( BOOL itemIsBeingIsolated ) {
        NSLog( @"did animate isolated view" );

        dispatch_async(dispatch_get_main_queue(), ^{
            if( !itemIsBeingIsolated ) {
                [weakSelf removeOverlay];
            }
        });

    };

    self.isolator.completionBlock = ^(BOOL itemIsBeingIsolated) {
        NSLog( @"View Isolated!" );

        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.hideBtn.hidden = !itemIsBeingIsolated;
            
            if( itemIsBeingIsolated ) {
                [weakSelf.view bringSubviewToFront:weakSelf.hideBtn];
            } else {
                [weakSelf.view sendSubviewToBack:weakSelf.hideBtn];
            }
        });
    };
}


#pragma mark Isolate View on LongPress

-(void)transitionToSnapshotViews:(UIGestureRecognizer *)gestureRecognizer {

    if( gestureRecognizer.state == UIGestureRecognizerStateBegan ) {

        CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];

        // NOTE: We specify tableView here because we have not yet set it (above)...
        [self.isolator isolateCell:cell atIndexPath:indexPath inTableView:self.tableView];
    }
}

#pragma mark Deisolate View on Button Tap

-(IBAction)hideBtnTapped:(id)sender {

    NSLog( @"Hide Button Tapped.  Deisolating current Item.." );

    if( self.isolator ) {
        [self.isolator deisolateCurrentViewAnimated:NO];
    }
}


#pragma mark -
#pragma mark Overlay View
#pragma mark -

-(void)addOverlay {

    UIView *overlayView = [UIView overlayViewWithFrame:self.view.bounds withName:OVERLAY_VIEW_NAMETAG];
    overlayView.alpha = 0.8;

    [self.view addSubview:overlayView];
}

-(void)removeOverlay {

    UIView *overlayView = [self.view viewNamed:OVERLAY_VIEW_NAMETAG];
    if( overlayView ) {
        [overlayView removeFromSuperview];
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
