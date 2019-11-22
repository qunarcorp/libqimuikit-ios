//
//  STIMFileManagerCell.m
//  qunarChatIphone
//
//  Created by chenjie on 15/7/24.
//
//

#import "STIMFileManagerCell.h"
#import "STIMFileIconTools.h"
#import "STIMJSONSerializer.h"
#import "NSBundle+STIMLibrary.h"

@interface STIMFileManagerCell()
{
    UIImageView             * _fileIcon;
    UILabel                 * _nameLabel;
    UILabel                 * _sizeLabel;
    UILabel                 * _descLabel;//显示时间 联系人
    UILabel                 * _statusLabel;
    
    STIMMessageModel                 * _message;
    BOOL                    _selected;
    UIImageView             * _selectBtn;
}

@end

@implementation STIMFileManagerCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _selected = NO;
        
        _selectBtn = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_selectBtn setImage:[UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"common_checkbox_no_44px"]];
        [self.contentView addSubview:_selectBtn];
        
        _fileIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_fileIcon];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.font = [UIFont systemFontOfSize:15];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.numberOfLines = 2;
        [self.contentView addSubview:_nameLabel];
        
        _sizeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _sizeLabel.font = [UIFont systemFontOfSize:12];
        _sizeLabel.backgroundColor = [UIColor clearColor];
        _sizeLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_sizeLabel];
        
        _descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _descLabel.font = [UIFont systemFontOfSize:12];
        _descLabel.backgroundColor = [UIColor clearColor];
        _descLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_descLabel];
        
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _statusLabel.font = [UIFont boldSystemFontOfSize:12];
        _statusLabel.textAlignment = NSTextAlignmentRight;
        _statusLabel.backgroundColor = [UIColor clearColor];
        _statusLabel.textAlignment = NSTextAlignmentRight;
        _statusLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_statusLabel];
        
        self.editing = YES;
    }
    return self;
}

- (void)setCellMessage:(STIMMessageModel *)message
{
    _message = message;
    
    NSDictionary *infoDic = [[STIMJSONSerializer sharedInstance] deserializeObject:message.message error:nil];
    NSString * fileName = [infoDic objectForKey:@"FileName"];
    NSString * fileSize = [infoDic objectForKey:@"FileSize"];
    NSString *fileUrl = [infoDic objectForKey:@"HttpUrl"];
    NSString *filePath = [[[STIMKit sharedInstance] getDownloadFilePath] stringByAppendingPathComponent:[[fileUrl pathComponents] lastObject]];
    long long msgDate = message.messageDate; 
    NSString * date = [[NSDate stimDB_dateWithTimeIntervalInMilliSecondSince1970:msgDate] stimDB_formattedDateDescription];
    if (fileName.length <= 0) {
        fileName = [NSBundle stimDB_localizedStringForKey:@"common_old_file"];
        fileSize = @"0.00B";
    }
    
    NSString *fileState = [NSBundle stimDB_localizedStringForKey:@"common_sent"];
    NSString * peopleStr =nil;
    if (message.messageDirection == STIMMessageDirection_Received) {
        peopleStr = [NSString stringWithFormat:@"%@%@", [NSBundle stimDB_localizedStringForKey:@"common_from"],message.from];
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:nil]) {
            fileState = [NSBundle stimDB_localizedStringForKey:@"common_not_download"];
        } else {
            fileState = [NSBundle stimDB_localizedStringForKey:@"common_already_download"];
        }
    }else{
        if ([[[message.xmppId componentsSeparatedByString:@"@"] objectAtIndex:1] hasPrefix:@"conference"]) {
            NSDictionary *groupDic = [[STIMKit sharedInstance] getGroupCardByGroupId:message.xmppId];
            if (groupDic.count > 0) {
                peopleStr = [NSString stringWithFormat:@"%@%@",[NSBundle stimDB_localizedStringForKey:@"common_issue"],[groupDic objectForKey:@"Name"]];
            } else {
                peopleStr = @"";
            }
        } else {
            NSDictionary *userDic = [[STIMKit sharedInstance] getUserInfoByUserId:message.to];
            if (userDic.count > 0) {
                peopleStr = [NSString stringWithFormat:@"%@%@",[NSBundle stimDB_localizedStringForKey:@"common_issue"],[userDic objectForKey:@"Name"]];
            } else {
                peopleStr = [NSString stringWithFormat:@"%@%@",[NSBundle stimDB_localizedStringForKey:@"common_issue"],[[message.to componentsSeparatedByString:@"@"] objectAtIndex:0]];
            }
        }
    }
    
    _nameLabel.text = fileName;
    _sizeLabel.text = fileSize;
    _descLabel.text = [NSString stringWithFormat:@"%@ %@",date,peopleStr];
    _statusLabel.text = fileState;
    _fileIcon.image = [STIMFileIconTools getFileIconWithExtension:fileName.pathExtension];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.isSelect) {
        _selectBtn.frame = CGRectMake(10, (self.contentView.height - 30) / 2, 30, 30);
    }else{
        _selectBtn.frame = CGRectZero;
    }
    
    _fileIcon.frame = CGRectMake(_selectBtn.right + 10, 10, 60, 60);
    
    _nameLabel.frame = CGRectMake(_fileIcon.right + 10, _fileIcon.top, self.contentView.width - _fileIcon.right - 10 - 10, 20);
    
    _sizeLabel.frame = CGRectMake(_nameLabel.left, _nameLabel.bottom + 5, _nameLabel.width, 15);
    
    _descLabel.frame = CGRectMake(_nameLabel.left, _sizeLabel.bottom + 2, _nameLabel.width - 50, 15);
    
    _statusLabel.frame = CGRectMake(self.contentView.width - 100, _descLabel.top, 90, 15);
    
}


- (void)setCellSelected : (BOOL)selected
{
    _selected = selected;
    [_selectBtn setImage:selected ? [UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"common_checkbox_yes_44px"] : [UIImage stimDB_imageNamedFromSTIMUIKitBundle:@"common_checkbox_no_44px"]];
}

- (BOOL)isCellSelected
{
    return _selected;
}

@end
