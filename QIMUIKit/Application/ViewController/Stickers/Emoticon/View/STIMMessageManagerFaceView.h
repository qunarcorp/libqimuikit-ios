//
//  STIMMessageManagerFaceView.h
//  STIMEmojiFace
//
//  Created by qitmac000495 on 16/5/10.
//  Copyright © 2016年 Qunar-lu. All rights reserved.
//

#import "STIMCommonUIFramework.h"
#import "STIMFaceView.h"

@protocol STIMMessageManagerFaceViewDelegate <NSObject>

- (void)SendTheFaceStr:(NSString *)faceStr withPackageId:(NSString *)packageId isDelete:(BOOL)dele;

- (void)SendTheContent;

- (void)segmentBtnDidClickedAtIndex : (NSInteger)index;

@end

@interface STIMMessageManagerFaceView : UIView <STIMFaceViewDelegate>

@property (nonatomic,weak) id<STIMMessageManagerFaceViewDelegate>delegate;
@property (nonatomic,copy) NSString         * packageId;
@property (nonatomic,assign) BOOL showAll;

- (instancetype)initWithFrame:(CGRect)frame WithPkId:(NSString *)packageId;

@end
