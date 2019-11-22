//
//  STIMSingleChatCell.h
//  Marquette
//
//  Created by ping.xue on 14-2-13.
//
//
#import "STIMMenuImageView.h"
#import "STIMCommonUIFramework.h"

#define kTextLabelTag       9999
@class STIMMessageModel;
@protocol STIMSingleChatCellDelegate <NSObject>
@required
- (void)processEvent:(int)event withMessage:(id) message;
@end

@interface STIMSingleChatCell : UITableViewCell

@property (nonatomic, retain)STIMMessageModel *message;
@property (nonatomic, assign) CGFloat frameWidth;
@property (nonatomic, weak) id<STIMSingleChatCellDelegate> delegate;
@property (nonatomic, assign) NSInteger imageIndex;
@property (nonatomic, assign) CGRect imageRect;
@property (nonatomic, retain) STIMMenuImageView *backView;

- (void)refreshUI;

- (NSInteger)indexForCellImagesAtLocation:(CGPoint)location;

@end
