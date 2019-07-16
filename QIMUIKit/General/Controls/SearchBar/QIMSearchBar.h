//
//  QIMSearchBar.h
//  QIMUIKit
//
//  Created by lilu on 2019/4/25.
//  Copyright © 2019 QIM. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol QIMSearchBarDelegate <NSObject>

- (void)qim_searchBarBecomeFirstResponder;

@end

@interface QIMSearchBar : UIView

@property (nonatomic, weak) id <QIMSearchBarDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
