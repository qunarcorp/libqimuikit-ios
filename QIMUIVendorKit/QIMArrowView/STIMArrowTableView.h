//
//  STIMArrowTableView.h
//  Demo
//
//  Created by 吕中威 on 16/9/6.
//  Copyright © 2016年 吕中威. All rights reserved.
//

#import "STIMArrowView.h"

@protocol SelectIndexPathDelegate <NSObject>

- (void)selectIndexPathRow:(NSInteger )index;

@end

@interface STIMArrowTableView : STIMArrowView<UITableViewDelegate, UITableViewDataSource>
// titles
@property (nonatomic, strong) NSArray           * _Nonnull dataArray;
// images
@property (nonatomic, strong) NSArray <UIImage *> * _Nonnull images;
// height
@property (nonatomic, assign) CGFloat           row_height;
// font
@property (nonatomic, assign) CGFloat           fontSize;
// textColor
@property (nonatomic, strong) UIColor           * _Nonnull titleTextColor;
@property (nonatomic, assign) NSTextAlignment   textAlignment;
// delegate
@property (nonatomic, assign) id <SelectIndexPathDelegate> _Nonnull delegate;

@end
