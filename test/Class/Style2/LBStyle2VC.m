
//
//  LBStyle2VC.m
//  test
//
//  Created by dengweihao on 2017/12/26.
//  Copyright © 2017年 dengweihao. All rights reserved.
//

#import "LBStyle2VC.h"

@interface LBStyle2VC ()

@end

@implementation LBStyle2VC
- (void)viewDidLoad {
    self.lagerURLStrings = @[
                             //大图
                             @"http://p7.pstatp.com/large/w960/5323000189d48a5f0e36",
                             @"http://p7.pstatp.com/large/w960/53200001fb0e61ace01b",
                             @"http://p7.pstatp.com/large/w960/532000034e18320c2d48",
                             @"http://p7.pstatp.com/large/w960/4ecc0006b02b8368d036",
                             @"http://p7.pstatp.com/large/w960/5321000191bd6759f92b",
                             @"http://p7.pstatp.com/large/w960/53220001900709950d8d",
                             @"http://p3.pstatp.com/large/w960/53220001268b1a373be9",
                             @"http://p7.pstatp.com/large/w960/532300012072044452cb",
                             @"http://p7.pstatp.com/large/w960/53220000c8b83e5db98d",
                             @"http://p3.pstatp.com/large/w960/4ecb0005eb381c954dae",
                             @"http://p7.pstatp.com/large/w960/53220000c8b63babf8e9",
                             @"http://p3.pstatp.com/large/w960/53230000c127743586ef"
                            
                             ];
    self.thumbnailURLStrings = @[
                                 //小图
                                 @"http://p7.pstatp.com/list/s200/5323000189d48a5f0e36",
                                 @"http://p7.pstatp.com/list/s200/53200001fb0e61ace01b",
                                 @"http://p7.pstatp.com/list/s200/532000034e18320c2d48",
                                 @"http://p7.pstatp.com/list/s200/4ecc0006b02b8368d036",
                                 @"http://p7.pstatp.com/list/s200/5321000191bd6759f92b",
                                 @"http://p7.pstatp.com/list/s200/53220001900709950d8d",
                                 @"http://p3.pstatp.com/list/400x400/53220001268b1a373be9",
                                 @"http://p7.pstatp.com/list/400x400/532300012072044452cb",
                                 @"http://p7.pstatp.com/list/s200/53220000c8b83e5db98d",
                                 @"http://p3.pstatp.com/list/s200/4ecb0005eb381c954dae",
                                 @"http://p7.pstatp.com/list/s200/53220000c8b63babf8e9",
                                 @"http://p3.pstatp.com/list/s200/53230000c127743586ef"
                                 ];
    [super viewDidLoad];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LBCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    cell.model = self.models[indexPath.row];
    __weak typeof(cell) wcell = cell;
    __weak typeof(self) wself = self;

    [cell setCallBack:^(LBModel *cellModel, int tag) {
        wself.hideStatusBar = YES;
        [wself setNeedsStatusBarAppearanceUpdate];
        NSMutableArray *items = [[NSMutableArray alloc]init];
        for (int i = 0 ; i < cellModel.urls.count; i++) {
            LBURLModel *urlModel = cellModel.urls[i];
            UIImageView *imageView = wcell.imageViews[i];
            LBPhotoWebItem *item = [[LBPhotoWebItem alloc]initWithURLString:urlModel.largeURLString frame:imageView.frame placeholdImage:imageView.image placeholdSize:imageView.frame.size];
            [items addObject:item];
        }
        [LBPhotoBrowserManager.defaultManager showImageWithWebItems:items selectedIndex:tag fromImageViewSuperView:wcell.contentView].lowGifMemory = YES;
        
        [[[[[LBPhotoBrowserManager.defaultManager addLongPressShowTitles:@[@"保存",@"识别二维码",@"分享",@"取消"]] addTitleClickCallbackBlock:^(UIImage *image, NSIndexPath *indexPath, NSString *title) {
            LBPhotoBrowserLog(@"%@",title);
        }]addPhotoBrowserWillDismissBlock:^{
            wself.hideStatusBar = NO;
            [wself setNeedsStatusBarAppearanceUpdate];
        }]addPhotoBrowserImageDidDraggedToMoveBlock:^(CGFloat bgViewAlpha) {
            if (bgViewAlpha < 0.9 && wself.hideStatusBar) {
                wself.hideStatusBar = NO;
                [wself setNeedsStatusBarAppearanceUpdate];
            }
            if (bgViewAlpha > 0.9 && !wself.hideStatusBar) {
                wself.hideStatusBar = YES;
                [wself setNeedsStatusBarAppearanceUpdate];
            }
        }]addPhotoBrowserDidDismissBlock:^{
            LBPhotoBrowserLog(@"PhotoBrowserDidDismiss");
        }];
        
    }];
    return cell;
}

- (BOOL)prefersStatusBarHidden {
    return self.hideStatusBar;
}

@end
