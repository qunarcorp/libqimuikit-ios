//
//  QIMATGroupMemberTextAttachment.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/3.
//

#import "QIMCommonUIFramework.h"

@interface QIMATGroupMemberTextAttachmentView : UIView

@property (nonatomic, strong) UIImage *contentImage;

@end

@interface QIMATGroupMemberTextAttachment : NSTextAttachment

@property (nonatomic, copy) NSString *groupMemberName;
@property (nonatomic, copy) NSString *groupMemberJid;

- (NSString *)getSendText;

@end
