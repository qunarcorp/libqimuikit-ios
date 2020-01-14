//
//  STIMSearchBar.h
//  STIMUIKit
//
//  Created by lihaibin.li on 2019/4/25.
//  Copyright © 2019 STIM. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol STIMSearchBarDelegate <NSObject>

- (void)stimDB_searchBarBecomeFirstResponder;

@end

@interface STIMSearchBar : UIView

@property (nonatomic, weak) id <STIMSearchBarDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
