//
//  DetailViewController.h
//  VanishingBars
//
//  Created by Tanner on 7/29/14.
//  Copyright (c) 2014 Tanner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

