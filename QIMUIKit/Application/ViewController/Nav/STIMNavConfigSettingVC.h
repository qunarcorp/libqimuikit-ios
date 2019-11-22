//
//  STIMNavConfigSettingVC.h
//  qunarChatIphone
//
//  Created by admin on 16/3/29.
//
//

#import "STIMCommonUIFramework.h"

#define NavConfigSettingChanged @"NavConfigSettingChanged"
@interface STIMNavConfigSettingVC : QTalkViewController

- (void)setEditedNavDict:(NSDictionary *)navDict;

- (void)setAddedNavDict:(NSDictionary *)navDict;

@end
