
/**
 *  可以完全定制，控件只是为了演示效果
 */

#import "STIMCommonUIFramework.h"

typedef void (^SWITCHACTION) ();

@interface STIMOfficialAccountToolbar : UIView

@property (nonatomic, copy) SWITCHACTION switchAction;

@end
