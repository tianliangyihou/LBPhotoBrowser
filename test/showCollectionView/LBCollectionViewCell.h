//
//  LBCollectionViewCell.h
//  test
//
//  Created by dengweihao on 2017/11/13.
//  Copyright © 2017年 dengweihao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBCollectionViewCell : UICollectionViewCell

@property (nonatomic , copy)NSString * urlString;
@property (weak, nonatomic) IBOutlet UIImageView *showImageView;
@property (weak, nonatomic) IBOutlet UILabel *gifLabel;

@end
