//
//  RCTConvert+UIAction.m
//  react-native-menu
//
//  Created by Jesse Katsumata on 11/3/20.
//

#import <React/RCTConvert.h>

@implementation RCTConvert (UIAction)

+ (UIAction *)UIAction:(id)json
{
  NSDictionary<NSString *, id> *details = [self NSDictionary:json];
  
    NSString* title = [RCTConvert NSString:details[@"title"]];
    UIImage* image = [RCTConvert UIImage:details[@"image"]];
    
    UIAction *action = [UIAction actionWithTitle:title image:image identifier:nil handler:^(UIAction* action){}];
    
  return action;
}
@end
