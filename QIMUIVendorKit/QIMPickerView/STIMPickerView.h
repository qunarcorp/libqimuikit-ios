//
//  STIMPickerView.h
//  STIMPickerView
//
//  Created by Madjid Mahdjoubi on 6/5/13.
//  Copyright (c) 2013 GG. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const STIMMMbackgroundColor;
extern NSString * const STIMMMtextColor;
extern NSString * const STIMMMtoolbarColor;
extern NSString * const STIMMMbuttonColor;
extern NSString * const STIMMMfont;
extern NSString * const STIMMMvalueY;
extern NSString * const STIMMMselectedObject;
extern NSString * const STIMMMtoolbarBackgroundImage;

@interface STIMPickerView: UIView 

+(void)showPickerViewInView: (UIView *)view
                withStrings: (NSArray *)strings
                withOptions: (NSDictionary *)options
                 completion: (void(^)(NSString *selectedString))completion;

+(void)showPickerViewInView: (UIView *)view
                withObjects: (NSArray *)objects
                withOptions: (NSDictionary *)options
    objectToStringConverter: (NSString *(^)(id object))converter
       completion: (void(^)(id selectedObject))completion;

+(void)dismissWithCompletion: (void(^)(NSString *))completion;

@end
