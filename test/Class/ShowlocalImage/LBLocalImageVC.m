//
//  LBLocalImageVC.m
//  test
//
//  Created by dengweihao on 2017/12/26.
//  Copyright © 2017年 dengweihao. All rights reserved.
//

#import "LBLocalImageVC.h"
#import "UIView+LBFrame.h"
#import "LBPhotoBrowserManager.h"
#import "UIImage+LBDecoder.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#define MAX_COUNT 10
#define LB_WEAK_SELF __weak typeof(self)wself = self

@interface LBLocalImageView : UIImageView
@property (nonatomic , strong)NSData *gifData;
@end

@implementation LBLocalImageView
@end;

@interface LBLocalImageVC ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic , strong)NSMutableArray *frames;
@property (nonatomic , weak)UIButton *addBtn;
@property (nonatomic , strong)NSMutableArray *imageViews;

@end

@implementation LBLocalImageVC

- (void)dealloc {
    LBPhotoBrowserLog(@"%@ 销毁了",NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.frames = @[].mutableCopy;
    self.imageViews = @[].mutableCopy;
    LB_WEAK_SELF;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        int column = 3;
        CGFloat itemWidth = ([UIScreen mainScreen].bounds.size.width - 2 * 10) / 3;
        CGFloat itemHeight = itemWidth;
        for (int i = 0; i < MAX_COUNT; i++) {
            CGFloat x = (i % column) * (10 + itemWidth) ;
            CGFloat y = (i / column) * (10 + itemHeight);
            CGRect frame = CGRectMake(x,100 + y, itemWidth, itemHeight);
            [wself.frames addObject:[NSValue valueWithCGRect:frame]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            UIButton *addBtn = [[UIButton alloc]initWithFrame:[wself.frames.firstObject CGRectValue]];
            addBtn.backgroundColor = [UIColor lightGrayColor];
            [addBtn setTitle:@"添加" forState:UIControlStateNormal];
            [addBtn addTarget:self action:@selector(getImageFromIpc) forControlEvents:UIControlEventTouchDown];
            [wself.view addSubview:addBtn];
            wself.addBtn = addBtn;
        });
    });
}


- (void)getImageFromIpc
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) return;
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    ipc.delegate = self;
    [self presentViewController:ipc animated:YES completion:nil];
}

#pragma mark -- <UIImagePickerControllerDelegate>--
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    LB_WEAK_SELF;
    [picker dismissViewControllerAnimated:YES completion:^{
        NSString *assetString = [[info objectForKey:UIImagePickerControllerReferenceURL] absoluteString];
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        if([assetString hasSuffix:@"GIF"]){
            ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc]init];
            [assetLibrary assetForURL:[info objectForKey:UIImagePickerControllerReferenceURL] resultBlock:^(ALAsset *asset) {
                
                ALAssetRepresentation *assetRepresentation = [asset representationForUTI:(__bridge NSString *)kUTTypeGIF];;
                NSUInteger size = (NSUInteger)assetRepresentation.size;
                uint8_t *buffer = malloc(size);
                NSError *error;
                NSUInteger bytes = [assetRepresentation getBytes:buffer fromOffset:0 length:size error:&error];
                NSData *data = [NSData dataWithBytes:buffer length:bytes];
                free(buffer);
                [wself configUIWithImage:image andGifData:data];
            } failureBlock:^(NSError *error) {

            }];
        }else {
            [self configUIWithImage:image andGifData:nil];
        }
    }];
   
}


- (void)configUIWithImage:(UIImage *)image andGifData:(NSData *)gifData{
    LBLocalImageView *imageView = [[LBLocalImageView alloc]initWithFrame:[self.frames[self.imageViews.count] CGRectValue]];
    imageView.gifData = gifData;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageClick:)];
    [imageView addGestureRecognizer:tap];
    imageView.clipsToBounds = YES;
    imageView.tag = self.imageViews.count;
    imageView.userInteractionEnabled = YES;
    imageView.image = image;
    [self.view addSubview:imageView];
    [self.view bringSubviewToFront:self.addBtn];
    [self.imageViews addObject:imageView];
    if (self.frames.count == self.imageViews.count) {
        [self.addBtn removeFromSuperview];
    }else {
        [UIView  animateWithDuration:0.25 animations:^{
            self.addBtn.frame = [self.frames[self.imageViews.count] CGRectValue];
        }];
    }
}

/**
 这个借口 继续完善 ---> 同一本地和网络
 */
- (void)imageClick:(UITapGestureRecognizer *)tap {
    NSMutableArray *items = @[].mutableCopy;
    for (LBLocalImageView *imageView in self.imageViews) {
        LBPhotoLocalItem *item = [[LBPhotoLocalItem alloc]initWithImage:imageView.image frame:imageView.frame gifData:imageView.gifData];
        [items addObject:item];
    }
    weak_self;
    // 这里只要你开心 可以无限addBlock
    [[[[[LBPhotoBrowserManager defaultManager] showImageWithLocalItems:items selectedIndex:tap.view.tag fromImageViewSuperView:self.view] addLongPressShowTitles:@[@"保存图片",@"识别二维码",@"取消"]] addTitleClickCallbackBlock:^(UIImage *image, NSIndexPath *deleIndexPath, NSString *title, BOOL isGif, NSData *gifImageData) {
        LBPhotoBrowserLog(@"%@",title);
    }]addPhotoBrowserDeleteItemBlock:^(NSIndexPath *indexPath, UIImage *image) {
        // 刷新UI
        [wself refreshUIWithIndex:indexPath.row];
    }].lowGifMemory = YES;
}

- (void)refreshUIWithIndex:(NSInteger)index {
    UIImageView *deleImageView = self.imageViews[index];
    deleImageView.hidden = YES;
    for (int i = 0; i < self.imageViews.count; i++) {
        if (i <= index) continue;
        UIImageView *imageView = self.imageViews[i];
        CGRect frame = CGRectZero;
        if (i - 1 >= 0) {
            UIImageView *imageViewPrevious = self.imageViews[i - 1];
            frame = imageViewPrevious.frame;
            imageView.tag = imageView.tag - 1;
        }
        if (CGRectEqualToRect(frame, CGRectZero)) {
            [imageView removeFromSuperview];
        }else {
            [UIView animateWithDuration:0.25 animations:^{
                imageView.frame = frame;
            }];
        }
    }
 
    NSValue *value = self.frames[self.imageViews.count - 1];
    [UIView animateWithDuration:0.25 animations:^{
        self.addBtn.frame = [value CGRectValue];
    }];
    [self.imageViews removeObjectAtIndex:index];
    [deleImageView removeFromSuperview];
}
@end
