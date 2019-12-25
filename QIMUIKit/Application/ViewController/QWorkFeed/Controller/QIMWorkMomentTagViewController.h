//
//  QIMWorkMomentTagViewController.h
//  QIMUIKit
//
//  Created by qitmac000645 on 2019/11/18.
//

#import <UIKit/UIKit.h>
#import "QIMCommonUIFramework.h"
NS_ASSUME_NONNULL_BEGIN

typedef void(^momentSelectedMomentTagsBlock)(NSArray * selectTags);

@interface QIMWorkMomentTagViewController : QTalkViewController
@property (nonatomic , copy) NSString * title;
@property (nonatomic, assign) BOOL canMutiSelected;
@property (nonatomic, copy) momentSelectedMomentTagsBlock block;
//-(id)initWithSelectArr:(NSMutableArray *)arr;
- (void)setSelectArrFromPushView:(NSMutableArray *)arr;
@end

NS_ASSUME_NONNULL_END
