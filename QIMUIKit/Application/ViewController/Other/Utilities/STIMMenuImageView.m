//
//  ImageLabel.m
//
//
//  Created by  apple on 08-10-31.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "STIMMenuImageView.h"
#import "STIMChatBubbleView.h"
@implementation STIMMenuImageView
@synthesize delegate;

+ (void)cancelHighlighted{
    [[NSNotificationCenter defaultCenter] postNotificationName:STIMMenuImageViewCancelHightlighted object:nil];
}

- (void)cancelHighlighted{
    [self resignFirstResponder];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.canShowMenu = YES;
        [self addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongEvent:)] ];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelHighlighted) name:STIMMenuImageViewCancelHightlighted object:nil];
        if (_bubbleView == nil) {
            _bubbleView = [[STIMChatBubbleView alloc] initWithFrame:self.bounds];
            [self addSubview:_bubbleView];
        }
    }
    return self;
}

- (void)setFrame:(CGRect)frame{

    [super setFrame:frame];
    if (self.image) {
        if (_bubbleView) {
            [_bubbleView removeMask];
            [_bubbleView removeFromSuperview];
        }
    } else {
        if (_bubbleView == nil) {
            _bubbleView = [[STIMChatBubbleView alloc] initWithFrame:self.bounds];
            [self addSubview:_bubbleView];
        }
        _bubbleView.direction = (STIMChatBubbleViewDirection)self.message.messageDirection;
        [_bubbleView setFrame:self.bounds];
    }
}

- (void)setFrame:(CGRect)frame withNeedAddBubble:(BOOL)flag {
//    if (flag) {
    [self setFrame:frame];
    if (flag) {
        
    } else {
        [self setBubbleBgColor:[UIColor clearColor]];
        [self setMenuViewHidden:YES];
    }
//    } else {
//        [_bubbleView setFrame:self.bounds];
//    }
}

- (void)setImage:(UIImage *)image{
    [super setImage:image];
    if (self.image) {
        if (_bubbleView) {
            [_bubbleView removeMask];
            [_bubbleView removeFromSuperview];
        }
    } else {
        if (_bubbleView == nil) {
            _bubbleView = [[STIMChatBubbleView alloc] initWithFrame:self.bounds];
            [self addSubview:_bubbleView];
        }
        _bubbleView.direction = (STIMChatBubbleViewDirection)self.message.messageDirection;
        [_bubbleView setFrame:self.bounds];
    }
}

- (void)setBubbleBgColor:(UIColor *)color {
    [_bubbleView setBgColor:color];
}

- (void)setStrokeColor:(UIColor *)color {
    [_bubbleView setStrokeColor:color];
}

- (void)setMenuViewHidden:(BOOL)hidden {
    if (hidden == YES) {
        [_bubbleView removeMask];
    } else {
        
    }
}

- (void)onLongEvent:(UILongPressGestureRecognizer *)tag {
    if (!self.canShowMenu) {
        return;
    }
    if ([tag state] == UIGestureRecognizerStateBegan) {
        BOOL needAddForward = NO;
        switch (self.message.messageType) {
            case STIMMessageType_Text:
            case STIMMessageType_Voice:
            case STIMMessageType_File:
            case STIMMessageType_LocalShare:
            case STIMMessageType_SmallVideo:
            case STIMMessageType_CommonTrdInfo:
                needAddForward = YES;
            default:
                break;
        }
        if (needAddForward && ![self.menuActionTypeList containsObject:@(MA_Forward)]) {
            NSMutableArray * newArr = [NSMutableArray arrayWithArray:self.menuActionTypeList];
            if (![[STIMKit sharedInstance] getIsIpad]) {
                [newArr addObject:@(MA_Forward)];
            }
            self.menuActionTypeList = newArr;
        }
        [self showCopyMenu];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:STIMMenuImageViewCancelHightlighted object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//默认copy菜单
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(copy:)) {
        return NO;
    }
    else {
        return [super canPerformAction:action withSender:sender];
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)becomeFirstResponder {
    if([super becomeFirstResponder]) {
        self.highlighted = YES;
        return YES;
    }
    return NO;
}

- (BOOL)resignFirstResponder {
    if([super resignFirstResponder]) {
        self.highlighted = NO;
        return YES;
    }
    return NO;
}

- (void)copy:(id)sender {
    //剪贴版
    UIPasteboard *board = [UIPasteboard generalPasteboard];
    [board setString:self.text];
    self.highlighted = NO;
    [self resignFirstResponder];
}

-(void)setClipboardWitxthText:(NSString *)text {
    UIPasteboard *board = [UIPasteboard generalPasteboard];
    [board setString:text];
    
}

- (void)toWithdrawMsg:(id)sender {
    [self resignFirstResponder];
    if (delegate && [delegate respondsToSelector:@selector(onMenuActionWithType:)]) {
        [delegate onMenuActionWithType:MA_ToWithdraw];
    }
}

- (void)replyMsg:(id)sender {
    [self resignFirstResponder];
    if (delegate && [delegate respondsToSelector:@selector(onMenuActionWithType:)]) {
        [delegate onMenuActionWithType:MA_ReplyMsg];
    }
}

- (void)forwardMsgs:(id)sender {
    [self resignFirstResponder];
    if (delegate && [delegate respondsToSelector:@selector(onMenuActionWithType:)]) {
        [delegate onMenuActionWithType:MA_Forward];
    }
}

- (void)referMsgs:(id)sender {
    [self resignFirstResponder];
    if (delegate && [delegate respondsToSelector:@selector(onMenuActionWithType:)]) {
        [delegate onMenuActionWithType:MA_Refer];
    }
}

- (void)copyOriginMsg:(id)sender {
    [self resignFirstResponder];
    if (delegate && [delegate respondsToSelector:@selector(onMenuActionWithType:)]) {
        [delegate onMenuActionWithType:MA_CopyOriginMsg];
    }
}

-(void)deleteMsg:(id)sender {
    [self resignFirstResponder];
    if (delegate && [delegate respondsToSelector:@selector(onMenuActionWithType:)]) {
        [delegate onMenuActionWithType:MA_Delete];
    }
}

- (void)copyMethod:(id)sender {
    [self resignFirstResponder];
    if (delegate && [delegate respondsToSelector:@selector(onMenuActionWithType:)]) {
        [delegate onMenuActionWithType:MA_Copy];
    }
}

- (void)collectionMethod:(id)sender {
    [self resignFirstResponder];
    if (delegate && [delegate respondsToSelector:@selector(onMenuActionWithType:)]) {
        [delegate onMenuActionWithType:MA_Collection];
    }
}

- (void)favoriteMethod:(id)sender {
    
    [self resignFirstResponder];
    if (delegate && [delegate respondsToSelector:@selector(onMenuActionWithType:)]) {
        [delegate onMenuActionWithType:MA_Favorite];
    }
}

- (void)transmitMsg:(id)sender
{
    [self resignFirstResponder];
    if (delegate && [delegate respondsToSelector:@selector(onMenuActionWithType:)]) {
        [delegate onMenuActionWithType:MA_Repeater];
    }
}


- (void)transmitSMSMsg:(id)sender{
    [self resignFirstResponder];
    if (delegate && [delegate respondsToSelector:@selector(onMenuActionWithType:)]) {
        [delegate onMenuActionWithType:MA_RepeaterToSMS];
    }
}

- (void)saveAddressBook:(id)sender{
    [self resignFirstResponder];
    if (delegate && [delegate respondsToSelector:@selector(onMenuActionWithType:)]) {
        [delegate onMenuActionWithType:MA_SaveAddressBook];
    }
}

- (void)callPhone:(id)sender
{
    [self resignFirstResponder];
    if (delegate && [delegate respondsToSelector:@selector(onMenuActionWithType:)]) {
        [delegate onMenuActionWithType:MA_CallPhone];
    }
}

- (void)moreItem:(id)sender{
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuVisible:NO animated:NO];
    [menu update];
    [menu setTargetRect: CGRectZero inView:self];
    [menu setMenuVisible:YES animated:YES];   //4.0 系统必须要动画，否则不弹出菜单
}

- (NSDictionary *)menuItemDicts {
    return @{@(MA_Copy) : @{@"MenuTitle" : [NSBundle stimDB_localizedStringForKey:@"Copy"], @"MenuAction" : @"copyMethod:"},
             @(MA_Collection) : @{@"MenuTitle" : [NSBundle stimDB_localizedStringForKey:@"Add to Stickers"], @"MenuAction" : @"collectionMethod:"},
             @(MA_Favorite) : @{@"MenuTitle" : [NSBundle stimDB_localizedStringForKey:@"Favorite"], @"MenuAction" : @"favoriteMethod:"},
             @(MA_Repeater) : @{@"MenuTitle" : [NSBundle stimDB_localizedStringForKey:@"Forward"], @"MenuAction" : @"transmitMsg:"},
             @(MA_Delete) : @{@"MenuTitle" : [NSBundle stimDB_localizedStringForKey:@"Delete"], @"MenuAction" : @"deleteMsg:"},
             @(MA_ReplyMsg) : @{@"MenuTitle" : [NSBundle stimDB_localizedStringForKey:@"Reply"], @"MenuAction" : @"replyMsg:"},
             @(MA_ToWithdraw) : @{@"MenuTitle" : [NSBundle stimDB_localizedStringForKey:@"Recall"], @"MenuAction" : @"toWithdrawMsg:"},
             @(MA_Forward) : @{@"MenuTitle" : [NSBundle stimDB_localizedStringForKey:@"More"], @"MenuAction" : @"forwardMsgs:"},
             @(MA_Refer) : @{@"MenuTitle" : [NSBundle stimDB_localizedStringForKey:@"Quote"], @"MenuAction" : @"referMsgs:"},
             @(MA_CopyOriginMsg) : @{@"MenuTitle" : [NSBundle stimDB_localizedStringForKey:@"Original_Message"], @"MenuAction" : @"copyOriginMsg:"},
             };
}

-(void)showCopyMenu {
    if([self becomeFirstResponder]) {
        NSMutableArray * menuItems = [NSMutableArray array];
        for (NSNumber *actionType in self.menuActionTypeList) {
            MenuActionType menuType = actionType.intValue;
            NSDictionary *menuDict = [[self menuItemDicts] objectForKey:@(menuType)];
            NSString *menuTitle = [menuDict objectForKey:@"MenuTitle"];
            NSString *menuSelector = [menuDict objectForKey:@"MenuAction"];
            switch (menuType) {
                case MA_ToWithdraw:
                {
                    BOOL flag = YES;
                    if ([[self message] messageDirection] != STIMMessageDirection_Sent) {
                        flag = NO;
                    }
                    long long date = self.message.messageDate;
                    if (date > 140000000000) {
                        date = date / 1000;
                    }
                    date = date + [[STIMKit sharedInstance] getServerTimeDiff];
                    if ([[NSDate dateWithTimeIntervalSince1970:date] stimDB_isEarlierThanDate:[NSDate stimDB_dateWithMinutesBeforeNow:2]]) {
                        flag = NO;
                    }
                    if (flag) {
                        
                        UIMenuItem *toWithdrawItem = [[UIMenuItem alloc] initWithTitle:menuTitle
                                                                                action:NSSelectorFromString(menuSelector)];
                        [menuItems addObject:toWithdrawItem];
                    }
                }
                    break;
                default: {
                    UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:menuTitle
                                                                      action:NSSelectorFromString(menuSelector)];
                    [menuItems addObject:menuItem];
                }
                    break;
            }
        }
        
        UIMenuController *menu = [UIMenuController sharedMenuController];
        if (menu.menuVisible)
        {
            [menu setMenuVisible:NO animated:YES];
        }
        if (menuItems.count > 0) {
            menu.menuItems = menuItems;
            [menu update];
            [menu setTargetRect:CGRectMake(self.centerX / 3.0, 0, 0, 0) inView:self];
            [menu setMenuVisible:YES animated:YES];
        }
    }
}


@end
