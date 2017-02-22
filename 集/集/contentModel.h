//
//  contentModel.h
//  基础数据库
//
//  Created by EssIOS on 16/10/24.
//  Copyright © 2016年 ljh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface contentModel : NSObject

@property(nonatomic,strong)NSString *content;
@property(nonatomic,strong)NSString *date;
@property(nonatomic,strong)NSString *imgpath;
@property(nonatomic,strong)NSString *longitude;
@property(nonatomic,strong)NSString *latitude;
@property (nonatomic,strong)NSString * userID;

@end
