//
//  MainViewController.m
//  RemoteController
//
//  Created by 杉山研究室 on 2013/11/15.
//  Copyright (c) 2013年 sueno. All rights reserved.
//

#import "MainViewController.h"

#import "sys/socket.h"
#import "netinet/in.h"
#import "netinet6/in6.h"
#import "arpa/inet.h"
#import "ifaddrs.h"
#import "netdb.h"


#import <CoreMotion/CoreMotion.h>

@interface MainViewController ()
@property (nonatomic, retain) CMMotionManager *manager;

@end

@implementation MainViewController


@synthesize manager = _manager;
@synthesize guestureMessageLabel = _guestureMessageLabel;


// rotation
int roll = 0;
int pitch = 0;
int yaw = 0;
int xR = 0;
int yR = 0;
int zR = 0;
int mask = -2;

// socket
int sockfd ;
struct sockaddr_in address ;

// config cache
NSString *name;
NSString *hand;
NSArray *drag;
NSArray *tapS;
NSArray *tapD;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // ジャイロセンサの設定　frequency : 周波数(Hz)
    float frequency = 24.0;
    self.manager = [[CMMotionManager alloc] init];
    [self startCMDeviceMotion:frequency];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    // タップの登録
    [self setTapEvent:1 multi:1 sel:@selector(view_1x1_Tapped:)];
    [self setTapEvent:1 multi:2 sel:@selector(view_1x2_Tapped:)];
    [self setTapEvent:1 multi:3 sel:@selector(view_1x3_Tapped:)];
    [self setTapEvent:1 multi:4 sel:@selector(view_1x4_Tapped:)];
//    [self setTapEvent:1 multi:5 sel:@selector(view_1x5_Tapped:)];
    [self setTapEvent:2 multi:1 sel:@selector(view_2x1_Tapped:)];
    [self setTapEvent:2 multi:2 sel:@selector(view_2x2_Tapped:)];
    [self setTapEvent:2 multi:3 sel:@selector(view_2x3_Tapped:)];
    [self setTapEvent:2 multi:4 sel:@selector(view_2x4_Tapped:)];
//    [self setTapEvent:2 multi:5 sel:@selector(view_2x5_Tapped:)];
    
    // マルチタッチを有効化
    self.view.multipleTouchEnabled = YES;
    
    // 設定取得 & 初期化
    UIDevice *device = [UIDevice currentDevice];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    [defaults setObject:device.name forKey:@"_Device"];
    [defaults setObject:@"192.168.7.147" forKey:@"_Host"];
    [defaults setObject:@"11000" forKey:@"_Port"];
    [defaults setObject:@"right" forKey:@"_Hand"];
    [defaults setObject:@"action" forKey:@"1S-Tap"];
    [defaults setObject:@"none" forKey:@"1D-Tap"];
    [defaults setObject:@"move" forKey:@"1-Drag"];
    [defaults setObject:@"reset" forKey:@"2S-Tap"];
    [defaults setObject:@"none" forKey:@"2D-Tap"];
    [defaults setObject:@"turn" forKey:@"2-Drag"];
    [defaults setObject:@"none" forKey:@"3S-Tap"];
    [defaults setObject:@"none" forKey:@"3D-Tap"];
    [defaults setObject:@"none" forKey:@"3-Drag"];
    [defaults setObject:@"none" forKey:@"4S-Tap"];
    [defaults setObject:@"none" forKey:@"4D-Tap"];
    [defaults setObject:@"none" forKey:@"4-Drag"];
    [ud registerDefaults:defaults];
    
    [self initConfigCache];
    [self connectServer];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 画面回転　固定設定
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return NO;
}
- (BOOL)shouldAutorotate {
    return NO;
}
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (IBAction)init_MotionSenser:(id)sender {
    [self initSenser];
}

- (void)startCMDeviceMotion:(float)frequency
{
    // センサーの有無を確認
    if (self.manager.deviceMotionAvailable) {
        //     if (true) {
        // 更新間隔の指定
        self.manager.deviceMotionUpdateInterval = 1.0 / frequency;  // 秒
        // ハンドラ
        CMDeviceMotionHandler handler = ^(CMDeviceMotion *motion, NSError *error) {
            roll = round(180 * motion.attitude.roll / M_PI);
            pitch = round(180 * motion.attitude.pitch / M_PI);
            yaw = round(180 * motion.attitude.yaw / M_PI);
            roll &= mask;
            pitch &= mask;
            yaw &= mask;
            
            if (xR!=roll || yR!=yaw || zR!=pitch*-1) {
                xR = roll; yR = yaw; zR = pitch*-1;
                
                [self sendMessage:[self getPointJson:hand x:xR y:yR z:zR]];
            }
            
        };
        
        // DeviceMotionの開始
        [self.manager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:handler];
    }
}

- (void) setTapEvent:(int)tap multi:(int)multi sel:(SEL)sel{
    UITapGestureRecognizer* tg = [[UITapGestureRecognizer alloc]initWithTarget:self action:sel];
    tg.numberOfTapsRequired = tap;
    tg.numberOfTouchesRequired = multi;
    [self.view addGestureRecognizer:tg];
}


// タップ
- (void)view_1x1_Tapped:(UITapGestureRecognizer *)sender {
    [self sendMessage:[self getTapJson:[tapS objectAtIndex:0] tap:sender]];
}
- (void)view_1x2_Tapped:(UITapGestureRecognizer *)sender {
    [self sendMessage:[self getTapJson:[tapS objectAtIndex:1] tap:sender]];
}
- (void)view_1x3_Tapped:(UITapGestureRecognizer *)sender {
    [self sendMessage:[self getTapJson:[tapS objectAtIndex:2] tap:sender]];
}
- (void)view_1x4_Tapped:(UITapGestureRecognizer *)sender {
    [self sendMessage:[self getTapJson:[tapS objectAtIndex:3] tap:sender]];
}
- (void)view_1x5_Tapped:(UITapGestureRecognizer *)sender {
    [self sendMessage:[self getTapJson:[tapS objectAtIndex:4] tap:sender]];
}
- (void)view_2x1_Tapped:(UITapGestureRecognizer *)sender {
    [self sendMessage:[self getTapJson:[tapD objectAtIndex:0] tap:sender]];
}
- (void)view_2x2_Tapped:(UITapGestureRecognizer *)sender {
    [self sendMessage:[self getTapJson:[tapD objectAtIndex:1] tap:sender]];
}
- (void)view_2x3_Tapped:(UITapGestureRecognizer *)sender {
    [self sendMessage:[self getTapJson:[tapD objectAtIndex:2] tap:sender]];
}
- (void)view_2x4_Tapped:(UITapGestureRecognizer *)sender {
    [self sendMessage:[self getTapJson:[tapD objectAtIndex:3] tap:sender]];
}
- (void)view_2x5_Tapped:(UITapGestureRecognizer *)sender {
    [self sendMessage:[self getTapJson:[tapD objectAtIndex:4] tap:sender]];
}
- (NSString *)getTapJson:(NSString *)tag tap:(UITapGestureRecognizer *)sender {
    CGPoint p = [sender locationInView:self.view];
    return [self getPointJson:tag point:p];
}














CGPoint startP;
CGPoint moveP;
CGPoint endP;

// ユーザによりViewへのタッチが開始したときに呼び出されるメソッド
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    startP = [((UITouch*)[touches anyObject])locationInView:self.view];
    [self sendMessage:[self getPointJson:@"Dstart" point:startP]];
}
// ユーザがドラッグしたときに呼び出されるメソッド
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    int fing = [[event allTouches] count];
    if ([drag count]<fing) return;
    moveP = [((UITouch*)[touches anyObject])locationInView:self.view];
    [self sendMessage:[self getPointJson:[drag objectAtIndex:fing-1] point:moveP]];
    NSLog(@"allTouches count : %lu (touchesBegan:withEvent:)", (unsigned long)[[event allTouches] count]);
}
// ユーザがタッチを終了したときに呼び出されるメソッド
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    endP = [((UITouch*)[touches anyObject])locationInView:self.view];
    [self sendMessage:[self getPointJson:@"Dend" point:endP]];
}


- (NSString *) getPointJson:(NSString *)type point:(CGPoint) p {
    NSString* str = [NSString stringWithFormat:@"{\"name\":\"%@\",\"type\":\"%@\",\"x\":\"%d\",\"y\":\"%d\"}",name,type,(int)p.x,(int)p.y];
    [self outputMessage:str];//Debug
    return str;
}
- (NSString *) getPointJson:(NSString *)type x:(int)x y:(int)y z:(int)z {
    NSString* str = [NSString stringWithFormat:@"{\"name\":\"%@\",\"type\":\"%@\",\"x\":\"%d\",\"y\":\"%d\",\"z\":\"%d\"}",name,type,x,y,z];
    [self outputMessage:str];//Debug
    return str;
}



- (void) outputMessage:(NSString *)msg {
    self.guestureMessageLabel.text = msg;
    //NSLog(msg);
}

- (void)connectServer {
    sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    address.sin_family = AF_INET;
    address.sin_port = htons([[[NSUserDefaults standardUserDefaults] stringForKey:@"_Port"] intValue]);
    address.sin_addr.s_addr = inet_addr([[[NSUserDefaults standardUserDefaults] stringForKey:@"_Host"] UTF8String]);
    NSLog(@"connect : ");
    NSLog(@"%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"_Host"]);
    NSLog(@"%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"_Port"]);
}

- (void) sendMessage:(NSString *)msg {
    //   int flug = sendto(sockfd, "hoge", 4, 0, (struct sockaddr *)&address, sizeof(address));
//    NSLog(@"%@",msg);
    sendto(sockfd, [msg UTF8String], msg.length, 0, (struct sockaddr *)&address, sizeof(address));
//    NSLog(@"%d",flug);
}

- (void)initConfigCache {
    name = [[NSUserDefaults standardUserDefaults] stringForKey:@"_Device"];
    hand = [[NSUserDefaults standardUserDefaults] stringForKey:@"_Hand"];
    drag = [NSArray arrayWithObjects:
            [[NSUserDefaults standardUserDefaults] stringForKey:@"1-Drag"],
            [[NSUserDefaults standardUserDefaults] stringForKey:@"2-Drag"],
            [[NSUserDefaults standardUserDefaults] stringForKey:@"3-Drag"],
            [[NSUserDefaults standardUserDefaults] stringForKey:@"4-Drag"],
//            [[NSUserDefaults standardUserDefaults] stringForKey:@"5-Drag"],
            nil];
    tapS = [NSArray arrayWithObjects:
            [[NSUserDefaults standardUserDefaults] stringForKey:@"1S-Tap"],
            [[NSUserDefaults standardUserDefaults] stringForKey:@"2S-Tap"],
            [[NSUserDefaults standardUserDefaults] stringForKey:@"3S-Tap"],
            [[NSUserDefaults standardUserDefaults] stringForKey:@"4S-Tap"],
//            [[NSUserDefaults standardUserDefaults] stringForKey:@"5S-Tap"],
            nil];
    tapD = [NSArray arrayWithObjects:
            [[NSUserDefaults standardUserDefaults] stringForKey:@"1D-Tap"],
            [[NSUserDefaults standardUserDefaults] stringForKey:@"2D-Tap"],
            [[NSUserDefaults standardUserDefaults] stringForKey:@"3D-Tap"],
            [[NSUserDefaults standardUserDefaults] stringForKey:@"4D-Tap"],
//            [[NSUserDefaults standardUserDefaults] stringForKey:@"5D-Tap"],
            nil];
}

- (void)initSenser {
    float frequency = 24.0;
    self.manager = nil;
    self.manager = [[CMMotionManager alloc] init];
    [self startCMDeviceMotion:frequency];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    NSLog(@"init motion");
}

- (void)viewWillAppear:(BOOL)animated {
    [self initConfigCache];
    [self connectServer];
}

- (void)applicationDidBecomeActive {
    [self initConfigCache];
    [self connectServer];
}

@end
