//
//  eLBeeIsolator.h
//  eLBee
//
//  Created by Jonathon Hibbard on 4/17/14.
//  Copyright (c) 2014 Integrated Events. All rights reserved.
//

typedef void( ^eLBeeAnimationCompletion)(void);
typedef void ( ^eLBeeIsolatorWillAnimateCompletion)(BOOL itemIsBeingIsolated);
typedef void ( ^eLBeeIsolatorDidAnimateCompletion)(BOOL itemIsBeingIsolated);
typedef void ( ^eLBeeIsolatorDidIsolateCompletion)(BOOL itemIsBeingIsolated);

//       ,-----------------------------------------------------------------,
//  -<x(|                     e L B e e    I S O L A T O R                 |]]])
//       `-----------------------------------------------------------------`

@interface eLBeeIsolator : NSObject

@property (nonatomic, copy) eLBeeIsolatorWillAnimateCompletion willAnimateBlock;     // A completion block to be fired before animations begin.
@property (nonatomic, copy) eLBeeIsolatorDidAnimateCompletion didAnimateBlock;  // A completion block to be fired after the (de)isolation of a view is complete
@property (nonatomic, copy) eLBeeIsolatorDidIsolateCompletion didIsolateBlock;    // Fired just before the (de)isolation of a view is complete ( so that other
                                                                                // prep/reset animations and/or operations can be fired if needed ).

@property (nonatomic, weak) UIView *parentView;         // The primary view that represents the main coordinate system and also where isolation view animations
                                                        // should occur ( typically self.view )

@property (nonatomic, weak) UITableView *tableView;     // When an isolation view be a UITableViewCell, this tableView will be used to convert the cell's "origin"
                                                        // to the parentView's coordinate system for proper placement.

@property (nonatomic, assign) BOOL shouldCenterInParent;

//       ,-----------------------------------------------------------------,
//   -<x|                P R I M A R Y    I N I T I A L I Z E R            |]])
//       `-----------------------------------------------------------------`

/**
 * eLBeeIsolator's Primary Initializer.  
 *
 * NOTE: A parentView REQUIRED.  If a parentView isn't defined ( say by passing in nil or using just init/new and and not defining the parentView manually ) then 
 * one should expect a meltdown to occur.
 *
 * NOTE2: A tableView is optional.  This becomes REQUIRED when the view to be isolated is a UITableViewCell.  When this is the case one should ( once again ) 
 * expect a meltdown to occur.
 *
 * @param UIView  parentView                                        @see parentView property def above.
 * @param UITableView tableView                                     @see tableView  property def above.
 * @param eLBeeIsolatorWillAnimateCompletion  willAnimateBlock      @see willAnimateBlock property def above.
 * @param eLBeeIsolationWillFinishCompletion  willFinishBlock       @see willFinishBlock property def above.
 * @param eLBeeIsolationDidFinishCompletion   didFinishBlock        @see didFinishBlock property def above.
 */
-(instancetype)initWithParentView:(UIView *)parentView havingTableView:(UITableView *)tableView willAnimateCompletion:( eLBeeIsolatorWillAnimateCompletion )willAnimateBlock didAnimateCompletion:( eLBeeIsolatorDidAnimateCompletion )willFinishBlock withCompletion:( eLBeeIsolatorDidIsolateCompletion )didIsolateBlock;


//       ,-----------------------------------------------------------------,
//    -<|        C O N V E I N E N C E    I N I T I A L I Z E R S          |])
//       `-----------------------------------------------------------------`

-(instancetype)initWithParentView:(UIView *)parentView havingTableView:(UITableView *)tableView didAnimateCompletion:( eLBeeIsolatorDidAnimateCompletion )willFinishBlock withCompletion:( eLBeeIsolatorDidIsolateCompletion )didIsolateBlock;
-(instancetype)initWithParentView:(UIView *)parentView havingTableView:(UITableView *)tableView withCompletion:( eLBeeIsolatorDidIsolateCompletion )didIsolateBlock;
-(instancetype)initWithParentView:(UIView *)parentView havingTableView:(UITableView *)tableView;
-(instancetype)initWithParentView:(UIView *)parentView;


//       ,-----------------------------------------------------------------,
//     <|                 P U B L I C    M E T H O D S                     |)
//       `-----------------------------------------------------------------`

// View
-(void)isolateView:(UIView *)view;


// Cell
-(void)isolateCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView;
-(void)isolateCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

// CellForRowAtIndexPath
-(void)isolateCellForRowAtIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView;
-(void)isolateCellForRowAtIndexPath:(NSIndexPath *)indexPath;

-(CGPoint)centerForIsolatedItemParent;

// Other Actions
-(void)removeOverlay;
-(void)deisolateCurrentItem;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//       ,-----------------------------------------------------------------,
//     .|                  U I V I E W    C A T E G O R I E S              )
//       `-----------------------------------------------------------------`

@interface UIView (Nametags)

@property (nonatomic, readonly) NSArray *nametags;

-(UIView *)viewNamed:(NSString *)viewName;
-(NSArray *)viewsNamed:(NSString *)viewName;

@end

@interface UIView (OverlayView)

+(UIView *)overlayViewWithFrame:(CGRect)overlayFrame;
+(UIView *)overlayViewWithFrame:(CGRect)overlayFrame withName:(NSString *)viewName;

@end


@interface UIView (SnapshotView)

//  CATEGORY METHOD(s)
+(UIView *)snapshotViewFromView:(UIView *)view withName:(NSString *)viewName withAlpha:(CGFloat)alpha;
+(UIView *)snapshotViewFromView:(UIView *)view withName:(NSString *)viewName withAlpha:(CGFloat)alpha havingFrameForView:(UIView *)toView;


//  INSTANCE METHOD(s)
-(UIView *)snapshotForCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView;

@end
