//
//  eLBeeIsolator.m
//  eLBee
//
//  Created by Jonathon Hibbard on 4/17/14.
//  Copyright (c) 2014 Integrated Events. All rights reserved.
//

#import "eLBeeIsolator.h"
#import "NSObject+Nametag.h"

static NSString * const ISOLATED_VIEW_NAMETAG = @"_eLBeeIsolatedViewSnapshot";
static NSString * const ISOLATED_CELL_NAMETAG = @"_eLBeeIsolatedCellSnapshot";

// @see [eLBeeIsolator isolateItem:] for usage of the below constants
static CGFloat const DEISOLATION_SCALE = 1.0;
static CGFloat const   ISOLATION_SCALE = 1.05;
static CGFloat const ISOLATOR_ANIMATION_DURATION = 0.1;
static CGFloat const ISOLATOR_ANIMATION_DELAY = 0;

@implementation UIView (Nametags)

-(NSArray *)nametags {
    
    NSMutableArray *array = [NSMutableArray array];
    for(NSLayoutConstraint *constraint in self.constraints) {
        if(constraint.nametag && ![array containsObject:constraint.nametag]) {
            [array addObject:constraint.nametag];
        }
    }
    
    return array;
}

// First matching view
-(UIView *)viewWithNametag: (NSString *)aName {
    if(!aName)return nil;
    
    // Is this the right view?
    if([self.nametag isEqualToString:aName]) {
        return self;
    }
    
    // Recurse depth first on subviews
    for(UIView *subview in self.subviews) {
        UIView *resultView = [subview viewNamed:aName];
        if(resultView)return resultView;
    }
    
    // Not found
    return nil;
}

// All matching views
-(NSArray *)viewsWithNametag: (NSString *)aName {
    if(!aName)return nil;
    
    NSMutableArray *array = [NSMutableArray array];
    if([self.nametag isEqualToString:aName]) {
        [array addObject:self];
    }
    
    // Recurse depth first on subviews
    for(UIView *subview in self.subviews) {
        NSArray *results = [subview viewsNamed:aName];
        if(results && results.count) {
            [array addObjectsFromArray:results];
        }
    }
    
    return array;
}

// First matching view
-(UIView *)viewNamed: (NSString *)aName {
    if(!aName) {
        return nil;
    }
    
    return [self viewWithNametag:aName];
}

// All matching views
-(NSArray *)viewsNamed: (NSString *)aName {
    if(!aName) {
        return nil;
    }
    
    return [self viewsWithNametag:aName];
}
@end


@implementation UIView (OverlayView)

+(UIView *)overlayViewWithFrame:(CGRect)overlayFrame {
    UIView *overlayView;
    return overlayView;
}

+(UIView *)overlayViewWithFrame:(CGRect)overlayFrame withName:(NSString *)viewName {
    UIView *overlayView;
    return overlayView;
}


@end

@implementation UIView (SnapshotView)

#pragma mark -
#pragma mark Category Method(s)
#pragma mark -

+(CGRect)rectForSnapshotView:(UIView *)snapshotView inTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath usingCoordsFromView:(UIView *)parentView {

    CGRect tableViewRect = tableView.bounds;
    CGRect cellRect = [tableView rectForRowAtIndexPath:indexPath];
    CGRect snapshotRect = [tableView convertRect:cellRect toView:parentView];
    CGFloat maxYPos = tableViewRect.size.height - snapshotRect.size.height;
    
    snapshotRect.origin.y = snapshotRect.origin.y > maxYPos ? maxYPos : 0;
    
    return snapshotRect;
}

+(UIView *)snapshotViewFromView:(UIView *)view withName:(NSString *)viewName withAlpha:(CGFloat)alpha {
    UIView *overlayView;
    return overlayView;
}

+(UIView *)snapshotViewFromView:(UIView *)view withName:(NSString *)viewName withAlpha:(CGFloat)alpha havingFrameForView:(UIView *)toView {
    UIView *overlayView;
    return overlayView;
}

+(UIView *)snapshotForRowAtIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView usingCoordsFromView:(UIView *)parentView {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    return [[self class] snapshotForCell:cell atIndexPath:indexPath inTableView:tableView usingCoordsFromView:parentView];
}

+(UIView *)snapshotForCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView usingCoordsFromView:(UIView *)parentView {
    UIView *snapshotView = [[self class] snapshotView:cell withName:ISOLATED_CELL_NAMETAG withAlpha:1.0];
    
    CGRect tableViewCellRect = [tableView rectForRowAtIndexPath:indexPath];
    CGRect snapshotViewRect = [tableView convertRect:tableViewCellRect toView:parentView];

    NSLog( @"Snapshot Rect = x: %f, y: %f, w: %f, h: %f", snapshotView.frame.origin.x, snapshotView.frame.origin.y, snapshotView.frame.size.width, snapshotView.frame.size.height );
    snapshotView.frame = snapshotViewRect;

    return snapshotView;
}

+(UIView *)snapshotView:(UIView *)view withName:(NSString *)viewName withAlpha:(CGFloat)alpha {
    UIView *snapshotView = [view snapshotViewAfterScreenUpdates:NO];
    snapshotView.frame = view.bounds;
    snapshotView.nametag = viewName;
    snapshotView.alpha = alpha;
    
    return snapshotView;
}


#pragma mark -
#pragma mark Instance Method(s)
#pragma mark -

-(CGRect)rectForSnapshotView:(UIView *)snapshotView inTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    CGRect tableViewRect = tableView.bounds;
    CGRect cellRect = [tableView rectForRowAtIndexPath:indexPath];
    CGRect snapshotRect = [tableView convertRect:cellRect toView:self];
    CGFloat maxYPos = tableViewRect.size.height - snapshotRect.size.height;
    
    snapshotRect.origin.y = snapshotRect.origin.y > maxYPos ? maxYPos : 0;
    
    return snapshotRect;
}

-(UIView *)snapshotForCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {

    UIView *snapshotView = [UIView snapshotView:cell withName:ISOLATED_CELL_NAMETAG withAlpha:1.0];
    snapshotView.frame = [UIView rectForSnapshotView:snapshotView inTableView:tableView atIndexPath:indexPath usingCoordsFromView:self];

    return snapshotView;
}

@end


@interface eLBeeIsolator()

@property (nonatomic, copy) NSString *isolatedItemNameTag;
@property (nonatomic, assign) BOOL isItemBeingIsolated;

@end

@implementation eLBeeIsolator

#pragma mark -
#pragma mark Init Method(s)
#pragma mark -

-(instancetype)initWithParentView:(UIView *)parentView havingTableView:(UITableView *)tableView willStartCompletion:( eLBeeIsolatorWillStartCompletion )willStartBlock didAnimateCompletion:( eLBeeIsolatorDidAnimateCompletion )didAnimateBlock withCompletion:( eLBeeIsolatorDidIsolateCompletion )completionBlock {

    self = [super init];
    if( self ) {

        _parentView = parentView;
        _tableView  = tableView;
        _isItemBeingIsolated = NO;
        _willStartBlock = willStartBlock;
        _didAnimateBlock = didAnimateBlock;
        _completionBlock = completionBlock;
    }

    return self;
}

-(instancetype)initWithParentView:(UIView *)parentView havingTableView:(UITableView *)tableView  didAnimateCompletion:( eLBeeIsolatorDidAnimateCompletion )didAnimateBlock withCompletion:( eLBeeIsolatorDidIsolateCompletion )completionBlock {
    return [self initWithParentView:parentView havingTableView:tableView willStartCompletion:nil didAnimateCompletion:didAnimateBlock withCompletion:completionBlock];
}

-(instancetype)initWithParentView:(UIView *)parentView havingTableView:(UITableView *)tableView withCompletion:( eLBeeIsolatorDidIsolateCompletion )completionBlock {
    return [self initWithParentView:parentView havingTableView:tableView willStartCompletion:nil didAnimateCompletion:nil withCompletion:completionBlock];
}


-(instancetype)initWithParentView:(UIView *)parentView havingTableView:(UITableView *)tableView {
    return [self initWithParentView:parentView havingTableView:tableView willStartCompletion:nil didAnimateCompletion:nil withCompletion:nil];
}


-(instancetype)initWithParentView:(UIView *)parentView {
    return [self initWithParentView:parentView havingTableView:nil willStartCompletion:nil didAnimateCompletion:nil withCompletion:nil];
}


#pragma mark - Current Isolated Item

-(UIView *)currentIsolatedItem {

    NSString *tagName = self.isolatedItemNameTag;
    if( [tagName length] == 0 ) {
        return nil;
    }
    
    return [self.parentView viewWithNametag:self.isolatedItemNameTag];
}

#pragma mark -
#pragma mark Isolate View Method(s)
#pragma mark -

-(void)isolateView:(UIView *)view {
    [UIView snapshotView:view withName:ISOLATED_VIEW_NAMETAG withAlpha:1.0];
    self.isolatedItemNameTag = ISOLATED_VIEW_NAMETAG;

    [self performIsolation];
}


#pragma mark -
#pragma mark Isolate Cell Method(s)
#pragma mark -

-(void)isolateCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {

    if( !self.tableView ) {
        NSLog( @"isolateCell:atIndexPath called, but a tableView was not defined.  Returning without performing any actions.");
        return;
    }

    UIView *isolatedCell = [UIView snapshotForCell:cell atIndexPath:indexPath inTableView:self.tableView usingCoordsFromView:self.parentView];
    isolatedCell.nametag = ISOLATED_CELL_NAMETAG;

    [self.parentView addSubview:isolatedCell];

    self.isolatedItemNameTag = ISOLATED_CELL_NAMETAG;

    [self performIsolation];
}

-(void)isolateCellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if( !self.tableView ) {
        NSLog( @"isolateCellForRowAtIndexPath: called, but a tableView was not defined.  Returning without performing any actions.");
        return;
    }

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self isolateCell:cell atIndexPath:indexPath];
}

-(void)isolateCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
    self.tableView = tableView;
    [self isolateCell:cell atIndexPath:indexPath];
}

-(void)isolateCellForRowAtIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self isolateCell:cell atIndexPath:indexPath inTableView:tableView];
}


#pragma mark -
#pragma mark Deisolation Methods
#pragma mark -

-(void)deisolateCurrentViewAnimated:(BOOL)animated {

    UIView *isolatedView = [self currentIsolatedItem];
    if( !isolatedView ) {
        return;
    }

    self.isItemBeingIsolated = NO;

    if( self.willStartBlock != nil ) {
        self.willStartBlock( self.isItemBeingIsolated );
    }

    if( animated ) {
        [self animateItem:isolatedView];
    }

    [isolatedView removeFromSuperview];
    [self removeOverlay];
    
    self.isolatedItemNameTag = nil;

    if( !animated && self.completionBlock != nil ) {
        self.completionBlock( self.isItemBeingIsolated );
    }
}

-(void)deisolateCurrentView {
    [self deisolateCurrentViewAnimated:NO];
}


#pragma mark -
#pragma mark Animation Method(s)
#pragma mark -

/**
 * Given the name of this method, it may not be immediately obvious what happens here.
 * This method is where isItemBeingIsolated gets an actual truthy value.
 *
 * When isItemBeingIsolated is set to YES, then the methods called will perform the deIsolation routine
 * which REMOVES the isolated item.  Otherwise, isolation occurs and the opposite effect occurs.
 *
 * The isolation item is determined by the isolatedItemNameTag (if it was set).  The nameTag property
 * exists thanks to the UIView+Nametags category (above).  The purpose of this tag is just a (better?)
 * alternative to using the (int)tag property.  This allows for defining an identifier that is less-likely
 * to already be defined (or assigned) to another view (conflict) that we refer to later ( we would 
 * have needed to create an actual property on our object to be used for keeping track of the view otherwise).
 * This isn't a bullet proof solution, but I feel its a lot better than the alternative(s).
 *
 * Anyways, the isolated "item" is retrieved from the parentView (since it, the isolatedItem, is currently a subview of it).
 * Calling it an isolated "item" because "view" was too specific as it could also be any of the available UIView subclasses too ( like a UITableViewCell... )
 */
-(void)performIsolation {

    // Sanity check to make sure we don't blow shit up while we're still trying to finish the previos request.
    if( self.isItemBeingIsolated ) {
        return;
    }

    self.isItemBeingIsolated = YES;

    UIView *item = [self currentIsolatedItem];
    if( !item ) {
        self.isItemBeingIsolated = NO;
        return;
    }

    item.alpha = 0.1;

    [self animateItem: item];
}
// Anyways, moving on...


-(CGPoint)centerForIsolatedItemParent {

    if( [self.isolatedItemNameTag isEqualToString:ISOLATED_CELL_NAMETAG] && self.tableView ) {
        return self.tableView.center;
    }

    return self.parentView.center;
}


-(void)animateItem:(UIView *)isolatedItem {

    if( !isolatedItem ) {
        return;
    }

    __block BOOL isIsolated = self.isItemBeingIsolated == YES;

    if( self.willStartBlock != nil ) {
        self.willStartBlock( isIsolated );
    }

    if( self.shouldCenterInParent ) {
        isolatedItem.center = [self centerForIsolatedItemParent]; // or any other point...
    }

    CGFloat toAlpha = 0.1;

    if( isIsolated ) {
        toAlpha = 1.0;
        [self.parentView bringSubviewToFront: isolatedItem];
    }

    CGFloat scaleTo = !isIsolated ? ISOLATION_SCALE : DEISOLATION_SCALE;
    CGAffineTransform transformAnimation = CGAffineTransformMakeScale(scaleTo, scaleTo);

    __weak typeof(self) weakSelf = self;

    [UIView animateWithDuration:ISOLATOR_ANIMATION_DURATION delay:ISOLATOR_ANIMATION_DELAY options:UIViewAnimationOptionCurveEaseOut animations:^{

        isolatedItem.alpha = toAlpha;
        isolatedItem.transform = transformAnimation;

    } completion:^(BOOL finished) {
        [weakSelf didAnimateItem:isolatedItem];
    }];
}

-(void)transformIsolatedItem:( UIView *)isolatedItem usingAnimation:(CGAffineTransform)animation withAlpha:(CGFloat)toAlpha {

    isolatedItem.alpha = toAlpha;
    isolatedItem.transform = animation;
}

-(void)transformIsolatedItem:( UIView *)isolatedItem usingAnimation:(CGAffineTransform)animation toPoint:(CGPoint)point withAlpha:(CGFloat)toAlpha {
    [self transformIsolatedItem:isolatedItem usingAnimation:animation withAlpha:toAlpha];
    isolatedItem.center = point;
}

-(void)didAnimateItem:(UIView *)isolatedItem {

    __block BOOL isIsolated = self.isItemBeingIsolated == YES;

    if( self.didAnimateBlock != nil ) {
        self.didAnimateBlock( isIsolated );
    }

    if( self.completionBlock != nil ) {
        self.completionBlock( isIsolated );
    }

    self.isItemBeingIsolated = NO;
}


-(void)removeOverlay {
    UIView *overlayView = [self.parentView viewNamed:@"overlayView"];
    [overlayView removeFromSuperview];
}


@end
