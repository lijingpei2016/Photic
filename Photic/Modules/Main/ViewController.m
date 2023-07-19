//
//  ViewController.m
//  Photic
//
//  Created by LJP on 2022/8/22.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

static NSString * const cellName = @"cellName";


@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *demoList;
@property (nonatomic, copy) NSArray *demoPageNameList;

@end

@implementation ViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"hello，photic");
    
    self.demoList = @[@"镜头", @"相册", @"三分滤镜"];
    self.demoPageNameList = @[@"PCCameraViewController", @"PCEditViewController", @"PC3PointFilterViewController"];
    
    [self.view addSubview:self.tableView];
    
    //申请权限
    [self requestAuthorization];
    
}

#pragma mark - Utility
- (void)requestAuthorization{
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^(){
            if (!granted) {
                [self dismissViewControllerAnimated:YES completion:nil];
                return ;
            } else {
                NSLog(@"摄像头权限 ok");
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                    dispatch_async(dispatch_get_main_queue(), ^(){
                        if (!granted) {
                            [self dismissViewControllerAnimated:YES completion:nil];
                            return;
                        } else {
                            NSLog(@"麦克风权限 ok");
                            
                            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    
                                    if (status == PHAuthorizationStatusAuthorized) {
                                        NSLog(@"相册权限 ok");
                                        
                                    }else{
                                        [self dismissViewControllerAnimated:YES completion:nil];
                                        return;
                                    }
                                });
                                
                            }];
                        }
                        
                    });
                }];
                
            }
            
        });
    }];
}

#pragma mark - Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.demoList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellName];
    }
    
    NSString *demoTitle = self.demoList[indexPath.row];
    cell.textLabel.text = demoTitle;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    UIViewController *vc = [(UIViewController *) [NSClassFromString(self.demoPageNameList[indexPath.row]) alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Property
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

@end
