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
@property (nonatomic, weak) IBOutlet UISwitch *showOverlaySwitch;

@end

@implementation eisoViewController

-(void)viewDidLoad {
    [super viewDidLoad];

    // Just for convenience..
    [self initIsolator];

    // Setup some dummy stuff..
    self.items = @[ @"Item 1", @"Item 2", @"Item 3", @"Item 4", @"Item 5", @"Item 6", @"Item 7", @"Item 8", @"Item 9", @"Item 10", @"Item 11", @"Item 12", @"Item 13", @"Item 14", @"Item 15", @"Item 16", @"Item 17", @"Item 18", @"Item 19", @"Item 20", ];

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

            if( !itemIsBeingIsolated ) {
                [weakSelf.view bringSubviewToFront:weakSelf.tableView];
                toAlpha = 1.0f;
            }

            [UIView animateWithDuration:0.3 animations:^{
                weakSelf.tableView.alpha = toAlpha;
            }];
        });
    };

    self.isolator.didAnimateBlock = ^( BOOL itemIsBeingIsolated ) {
        NSLog( @"did animate isolated view" );
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

        [self addOverlay];

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
        [self removeOverlay];

        [self.isolator deisolateCurrentViewAnimated:NO];
    }
}


#pragma mark -
#pragma mark Overlay
#pragma mark -

-(void)addOverlay {

    [self.navigationController setNavigationBarHidden:YES animated:YES];

    if( [self.showOverlaySwitch isOn] ) {

        UIView *overlayView = [UIView overlayViewWithFrame:self.view.bounds withName:OVERLAY_VIEW_NAMETAG];
        [self.view addSubview:overlayView];
        [self.view bringSubviewToFront:overlayView];
    }
}

-(void)removeOverlay {

    [self.navigationController setNavigationBarHidden:NO animated:YES];

    if( [self.showOverlaySwitch isOn] ) {

        UIView *overlayView = [self.view viewNamed:OVERLAY_VIEW_NAMETAG];
        if( overlayView ) {
            [overlayView removeFromSuperview];
        }
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
