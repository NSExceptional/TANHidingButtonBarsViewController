//
//  MasterViewController.m
//  VanishingBars
//
//  Created by Tanner on 7/29/14.
//  Copyright (c) 2014 Tanner. All rights reserved.
//

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

#define SHOWS_TOOLBAR self.navigationController.toolbarHidden
#define NAVBAR_FRAME self.navigationController.navigationBar.frame
#define TOOLBAR_FRAME self.navigationController.toolbar.frame
#define TABLE_FRAME self.tableView.frame

#define NAVBAR_HEIGHT self.navigationController.navigationBar.frame.size.height
#define TOOLBAR_HEIGHT self.navigationController.toolbar.frame.size.height
#define NAVBAR_ORIGIN_HIDDEN (-self.navigationController.navigationBar.frame.size.height + 21)
#define NAVBAR_ORIGIN_REVEALED 20
#define TOOLBAR_ORIGIN_HIDDEN ([[UIScreen mainScreen] bounds].size.height)
#define TOOLBAR_ORIGIN_REVEALED (SCREEN_HEIGHT - TOOLBAR_HEIGHT)

#define TABLE_HEIGHT_BARS_HIDDEN (SCREEN_HEIGHT - 21)
#define TABLE_HEIGHT_BARS_REVEALED (SCREEN_HEIGHT - (NAVBAR_HEIGHT + 20 + (SHOWS_TOOLBAR ? 0 : TOOLBAR_HEIGHT)))
#define TABLE_ORIGIN_BARS_HIDDEN 21
#define TABLE_ORIGIN_BARS_REVEALED NAVBAR_HEIGHT + NAVBAR_ORIGIN_REVEALED

#import "TANHidingButtonBarsViewController.h"

@interface TANHidingButtonBarsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (assign, nonatomic) CGFloat previousScrollViewYOffset;

@end

@implementation TANHidingButtonBarsViewController

#pragma mark - Segues

#pragma mark - Table View

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitleTextColor:[UIColor blackColor]];
    self.vanishingBarsEnabled = YES;
}

//- (void)viewDidDisappear:(BOOL)animated
//{
//    self.previousScrollViewYOffset = 0;
//}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    if (self.barsHidden && self.vanishingBarsEnabled)
    {
        [self revealBarsAnimated:YES];
        return NO;
    }
    
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self revealBarsAnimated:NO];

    TANHidingButtonBarsViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"master"];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 200;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    cell.textLabel.text = [NSString stringWithFormat:@"Row %ld", (long)indexPath.row];
    return cell;
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if (self.vanishingBarsEnabled)
    {
        ScrollDirection scrollDirection;
        if (self.previousScrollViewYOffset > scrollView.contentOffset.y)
            scrollDirection = ScrollDirectionUp;
        else //if (self.previousScrollViewYOffset < scrollView.contentOffset.y)
            scrollDirection = ScrollDirectionDown;
        
        self.previousScrollViewYOffset = scrollView.contentOffset.y;
        
        if (scrollDirection == ScrollDirectionUp)
        {
            self.barsHidden = NO;
            
            [self adjustBarPositionsInScrollView:scrollView];
        }
    }
}

// scrollView scrolls up, then down as it's being added
// to the navigation stack, resulting in the bars being
// hidden before being presented. We need to fix this!
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // scrollDirectionDown: content is moving up to reveal lower content
    // scrollDirectionUp:   content is moving down to reveal higher content
    if (self.vanishingBarsEnabled)
    {
        ScrollDirection scrollDirection;
        if (self.previousScrollViewYOffset > scrollView.contentOffset.y)
        {
            scrollDirection = ScrollDirectionUp;
        }
        else //if (self.previousScrollViewYOffset < scrollView.contentOffset.y)
        {
            scrollDirection = ScrollDirectionDown;
        }
        
        if (scrollDirection == ScrollDirectionDown)
        {
            [self adjustBarPositionsInScrollView:scrollView];
        }
        else if (scrollDirection == ScrollDirectionUp){
            if (self.barsHidden == NO) {
                [self adjustBarPositionsInScrollView:scrollView];
            }
        }
    }
}

#pragma mark - Hiding bars

- (void)hideBarsAnimated:(BOOL)animated
{
    [self hideBarsAnimated:animated completion:nil];
}

- (void)hideBarsAnimated:(BOOL)animated completion:(void (^)(BOOL))completion
{
    if (self.barsHidden || !self.vanishingBarsEnabled)
    {
        if (completion)
            completion(YES);
        return;
    }

    self.barsHidden = YES;
    [self moveBarsTo:NAVBAR_ORIGIN_HIDDEN and:TOOLBAR_ORIGIN_HIDDEN animated:animated isToggle:YES completion:completion];
}

- (void)revealBarsAnimated:(BOOL)animated
{
    [self revealBarsAnimated:YES completion:nil];
}

- (void)revealBarsAnimated:(BOOL)animated completion:(void (^)(BOOL))completion
{
    if (!self.barsHidden || !self.vanishingBarsEnabled)
    {
        if (completion)
            completion(YES);
        return;
    }
    
    self.barsHidden = NO;
    [self moveBarsTo:NAVBAR_ORIGIN_REVEALED and:TOOLBAR_ORIGIN_REVEALED animated:animated isToggle:YES completion:completion];
}

- (void)adjustBarPositionsInScrollView:(UIScrollView *)scrollView
{
    // navbar
    CGRect navFrame = NAVBAR_FRAME;
    
    // toolbar
    CGRect toolbarFrame = TOOLBAR_FRAME;
    
    // scrollview
    CGRect tableViewFrame = TABLE_FRAME;
    
    CGFloat framePercentageHidden = ((NAVBAR_ORIGIN_REVEALED - navFrame.origin.y) / (navFrame.size.height - 1));
    CGFloat scrollOffset = scrollView.contentOffset.y;
    CGFloat scrollDiff = scrollOffset - self.previousScrollViewYOffset;
    CGFloat scrollHeight = scrollView.frame.size.height;
    CGFloat scrollContentSizeHeight = scrollView.contentSize.height + scrollView.contentInset.bottom;
    
    if (scrollOffset <= -scrollView.contentInset.top)
    {
        self.barsHidden = NO;
        
        navFrame.origin.y = NAVBAR_ORIGIN_REVEALED;
        toolbarFrame.origin.y = TOOLBAR_ORIGIN_REVEALED;
        
    }
    else if ((scrollOffset + scrollHeight) >= scrollContentSizeHeight)
    {
        self.barsHidden = YES;
        
        navFrame.origin.y = NAVBAR_ORIGIN_HIDDEN;
        toolbarFrame.origin.y = TOOLBAR_ORIGIN_HIDDEN;
    }
    else
    {
        //self.barsHidden = NO;
        
        navFrame.origin.y = MIN(NAVBAR_ORIGIN_REVEALED, MAX(NAVBAR_ORIGIN_HIDDEN, navFrame.origin.y - scrollDiff));
        toolbarFrame.origin.y = MAX(TOOLBAR_ORIGIN_REVEALED, MIN(TOOLBAR_ORIGIN_HIDDEN, toolbarFrame.origin.y + scrollDiff));
    }
    
    
    if (self.previousScrollViewYOffset < scrollView.contentOffset.y && framePercentageHidden == 1)
    {
        self.barsHidden = YES;
    }
    
    // height based on whether the toolbar is visible or not
    tableViewFrame.origin.y = navFrame.origin.y + navFrame.size.height;
    tableViewFrame.size.height = (SHOWS_TOOLBAR ? SCREEN_HEIGHT : toolbarFrame.origin.y) - tableViewFrame.origin.y;
    
    [self.navigationController.navigationBar setFrame:navFrame];
    [self.navigationController.toolbar setFrame:toolbarFrame];
    [self.tableView setFrame:tableViewFrame];
    [self fadeBarButtonItems:(1 - framePercentageHidden)];
    self.previousScrollViewYOffset = scrollOffset;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.vanishingBarsEnabled)
    {
        [self stoppedScrolling];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate && self.vanishingBarsEnabled)
    {
        [self stoppedScrolling];
    }
}

- (void)stoppedScrolling
{
    if (self.vanishingBarsEnabled)
    {
        if (NAVBAR_FRAME.origin.y < 0)
        {
            BOOL toggle = !self.barsHidden;
            self.barsHidden = YES;
            [self moveBarsTo:NAVBAR_ORIGIN_HIDDEN and:TOOLBAR_ORIGIN_HIDDEN animated:YES isToggle:toggle completion:nil];
        }
        else
        {
            BOOL toggle = self.barsHidden;
            self.barsHidden = NO;
            [self moveBarsTo:NAVBAR_ORIGIN_REVEALED and:TOOLBAR_ORIGIN_REVEALED animated:YES isToggle:toggle completion:nil];
        }
    }
}

- (void)moveBarsTo:(CGFloat)top and:(CGFloat)bottom animated:(BOOL)animated isToggle:(BOOL)isToggle completion:(void (^)(BOOL))completion
{
    void (^moveBars)() = ^void()
    {
        CGRect navFrame = NAVBAR_FRAME;
        CGFloat navAlpha = (navFrame.origin.y > top ? 0 : 1);
        navFrame.origin.y = top;
        [self.navigationController.navigationBar setFrame:navFrame];
        [self fadeBarButtonItems:navAlpha];
        
        CGRect toolbarFrame = TOOLBAR_FRAME;
        toolbarFrame.origin.y = MAX(bottom, TOOLBAR_ORIGIN_REVEALED);
        [self.navigationController.toolbar setFrame:toolbarFrame];
        
        CGRect tableViewFrame = TABLE_FRAME;
        
        if (!self.barsHidden && isToggle)
        {
            CGPoint offset = self.tableView.contentOffset;
            offset.y -= navFrame.size.height - tableViewFrame.origin.y;
            [self.tableView setContentOffset:offset animated:YES];
        }
        
        if (self.barsHidden)
        {
            tableViewFrame.origin.y = TABLE_ORIGIN_BARS_HIDDEN;
            tableViewFrame.size.height = TABLE_HEIGHT_BARS_HIDDEN;
        }
        else
        {
            tableViewFrame.origin.y = TABLE_ORIGIN_BARS_REVEALED;
            tableViewFrame.size.height = TABLE_HEIGHT_BARS_REVEALED;
        }
        
        [self.tableView setFrame:tableViewFrame];
    };
    
    if (animated)
    {
        if (completion)
        {
            [UIView animateWithDuration:0.15 animations:moveBars completion:completion];
        }
        else
        {
            [UIView animateWithDuration:0.15 animations:moveBars];
        }
    }
    else
    {
        moveBars();
        
        if (completion)
            completion(YES);
    }
}

- (void)fadeBarButtonItems:(CGFloat)alpha
{
    if (self.barsHidden)
    {
        alpha = 0;
    }
    [self.navigationItem.leftBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *item, NSUInteger i, BOOL *stop)
     {
         [item.customView setAlpha:alpha];
     }];
    [self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem *item, NSUInteger i, BOOL *stop)
     {
         [item.customView setAlpha:alpha];
     }];
    

    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                [self.titleTextColor colorWithAlphaComponent:alpha],
                                                NSForegroundColorAttributeName,
                                                nil]];
    // for custom titleView's, like mine
    [self.navigationItem.titleView setAlpha:alpha];
    
    // what was all this for?
    
//    CGFloat verticalOffset = -25 * alpha;
//    [[UINavigationBar appearance] setTitleVerticalPositionAdjustment:verticalOffset forBarMetrics:UIBarMetricsDefault];
    
    self.navigationController.navigationBar.tintColor = [self.navigationController.navigationBar.tintColor colorWithAlphaComponent:alpha];
}


@end
