//
//  STIMATGroupMemberTextAttachment.h
//  STChatIphone
//
//  Created by 李海彬 on 2018/4/3.
//

#import "STIMCommonUIFramework.h"

@interface STIMATGroupMemberTextAttachmentView : UIView

@property (nonatomic, strong) UIImage *contentImage;

@end

@interface STIMATGroupMemberTextAttachment : NSTextAttachment

@property (nonatomic, copy) NSString *groupMemberName;
@property (nonatomic, copy) NSString *groupMemberJid;

- (NSString *)getSendText;

@end
