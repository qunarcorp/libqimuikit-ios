//
//  STIMWorkCommentTextView.m
//  STIMUIKit
//
//  Created by lihaibin.li on 2019/1/10.
//  Copyright © 2019 STIM. All rights reserved.
//

#import "STIMWorkCommentTextView.h"

@implementation STIMWorkCommentTextView

- (CGRect)textRectForBounds:(CGRect)bounds {
    
    return CGRectMake(bounds.origin.x + 18, bounds.origin.y, bounds.size.width - 36, bounds.size.height);
}

@end
