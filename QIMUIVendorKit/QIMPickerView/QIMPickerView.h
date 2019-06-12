//
//  QIMPickerView.h
//  QIMPickerView
//
//  Created by Madjid Mahdjoubi on 6/5/13.
//  Copyright (c) 2013 GG. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const QIMMMbackgroundColor;
extern NSString * const QIMMMtextColor;
extern NSString * const QIMMMtoolbarColor;
extern NSString * const QIMMMbuttonColor;
extern NSString * const QIMMMfont;
extern NSString * const QIMMMvalueY;
extern NSString * const QIMMMselectedObject;
extern NSString * const QIMMMtoolbarBackgroundImage;

@interface QIMPickerView: UIView 

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
