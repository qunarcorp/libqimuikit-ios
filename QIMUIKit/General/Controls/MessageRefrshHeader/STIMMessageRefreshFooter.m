//
//  STIMMessageRefreshFooter.m
//  STIMUIKit
//
//  Created by lihaibin.li on 2019/7/2.
//

#import "STIMMessageRefreshFooter.h"
#define TEXT_COLOR       [UIColor stimDB_colorWithHex:0x959595 alpha:1.0]

@implementation STIMMessageRefreshFooter

+ (MJRefreshAutoNormalFooter *)messsageFooterWithRefreshingTarget:(id)target refreshingAction:(SEL)action {
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:target refreshingAction:action];
    return footer;
}


@end
