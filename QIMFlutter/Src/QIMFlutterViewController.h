//
//  QIMFlutterViewController.h
//  QIMUIKit
//
//  Created by lilu on 2019/9/20.
//

#import <UIKit/UIKit.h>
#if __has_include(<Flutter/Flutter.h>)
#import <Flutter/Flutter.h>


NS_ASSUME_NONNULL_BEGIN

@interface QIMFlutterViewController : FlutterViewController

@end

NS_ASSUME_NONNULL_END

#else


NS_ASSUME_NONNULL_BEGIN

@interface QIMFlutterViewController : UIViewController

@end

NS_ASSUME_NONNULL_END

#endif
