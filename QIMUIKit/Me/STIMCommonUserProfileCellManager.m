//
//  STIMCommonUserProfileCellManager.m
//  STChatIphone
//
//  Created by 李海彬 on 2017/12/25.
//

#import "STIMCommonUserProfileCellManager.h"
#import "STIMMWPhotoBrowser.h"
#import "STIMCommonUserInfoCell.h"
#import "STIMCommonTableViewCell.h"
#import "STIMCommonUserInfoHeaderCell.h"
#import "STIMMenuView.h"
#import "STIMWebView.h"
#import "STIMUserInfoModel.h"
#import "STIMModifyRemarkViewController.h"
#import "STIMMySignatureViewController.h"
#import "STIMCommonFont.h"
#import "NSBundle+STIMLibrary.h"

#define QCMineProfileCellHeight     79.0f
#define QCMineOtherCellHeight       [[STIMCommonFont sharedInstance] currentFontSize] + 24
#define QCMineSectionHeaderHeight   10.0f
#define QCMineMinSectionHeight      0.00001f

@interface STIMCommonUserProfileCellManager () <STIMMWPhotoBrowserDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIViewController *rootVC;
@property (nonatomic, copy) NSString *userId;

@end

@implementation STIMCommonUserProfileCellManager

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController WithUserId:(NSString *)userId {
    if (self = [super init]) {
        self.rootVC = rootViewController;
        self.userId = userId;
    }
    return self;
}

#pragma mark - Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *userProfileRowType = self.dataSource[indexPath.section][indexPath.row];
    CGFloat cellRowHeight = 44;
    switch (userProfileRowType.integerValue) {
        case QCUserProfileHeader:
        case QCUserProfileUserInfo: {
            cellRowHeight = QCMineProfileCellHeight;
        }
            break;
        case QCUserProfileDepartment: {
            CGSize size = [self.model.department stimDB_sizeWithFontCompatible:[UIFont systemFontOfSize:[[STIMCommonFont sharedInstance] currentFontSize] - 4] constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 70, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
            cellRowHeight = MAX([[STIMCommonFont sharedInstance] currentFontSize] + 32, size.height + 10);
        }
            break;
        default: {
            cellRowHeight = QCMineOtherCellHeight;
        }
            break;
    }
    return cellRowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0.00001f;
    }
    return QCMineSectionHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return QCMineMinSectionHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSNumber *userProfileRowType = self.dataSource[indexPath.section][indexPath.row];
    switch ([userProfileRowType integerValue]) {
//            QCUserProfileUserInfo,      //用户
//            QCUserProfileHeader,        //头像
//            QCUserProfileUserSignature,      //个性签名
//            QCUserProfileMyQrcode,      //二维码
//            QCUserProfileRemark,        //备注
//            QCUserProfileUserName,      //用户名称
//            QCUserProfileUserId,        //用户Id
//            QCUserProfileLeader,        //直属上级
//            QCUserProfileWorderId,      //工号
//            QCUserProfilePhoneNumber,   //手机号
//            QCUserProfileDepartment,    //部门
//            QCUserProfileComment,       //评论
//            QCUserProfileSendMail,      //发送邮件
//            QCUserProfileCustom,        //自定义
        case QCUserProfileUserInfo: {
            [self onUserHeaderClick];
        }
            break;
        case QCUserProfileHeader: {
//            STIMVerboseLog(@"查看大图");
            __weak typeof(self) weakSelf = self;
            UIAlertController *sheetVc = [UIAlertController alertControllerWithTitle:@"选择" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *showHeaderAction = [UIAlertAction actionWithTitle:@"查看头像" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf onUserHeaderClick];
            }];
            UIAlertAction *pickerPhotoAction = [UIAlertAction actionWithTitle:@"相册中获取" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                UIImagePickerController *picker = [[UIImagePickerController alloc]init];
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:picker.sourceType];
                }
                picker.delegate = self;
                picker.allowsEditing = YES;
                [weakSelf.rootVC presentViewController:picker animated:YES completion:nil];
            }];
            UIAlertAction *takePhoto = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                    
                    UIImagePickerControllerSourceType souceType = UIImagePickerControllerSourceTypeCamera;
                    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
                    picker.delegate = self;
                    picker.allowsEditing = YES;
                    picker.sourceType = souceType;
                    [weakSelf.rootVC presentViewController:picker animated:YES completion:nil];
                } else {
                    
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"Reminder"] message:@"当前设备不支持拍照" delegate:self cancelButtonTitle:[NSBundle stimDB_localizedStringForKey:@"Confirm"] otherButtonTitles:nil, nil];
                    [alertView show];
                }
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[NSBundle stimDB_localizedStringForKey:@"Cancel"] style:UIAlertActionStyleDestructive handler:nil];
            [sheetVc addAction:showHeaderAction];
            [sheetVc addAction:pickerPhotoAction];
            [sheetVc addAction:takePhoto];
            [sheetVc addAction:cancelAction];
            [self.rootVC presentViewController:sheetVc animated:YES completion:nil];
        }
            break;
        case QCUserProfileUserSignature: {
            STIMMySignatureViewController * mySignVC = [[STIMMySignatureViewController alloc] init];
            mySignVC.userId = [[STIMKit sharedInstance] getLastJid];
            mySignVC.playholder = self.model.personalSignature;
            [self.rootVC.navigationController pushViewController:mySignVC animated:YES];
        }
            break;
        case QCUserProfileMyQrcode: {
            [STIMFastEntrance showQRCodeWithQRId:self.userId withType:QRCodeType_UserQR];
        }
            break;
        case QCUserProfileRemark: {
            STIMModifyRemarkViewController * modifyRemarkVC = [[STIMModifyRemarkViewController alloc] init];
            modifyRemarkVC.jid = self.userId;
            modifyRemarkVC.nickName = [_userInfo objectForKey:@"Name"];
            [self.rootVC.navigationController pushViewController:modifyRemarkVC animated:YES];
        }
            break;
        case QCUserProfileComment: {
            NSData *userInfoData = [self.userInfo objectForKey:@"UserInfo"];
            NSDictionary *dic = [NSKeyedUnarchiver unarchiveObjectWithData:userInfoData];
            NSString *commentUrl = [dic objectForKey:@"commenturl"];
            NSURL *url = [NSURL URLWithString:commentUrl];
            NSString *query = [url query];
            NSString *baseUrl = nil;
            if (query.length > 0) {
                baseUrl =[commentUrl substringToIndex:commentUrl.length - query.length - 1];
                query = [query stringByAppendingString:@"&"];
            } else {
                baseUrl = commentUrl;
                query = @"";
            }
            commentUrl = [NSString stringWithFormat:@"%@?%@u=%@&k=%@&t=%@",
                          baseUrl,
                          query,
                          [[STIMKit getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                          [[STIMKit sharedInstance] myRemotelogginKey],
                          [self.userInfo objectForKey:@"UserId"]];
            
            STIMWebView *webView = [[STIMWebView alloc] init];
            [webView setUrl:commentUrl];
            [self.rootVC.navigationController pushViewController:webView animated:YES];
        }
            break;
        case QCUserProfileSendMail: {
            NSString *userId = [self.userInfo objectForKey:@"UserId"];
            [[STIMFastEntrance sharedInstance] sendMailWithRootVc:self.rootVC ByUserId:userId.length?userId:@"lilulucas.li"];
        }
            break;
        default:
            break;
    }
}

#pragma mark - DataSource

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource[section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *userProfileRowType = self.dataSource[indexPath.section][indexPath.row];
    switch ([userProfileRowType integerValue]) {
        case QCUserProfileUserInfo: {
            NSString *cellId = [NSString stringWithFormat:@"QCUserProfileUserInfo_%lu", (unsigned long)QCUserProfileUserInfo];
            STIMCommonUserInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
            if (!cell) {
                cell = [[STIMCommonUserInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
             }
            cell.accessoryType = UITableViewCellAccessoryNone;
            [cell.avatarImage stimDB_setImageWithJid:self.userId];
//            cell.avatarImage.image = [[STIMKit sharedInstance] getUserHeaderImageByUserId:self.userId];
            cell.nickNameLabel.text = self.model.name;
            cell.signatureLabel.text = self.model.personalSignature;
            [cell setAccessibilityIdentifier:@"user_header"];
            return cell;
        }
            break;
        case QCUserProfileHeader: {
            NSString *cellId = [NSString stringWithFormat:@"QCUserProfileHeader_%lu;", (unsigned long)QCUserProfileHeader];
            STIMCommonUserInfoHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
            if (!cell) {
                cell = [[STIMCommonUserInfoHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//            cell.avatarImage.image = [[STIMKit sharedInstance] getUserHeaderImageByUserId:self.userId];
            [cell.avatarImage stimDB_setImageWithJid:self.userId];
            cell.textLabel.text = @"头像";
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:[[STIMCommonFont sharedInstance] currentFontSize] - 4];
            cell.textLabel.textColor = [UIColor qtalkTextBlackColor];
            return cell;
        }
            break;
        case QCUserProfileUserSignature: {
            static NSString *cellIdentifier = @"Signature cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
                [cell.textLabel setText:[NSBundle stimDB_localizedStringForKey:@"user_introduce"]];
                STIMMenuView * menuView = [[STIMMenuView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
                menuView.tag = 1000;
                [cell.contentView addSubview:menuView];
            }
            
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:FONT_SIZE-4];
            cell.textLabel.textColor = [UIColor qtalkTextBlackColor];
            cell.detailTextLabel.font = [UIFont fontWithName:FONT_NAME size:FONT_SIZE-4];
            cell.detailTextLabel.textColor = [UIColor qtalkTextLightColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.detailTextLabel.text = self.model.personalSignature;
            [cell setAccessibilityIdentifier:cellIdentifier];
            [(STIMMenuView * )[cell.contentView viewWithTag:1000] setCoprText:self.model.personalSignature];
            
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:[[STIMCommonFont sharedInstance] currentFontSize] - 4];
            cell.detailTextLabel.font = [UIFont fontWithName:FONT_NAME size:[[STIMCommonFont sharedInstance] currentFontSize] - 4];

            return cell;
        }
            break;
        case QCUserProfileMyQrcode: {
            static NSString *cellIdentifier = @"MyQrcode cell";
            STIMCommonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [STIMCommonTableViewCell cellWithStyle:kSTIMCommonTableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
            }
            [cell setAccessibilityIdentifier:@"MyQrcode"];
            cell.accessoryType_LL = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = [NSBundle stimDB_localizedStringForKey:@"myself_tab_qrcode"];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:24];
            cell.detailTextLabel.text = @"\U0000f10d";
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:[[STIMCommonFont sharedInstance] currentFontSize] - 4];
            cell.textLabel.textColor = [UIColor qtalkTextBlackColor];
            return cell;
        }
            break;
        case QCUserProfileRemark: {
            static NSString *cellIdentifier = @"Remark cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
                [cell.textLabel setText:[NSBundle stimDB_localizedStringForKey:@"user_remark"]];
                
                STIMMenuView * menuView = [[STIMMenuView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
                menuView.tag = 1000;
                [cell.contentView addSubview:menuView];
            }
            [cell setAccessibilityIdentifier:@"user_remark"];
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:FONT_SIZE-4];
            cell.textLabel.textColor = [UIColor qtalkTextBlackColor];
            cell.detailTextLabel.font = [UIFont fontWithName:FONT_NAME size:FONT_SIZE-4];
            cell.detailTextLabel.textColor = [UIColor qtalkTextLightColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            NSString * remarkName = [[STIMKit sharedInstance] getUserMarkupNameWithUserId:self.userId];
            cell.detailTextLabel.text = remarkName?remarkName:@"设置备注";
            [cell setAccessibilityValue:remarkName?remarkName:@"设置备注"];
            [(STIMMenuView * )[cell.contentView viewWithTag:1000] setCoprText:remarkName];
            
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:[[STIMCommonFont sharedInstance] currentFontSize] - 4];
            cell.detailTextLabel.font = [UIFont fontWithName:FONT_NAME size:[[STIMCommonFont sharedInstance] currentFontSize] - 4];

            return cell;
        }
            break;
        case QCUserProfileUserName: {
            static NSString *cellIdentifier = @"UserName cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
                [cell.textLabel setText:[NSBundle stimDB_localizedStringForKey:@"user_name"]];
                
                STIMMenuView * menuView = [[STIMMenuView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
                menuView.tag = 1000;
                [cell.contentView addSubview:menuView];
            }
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:FONT_SIZE-4];
            cell.textLabel.textColor = [UIColor qtalkTextBlackColor];
            cell.detailTextLabel.font = [UIFont fontWithName:FONT_NAME size:FONT_SIZE-4];
            cell.detailTextLabel.textColor = [UIColor qtalkTextLightColor];
            cell.detailTextLabel.text = self.model.name;
            
            [(STIMMenuView * )[cell.contentView viewWithTag:1000] setCoprText:self.model.name];
            
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:[[STIMCommonFont sharedInstance] currentFontSize] - 4];
            cell.detailTextLabel.font = [UIFont fontWithName:FONT_NAME size:[[STIMCommonFont sharedInstance] currentFontSize] - 4];

            return cell;
        }
            break;
        case QCUserProfileUserId: {
            static NSString *cellIdentifier = @"UserId cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
                [cell.textLabel setText:[NSBundle stimDB_localizedStringForKey:@"user_id"]];
                cell.detailTextLabel.text = self.model.ID;
                
                STIMMenuView * menuView = [[STIMMenuView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
                menuView.coprText = self.model.ID;
                [cell.contentView addSubview:menuView];
            }
            cell.textLabel.textColor = [UIColor qtalkTextBlackColor];
            cell.detailTextLabel.textColor = [UIColor qtalkTextLightColor];
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:[[STIMCommonFont sharedInstance] currentFontSize] - 4];
            cell.detailTextLabel.font = [UIFont fontWithName:FONT_NAME size:[[STIMCommonFont sharedInstance] currentFontSize] - 4];

            return cell;
        }
            break;
        case QCUserProfileDepartment: {
            static NSString *cellIdentifier = @"DescInfo cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
                [cell.textLabel setText:[STIMKit getSTIMProjectType] == STIMProjectTypeQChat ? [NSBundle stimDB_localizedStringForKey:@"user_introduce"] : [NSBundle stimDB_localizedStringForKey:@"user_department"]];
                cell.detailTextLabel.text = self.model.department;
                
                CGSize size = [self.model.department stimDB_sizeWithFontCompatible:[UIFont systemFontOfSize:[[STIMCommonFont sharedInstance] currentFontSize] - 4] constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 70, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
                STIMMenuView * menuView = [[STIMMenuView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, MAX([[STIMCommonFont sharedInstance] currentFontSize] + 32, size.height + 10))];
                menuView.coprText = self.model.department;
                [cell.contentView addSubview:menuView];
            }
            cell.textLabel.textColor = [UIColor qtalkTextBlackColor];
            cell.textLabel.textAlignment = NSTextAlignmentRight;
            cell.detailTextLabel.textColor = [UIColor qtalkTextLightColor];
            cell.detailTextLabel.numberOfLines = 0;
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:[[STIMCommonFont sharedInstance] currentFontSize] - 4];
            cell.detailTextLabel.font = [UIFont fontWithName:FONT_NAME size:[[STIMCommonFont sharedInstance] currentFontSize] - 4];
            return cell;
        }
            break;
        case QCUserProfileComment: {
            static NSString *cellIdentifier = @"comment cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                [cell.textLabel setText:[NSBundle stimDB_localizedStringForKey:@"user_comment"]];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            }
            cell.textLabel.textColor = [UIColor qtalkTextBlackColor];
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:[[STIMCommonFont sharedInstance] currentFontSize] - 4];
            return cell;

        }
            break;
        case QCUserProfileSendMail: {
            static NSString *cellIdentifier = @"SendMail cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                [cell.textLabel setText:[NSBundle stimDB_localizedStringForKey:@"user_send_mail"]];
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            }
            cell.textLabel.textColor = [UIColor qtalkTextBlackColor];
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:[[STIMCommonFont sharedInstance] currentFontSize] - 4];
            return cell;
        }
            break;
        case QCUserProfilePhoneNumber: {
            static NSString *cellIdentifier = @"MobileNo cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
                [cell.textLabel setText:[NSBundle stimDB_localizedStringForKey:@"user_mobile_no"]];
                // 手机号
                cell.detailTextLabel.text = @"点击查看";
                
                CGSize size = [self.model.department stimDB_sizeWithFontCompatible:[UIFont systemFontOfSize:[[STIMCommonFont sharedInstance] currentFontSize] - 4] constrainedToSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 70, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
                STIMMenuView * menuView = [[STIMMenuView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, MAX([[STIMCommonFont sharedInstance] currentFontSize] + 32, size.height + 10))];
                menuView.coprText = self.model.department;
                [cell.contentView addSubview:menuView];
            }
            cell.textLabel.textColor = [UIColor qtalkTextBlackColor];
            cell.detailTextLabel.textColor = [UIColor stimDB_colorWithHex:0x999999 alpha:1];
            cell.detailTextLabel.numberOfLines = 0;
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:[[STIMCommonFont sharedInstance] currentFontSize] - 4];
            cell.detailTextLabel.font = [UIFont fontWithName:FONT_NAME size:[[STIMCommonFont sharedInstance] currentFontSize] - 4];
            return cell;
        }
            break;
        default: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
                [cell setBackgroundColor:[UIColor clearColor]];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
            return cell;
        }
            break;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return cell;
}

#pragma mark - STIMUserInfoTableViewCell Delegate
- (void)onUserHeaderClick{
    STIMMWPhotoBrowser *browser = [[STIMMWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = YES;
    browser.zoomPhotosToFill = YES;
    browser.enableSwipeToDismiss = NO;
    [browser setCurrentPhotoIndex:0];
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    browser.wantsFullScreenLayout = YES;
#endif
    
    //初始化navigation
    STIMNavController *nc = [[STIMNavController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.rootVC presentViewController:nc animated:YES completion:nil];
}

#pragma mark - STIMMWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(STIMMWPhotoBrowser *)photoBrowser {
    return 1;
}

- (id <STIMMWPhoto>)photoBrowser:(STIMMWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    
#pragma mark - 查看大图
    //1. 根据userId读取本地大图路径
    //2. 本地路径存在 -> fileURLWithPath转URL
    //3. 本地路径不存在 -> 直接加载URL
    NSString *headerUrl = [[STIMKit sharedInstance] getUserHeaderSrcByUserId:self.userId];
    if (![headerUrl stimDB_hasPrefixHttpHeader]) {
        headerUrl = [NSString stringWithFormat:@"%@/%@", [[STIMKit sharedInstance] qimNav_InnerFileHttpHost], headerUrl];
    }
    STIMMWPhoto *photo = [[STIMMWPhoto alloc] initWithURL:[NSURL URLWithString:headerUrl]];
    return photo;
}

- (void)photoBrowserDidFinishModalPresentation:(STIMMWPhotoBrowser *)photoBrowser {
    //界面消失
    [photoBrowser dismissViewControllerAnimated:YES completion:^{
        //tableView 回滚到上次浏览的位置
    }];
}

#pragma mark - UINavigationControllerDelegate, UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    [self saveImage:image];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveImage:(UIImage *)image {
    image = [image stimDB_scaleToSize:CGSizeMake(120, 120)];
    NSData *currentImageData = UIImageJPEGRepresentation(image, 0.5);
    if (currentImageData) {

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [[STIMKit sharedInstance] updateMyPhoto:currentImageData];
        });
    }
}

@end
