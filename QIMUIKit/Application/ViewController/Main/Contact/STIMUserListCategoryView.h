//
//  STIMUserListCategoryView.h
//  STChatIphone
//
//  Created by 李海彬 on 2018/1/17.
//

#import "STIMCommonUIFramework.h"

typedef enum {
    UserListCategoryTypeNotRead,
    UserListCategoryTypeFriend,
    UserListCategoryTypeGroup,
    UserListCategoryTypePublicNumber,
    UserListCategoryTypeOrganizational,
} UserListCategoryType;

@protocol STIMUserListCategoryViewDelegate <NSObject>

- (void)didSelectUserListCategoryRowAtCategoryType:(UserListCategoryType)categoryType;

@end

@interface STIMUserListCategoryView : UIView

@property (nonatomic, weak) id <STIMUserListCategoryViewDelegate> categoryViewDelegate;

- (instancetype)initWithFrame:(CGRect)frame WithCategoryList:(NSArray *)types;

- (void)reloadData;

@end
