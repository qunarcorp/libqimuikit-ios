//
//  QIMWorkMomentTagView.h
//  QIMUIKit
//
//  Created by qitmac000645 on 2019/11/18.
//

#import <UIKit/UIKit.h>
#import "QIMCommonUIFramework.h"
@class QIMWorkMomentTagModel;
NS_ASSUME_NONNULL_BEGIN
typedef void(^QIMWorkMomentTagClickedBlock)(QIMWorkMomentTagModel * model);
typedef void(^QIMWorkMomentDidClickedCloseBtnBlock)(QIMWorkMomentTagModel * model);
@interface QIMWorkMomentTagView : UIView
@property (nonatomic,assign)BOOL canDelete;
@property (nonatomic , strong) QIMWorkMomentTagModel * model;
@property (nonatomic,copy) QIMWorkMomentTagClickedBlock addTagBlock;
@property (nonatomic, copy) QIMWorkMomentTagClickedBlock removeBlock;
@property (nonatomic,copy) QIMWorkMomentDidClickedCloseBtnBlock closeBlock;

- (void)resetTagViewStatus;
@end

NS_ASSUME_NONNULL_END