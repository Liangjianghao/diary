//
//  ViewController.m
//  集
//
//  Created by EssIOS on 16/11/22.
//  Copyright © 2016年 ljh. All rights reserved.
//

#import "ViewController.h"
#import "DBManager.h"
#import "contentModel.h"
#import "MBProgressHUD.h"

#define HEIGHT [UIScreen mainScreen].bounds.size.height
#define WIDTH [UIScreen mainScreen].bounds.size.width
#define kOFFSET_FOR_KEYBOARD 80.0


@interface ViewController ()<UITextViewDelegate,UITextFieldDelegate,UIScrollViewDelegate>
{
    NSMutableArray *dataArr;
    UIScrollView *mainScroll;
    contentModel *todayModel;
    UITextView *textV;
    NSString *todayDate;
    NSString *todayTime;
    NSString *tomorrowDate;
    NSString *userName;
    NSString *imgPath;
    MBProgressHUD *hud;
    UIButton *rightbtn;


}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSLog(@"%@",NSHomeDirectory());

    rightbtn=[UIButton buttonWithType:UIButtonTypeCustom];
    rightbtn.frame=CGRectMake(0, 0,40, 30);
    [rightbtn setTitle:@"保存" forState:UIControlStateNormal];
//    [rightbtn setTitleColor:[UIColor colorWithDisplayP3Red:21/255.0 green:126/255.0 blue:251/255.0 alpha:1] forState:UIControlStateNormal];
    [rightbtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    rightbtn.backgroundColor=[UIColor grayColor];
    [rightbtn setBackgroundImage:[UIImage imageNamed:@"保存"] forState:UIControlStateNormal];
    rightbtn.titleLabel.font=[UIFont systemFontOfSize:17];
    [rightbtn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:rightbtn];
    
//    self.navigationController.navigationBar.barTintColor=[UIColor colorWithDisplayP3Red:21/255.0 green:126/255.0 blue:251/255.0 alpha:1];
    
    [self loadData];
    [self uiConfig];
    self.view.backgroundColor=[UIColor whiteColor];

    self.tabBarItem.title=@"首页";
    
    self.automaticallyAdjustsScrollViewInsets=NO;
}
-(void)rightBtnClick:(UIButton *)btn
{
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // Set the label text.
    hud.label.text = @"保存数据中,请稍候...";
    NSString *content;
    if (todayModel.content) {
        UITextView *tv=[self.view viewWithTag:1001+dataArr.count-1];
        content=tv.text;
    }
    else
    {
        content=textV.text;
    }
    NSLog(@"%@",content);
    
    NSDictionary *contenDic=[NSDictionary dictionaryWithObjectsAndKeys:content,@"content",todayDate,@"date",todayTime,@"time",imgPath,@"imgpath",@"Longitude",@"Longitude",@"Latitude",@"Latitude",@"10101020",@"userID", nil];
    
    [DBManager keepDataWithDictionary:contenDic withBlock:^(NSString *result) {
        if ([result isEqualToString:@"success"]) {
            hud.label.text=@"保存成功";
            [hud hideAnimated:YES afterDelay:1];
            [self loadData];
            [self uiConfig];
            
        }
        else
        {
            hud.label.text=@"保存失败,请重试";
            [hud hideAnimated:YES afterDelay:2];
        }
    }];
}
-(void)loadData
{
    dataArr=[[NSMutableArray alloc]init];
    dataArr=[DBManager selectAllModel];
    
}
-(void)uiConfig
{
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    mainScroll=[[UIScrollView alloc]init];
    mainScroll.frame=CGRectMake(0, 64, WIDTH, HEIGHT);
    mainScroll.backgroundColor=[UIColor whiteColor];
    mainScroll.pagingEnabled=YES;
    mainScroll.delegate=self;
    [self.view addSubview:mainScroll];
    
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *date=[formatter stringFromDate:[NSDate date]];
    NSLog(@"date -->>%@",date);
    todayDate=date;

    
    NSLog(@"time %@",todayTime);
    tomorrowDate = [formatter stringFromDate:[NSDate dateWithTimeInterval:24*60*60 sinceDate:[NSDate date]]];//后一天

    [formatter setDateFormat:@"HH:mm:ss"];
    NSString *time=[formatter stringFromDate:[NSDate date]];
    todayTime=time;
    
    todayModel =[DBManager todayWithDate:date];

    [self nowViewConifg];

    [self beforeViewConifig];
}
-(void)nowViewConifg
{
    
    UIView *baseV=[[UIView alloc]init];
    baseV.frame=CGRectMake(10+WIDTH*dataArr.count, 10, WIDTH-20, HEIGHT-20-64);
    baseV.backgroundColor=[UIColor whiteColor];
    //圆角
    baseV.layer.cornerRadius=5;
    //        baseV.clipsToBounds=YES;
    //阴影:
    //        baseV.clipsToBounds=NO;
    baseV.layer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
    baseV.layer.shadowOffset = CGSizeMake(2,2);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3),这个跟shadowRadius配合使用
    baseV.layer.shadowOpacity = 0.8;//阴影透明度，默认0
    baseV.layer.shadowRadius = 4;
    [mainScroll addSubview:baseV];
    
    UIImageView *imgV=[[UIImageView alloc]init];
    imgV.frame=CGRectMake(5, 10, WIDTH-30, (WIDTH-30)*3/4.0);
    [imgV setImage:[UIImage imageNamed:@"375.png"]];
    [baseV addSubview:imgV];
    if (todayModel.content) {
        imgV.tag=102;
    }
    else
    {
        imgV.tag=101;
    }
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(takePhoto:)];
    [imgV addGestureRecognizer:tap];
    imgV.userInteractionEnabled=YES;
    
    
    UIView *bgView=[[UIView alloc]initWithFrame:CGRectMake(5,(WIDTH-30)*3/4.0+20, WIDTH-30, 150)];
    bgView.backgroundColor=[UIColor whiteColor];
    bgView.layer.shadowOffset = CGSizeMake(1, 1);
    bgView.layer.shadowRadius = 5.0;
    bgView.layer.shadowColor = [UIColor blackColor].CGColor;
    bgView.layer.shadowOpacity = 0.8;
    bgView.layer.cornerRadius=5;

    textV=[[UITextView alloc]init];
    textV.frame=CGRectMake(0,0, WIDTH-30, 150);
    textV.delegate=self;
    textV.backgroundColor=[UIColor whiteColor];
    textV.tag=2001;
    textV.textColor=[UIColor lightGrayColor];
    textV.font=[UIFont systemFontOfSize:17];
    [bgView addSubview:textV];
    
    [baseV addSubview:bgView];
    

    

    UILabel *timeLabel=[[UILabel alloc]init];
    timeLabel.frame=CGRectMake(10, HEIGHT-20-64-55, 100, 40);
    timeLabel.text=todayDate;
    timeLabel.textColor=[UIColor lightGrayColor];
    [baseV addSubview:timeLabel];
    
    
    UILabel *userLabel=[[UILabel alloc]init];
    userLabel.frame=CGRectMake(WIDTH-120, HEIGHT-20-64-55, 100, 40);
    userLabel.text=[NSString stringWithFormat:@"%@",todayTime];
    userLabel.textColor=[UIColor lightGrayColor];

    [baseV addSubview:userLabel];
    
    if (todayModel.content) {
        textV.text = @"明天还未到";
        timeLabel.text=tomorrowDate;

    }
    else
    {
        textV.text = @"添加文字记忆...";
        timeLabel.text=todayDate;

        
    }
    
}
-(void)beforeViewConifig
{
    
    if (todayModel.content) {
        [mainScroll setContentOffset:CGPointMake(WIDTH*(dataArr.count-1),0) animated:YES];
        mainScroll.contentSize=CGSizeMake(WIDTH*(dataArr.count), HEIGHT);
    }
    else
    {
        [mainScroll setContentOffset:CGPointMake(WIDTH*dataArr.count,0) animated:YES];
        mainScroll.contentSize=CGSizeMake(WIDTH*(dataArr.count+1), HEIGHT);
    }
    
    for (int i=0; i<dataArr.count; i++) {
        UIView *baseV=[[UIView alloc]init];
        baseV.frame=CGRectMake(10+WIDTH*i, 10, WIDTH-20, HEIGHT-20-64);
        baseV.backgroundColor=[UIColor whiteColor];
        //圆角
        baseV.layer.cornerRadius=5;
        //        baseV.clipsToBounds=YES;
        //阴影:
        //        baseV.clipsToBounds=NO;
        baseV.layer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
        baseV.layer.shadowOffset = CGSizeMake(2,2);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3),这个跟shadowRadius配合使用
        baseV.layer.shadowOpacity = 0.8;//阴影透明度，默认0
        baseV.layer.shadowRadius = 4;
        
        [mainScroll addSubview:baseV];
        
        UIImageView *imgV=[[UIImageView alloc]init];
        imgV.frame=CGRectMake(5, 10, WIDTH-30, (WIDTH-30)*3/4.0);
        UIImage *image=[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/Library/%@.jpg",NSHomeDirectory(),[dataArr[i] imgpath]]];
        if (image) {
            NSLog(@"image");
            [imgV setImage:image];
        }
        else
        {
            [imgV setImage:[UIImage imageNamed:@"376.png"]];
        }
        [baseV addSubview:imgV];
        
        UITextView *textView=[[UITextView alloc]init];
        textView.frame=CGRectMake(5, (WIDTH-30)*3/4.0+20, WIDTH-30, 150);
        textView.delegate=self;
        textView.backgroundColor=[UIColor groupTableViewBackgroundColor];
        textView.tag=1001+i;
        textView.text = [NSString stringWithFormat:@"%@",[dataArr[i] content]];
        textView.textColor = [UIColor lightGrayColor];
        textView.editable=NO;
        [baseV addSubview:textView];
        
        textView.textColor=[UIColor blackColor];
        textView.font=[UIFont systemFontOfSize:17];
        
        UILabel *timeLabel=[[UILabel alloc]init];
        timeLabel.frame=CGRectMake(10, HEIGHT-20-64-55, 100, 40);
        timeLabel.text=[NSString stringWithFormat:@"%@",[dataArr[i] date]];
        timeLabel.textColor=[UIColor lightGrayColor];
        [baseV addSubview:timeLabel];
        
        
        UILabel *userLabel=[[UILabel alloc]init];
        userLabel.frame=CGRectMake(WIDTH-120, HEIGHT-20-64-55, 100, 40);
        userLabel.text=[NSString stringWithFormat:@"%@",[dataArr[i] time]];
        userLabel.textColor=[UIColor lightGrayColor];
        
        [baseV addSubview:userLabel];
        
//        rightbtn.backgroundColor=[UIColor redColor];
        
        if (todayModel.content) {
            if (i==dataArr.count-1) {
                UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(takePhoto:)];
                [imgV addGestureRecognizer:tap];
                imgV.userInteractionEnabled=YES;
                imgV.tag=101;
                textView.editable=YES;
                UIImage *image=[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/Library/%@.jpg",NSHomeDirectory(),[dataArr[i] imgpath]]];
                if (image) {
                    NSLog(@"image");
                    [imgV setImage:image];
                }
                else
                {
                    [imgV setImage:[UIImage imageNamed:@"375.png"]];
                }

            }
        }
        
    }
}

#pragma mark textview delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        //在这里做你响应return键的代码
        [self.view endEditing:YES];
        return NO; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    
    return YES;
}
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"添加文字记忆..."]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
    
    if  (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"添加文字记忆...";
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}
-(void)takePhoto:(UITapGestureRecognizer *)tap
{
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.delegate = self;
    //    imagePicker.allowsEditing = YES;

    UIAlertController *alertC=[UIAlertController alertControllerWithTitle:@"提示:" message:@"拍照" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *takephotoAction=[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
        
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }];
    
    UIAlertAction *photoAction=[UIAlertAction actionWithTitle:@"相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:imagePicker animated:YES completion:nil];
        
    }];
    
    UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];

    [alertC addAction:takephotoAction];
    [alertC addAction:photoAction];
    [alertC addAction:cancelAction];
    
    [self presentViewController:alertC animated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    UIImageView *imgV=[self.view viewWithTag:101];
    imgV.image=image;
    [[NSUserDefaults standardUserDefaults]setValue:@"10101020" forKey:@"userID"];

    NSString * userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userID"];

    NSString * time = [NSString stringWithFormat:@"%@",[NSDate date]];
    
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *date=[formatter stringFromDate:[NSDate date]];
    
    NSLog(@"date -->>%@",date);

    NSString * imageUrl  =[NSString stringWithFormat:@"%@%@.jpg",time,userID];

    NSDictionary * imageDic = @{@"image":image,@"imageurl":imageUrl};

    
    [self useImage:imageDic];
    
    imgPath=imageUrl;
    

    
//    [mainScroll setContentOffset:CGPointMake(WIDTH*(dataArr.count),0) animated:YES];
    
//    [self loadData];
//    
//    [self uiConfig];
    
    [self dismissViewControllerAnimated:picker completion:^{
        
    }];
}
- (void)useImage:(NSDictionary *)imageDic
{
    UIImage * image = [imageDic objectForKey:@"image"];
    NSString * imageUrl = [imageDic objectForKey:@"imageurl"];
    NSString * writePath = [NSString stringWithFormat:@"%@/Library/%@",NSHomeDirectory(),imageUrl];
    //对图片进行压缩
    CGSize newSize = CGSizeMake(768, 1024);
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //照片写入本地存储
    NSData * photoData = UIImageJPEGRepresentation(newImage,1);
    [photoData writeToFile:writePath atomically:NO];
    

}
#pragma mark 调出键盘时 视图上移
-(void)keyboardWillShow {
    // Animate the current view out of the way
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}

-(void)keyboardWillHide {
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}


//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}
#pragma mark scrollDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
//    NSLog(@"%f  %f",scrollView.contentOffset.x,scrollView.contentSize.width);
    

    if (scrollView.contentOffset.x<scrollView.contentSize.width-WIDTH) {
        
        rightbtn.hidden=YES;
    }
    else
    {
        rightbtn.hidden=NO;
    }
}
@end
