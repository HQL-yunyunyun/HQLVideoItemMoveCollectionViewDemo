//
//  UICollectionViewCell+GCSnapshotView.m
//  HQLVideoItemPanMoveLayoutDemo
//
//  Created by 何启亮 on 2018/8/24.
//  Copyright © 2018年 hql_personal_team. All rights reserved.
//

#import "UICollectionViewCell+GCSnapshotView.h"

@implementation UICollectionViewCell (GCSnapshotView)

- (UIView *)GC_snapshotView {
    if ([self respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)]) {
        return [self snapshotViewAfterScreenUpdates:YES];
    }
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0f);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [[UIImageView alloc] initWithImage:image];
}

- (UIView *)GC_snapshotViewOnlyValueWithClipWidth:(CGFloat)width {
    if ([self respondsToSelector:@selector(resizableSnapshotViewFromRect:afterScreenUpdates:withCapInsets:)]) {
        return [self resizableSnapshotViewFromRect:CGRectMake(width, 0, self.bounds.size.width - 2 * width, self.bounds.size.height) afterScreenUpdates:YES withCapInsets:UIEdgeInsetsZero];
    }
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0f);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRef sourceImage = [image CGImage];
    CGImageRef newImage = CGImageCreateWithImageInRect(sourceImage, CGRectMake(width, 0, self.bounds.size.width - 2 * width, self.bounds.size.height));
    UIImage *new = [[UIImage alloc] initWithCGImage:newImage];
    
    CGImageRelease(sourceImage);
    CGImageRelease(newImage);
    
    return [[UIImageView alloc] initWithImage:new];
}

@end
