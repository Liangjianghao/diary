//
//  DBManager.h
//  基础数据库
//
//  Created by EssIOS on 16/10/24.
//  Copyright © 2016年 ljh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "contentModel.h"
@interface DBManager : NSObject


+(NSString *)getBasePath;
+(FMDatabase * )getBaseDB;
+ (void)creatBaseDataTable;
+ (NSMutableArray *)selectAllModel;
+ (void)keepDataWithDictionary:(NSDictionary *)dic withBlock:(void (^)(NSString *result))block;
+ (contentModel *)todayWithDate:(NSString *)date;

@end
