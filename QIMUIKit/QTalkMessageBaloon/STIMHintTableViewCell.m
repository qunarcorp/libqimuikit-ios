//
//  STIMHintTableViewCell.m
//  STIMUIKit
//
//  Created by qitmac000645 on 2019/8/22.
//

#define kSpaceToSide    30
#define kHintCelMaxWidth    ([UIScreen mainScreen].bounds.size.width - kSpaceToSide * 2)
#define kHintTextFontSize   12


#import "STIMHintTableViewCell.h"
#import "STIMMessageCellCache.h"
#import "STIMJSONSerializer.h"
#import "STIMLinkTextStorage.h"
#import "STIMTextContainer.h"
#import "STIMAttributedLabel.h"
#import "UIColor+STIMUtility.h"

@interface STIMHintTableViewCell()<STIMAttributedLabelDelegate>
{
    NSArray * _hintArr;
    STIMAttributedLabel * _hintLabel;
    UIImageView * _backView;
}
/*  hintArr
 *  text:显示的文字
 *  isLink:是否是可点击的
 *  url:如果可点击，点击后的url
 */
@end
@implementation STIMHintTableViewCell

+ (CGFloat)getCellHeightWihtMessage:(STIMMessageModel *)message chatType:(ChatType)chatType{
    STIMTextContainer * container = [[STIMTextContainer alloc] init];
    container.textAlignment = kCTCenterTextAlignment;
    container.lineBreakMode = kCTLineBreakByCharWrapping;
    container.font = [UIFont systemFontOfSize:kHintTextFontSize];
    container.isWidthToFit = YES;
    container.textColor = [UIColor stimDB_colorWithHex:0x666666 alpha:1];
    
    if (message.extendInformation) {
        message.message  = message.extendInformation;
    }
    
//    NSArray * hintArr = [[STIMJSONSerializer sharedInstance] deserializeObject:[message.message dataUsingEncoding:NSUTF8StringEncoding]  error:nil];
//
//    if (hintArr == nil) {
        NSDictionary * info = [[STIMJSONSerializer sharedInstance] deserializeObject:[message.message dataUsingEncoding:NSUTF8StringEncoding]  error:nil];
         NSArray * hintArr = info[@"hints"];
//    }
    for (NSDictionary * hintDic in hintArr) {
        BOOL isLink = NO;
        if (message.messageType == STIMMessageTypeRobotTurnToUser) {
            NSString * type = [hintDic[@"event"][@"type"] lowercaseString];
            isLink = type && ![type isEqualToString:@"text"];
        }else{
            [hintDic[@"isLink"] boolValue];
        }
        NSString * text = hintDic[@"text"];
        if (isLink) {
            [container appendLinkWithText:text linkFont:[UIFont systemFontOfSize:kHintTextFontSize] linkColor:[UIColor stimDB_colorWithHex:0x20bcd2] underLineStyle:kCTUnderlineStyleNone linkData:hintDic];
        }else{
            [container appendText:text];
        }
    }
    container = [container createTextContainerWithTextWidth:kHintCelMaxWidth];
    float cellHeight = [container getHeightWithFramesetter:nil width:container.textWidth] + 10;
    
    [[STIMMessageCellCache sharedInstance] setObject:container forKey:message.messageId];
    return cellHeight;
}

- (STIMTextContainer *)getTextContainerWith:(STIMMessageModel *)message{
    STIMTextContainer * container = [[STIMTextContainer alloc] init];
    container.textAlignment = kCTCenterTextAlignment;
    container.lineBreakMode = kCTLineBreakByCharWrapping;
    container.font = [UIFont systemFontOfSize:kHintTextFontSize];
    container.isWidthToFit = YES;
    container.textColor = [UIColor stimDB_colorWithHex:0x666666 alpha:1];
    if (message.extendInformation) {
        message.message  = message.extendInformation;
    }
    
//    NSArray * hintArr = [[STIMJSONSerializer sharedInstance] deserializeObject:[message.message dataUsingEncoding:NSUTF8StringEncoding]  error:nil];
    
//    if (hintArr == nil) {
        NSDictionary * info = [[STIMJSONSerializer sharedInstance] deserializeObject:[message.message dataUsingEncoding:NSUTF8StringEncoding]  error:nil];
        NSArray * hintArr = info[@"hints"];
//    }
    for (NSDictionary * hintDic in hintArr) {
        BOOL isLink = NO;
        if (message.messageType == STIMMessageTypeRobotTurnToUser) {
            NSString * type = [hintDic[@"event"][@"type"] lowercaseString];
            isLink = type && ![type isEqualToString:@"text"];
        }else{
            [hintDic[@"isLink"] boolValue];
        }
        NSString * text = hintDic[@"text"];
        if (isLink) {
            [container appendLinkWithText:text linkFont:[UIFont systemFontOfSize:kHintTextFontSize] linkColor:[UIColor stimDB_colorWithHex:0x00BEB3] underLineStyle:kCTUnderlineStyleNone linkData:hintDic];
        }else{
            [container appendText:text];
        }
    }
    container = [container createTextContainerWithTextWidth:kHintCelMaxWidth];
    return container;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.contentView removeAllSubviews];
        
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView setBackgroundColor:[UIColor clearColor]];
        
        _backView = [[UIImageView alloc] initWithImage:nil];
        _backView.backgroundColor = [UIColor stimDB_colorWithHex:0xD3D3D3];
        _backView.layer.masksToBounds = YES;
        _backView.layer.cornerRadius = 2.f;
        [self.contentView addSubview:_backView];
        
        _hintLabel = [[STIMAttributedLabel alloc] init];
        [_hintLabel setTextColor:[UIColor stimDB_colorWithHex:0x666666]];
        _hintLabel.backgroundColor = [UIColor clearColor];
        _hintLabel.delegate = self;
        //        [_backView addSubview:_hintLabel];
        //        [_backView bringSubviewToFront:_hintLabel];
        [self.contentView insertSubview:_hintLabel aboveSubview:_backView];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)refreshUI{
    _hintLabel.textContainer = [self getTextContainerWith:self.message];
    float spaceToSide = ([UIScreen mainScreen].bounds.size.width - _hintLabel.textContainer.textWidth) / 2;
    [_hintLabel setFrameWithOrign:CGPointMake(spaceToSide, 5) Width:_hintLabel.textContainer.textWidth];
    _backView.frame = CGRectMake(spaceToSide - 10, 0, _hintLabel.textContainer.textWidth + 18, _hintLabel.textContainer.textHeight + 8);
}

#pragma mark - QCAttributedLabelDelegate

-(void)attributedLabel:(STIMAttributedLabel *)attributedLabel textStorageClicked:(id<STIMTextStorageProtocol>)textStorage atPoint:(CGPoint)point{
    if ([textStorage isKindOfClass:[STIMLinkTextStorage class]]) {
        NSDictionary * linkData = [(STIMLinkTextStorage *)textStorage linkData];
        NSString * type = @"nomal";
        if (self.message.messageType == STIMMessageTypeRobotTurnToUser) {
            type = @"transfer";
        }
        if (_hintDelegate && [_hintDelegate respondsToSelector:@selector(hintCell:linkClickedWithInfo:)]) {
            [_hintDelegate hintCell:self linkClickedWithInfo:@{@"type":type,@"linkData":linkData?linkData:@""}];
        }
    }
}



@end
