//
//  GCVideoItemMoveViewCell.m
//  HQLVideoItemMoveCollectionViewDemo
//
//  Created by 何启亮 on 2018/8/24.
//  Copyright © 2018年 hql_personal_team. All rights reserved.
//

#import "GCVideoItemMoveViewCell.h"

#import <Masonry.h>

@implementation GCVideoItemMoveViewCellModel
@end

@interface GCVideoItemMoveViewCell ()

@property (nonatomic, strong) UIButton *m_button;

@end

@implementation GCVideoItemMoveViewCell

#pragma mark - initialize method

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self prepareUI];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"dealloc ---> %@", NSStringFromClass([self class]));
}

#pragma mark - prepareUI

- (void)prepareUI {
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.cornerRadius = 2;
    self.layer.masksToBounds = YES;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:button];
    self.m_button = button;
    [button addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

#pragma mark - event

- (void)onButtonClick:(UIButton *)button {
    self.clickHandle ? self.clickHandle(self) : nil;
}

#pragma mark - setter & getter

- (void)setModel:(GCVideoItemMoveViewCellModel *)model {
    _model = model;
    self.backgroundColor = model.color;
    if (model.isSelected) {
        self.layer.borderWidth = 2;
    } else {
        self.layer.borderWidth = 0;
    }
}

@end
