//
//  STIMIconInfo.h
//  STChatIphone
//
//  Created by 李海彬 on 2017/12/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface STIMIconInfo : NSObject

@property (nonatomic, strong) NSString *text;
@property (nonatomic, assign) NSInteger size;
@property (nonatomic, strong) UIColor *color;

- (instancetype)initWithText:(NSString *)text size:(NSInteger)size color:(UIColor *)color;
+ (instancetype)iconInfoWithText:(NSString *)text size:(NSInteger)size color:(UIColor *)color;

@end
