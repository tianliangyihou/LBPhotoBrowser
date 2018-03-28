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

@interface ViewController ()

@end


@implementation ViewController

- (IBAction)collectionViewClick:(id)sender {
    LBLocalImageCollectionViewVC *lcv = [[LBLocalImageCollectionViewVC alloc]init];
    [self.navigationController pushViewController:lcv animated:YES];
}

- (IBAction)localBtnClick:(id)sender {
    LBLocalImageVC *lvc = [[LBLocalImageVC alloc]init];
    [self.navigationController pushViewController:lvc animated:YES];
}

- (IBAction)style1BtnbClick:(id)sender {
    LBStyle1VC *svc1 = [[LBStyle1VC alloc]init];
    [self.navigationController pushViewController:svc1 animated:YES];
}

- (IBAction)style2BtnClick:(id)sender {
    LBStyle2VC *svc2 = [[LBStyle2VC alloc]init];
    [self.navigationController pushViewController:svc2 animated:YES];
    
}

- (IBAction)style3BtnClicl:(id)sender {
    LBStyle3VC *svc3 = [[LBStyle3VC alloc]init];
    [self.navigationController pushViewController:svc3 animated:YES];
}
@end
