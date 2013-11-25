//
//  MasterViewController.h
//  RemoteController
//
//  Created by 杉山研究室 on 2013/11/15.
//  Copyright (c) 2013年 sueno. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;

@end
