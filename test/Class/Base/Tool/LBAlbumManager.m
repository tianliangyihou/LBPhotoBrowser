//
//  LBAlbumManager.m
//  test
//
//  Created by dengweihao on 2018/4/25.
//  Copyright © 2018年 dengweihao. All rights reserved.
//

#import "LBAlbumManager.h"
#import "LBProgressHUD.h"

#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <TZImagePickerController/TZImagePickerController.h>

static LBAlbumManager *_mgr = nil;

@interface LBAlbumManager () <TZImagePickerControllerDelegate>

@property (nonatomic , strong)ALAssetsLibrary *assetsLibrary;

@property (nonatomic , strong)TZImagePickerController *imagePickerVC;

@property (nonatomic , copy)void(^imageModelsBlock)(NSArray <LBImageAlbumModel *> *imageModels);

@property (nonatomic , strong)NSMutableArray <LBImageAlbumModel *> *imageModels;

@end



@implementation LBImageAlbumModel

@end

@implementation LBAlbumManager


- (NSMutableArray *)imageModels {
    if (!_imageModels) {
        _imageModels = [[NSMutableArray alloc]init];
    }
    return _imageModels;
}

- (TZImagePickerController *)imagePickerVC {
    if (!_imagePickerVC) {
        TZImagePickerController *imagePickerVC = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
        imagePickerVC.allowPickingGif = YES;
        imagePickerVC.allowPickingOriginalPhoto = YES;
        _imagePickerVC = imagePickerVC;
    }
    return _imagePickerVC;
}

- (ALAssetsLibrary *)assetsLibrary {
    if (!_assetsLibrary) {
        _assetsLibrary = [[ALAssetsLibrary alloc]init];
    }
    return _assetsLibrary;
}

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _mgr = [[LBAlbumManager alloc]init];
    });
    return _mgr;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearMemory) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}
- (void)clearMemory {
    self.assetsLibrary = nil;
}

#pragma mark - 选择图片
- (void)selectImagesFromAlbumShow:(void(^)(UIViewController *needToPresentVC))presentBlock imageModels:(void(^)(NSArray <LBImageAlbumModel *> *imageModels))imageModelsBlock maxCount:(int)count{
    if (!presentBlock) {
        return;
    }
    self.imagePickerVC.maxImagesCount = count;
    presentBlock(self.imagePickerVC);
    if (!imageModelsBlock) {
        return;
    }
    self.imageModelsBlock = imageModelsBlock;
}

#pragma mark - 保存图片

- (void)saveImage:(UIImage *)image {
    if (!image) {
        [LBProgressHUD showTest:@"保存图片不能为空"];
        return;
    }
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}
- (void)saveGifImageWithData:(NSData *)data {
    if (!data || data.length == 0) {
        [LBProgressHUD showTest:@"保存图片不能为空"];
        return;
    }
    [self.assetsLibrary writeImageDataToSavedPhotosAlbum:data metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error) {
            [LBProgressHUD showTest:error.localizedDescription];
        }else {
            [LBProgressHUD showTest:@"保存gif成功"];
        }
    }];
}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        [LBProgressHUD showTest:error.localizedDescription];
    }else {
        [LBProgressHUD showTest:@"保存成功"];
    }
}
#pragma mark - 图片选择器的delegate

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingGifImage:(UIImage *)animatedImage sourceAssets:(id)asset {
    LBImageAlbumModel *model = [[LBImageAlbumModel alloc]init];
    model.isGif = YES;
    if (![asset isKindOfClass:[ALAsset class]]) {
        PHAsset *ph_asset = (PHAsset *)asset;
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        [[PHImageManager defaultManager] requestImageDataForAsset:ph_asset
                                                          options:options
                                                    resultHandler:
         ^(NSData *imageData,
           NSString *dataUTI,
           UIImageOrientation orientation,
           NSDictionary *info) {
             model.gifImageData = imageData;
             model.image = animatedImage.images.firstObject;
             [self.imageModels addObject:model];
             [self albumSelctedFinish];
         }];
    }else {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            ALAsset *al_asset = (ALAsset *)asset;
            ALAssetRepresentation *assetRepresentation = [al_asset representationForUTI:(__bridge NSString *)kUTTypeGIF];;
            NSUInteger size = (NSUInteger)assetRepresentation.size;
            uint8_t *buffer = malloc(size);
            NSError *error;
            NSUInteger bytes = [assetRepresentation getBytes:buffer fromOffset:0 length:size error:&error];
            NSData *data = [NSData dataWithBytes:buffer length:bytes];
            if (data.length > 0) {
                model.gifImageData = data;
                model.isGif = YES;
                model.image = animatedImage.images.firstObject;
            }else {
                model.isGif = NO;
                model.image = animatedImage;
            }
            free(buffer);
            [self.imageModels addObject:model];
            [self albumSelctedFinish];

        });
    }
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    [photos enumerateObjectsUsingBlock:^(UIImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        LBImageAlbumModel *model = [[LBImageAlbumModel alloc]init];
        model.isGif = NO;
        model.image = obj;
        [self.imageModels addObject:model];
    }];
    [self albumSelctedFinish];
}

- (void)albumSelctedFinish {
    if ([[NSThread currentThread] isMainThread]) {
        if (self.imageModelsBlock) {
            self.imageModelsBlock(([self.imageModels copy]));
        }
        [self.imageModels removeAllObjects];
        self.imagePickerVC = nil;
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.imageModelsBlock) {
                self.imageModelsBlock(([self.imageModels copy]));
            }
            [self.imageModels removeAllObjects];
            self.imagePickerVC = nil;
        });
    }
}


@end
