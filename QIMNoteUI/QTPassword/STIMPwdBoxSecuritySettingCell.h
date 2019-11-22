//
//  STIMPwdBoxSecuritySettingCell.h
//  STIMNoteUI
//
//  Created by 李露 on 10/12/18.
//  Copyright © 2018 STIM. All rights reserved.
//

#import "STIMCommonUIFramework.h"
#if __has_include("STIMNoteManager.h")
NS_ASSUME_NONNULL_BEGIN

@interface STIMPwdBoxSecuritySettingCell : UITableViewCell

+ (CGFloat)getCellHeight;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

- (void)setServiceStatusDetail:(NSString *)detailStr;

- (void)setServiceStatusTitle:(NSString *)statusTitle;

@end

NS_ASSUME_NONNULL_END
#endif
