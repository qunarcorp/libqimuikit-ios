//
//  STIMCommonTableViewCellManager.m
//  STChatIphone
//
//  Created by 李海彬 on 2017/12/21.
//

#import "STIMCommonTableViewCellManager.h"
#import "STIMCommonTableViewCellData.h"
#import "STIMCommonTableViewCell.h"
#import "STIMCommonUserInfoCell.h"
#import "STIMWebView.h"
#import "NSBundle+STIMLibrary.h"
#import "STIMDataController.h"
#import "STIMFileManagerViewController.h"
#import "STIMFeedBackViewController.h"
#import "STIMAboutVC.h"
#import "STIMMySettingController.h"
#import "STIMDressUpController.h"
#import "STIMGroupChangeNameVC.h"
#import "STIMGroupChangeTopicVC.h"
#import "STIMFriendSettingViewController.h"
#import "STIMUserProfileViewController.h"
#import "STIMCommonFont.h"
#import "STIMUserInfoModel.h"
#import "QCGroupModel.h"
#import "STIMMenuView.h"
#import "STIMServiceStatusViewController.h"

@interface STIMCommonTableViewCellManager ()

@property (nonatomic, strong) UIViewController *rootVC;

@end

@implementation STIMCommonTableViewCellManager

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    if (self = [super init]) {
        self.rootVC = rootViewController;
    }
    return self;
}

#pragma mark - Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    STIMCommonTableViewCellData *cellData = self.dataSource[indexPath.section][indexPath.row];
    switch (cellData.cellDataType) {
        case STIMCommonTableViewCellDataTypeBlankLines: {
            return QCBlankLineCellHeight;
        }
            break;
        case STIMCommonTableViewCellDataTypeMine: {
            return QCMineProfileCellHeight;
        }
            break;
        default: {
            return QCMineOtherCellHeight;
        }
            break;
    }
    return QCMineOtherCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.dataSourceTitle.count > 0) {
        NSString *sectionTitle = [self.dataSourceTitle objectAtIndex:section];
        if (sectionTitle.length > 0) {
            return 37;
        } else {
            return 10.0f;
        }
    } else {
        if (section == 0) {
            return 0.00001f;
        }
        return QCMineSectionHeaderHeight;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return QCMineMinSectionHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    STIMCommonTableViewCellData *itemData = self.dataSource[indexPath.section][indexPath.row];
    switch (itemData.cellDataType) {
        case STIMCommonTableViewCellDataTypeMine: {
            STIMUserProfileViewController *myProfileVc = [[STIMUserProfileViewController alloc] init];
            myProfileVc.userId = [[STIMKit sharedInstance] getLastJid];
            myProfileVc.myOwnerProfile = YES;
            [self.rootVC.navigationController pushViewController:myProfileVc animated:YES];
        }
            break;
        case STIMCommonTableViewCellDataTypeMyRedEnvelope: {
            NSString *myRedpackageUrl = [[STIMKit sharedInstance] myRedpackageUrl];
            if (myRedpackageUrl.length > 0) {
                [STIMFastEntrance openWebViewForUrl:myRedpackageUrl showNavBar:YES];
            }
        }
            break;
        case STIMCommonTableViewCellDataTypeBalanceInquiry: {
            NSString *balacnceUrl = [[STIMKit sharedInstance] redPackageBalanceUrl];
            if (balacnceUrl.length > 0) {
                [STIMFastEntrance openWebViewForUrl:balacnceUrl showNavBar:YES];
            }
        }
            break;
        case STIMCommonTableViewCellDataTypeAttendance:{
#if __has_include("QimRNBModule.h")
            Class RunC = NSClassFromString(@"QimRNBModule");
            SEL sel = NSSelectorFromString(@"clockOnVC");
            UIViewController *vc = nil;
            if ([RunC respondsToSelector:sel]) {
                vc = [RunC performSelector:sel withObject:nil];
            }
            [self.rootVC presentViewController:vc animated:YES completion:nil];
#endif
        }
            break;
        case STIMCommonTableViewCellDataTypeTotpToken:{
#if __has_include("QimRNBModule.h")
            [STIMFastEntrance openSTIMRNVCWithModuleName:@"TOTP" WithProperties:@{}];
#endif
        }
            break;
        case STIMCommonTableViewCellDataTypeMyFile: {
            
            STIMFileManagerViewController *fileManagerVc = [[STIMFileManagerViewController alloc] init];
            [self.rootVC.navigationController pushViewController:fileManagerVc animated:YES];
        }
            break;
        case STIMCommonTableViewCellDataTypeFeedback: {
            STIMFeedBackViewController *feedBackVc = [[STIMFeedBackViewController alloc] init];
            [self.rootVC.navigationController pushViewController:feedBackVc animated:YES];
        }
            break;
        case STIMCommonTableViewCellDataTypeSetting: {
            STIMMySettingController *settingVc = [[STIMMySettingController alloc] init];
            [self.rootVC.navigationController pushViewController:settingVc animated:YES];
        }
            break;
        case STIMCommonTableViewCellDataTypeMessageNotification: {
            
        }
            break;
        case STIMCommonTableViewCellDataTypeMessageOnlineNotification: {
            
        }
            break;
        case STIMCommonTableViewCellDataTypeShowSignature: {
            
        }
            break;
        case STIMCommonTableViewCellDataTypeServiceMode: {
            STIMServiceStatusViewController *serverVc = [[STIMServiceStatusViewController alloc] init];
            [self.rootVC.navigationController pushViewController:serverVc animated:YES];
        }
            break;
        case STIMCommonTableViewCellDataTypeContactBlack: {
            /*
            STIMContactBlackVC *friendListVC = [[STIMContactBlackVC alloc] init];
            [self.rootVC.navigationController pushViewController:friendListVC animated:YES];
            */
        }
            break;
        case STIMCommonTableViewCellDataTypeDressUp: {
            STIMDressUpController * dressUpVC = [[STIMDressUpController alloc] init];
            [self.rootVC.navigationController pushViewController:dressUpVC animated:YES];
        }
            break;
        case STIMCommonTableViewCellDataTypeSearchHistory: {
            STIMWebView *webView = [[STIMWebView alloc] init];
            [webView setUrl:[NSString stringWithFormat:@"%@/lookback/main_controller.php", [[STIMKit sharedInstance] qimNav_InnerFileHttpHost]]];
            //@"https://qim.qunar.com/lookback/main_controller.php"];
            [self.rootVC.navigationController pushViewController:webView animated:YES];
        }
            break;
        case STIMCommonTableViewCellDataTypeClearSessionList: {
            UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:[NSBundle stimDB_localizedStringForKey:@"Reminder"] message:@"将要删掉当前用户的所有消息，是否继续？" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[NSBundle stimDB_localizedStringForKey:@"cancel"] style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:[NSBundle stimDB_localizedStringForKey:@"ok"] style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [[STIMKit sharedInstance] clearAllNoRead];
                [[STIMKit sharedInstance] deleteSessionList];
            }];
            [alertVc addAction:okAction];
            [alertVc addAction:cancelAction];
            [self.rootVC.navigationController presentViewController:alertVc animated:YES completion:nil];
        }
            break;
        case STIMCommonTableViewCellDataTypeGroupName: {
            STIMGroupChangeNameVC *changeNameVC = [[STIMGroupChangeNameVC alloc] init];
            [changeNameVC setGroupId:self.groupModel.groupId];
            [changeNameVC setGroupName:self.groupModel.groupName];
            [self.rootVC.navigationController pushViewController:changeNameVC animated:YES];
        }
            break;
        case STIMCommonTableViewCellDataTypeGroupTopic: {
            STIMGroupChangeTopicVC *changeTopicVC = [[STIMGroupChangeTopicVC alloc] init];
            [changeTopicVC setGroupId:self.groupModel.groupId];
            [changeTopicVC setGroupTopic:self.groupModel.groupAnnouncement];
            [self.rootVC.navigationController pushViewController:changeTopicVC animated:YES];
        }
            break;
        case STIMCommonTableViewCellDataTypeGroupQRcode: {
            [STIMFastEntrance showQRCodeWithQRId:self.groupModel.groupId withType:QRCodeType_GroupQR];
        }
            break;
        case STIMCommonTableViewCellDataTypeGroupLeave: {
            
        }
            break;
        case STIMCommonTableViewCellDataTypePrivacy: {
            STIMFriendSettingViewController *settingVC = [[STIMFriendSettingViewController alloc] init];
            [settingVC setOldNavHidden:self.rootVC.navigationController.navigationBarHidden];
            [self.rootVC.navigationController pushViewController:settingVC animated:YES];
        }
            break;
        case STIMCommonTableViewCellDataTypeGeneral: {
            
        }
            break;
        case STIMCommonTableViewCellDataTypeUpdateConfig: {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [[STIMKit sharedInstance] checkClientConfig];
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"Reminder"] message:@"配置更新完成，建议重启客户端进行查看！" delegate:nil cancelButtonTitle:[NSBundle stimDB_localizedStringForKey:@"Confirm"] otherButtonTitles:nil];
                    [alertView show];
                });
            });
        }
            break;
        case STIMCommonTableViewCellDataTypeClearCache: {
            [[STIMDataController getInstance] removeAllImage];
            [[STIMDataController getInstance] clearLogFiles];
        }
            break;
        case STIMCommonTableViewCellDataTypeMconfig: {
            NSString *linkUrl = [NSString stringWithFormat:@"%@?u=%@&d=%@&navBarBg=208EF2", [[STIMKit sharedInstance] qimNav_Mconfig], [STIMKit getLastUserName], [[STIMKit sharedInstance] getDomain]];
            STIMWebView *webView = [[STIMWebView alloc] init];
            [webView setUrl:linkUrl];
            [self.rootVC.navigationController pushViewController:webView animated:YES];
        }
            break;
        case STIMCommonTableViewCellDataTypeAbout: {
            STIMAboutVC *aboutVc = [[STIMAboutVC alloc] init];
            [self.rootVC.navigationController pushViewController:aboutVc animated:YES];
        }
            break;
        case STIMCommonTableViewCellDataTypeLogout: {
            [STIMFastEntrance signOut];
        }
            break;
        default:
            break;
    }
}

#pragma mark - DataSource

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle = [self.dataSourceTitle objectAtIndex:section];
    if (sectionTitle == nil) {
        return nil;
    }
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(16, 10, [UIScreen mainScreen].bounds.size.width - 10, 17);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithRed:97/255.0 green:97/255.0 blue:97/255.0 alpha:1/1.0];
    label.shadowOffset = CGSizeMake(-1.0, 1.0);
    label.font = [UIFont systemFontOfSize:12];
    label.text = sectionTitle;
    
    UIView *view = [[UIView alloc] init];
    [view addSubview:label];
    
    return view;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.dataSourceTitle objectAtIndex:section];
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource[section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    STIMCommonTableViewCellData *cellData = self.dataSource[indexPath.section][indexPath.row];
    switch (cellData.cellDataType) {
        case STIMCommonTableViewCellDataTypeBlankLines: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellData.title];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellData.title];
            }
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width);
            cell.contentView.backgroundColor = [UIColor stimDB_colorWithHex:0xf5f5f5 alpha:1.0];
            return cell;
        }
            break;
        case STIMCommonTableViewCellDataTypeMine: {
            STIMCommonUserInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellData.title];
            if (!cell) {
                cell = [[STIMCommonUserInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellData.title];
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//            cell.avatarImage.image = [[STIMKit sharedInstance] getUserHeaderImageByUserId:self.model.ID];
            [cell.avatarImage stimDB_setImageWithJid:self.model.ID];
            [cell setAccessibilityIdentifier:@"STIMCommonTableViewCellDataTypeMine"];
            cell.nickNameLabel.text = self.model.name;
            cell.signatureLabel.text = self.model.personalSignature;
            cell.showQRCode = YES;
            return cell;
        }
            break;
        case STIMCommonTableViewCellDataTypeMessageNotification:
        case STIMCommonTableViewCellDataTypeMessageOnlineNotification:
        case STIMCommonTableViewCellDataTypeShowSignature:
        case STIMCommonTableViewCellDataTypeGroupPush:
        case STIMCommonTableViewCellDataTypeMessageAlertSound:
        case STIMCommonTableViewCellDataTypeMessageVibrate:
        case STIMCommonTableViewCellDataTypeMessageShowPreviewText: {
            STIMCommonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellData.title];
            if (!cell) {
                cell = [STIMCommonTableViewCell cellWithStyle:kSTIMCommonTableViewCellStyleValueLeft reuseIdentifier:cellData.title];
            }
            cell.textLabel.text = cellData.title;
            cell.textLabel.textColor = [UIColor qtalkTextBlackColor];
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:[[STIMCommonFont sharedInstance] currentFontSize] - 4];
            cell.accessoryType_LL = kSTIMCommonTableViewCellAccessorySwitch;
            BOOL switchOn = [self getSwitchOnWithType:cellData.cellDataType];
            [cell setSwitchOn:switchOn animated:NO];
            cell.tag = cellData.cellDataType;
            [cell addSwitchTarget:self tag:cellData.cellDataType action:@selector(switchActions:) forControlEvents:UIControlEventValueChanged];
            return cell;
        }
            break;
        case STIMCommonTableViewCellDataTypeSearchHistory: {
            STIMCommonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellData.title];
            if (!cell) {
                cell = [STIMCommonTableViewCell cellWithStyle:kSTIMCommonTableViewCellStyleValueLeft reuseIdentifier:cellData.title];
            }
            [cell setAccessibilityIdentifier:cellData.title];
            cell.textLabel.text = cellData.title;
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:[[STIMCommonFont sharedInstance] currentFontSize] - 4];
            cell.textLabel.textColor = [UIColor stimDB_colorWithHex:0x03A9F4 alpha:1.0];
            return cell;
        }
            break;
        case STIMCommonTableViewCellDataTypeClearSessionList: {
            STIMCommonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellData.title];
            if (!cell) {
                cell = [STIMCommonTableViewCell cellWithStyle:kSTIMCommonTableViewCellStyleValueLeft reuseIdentifier:cellData.title];
            }
            [cell setAccessibilityIdentifier:cellData.title];
            cell.textLabel.text = cellData.title;
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:[[STIMCommonFont sharedInstance] currentFontSize] - 4];
            cell.textLabel.textColor = [UIColor colorWithRed:251/255.0 green:70/255.0 blue:86/255.0 alpha:1/1.0];
            return cell;
        }
            break;
        case STIMCommonTableViewCellDataTypeClearCache: {
            STIMCommonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellData.title];
            if (!cell) {
                cell = [STIMCommonTableViewCell cellWithStyle:kSTIMCommonTableViewCellStyleValue1 reuseIdentifier:cellData.title];
            }
            [cell setAccessibilityIdentifier:cellData.title];
            cell.accessoryType_LL = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = cellData.title;
            long long totalSize = [[STIMDataController getInstance] sizeofImagePath];
            NSString *str = [[STIMDataController getInstance] transfromTotalSize:totalSize];
            cell.detailTextLabel.text = str;
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:[[STIMCommonFont sharedInstance] currentFontSize] - 4];
            cell.textLabel.textColor = [UIColor qtalkTextBlackColor];
            return cell;
        }
            break;
        case STIMCommonTableViewCellDataTypeLogout: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellData.title];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellData.title];
            }
            [cell removeAllSubviews];
            [cell setAccessibilityIdentifier:cellData.title];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, cell.height)];
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont fontWithName:FONT_NAME size:[[STIMCommonFont sharedInstance] currentFontSize] - 4];
            label.textColor = [UIColor colorWithRed:251/255.0 green:70/255.0 blue:86/255.0 alpha:1/1.0];
            [label setText:[NSBundle stimDB_localizedStringForKey:@"Setting_tab_Logout"]];
            [cell addSubview:label];
            return cell;
        }
            break;
        case STIMCommonTableViewCellDataTypeGroupName: {
            static NSString *cellIdentifier = @"GroupName cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
                [cell.textLabel setText:@"群名称"];
                
                STIMMenuView * menuView = [[STIMMenuView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
                menuView.tag = 1000;
                [cell.contentView addSubview:menuView];
            }
            [cell setAccessibilityIdentifier:@"GroupName"];
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:FONT_SIZE-4];
            cell.textLabel.textColor = [UIColor qtalkTextBlackColor];
            cell.detailTextLabel.font = [UIFont fontWithName:FONT_NAME size:FONT_SIZE-4];
            cell.detailTextLabel.textColor = [UIColor qtalkTextLightColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            NSString * groupName = self.groupModel.groupName;
            cell.detailTextLabel.text = groupName?groupName:@"设置群名称";
            
            [(STIMMenuView * )[cell.contentView viewWithTag:1000] setCoprText:groupName];
            
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:[[STIMCommonFont sharedInstance] currentFontSize] - 4];
            cell.detailTextLabel.font = [UIFont fontWithName:FONT_NAME size:[[STIMCommonFont sharedInstance] currentFontSize] - 4];
            
            return cell;
        }
            break;
        case STIMCommonTableViewCellDataTypeGroupTopic: {
            static NSString *cellIdentifier = @"groupAnnouncement cell";
            STIMCommonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[STIMCommonTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
                [cell.textLabel setText:[NSBundle stimDB_localizedStringForKey:@"Group Notice"]];
                
                STIMMenuView * menuView = [[STIMMenuView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
                menuView.tag = 1000;
                [cell.contentView addSubview:menuView];
            }
            [cell setAccessibilityIdentifier:@"groupAnnouncement"];
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:FONT_SIZE-4];
            cell.textLabel.textColor = [UIColor qtalkTextBlackColor];
            cell.detailTextLabel.font = [UIFont fontWithName:FONT_NAME size:FONT_SIZE-4];
            cell.detailTextLabel.textColor = [UIColor qtalkTextLightColor];
            cell.accessoryType_LL = UITableViewCellAccessoryDisclosureIndicator;
            NSString * groupAnnouncement = self.groupModel.groupAnnouncement;
            cell.detailTextLabel.text = groupAnnouncement?groupAnnouncement:@"未设置";
            
            [(STIMMenuView * )[cell.contentView viewWithTag:1000] setCoprText:groupAnnouncement];
            
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:[[STIMCommonFont sharedInstance] currentFontSize] - 4];
            cell.detailTextLabel.font = [UIFont fontWithName:FONT_NAME size:[[STIMCommonFont sharedInstance] currentFontSize] - 4];
            
            return cell;
        }
            break;
        case STIMCommonTableViewCellDataTypeGroupQRcode: {
            static NSString *cellIdentifier = @"MyQrcode cell";
            STIMCommonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [STIMCommonTableViewCell cellWithStyle:kSTIMCommonTableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
            }
            [cell setAccessibilityIdentifier:@"MyQrcode"];
            cell.accessoryType_LL = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = [NSBundle stimDB_localizedStringForKey:@"Group QR Code"];
            cell.detailTextLabel.font = [UIFont fontWithName:@"Qtalk" size:24];
            cell.detailTextLabel.text = @"\U0000f10d";
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:[[STIMCommonFont sharedInstance] currentFontSize] - 4];
            cell.textLabel.textColor = [UIColor qtalkTextBlackColor];
            return cell;
        }
            break;
        case STIMCommonTableViewCellDataTypeGroupLeave: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellData.title];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellData.title];
            }
            [cell removeAllSubviews];
            [cell setAccessibilityIdentifier:cellData.title];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, cell.height)];
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont fontWithName:FONT_NAME size:[[STIMCommonFont sharedInstance] currentFontSize] - 4];
            label.textColor = [UIColor colorWithRed:251/255.0 green:70/255.0 blue:86/255.0 alpha:1/1.0];
            [label setText:@"删除并退出"];
            [cell addSubview:label];
            return cell;
        }
            break;
        default: {
            STIMCommonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellData.title];
            if (!cell) {
                if (cellData.icon) {
                    cell = [STIMCommonTableViewCell cellWithStyle:kSTIMCommonTableViewCellStyleDefault reuseIdentifier:cellData.title];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

                    cell.imageView.image = cellData.icon;
                } else {
                    cell = [STIMCommonTableViewCell cellWithStyle:kSTIMCommonTableViewCellStyleValueLeft reuseIdentifier:cellData.title];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
            }
            [cell setAccessibilityIdentifier:cellData.title];
            cell.textLabel.text = cellData.title;
            cell.textLabel.font = [UIFont fontWithName:FONT_NAME size:[[STIMCommonFont sharedInstance] currentFontSize] - 4];
            cell.textLabel.textColor = [UIColor qtalkTextBlackColor];
            return cell;
        }
            break;
    }
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EmptyCell"];
}

- (BOOL)getSwitchOnWithType:(STIMCommonTableViewCellDataType)type {
    BOOL switchOn = NO;
    switch (type) {
        case STIMCommonTableViewCellDataTypeMessageNotification: {
            switchOn = [[STIMKit sharedInstance] isNewMsgNotify];
        }
            break;
        case STIMCommonTableViewCellDataTypeMessageOnlineNotification: {
            BOOL state = [[STIMKit sharedInstance] getLocalMsgNotifySettingWithIndex:STIMMSGSETTINGPUSH_ONLINE];

            switchOn = state;
        }
            break;
        case STIMCommonTableViewCellDataTypeShowSignature: {
            switchOn = [[STIMKit sharedInstance] moodshow];
        }
            break;
        case STIMCommonTableViewCellDataTypeGroupPush: {
            switchOn = [[STIMKit sharedInstance] groupPushState:self.groupModel.groupId];
        }
            break;
        default: {
            switchOn = NO;
        }
            break;
    }
    return switchOn;
}

- (void)switchActions:(UISwitch *)sender {
    switch (sender.tag) {
        case STIMCommonTableViewCellDataTypeMessageNotification: {
            [[STIMKit sharedInstance] setNewMsgNotify:sender.on];
        }
            break;
        case STIMCommonTableViewCellDataTypeMessageOnlineNotification: {
            BOOL success = [[STIMKit sharedInstance] setMsgNotifySettingWithIndex:STIMMSGSETTINGPUSH_ONLINE WithSwitchOn:sender.on];
            if (!success) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSBundle stimDB_localizedStringForKey:@"Reminder"] message:[NSBundle stimDB_localizedStringForKey:@"Failed to switch the setting"]
                                                                   delegate:self
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:[NSBundle stimDB_localizedStringForKey:@"Confirm"], nil];
                
                [alertView show];
                [sender setOn:!sender.on animated:YES];
            }
        }
            break;
        case STIMCommonTableViewCellDataTypeShowSignature: {
            [[STIMKit sharedInstance] setMoodshow:sender.on];
        }
            break;
        case STIMCommonTableViewCellDataTypeGroupPush: {
            [[STIMKit sharedInstance] updatePushState:self.groupModel.groupId withOn:sender.on];
        }
            break;
        default:
            break;
    }
}

@end
