//
//  TANHidingButtonBarsViewController.h
//  VanishingBars
//
//  Created by Tanner on 7/29/14.
//  Copyright (c) 2014 Tanner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TANHidingButtonBarsViewController : UITableViewController

typedef enum ScrollDirection {
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
    ScrollDirectionUp,
    ScrollDirectionDown,
    ScrollDirectionCrazy,
} ScrollDirection;

@property (strong, nonatomic) UIColor *titleTextColor;
@property (assign, nonatomic) BOOL barsHidden;
@property (assign, nonatomic) BOOL vanishingBarsEnabled;

- (void)hideBarsAnimated:(BOOL)animated;
- (void)hideBarsAnimated:(BOOL)animated completion:(void (^)(BOOL))completion;
- (void)revealBarsAnimated:(BOOL)animated;
- (void)revealBarsAnimated:(BOOL)animated completion:(void (^)(BOOL))completion;

- (void)moveBarsTo:(CGFloat)top and:(CGFloat)bottom animated:(BOOL)animated isToggle:(BOOL)isToggle completion:(void (^)(BOOL))completion;

@end