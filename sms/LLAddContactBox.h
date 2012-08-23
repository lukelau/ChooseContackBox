//
//  LLAddContactBox.h
//  sms
//  类似短信添加联系人的输入框
//  Created by Luke Lau on 8/22/12.
//  Copyright (c) 2012 ioslukelau@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LLAddContactBox : NSObject

/**
 当联系人多行之后，需要上下滚动
 */
@property (nonatomic,retain) UIScrollView *container;

/**
 输入框
 */
@property (nonatomic,retain) UITextField *contactTextField;

@property (nonatomic,retain) NSMutableArray *contactList;

/**
 添加联系人的按钮
 */
@property (nonatomic,retain) UIButton *addContectButton;
+ (LLAddContactBox *)instance;


@end


@interface LLContactView : UIView
@property (nonatomic,retain) NSString *mobile;
@property (nonatomic,retain) NSString *name;


@property (nonatomic,retain) UIButton *contactButton;
@property (nonatomic,assign) id delegate;
+ (LLContactView *)instance:(NSString *)contactString;


@end
