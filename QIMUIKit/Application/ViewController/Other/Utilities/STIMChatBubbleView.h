//
//  STIMChatBubbleView.h
//  STChatIphone
//
//  Created by haibin.li on 16/2/16.
//
//

#import "STIMCommonUIFramework.h"

typedef enum {
    STIMChatBubbleViewDirectionRight,
    STIMChatBubbleViewDirectionLeft,
}STIMChatBubbleViewDirection;

@interface STIMChatBubbleView : UIView

@property (nonatomic,assign) STIMChatBubbleViewDirection direction;

- (void)removeMask;

- (void)setBgColor:(UIColor *)color;

- (void)setStrokeColor:(UIColor *)color;

@end
