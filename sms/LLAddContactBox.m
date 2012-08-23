//
//  LLAddContactBox.m
//  sms
//
//  Created by Luke Lau on 8/22/12.
//  Copyright (c) 2012 ioslukelau@gmail.com . All rights reserved.
//

#import "LLAddContactBox.h"
#import <Foundation/NSString.h>
#import <QuartzCore/QuartzCore.h> 

@interface LLAddContactBox()<UITextFieldDelegate>
@property (nonatomic,retain) LLContactView *selectedContactView;
@end

#define LLAddContactBox_LineHeight 30
#define LLAddContactBox_FontSize 15
#define LLAddContactBox_ScrollViewMaxHeight 150
#define LLAddContactBox_TextFieldSpace 5

#define LL_ContactColor [UIColor colorWithRed:247/255.0 green:214.0/255.0 blue:165.0/255.0 alpha:1.0]
#define LL_ContactHighlightedColor [UIColor colorWithRed:225/255.0 green:158.0/255.0 blue:65.0/255.0 alpha:1.0]
@implementation LLAddContactBox
@synthesize container;
@synthesize contactTextField;
@synthesize addContectButton;
@synthesize contactList;
@synthesize selectedContactView;

+ (LLAddContactBox *)instance {
    LLAddContactBox *box = [[LLAddContactBox alloc] init];
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, LLAddContactBox_LineHeight)];
    box.container = scroll;
    [scroll release];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 60, LLAddContactBox_LineHeight)];
    label.text = @"收件人：";
    label.font = [UIFont systemFontOfSize:LLAddContactBox_FontSize];
    label.textColor = [UIColor colorWithRed:110/255.0 green:110.0/255.0 blue:110.0/255.0 alpha:1.0];
    [box.container addSubview:label];
    [label release];
    UITextField *textField = [[[UITextField alloc] initWithFrame:CGRectMake(60, LLAddContactBox_TextFieldSpace, 200, LLAddContactBox_LineHeight - LLAddContactBox_TextFieldSpace*2)] autorelease];
    box.contactTextField = textField;
    box.contactTextField.delegate = box;
    [box.container addSubview:box.contactTextField];
    box.contactTextField.font = [UIFont systemFontOfSize:LLAddContactBox_FontSize];
    box.contactTextField.center = CGPointMake(160, LLAddContactBox_LineHeight/2);
    
    box.addContectButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [box.container addSubview:box.addContectButton];
    box.addContectButton.center = CGPointMake(300, LLAddContactBox_LineHeight/2);
    
    box.contactList = [[NSMutableArray alloc] initWithCapacity:1];
    return box;
}

- (void)dealloc {
    [contactTextField release];
    [addContectButton release];
    [container release];
    [selectedContactView release];
    [super dealloc];
}
#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField.text compare:@" "] == NSOrderedSame && [string compare:@""] == NSOrderedSame) {
        if ([self.contactList count] > 0) {
            if (self.selectedContactView) {
                [self.selectedContactView removeFromSuperview];
                [self.contactList removeObject:self.selectedContactView];
                [self placeUIElement];
                self.selectedContactView = nil;
            }
            else {
                [self onContactButton:[self.contactList lastObject]];
            }
            
        }
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *mobile = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([mobile length]>0) {
       // LLContact *newContact = [[[LLContact alloc] init] autorelease];
        
       // newContact.mobile = mobile;
      //  newContact.contactView = [LLContactView instance:mobile];   
        LLContactView *newContact = [LLContactView instance:mobile]; 
        newContact.delegate = self;
        [self.contactList addObject:newContact];
        
        [self placeUIElement];
        textField.text = @" ";
    }
    return YES;
}

#pragma mark -

- (void)onContactButton:(LLContactView *)sender
{
    [self.selectedContactView.contactButton setBackgroundColor:LL_ContactColor];
    [sender.contactButton setBackgroundColor:LL_ContactHighlightedColor];
    self.selectedContactView = sender;
}

#pragma mark - 重新排列节点
- (void)placeUIElement
{
    CGFloat lineWidthLeft = 320-60-10; // 第一行
    CGFloat lineIndex = 0;
    
    for (LLContactView *contactView in self.contactList) {
        CGFloat width = contactView.frame.size.width;
        CGFloat offsetX = 0;
        
        if (width+6 > lineWidthLeft) {
            lineIndex ++;
            lineWidthLeft = 310;
        }

        
        offsetX = 310-lineWidthLeft+width/2+3;
        lineWidthLeft -= width + 3;

        
        contactView.center = CGPointMake(offsetX,  LLAddContactBox_LineHeight/2 + lineIndex*LLAddContactBox_LineHeight);
        [self.container addSubview:contactView];

    }
    
    if (lineWidthLeft < 70) {
        lineIndex++;    
        lineWidthLeft = 310;
    }
 
    
    self.contactTextField.center = CGPointMake(300 - lineWidthLeft/2, LLAddContactBox_LineHeight/2 + LLAddContactBox_LineHeight*lineIndex);
    self.contactTextField.frame = CGRectMake(310-lineWidthLeft, LLAddContactBox_LineHeight*lineIndex+LLAddContactBox_TextFieldSpace, lineWidthLeft - 50, LLAddContactBox_LineHeight-LLAddContactBox_TextFieldSpace*2);
    
    self.addContectButton.center = CGPointMake(300, LLAddContactBox_LineHeight/2 + LLAddContactBox_LineHeight*lineIndex);
    
    CGFloat contentSizeHeight = (lineIndex+1) * LLAddContactBox_LineHeight;
    self.container.contentSize = CGSizeMake(320, contentSizeHeight);
    if (contentSizeHeight > LLAddContactBox_ScrollViewMaxHeight) {
        contentSizeHeight = LLAddContactBox_ScrollViewMaxHeight;
    } 
    self.container.frame = CGRectMake(0, 0, 320, contentSizeHeight);
}

@end


@implementation LLContactView
@synthesize contactButton;
@synthesize delegate;

+ (LLContactView *)instance:(NSString *)contactString
{
#define LLContactView_Text_Space 5
    CGSize textSize = [contactString sizeWithFont:[UIFont systemFontOfSize:LLAddContactBox_FontSize] constrainedToSize:CGSizeMake(280, LLAddContactBox_LineHeight)  lineBreakMode:UILineBreakModeWordWrap];
    
    LLContactView *contactView = [[[LLContactView alloc] initWithFrame:CGRectMake(0, 0, textSize.width + LLContactView_Text_Space*2, LLAddContactBox_LineHeight)] autorelease];
     
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];//UIButtonTypeRoundedRect
    button.layer.cornerRadius = 8;
    button.backgroundColor = LL_ContactColor;
    button.frame = CGRectMake(0, 3, textSize.width + LLContactView_Text_Space*2, LLAddContactBox_LineHeight-6);
    [button setTitle:contactString forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:LLAddContactBox_FontSize];
    button.titleLabel.textColor = [UIColor blackColor];
    [button addTarget:contactView action:@selector(onContactButton) forControlEvents:UIControlEventTouchUpInside];
    [contactView addSubview:button];
    contactView.contactButton = button;
    
    return contactView;
}

/**
 点击了联系人
 */
- (void)onContactButton {
    
    if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(onContactButton:)]) {
        [self.delegate onContactButton:self];
    }
        
}

- (void)dealloc {
    [contactButton release];
    self.delegate = nil;
    [super dealloc];
}
@end
            

@implementation LLContact
@synthesize mobile;
@synthesize name;
@synthesize contactView;

- (void)dealloc {
    [mobile release];
    [name release];
    [contactView release];
    [super dealloc];
}
@end