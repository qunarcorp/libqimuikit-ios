//
//  QIMWorkFeedMessageView.h
//  QIMUIKit
//
//  Created by Kamil on 2019/5/15.
//

#import <UIKit/UIKit.h>
#import "QIMWorkMessageCell.h"

NS_ASSUME_NONNULL_BEGIN
@class QIMWorkMomentContentModel;

@protocol QIMWorkFeedMessageViewDataSource <NSObject>

-(NSDictionary *)qImWorkFeedMessageViewModelWithMomentPostUUID:(NSString *)momentId viewTag:(NSInteger)viewTag;

-(NSArray *)qImWorkFeedMessageViewOriginDataSourceWithViewTag:(NSInteger)viewTag;

@end

@protocol QIMWorkFeedMessageViewDelegate <NSObject>
-(void)qImWorkFeedMessageViewMoreDataSourceWithviewTag:(NSInteger)viewTag finishBlock:(void(^)(NSArray * arr))block;

-(void)qImWorkFeedMessageViewLoadNewDataWithNewTag:(NSInteger)viewTag finishBlock:(void(^)(NSArray * arr))block;
@end


@interface QIMWorkFeedMessageView : UIView
@property (nonatomic, assign) QIMWorkMomentCellType messageCellType;
@property (nonatomic, strong) NSMutableArray *noticeMsgs;
@property (nonatomic, weak) id<QIMWorkFeedMessageViewDelegate>delegate;
-(instancetype)initWithFrame:(CGRect)frame dataSource:(id<QIMWorkFeedMessageViewDataSource>)dataSource AndViewTag:(NSInteger) viewTag;

- (void)updateNewData;
//-(void)updateDataWith:(NSArray *)dataArr;
@end

NS_ASSUME_NONNULL_END
