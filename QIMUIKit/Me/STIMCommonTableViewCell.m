//
//  STIMCommonTableViewCell.m
//  qunarChatIphone
//
//  Created by 李露 on 2017/12/21.
//

#import "STIMCommonTableViewCell.h"

#define CONTACT_CELL_IMAGE_SIZE 36

@interface STIMCommonTableViewCell ()

@property (nonatomic) STIMCommonTableViewCellStyle style;

@end

@implementation STIMCommonTableViewCell

+ (instancetype)cellWithStyle:(STIMCommonTableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    STIMCommonTableViewCell *cell;
    switch (style) {
        case kSTIMCommonTableViewCellStyleValue1:
        case kSTIMCommonTableViewCellStyleValue2:
        case kSTIMCommonTableViewCellStyleSubtitle:
        case kSTIMCommonTableViewCellStyleDefault:
            cell = [[STIMCommonTableViewCell alloc] initWithStyle:(UITableViewCellStyle)style reuseIdentifier:reuseIdentifier];
            cell.textLabel.font = [UIFont systemFontOfSize:TABLE_VIEW_CELL_DEFAULT_FONT_SIZE];
            break;
        case kSTIMCommonTableViewCellStyleValueCenter:
        case kSTIMCommonTableViewCellStyleContactList:
        case kSTIMCommonTableViewCellStyleValueLeft:
            cell = [[STIMCommonTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.font = [UIFont systemFontOfSize:TABLE_VIEW_CELL_DEFAULT_FONT_SIZE];
            break;
        case kSTIMCommonTableViewCellStyleContactSearchList:
            cell = [[STIMCommonTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
            cell.detailTextLabel.textColor = [UIColor qtalkTextLightColor];
            
            break;
    }
    
    cell.style = style;
    return cell;
}

- (void)setAccessoryType_LL:(STIMCommonTableViewCellAccessoryType)accessoryType_LL {
    _accessoryType_LL = accessoryType_LL;
    switch (accessoryType_LL) {
        case kSTIMCommonTableViewCellAccessoryNone:
            self.accessoryType = UITableViewCellAccessoryNone;
            break;
        case kSTIMCommonTableViewCellAccessoryDisclosureIndicator:
            self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case kSTIMCommonTableViewCellAccessoryDetailButton:
            self.accessoryType = UITableViewCellAccessoryDetailButton;
            break;
        case kSTIMCommonTableViewCellAccessoryDetailDisclosureButton:
            self.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
            break;
        case kSTIMCommonTableViewCellAccessoryCheckmark:
            self.accessoryType = UITableViewCellAccessoryCheckmark;
            break;
            
        case kSTIMCommonTableViewCellAccessoryText: {
            self.accessoryType = UITableViewCellAccessoryNone;
            UILabel *label = [[UILabel alloc] init];
            label.textColor = [UIColor blackColor];
            CGFloat fontSize = self.textLabel.font.pointSize;
            label.font = [UIFont systemFontOfSize:fontSize - 1];
            label.textAlignment = NSTextAlignmentCenter;
            self.accessoryView = label;
            self.selectionStyle = UITableViewCellSelectionStyleNone;
        }
            break;
        case kSTIMCommonTableViewCellAccessorySwitch:
            self.accessoryType = UITableViewCellAccessoryNone;
            self.accessoryView = [[UISwitch alloc] init];
            self.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
            
        default:
            break;
    }
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame;
    
    switch (self.style) {
        case kSTIMCommonTableViewCellStyleValueCenter: {
            [self.textLabel sizeToFit];
            frame = self.contentView.bounds;
            self.textLabel.center = CGPointMake(frame.size.width/2, frame.size.height/2);
            break;
        }
        case kSTIMCommonTableViewCellStyleContactList: {
            frame = CGRectMake(10, 0, CONTACT_CELL_IMAGE_SIZE, CONTACT_CELL_IMAGE_SIZE);
            frame.origin.y = (CGRectGetHeight(self.contentView.frame) - CONTACT_CELL_IMAGE_SIZE) / 2;
            self.imageView.frame = frame;
            
            [self.textLabel sizeToFit];
            frame = self.textLabel.frame;
            frame.origin.x = CGRectGetMaxX(self.imageView.frame) + 10;
            frame.origin.y = (CGRectGetHeight(self.contentView.frame) - CGRectGetHeight(frame)) / 2;
            self.textLabel.frame = frame;
            
            break;
        }
        case kSTIMCommonTableViewCellStyleContactSearchList: {
            
            
            break;
        }
        case kSTIMCommonTableViewCellStyleValueLeft: {
            [self.textLabel sizeToFit];
            frame = self.textLabel.frame;
            frame.origin.x = TABLE_VIEW_CELL_LEFT_MARGIN;
            frame.origin.y = (CGRectGetHeight(self.contentView.frame) - CGRectGetHeight(frame)) / 2;
            self.textLabel.frame = frame;
            break;
        }
        default:
            break;
    }
}

- (BOOL)isSwitchOn {
    if (self.accessoryView && [self.accessoryView isKindOfClass:[UISwitch class]]) {
        UISwitch *switcher = (UISwitch *)self.accessoryView;
        return switcher.on;
    }else {
        return NO;
    }
}

- (void)setSwitchOn:(BOOL)on animated:(BOOL)animated {
    if (self.accessoryView && [self.accessoryView isKindOfClass:[UISwitch class]]) {
        UISwitch *switcher = (UISwitch *)self.accessoryView;
        [switcher setOn:on animated:animated];
    }
}

- (void)addSwitchTarget:(id)object tag:(NSUInteger)type action:(nonnull SEL)action forControlEvents:(UIControlEvents)controlEvents {
    if (self.accessoryView && [self.accessoryView isKindOfClass:[UISwitch class]]) {
        UISwitch *switcher = (UISwitch *)self.accessoryView;
        switcher.tag = type;
        [switcher addTarget:object action:action forControlEvents:controlEvents];
    }
}

- (NSString *)rightTextValue {
    if (self.accessoryView && [self.accessoryView isKindOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)self.accessoryView;
        return label.text;
    }
    
    return nil;
}

- (void)setRightTextValue:(NSString *)value {
    if (self.accessoryView && [self.accessoryView isKindOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)self.accessoryView;
        label.text = value;
        [label sizeToFit];
    }
}

@end
