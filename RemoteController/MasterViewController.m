//
//  MasterViewController.m
//  RemoteController
//
//  Created by 杉山研究室 on 2013/11/15.
//  Copyright (c) 2013年 sueno. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"

@interface MasterViewController () {
    NSArray *_objects;
}
@end

@implementation MasterViewController


- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
//    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    UIDevice *device = [UIDevice currentDevice];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 設定取得
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary]; //default設定
    [defaults setObject:device.name forKey:@"_Device"];
    [defaults setObject:@"192.168.7.147" forKey:@"_Host"];
    [defaults setObject:@"11000" forKey:@"_Port"];
    [defaults setObject:@"right" forKey:@"_Hand"];
    [defaults setObject:@"none" forKey:@"1S-Tap"];
    [defaults setObject:@"none" forKey:@"1D-Tap"];
    [defaults setObject:@"move" forKey:@"1-Drag"];
    [defaults setObject:@"none" forKey:@"2S-Tap"];
    [defaults setObject:@"none" forKey:@"2D-Tap"];
    [defaults setObject:@"turn" forKey:@"2-Drag"];
    [defaults setObject:@"none" forKey:@"3S-Tap"];
    [defaults setObject:@"none" forKey:@"3D-Tap"];
    [defaults setObject:@"none" forKey:@"3-Drag"];
    [defaults setObject:@"none" forKey:@"4S-Tap"];
    [defaults setObject:@"none" forKey:@"4D-Tap"];
    [defaults setObject:@"none" forKey:@"4-Drag"];
    [ud registerDefaults:defaults];
//    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSDictionary *dic = [defaults persistentDomainForName:appDomain];
    
    _objects = [[defaults allKeys] sortedArrayUsingSelector:@selector(compare:)];;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
//    if (!_objects) {
//        _objects = [[NSMutableArray alloc] init];
//    }
//    [_objects insertObject:[NSDate date] atIndex:0];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger num = 0;
    switch (section) {
        case 0:
            num = [_objects count];
            break;
            
        default:
            break;
    }
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier];

    if (true)
    {
        cell = [[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIFont *textFont = [UIFont systemFontOfSize:17.0];
        
        UILabel *nameLabel;
        UITextField *passTextFld;
        // ラベル
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 0.0f, 140.0f, 50.0f)];
        nameLabel.backgroundColor = [UIColor clearColor];
        [nameLabel setFont:textFont];
        [cell.contentView addSubview:nameLabel];
        
        // テキスト
        passTextFld = [[UITextField alloc] initWithFrame:CGRectMake(130.0f, 0.0f, 140.0f, 50.0f)];
        [passTextFld setFont:textFont];
        passTextFld.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        passTextFld.autocapitalizationType = UITextAutocapitalizationTypeNone;
        
        [nameLabel setText:_objects[indexPath.row]];
        [passTextFld setText:[[NSUserDefaults standardUserDefaults] stringForKey:_objects[indexPath.row]]];
        
        passTextFld.placeholder = _objects[indexPath.row];
        passTextFld.returnKeyType = UIReturnKeyDefault;
        passTextFld.secureTextEntry = NO;
        passTextFld.tag = indexPath.row;
        
        passTextFld.delegate = self;
        
//        [passTextFld addTarget:self action:@selector(hoge:) forControlEvents:UIControlEventEditingDidEndOnExit];
        
        [cell.contentView addSubview:passTextFld];
    }
    
    return cell;
}



// TextField Returnタップ
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // キーボード非表示
    [textField resignFirstResponder];
    
    NSString *key = textField.placeholder;
    NSString *val = textField.text;
    [[NSUserDefaults standardUserDefaults] setObject:val forKey:key];
    
    return YES;
}

@end
