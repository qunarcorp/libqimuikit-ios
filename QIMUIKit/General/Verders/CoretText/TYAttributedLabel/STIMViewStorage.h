//
//  QCDrawViewStorage.h
//  STIMAttributedLabelDemo
//
//  Created by tanyang on 15/4/9.
//  Copyright (c) 2016年 chenjie. All rights reserved.
//

#import "STIMCommonUIFramework.h"
#import "STIMDrawStorage.h"

@interface STIMViewStorage : STIMDrawStorage<STIMViewStorageProtocol>

@property (nonatomic, strong)   UIView *view;       // 添加view

@end
