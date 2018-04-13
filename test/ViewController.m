//
//  ViewController.m
//  test
//
//  Created by dengweihao on 2017/3/14.
//  Copyright © 2017年 dengweihao. All rights reserved.
//

#import "ViewController.h"
#import "LBLocalImageVC.h"
#import "LBStyle1VC.h"
#import "LBStyle2VC.h"
#import "LBStyle3VC.h"
#import "LBLocalImageCollectionViewVC.h"
#import "LBWebImageCollectionViewVC.h"
#import <SDWebImage/SDWebImageManager.h>

static NSString *cellID = @"llb.cellID";

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic , weak)UITableView *tableView;

@property (nonatomic , strong)NSArray *titles;

@end

@implementation ViewController


- (UITableView *)tableView {
    if (!_tableView) {
        CGFloat navHeight = [UIScreen mainScreen].bounds.size.height == 812 ?  88 : 64;
        UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, navHeight, SCREEN_WIDTH, SCREEN_HEIGHT - navHeight) style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.tableFooterView = [UIView new];
        [self.view addSubview:tableView];
        _tableView = tableView;
    }
    return _tableView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    _titles = @[@"collectionView展示本地图片(复用cell)",
                @"collectionView展示网络(复用cell)",
                @"本地图片(不复用cell)",
                @"style1(网络图片)类似微信图片浏览器",
                @"style2(网络图片)类似今日头条图片浏览器",
                @"style3(网络图片)没有缩略图",
                @"清除SDWebImage的所有缓存"
                ];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self tableView];
}

#pragma mark - dataSource && delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _titles.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.textLabel.text = _titles[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
        {
            LBLocalImageCollectionViewVC *lcv = [[LBLocalImageCollectionViewVC alloc]init];
            [self.navigationController pushViewController:lcv animated:YES];
        }
            break;
        case 1:
        {
            LBWebImageCollectionViewVC *cvc = [[LBWebImageCollectionViewVC alloc]init];
            [self.navigationController pushViewController:cvc animated:YES];
        }
            break;
        case 2:
        {
            LBLocalImageVC *lvc = [[LBLocalImageVC alloc]init];
            [self.navigationController pushViewController:lvc animated:YES];
        }
            break;
        case 3:
        {
            LBStyle1VC *svc1 = [[LBStyle1VC alloc]init];
            [self.navigationController pushViewController:svc1 animated:YES];
        }
            break;
        case 4:
        {
            LBStyle2VC *svc2 = [[LBStyle2VC alloc]init];
            [self.navigationController pushViewController:svc2 animated:YES];
        }
            break;
        case 5:
        {
            LBStyle3VC *svc3 = [[LBStyle3VC alloc]init];
            [self.navigationController pushViewController:svc3 animated:YES];
        }
            break;
        default:
        {
            [[SDWebImageManager sharedManager].imageCache clearMemory];
            [SDWebImageManager.sharedManager.imageCache clearDiskOnCompletion:nil];
        }
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}
@end
