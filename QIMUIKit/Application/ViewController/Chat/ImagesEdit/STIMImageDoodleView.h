//
//  STIMImageDoodleView.h
//  STChatIphone
//
//  Created by haibin.li on 15/7/8.
//
//

#import "STIMCommonUIFramework.h"

typedef NS_ENUM(NSInteger, DrawingMode) {
    DrawingModeNone = 0,
    DrawingModePaint,
    DrawingModeErase,
};

@interface STIMImageDoodleView : UIView

@property (nonatomic, readwrite) DrawingMode drawingMode;
@property (nonatomic, strong) UIColor *selectedColor;

-(instancetype)initWithFrame:(CGRect)frame;

-(UIImage *)getDoodleImage;

-(void)clean;

@end
