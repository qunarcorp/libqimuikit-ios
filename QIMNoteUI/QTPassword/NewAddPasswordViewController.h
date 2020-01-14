//
//  NewAddPasswordViewController.h
//  STChatIphone
//
//  Created by 李海彬 on 2017/7/11.
//
//

#import "STIMCommonUIFramework.h"
#if __has_include("STIMNoteManager.h")
#import "STIMNoteModel.h"

@interface NewAddPasswordViewController : UIViewController

@property (nonatomic, assign) BOOL edited;

- (void)setSTIMNoteModel:(STIMNoteModel *)model;

@property (nonatomic, assign) NSInteger CID;

@property (nonatomic, assign) NSInteger QID;

@end
#endif
