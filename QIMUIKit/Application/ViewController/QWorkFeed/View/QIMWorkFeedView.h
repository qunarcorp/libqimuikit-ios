//
//  QIMWorkFeedView.h
//  QIMUIKit
//
//  Created by lilu on 2019/4/29.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMCommonUIFramework.h"

NS_ASSUME_NONNULL_BEGIN

@interface QIMWorkFeedView : UIView

@property (nonatomic, copy) NSString *userId;

@property (nonatomic, strong) UIViewController *rootVC;

@property (nonatomic, copy) NSNumber * tagID;

-(instancetype)initWithFrame:(CGRect)frame
                      userId:(NSString *)userId
            showNewMomentBtn:(BOOL)showBtn
               showNoticView:(BOOL)showNtc;

-(instancetype)initWithFrame:(CGRect)frame
                       tagID:(NSString *)tagId
            showNewMomentBtn:(BOOL)showBtn
               showNoticView:(BOOL)showNtc
           showHeaderTagView:(BOOL)showTag;

-(instancetype)initWithFrame:(CGRect)frame
                      userId:(NSString *)userId
            showNewMomentBtn:(BOOL)showBtn
               showNoticView:(BOOL)showNtc
          showheaderEntrence:(BOOL)showheaderEntrence;



- (void)updateMomentView;

@end

NS_ASSUME_NONNULL_END
