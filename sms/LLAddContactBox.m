//
//  LLAddContactBox.m
//  sms
//
//  Created by Luke Lau on 8/22/12.
//  Copyright (c) 2012 ioslukelau@gmail.com All rights reserved.
//

#import "LLAddContactBox.h"
#import <Foundation/NSString.h>
#import <QuartzCore/QuartzCore.h> 
#import <AddressBook/ABAddressBook.h>
#import <AddressBook/AddressBook.h>

@interface LLAddContactBox()<UITextFieldDelegate>
@property (nonatomic,retain) LLContactView *selectedContactView;
@end

#define LLAddContactBox_LineHeight 30
#define LLAddContactBox_FontSize 15
#define LLAddContactBox_ScrollViewMaxHeight 150
#define LLAddContactBox_TextFieldSpace 5

#define LL_ContactColor [UIColor colorWithRed:247/255.0 green:214.0/255.0 blue:165.0/255.0 alpha:1.0]
#define LL_ContactHighlightedColor [UIColor colorWithRed:225/255.0 green:158.0/255.0 blue:65.0/255.0 alpha:1.0]

// 【收件人】三个字左边的距离
#define LL_RecieveLabelWidth 60
#define LL_Left_Space 20
#define LL_Add_CenterX 320 - 20 - 15

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
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(LL_Left_Space, 0, LL_RecieveLabelWidth, LLAddContactBox_LineHeight)];
    label.text = @"收件人：";
    label.font = [UIFont systemFontOfSize:LLAddContactBox_FontSize];
    label.textColor = [UIColor colorWithRed:110/255.0 green:110.0/255.0 blue:110.0/255.0 alpha:1.0];
    [box.container addSubview:label];
    [label release];
    UITextField *textField = [[[UITextField alloc] initWithFrame:CGRectMake(LL_RecieveLabelWidth+LL_Left_Space, LLAddContactBox_TextFieldSpace, 100, LLAddContactBox_LineHeight - LLAddContactBox_TextFieldSpace*2)] autorelease];
    box.contactTextField = textField;
    box.contactTextField.delegate = box;
    [box.container addSubview:box.contactTextField];
    box.contactTextField.font = [UIFont systemFontOfSize:LLAddContactBox_FontSize];
    
    box.addContectButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [box.addContectButton addTarget:box action:@selector(onAddContact) forControlEvents:UIControlEventTouchUpInside];
    [box.container addSubview:box.addContectButton];
    box.addContectButton.center = CGPointMake(LL_Add_CenterX, LLAddContactBox_LineHeight/2);
    
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
        LLContactView *newContact = [LLContactView instance:mobile]; 
        newContact.delegate = self;
        [self.contactList addObject:newContact];
        
        [self placeUIElement];
        textField.text = @" ";
    }
    return YES;
}

#pragma mark - Button Event

- (void)onContactButton:(LLContactView *)sender
{
    [self.selectedContactView.contactButton setBackgroundColor:LL_ContactColor];
    self.selectedContactView.contactButton.titleLabel.textColor = [UIColor blackColor];
    [sender.contactButton setBackgroundColor:LL_ContactHighlightedColor];
    self.selectedContactView = sender;
}

- (void)onAddContact 
{
    [self ReadAllPeoples];
}

#pragma mark - 读取联系人的库
//读取所有联系人
-(void)ReadAllPeoples
{	
	//取得本地通信录名柄
	ABAddressBookRef tmpAddressBook = ABAddressBookCreate();
	//取得本地所有联系人记录
	NSArray* tmpPeoples = (NSArray*)ABAddressBookCopyArrayOfAllPeople(tmpAddressBook);
	for(id tmpPerson in tmpPeoples) 
	{		
		//获取的联系人单一属性:First name
		NSString* tmpFirstName = (NSString*)ABRecordCopyValue(tmpPerson, kABPersonFirstNameProperty);
		NSLog(@"First name:%@", tmpFirstName);
		[tmpFirstName release];
		//获取的联系人单一属性:Last name
		NSString* tmpLastName = (NSString*)ABRecordCopyValue(tmpPerson, kABPersonLastNameProperty); 
		NSLog(@"Last name:%@", tmpLastName);
		[tmpLastName release];
		//获取的联系人单一属性:Nickname
		NSString* tmpNickname = (NSString*)ABRecordCopyValue(tmpPerson, kABPersonNicknameProperty);  
		NSLog(@"Nickname:%@", tmpNickname);
		[tmpNickname release];
		//获取的联系人单一属性:Company name
		NSString* tmpCompanyname = (NSString*)ABRecordCopyValue(tmpPerson, kABPersonOrganizationProperty); 
		NSLog(@"Company name:%@", tmpCompanyname);
		[tmpCompanyname release];
		//获取的联系人单一属性:Job Title
		NSString* tmpJobTitle= (NSString*)ABRecordCopyValue(tmpPerson, kABPersonJobTitleProperty); 
		NSLog(@"Job Title:%@", tmpJobTitle);
		[tmpJobTitle release];
		//获取的联系人单一属性:Department name
		NSString* tmpDepartmentName = (NSString*)ABRecordCopyValue(tmpPerson, kABPersonDepartmentProperty);
		NSLog(@"Department name:%@", tmpDepartmentName);
		[tmpDepartmentName release];
		
        /*
        //获取的联系人单一属性:Email(s)
		ABMultiValueRef tmpEmails = ABRecordCopyValue(tmpPerson, kABPersonEmailProperty);
		for(NSInteger j = 0; ABMultiValueGetCount(tmpEmails); j++) 
		{
			NSString* tmpEmailIndex = (NSString*)ABMultiValueCopyValueAtIndex(tmpEmails, j);
			NSLog(@"Emails%d:%@", j, tmpEmailIndex);
			[tmpEmailIndex release];
		}
		CFRelease(tmpEmails);
        */
        
        
		//获取的联系人单一属性:Birthday
		NSDate* tmpBirthday = (NSDate*)ABRecordCopyValue(tmpPerson, kABPersonBirthdayProperty);
		NSLog(@"Birthday:%@", tmpBirthday);	
		[tmpBirthday release];
		//获取的联系人单一属性:Note
		NSString* tmpNote = (NSString*)ABRecordCopyValue(tmpPerson, kABPersonNoteProperty);
		NSLog(@"Note:%@", tmpNote);	
		[tmpNote release];
		//获取的联系人单一属性:Generic phone number
		ABMultiValueRef tmpPhones = ABRecordCopyValue(tmpPerson, kABPersonPhoneProperty);
		for(NSInteger j = 0; j < ABMultiValueGetCount(tmpPhones); j++) 
		{
			NSString* tmpPhoneIndex = (NSString*)ABMultiValueCopyValueAtIndex(tmpPhones, j);
			NSLog(@"tmpPhoneIndex%d:%@", j, tmpPhoneIndex);
			[tmpPhoneIndex release];
		}
		CFRelease(tmpPhones);
	}
	//释放内存 
	[tmpPeoples release];
	CFRelease(tmpAddressBook);
}
#pragma mark - 重新排列节点
- (void)placeUIElement
{ 
    CGFloat lineWidthWhole = 320 - 2*LL_Left_Space; // 一行最大的空间
    CGFloat lineWidthLeft = lineWidthWhole-LL_RecieveLabelWidth; // 第一行
    CGFloat lineIndex = 0;
   
    for (LLContactView *contactView in self.contactList) {
        CGFloat width = contactView.frame.size.width;
        CGFloat offsetX = 0;
        
        if (width+6 > lineWidthLeft) {
            lineIndex ++;
            lineWidthLeft = lineWidthWhole;
        }
        
        //offsetX = lineWidthWhole-lineWidthLeft+width/2+3;
        offsetX = 320-lineWidthLeft-LL_Left_Space+width/2+3;
        lineWidthLeft -= width + 3;

        contactView.center = CGPointMake(offsetX, LLAddContactBox_LineHeight/2 + lineIndex*LLAddContactBox_LineHeight);
        [self.container addSubview:contactView];

    }
    
    if (lineWidthLeft < 70) {
        lineIndex++;    
        lineWidthLeft = lineWidthWhole;
    }
    
    self.contactTextField.frame = CGRectMake(lineWidthWhole-lineWidthLeft+LL_Left_Space, LLAddContactBox_LineHeight*lineIndex+LLAddContactBox_TextFieldSpace, lineWidthLeft - 50, LLAddContactBox_LineHeight-LLAddContactBox_TextFieldSpace*2);
    
    self.addContectButton.center = CGPointMake(LL_Add_CenterX, LLAddContactBox_LineHeight/2 + LLAddContactBox_LineHeight*lineIndex);
    
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
@synthesize mobile;
@synthesize name;

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
            