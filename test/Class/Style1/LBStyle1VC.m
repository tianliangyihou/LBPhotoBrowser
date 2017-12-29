
//
//  LBStyle1VC.m
//  test
//
//  Created by dengweihao on 2017/12/26.
//  Copyright © 2017年 dengweihao. All rights reserved.
//

#import "LBStyle1VC.h"

@interface LBStyle1VC ()

@end

@implementation LBStyle1VC

- (void)viewDidLoad {
    self.lagerURLStrings = @[
                             //大图
                             @"http://p7.pstatp.com/large/w960/5322000131e01b7a477d",
                             @"http://p7.pstatp.com/large/w960/5321000135125ebb938a",
                             @"http://wx1.sinaimg.cn/large/bfc243a3gy1febm7orgqfj20i80ht15x.jpg",
                             @"http://wx2.sinaimg.cn/large/bfc243a3gy1febm7pmnk7j20i70jidwo.jpg",
                             @"http://p2.pstatp.com/large/w960/4ecc00055b3ffcc909a9",
                             @"http://wx4.sinaimg.cn/large/bfc243a3gy1febm7rncxaj20ek0i74dv.jpg",
                             @"http://wx2.sinaimg.cn/large/bfc243a3gy1febm7sdk4lj20ib0i714u.jpg",
                             @"http://wx4.sinaimg.cn/large/bfc243a3gy1febm7tekewj20i20i4aoy.jpg",
                             @"http://wx1.sinaimg.cn/large/bfc243a3gy1febm7n9eorj20i60hsann.jpg",
                             @"http://wx3.sinaimg.cn/large/bfc243a3gy1febm7nzbz7j20ib0iek5j.jpg"
                             ];
    self.thumbnailURLStrings = @[
                                 //小图
                                 @"http://p7.pstatp.com/list/s200/5322000131e01b7a477d",
                                 @"http://p7.pstatp.com/list/s200/5321000135125ebb938a",
                                 @"http://wx1.sinaimg.cn/thumbnail/bfc243a3gy1febm7orgqfj20i80ht15x.jpg",
                                 @"http://wx2.sinaimg.cn/thumbnail/bfc243a3gy1febm7pmnk7j20i70jidwo.jpg",
                                 @"http://p2.pstatp.com/list/s200/4ecc00055b3ffcc909a9",
                                 @"http://wx4.sinaimg.cn/thumbnail/bfc243a3gy1febm7rncxaj20ek0i74dv.jpg",
                                 @"http://wx2.sinaimg.cn/thumbnail/bfc243a3gy1febm7sdk4lj20ib0i714u.jpg",
                                 @"http://wx4.sinaimg.cn/thumbnail/bfc243a3gy1febm7tekewj20i20i4aoy.jpg",
                                 @"http://wx1.sinaimg.cn/thumbnail/bfc243a3gy1febm7n9eorj20i60hsann.jpg",
                                 @"http://wx3.sinaimg.cn/thumbnail/bfc243a3gy1febm7nzbz7j20ib0iek5j.jpg"
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
            LBPhotoWebItem *item = [[LBPhotoWebItem alloc]initWithURLString:urlModel.largeURLString frame:imageView.frame];
            item.placeholdImage = imageView.image;
            [items addObject:item];
        }
        
        [LBPhotoBrowserManager.defaultManager showImageWithWebItems:items selectedIndex:tag fromImageViewSuperView:wcell.contentView].lowGifMemory = YES;
        
        [[[[LBPhotoBrowserManager.defaultManager addLongPressShowTitles:@[@"保存",@"识别二维码",@"分享",@"取消"]] addTitleClickCallbackBlock:^(UIImage *image, NSIndexPath *indexPath, NSString *title) {
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
        }].needPreloading = YES;
        
    }];
    return cell;
}
- (BOOL)prefersStatusBarHidden {
    return self.hideStatusBar;
}



@end
