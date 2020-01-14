//
//  STIMCommonFont.h
//  STChatIphone
//
//  Created by haibin.li on 16/3/7.
//
//

#import "STIMCommonUIFramework.h"

@interface STIMCommonFont : NSObject

+ (instancetype)sharedInstance;

- (float)currentFontSize;

- (void)setCurrentFontSize:(float)fontSize;

- (NSString *)currentFontName;

- (void)setCurrentFontName:(NSString *)fontName;

@end
