//
//  DetailViewController.h
//  RemoteController
//
//  Created by 杉山研究室 on 2013/11/15.
//  Copyright (c) 2013年 sueno. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
