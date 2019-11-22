//
//  STIMWorkFeedMessageView.h
//  STIMUIKit
//
//  Created by Kamil on 2019/5/15.
//

#import <UIKit/UIKit.h>
#import "STIMWorkMessageCell.h"

NS_ASSUME_NONNULL_BEGIN
@class STIMWorkMomentContentModel;

@protocol STIMWorkFeedMessageViewDataSource <NSObject>

-(NSDictionary *)qImWorkFeedMessageViewModelWithMomentPostUUID:(NSString *)momentId viewTag:(NSInteger)viewTag;

-(NSArray *)qImWorkFeedMessageViewOriginDataSourceWithViewTag:(NSInteger)viewTag;

@end

@protocol STIMWorkFeedMessageViewDelegate <NSObject>
-(void)qImWorkFeedMessageViewMoreDataSourceWithviewTag:(NSInteger)viewTag finishBlock:(void(^)(NSArray * arr))block;

-(void)qImWorkFeedMessageViewLoadNewDataWithNewTag:(NSInteger)viewTag finishBlock:(void(^)(NSArray * arr))block;
@end


@interface STIMWorkFeedMessageView : UIView
@property (nonatomic, assign) STIMWorkMomentCellType messageCellType;
@property (nonatomic, strong) NSMutableArray *noticeMsgs;
@property (nonatomic, weak) id<STIMWorkFeedMessageViewDelegate>delegate;
-(instancetype)initWithFrame:(CGRect)frame dataSource:(id<STIMWorkFeedMessageViewDataSource>)dataSource AndViewTag:(NSInteger) viewTag;

- (void)updateNewData;
//-(void)updateDataWith:(NSArray *)dataArr;
@end

NS_ASSUME_NONNULL_END
