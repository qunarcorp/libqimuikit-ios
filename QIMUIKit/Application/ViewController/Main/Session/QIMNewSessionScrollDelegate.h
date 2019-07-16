//
//  QIMNewSessionScrollDelegate.h
//  QIMUIKit
//
//  Created by lilu on 2019/6/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol QIMNewSessionScrollDelegate <NSObject>

- (void)qimDeleteSession:(NSIndexPath *)indexPath;
- (void)qimStickySession:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
