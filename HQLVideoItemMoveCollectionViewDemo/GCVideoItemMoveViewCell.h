//
//  GCVideoItemMoveViewCell.h
//  HQLVideoItemMoveCollectionViewDemo
//
//  Created by 何启亮 on 2018/8/24.
//  Copyright © 2018年 hql_personal_team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GCVideoItemMoveViewCellModel : NSObject

@property (nonatomic, assign) BOOL isSelected;

@property (nonatomic, strong) UIColor *color;

@end

@interface GCVideoItemMoveViewCell : UIView

@property (nonatomic, strong) GCVideoItemMoveViewCellModel *model;

@property (nonatomic, copy) void(^clickHandle)(GCVideoItemMoveViewCell *cell);

@end
