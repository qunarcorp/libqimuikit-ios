//
//  STIMTapGestureRecognizer.h
//  STChatIphone
//

#import "STIMCommonUIFramework.h"

@interface STIMTapGestureRecognizer : UITapGestureRecognizer
@property (nonatomic, retain)NSString *imageLink;
@property (nonatomic, retain)NSDictionary *userInfo;
@property (nonatomic, assign)CGRect imageRect;
@property (nonatomic, retain)UIImage *image;
@property (nonatomic, assign)NSInteger currentImageNum;
@end
