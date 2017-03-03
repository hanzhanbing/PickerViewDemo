//
//  ViewController.m
//  PickerViewDemo(省市县三级联动)
//
//  Created by 韩占禀 on 15/4/29.
//  Copyright (c) 2015年 jiehang. All rights reserved.
//

#import "ViewController.h"

#define FirstComponent 0
#define SubComponent 1
#define ThirdComponent 2
#define WIDTH self.view.frame.size.width/3.5;
#define HEIGHT self.view.frame.size.height/5;

@interface ViewController ()
{
    UIPickerView *picker;
    UIDatePicker *datePicker;
    NSDictionary *dict;
    NSArray *pickerArray;
    NSArray *subPickerArray;
    NSArray *thirdPickerArray;
    NSString *province; //省
    NSString *city; //市
    NSString *county; //县
    NSString *selectContent; //选择的省市县
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"省市县三级联动";
    
    //初始化数据
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Address" ofType:@"plist"];
    dict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    pickerArray = [dict allKeys];
    province = pickerArray[0];
    if (dict[province]!=nil) {
        subPickerArray = [dict[province] allKeys];
        city = subPickerArray[0];
    } else {
        subPickerArray = nil;
    }
    if (dict[province][city]!=nil) {
        thirdPickerArray = dict[province][city];
    } else {
        thirdPickerArray = nil;
    }
    
    //初始化UIDatePicker
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 250)];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];//设置为中文显示
    datePicker.locale = locale;
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
   
    [self.view addSubview:datePicker];
    
    UIButton *sureBtn = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width-100)/2, 400, 100, 40)];
    sureBtn.backgroundColor = [UIColor colorWithRed:1.000 green:0.230 blue:0.346 alpha:1.000];
    [sureBtn setTitle:@"选择省市区" forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(sureSelect) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sureBtn];
}

- (void)changeDate:(UIDatePicker *)pick {
    NSTimeInterval timeInterval = 8*60*60; //相差8个时区
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
//    formatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
    formatter.dateFormat = @"yyyy-MM-dd";
    NSString *dateStr = [formatter stringFromDate:pick.date];
    NSLog(@"%@ %@",[pick.date dateByAddingTimeInterval:timeInterval],dateStr);
}

#pragma mark - 确定选择按钮监听
- (void)sureSelect {
    NSString *title = UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) ? @"\n\n\n\n\n\n\n\n\n" : @"\n\n\n\n\n\n\n\n\n\n\n";
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        province = pickerArray[[picker selectedRowInComponent:FirstComponent]];
        city = subPickerArray[[picker selectedRowInComponent:SubComponent]];
        county = thirdPickerArray[[picker selectedRowInComponent:ThirdComponent]];
        if (city==nil) {
            selectContent = [NSString stringWithFormat:@"%@",province];
        } else if(county==nil) {
            selectContent = [NSString stringWithFormat:@"%@-%@",province,city];
        } else {
            selectContent = [NSString stringWithFormat:@"%@-%@-%@",province,city,county];
        }
        self.title = selectContent;
    }];
    
    //初始化UIPickerView
    picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-20, 200)];
    picker.delegate = self;
    picker.dataSource = self;
    [alertController.view addSubview:picker];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UIPickerViewDelegate、UIPickerViewDataSource协议
//确定有几组
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

//确定每组的元素个数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    switch (component) {
        case FirstComponent:
            return pickerArray.count;
            break;
        case SubComponent:
            return subPickerArray.count;
            break;
        case ThirdComponent:
            return thirdPickerArray.count;
            break;
        default:
            break;
    }
    return 0;
}

//宽度
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return WIDTH;
}

//绑定数据
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (component) {
        case FirstComponent:
            return pickerArray[row];
            break;
        case SubComponent:
            return subPickerArray[row];
            break;
        case ThirdComponent:
            return thirdPickerArray[row];
            break;
        default:
            break;
    }
    return nil;
}

//数据选择控制
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    switch (component) {
        case FirstComponent:
            province = pickerArray[row];
            if (dict[province]!=nil) {
                subPickerArray = [dict[province] allKeys];
                city = subPickerArray[0];
                if (dict[province][city]!=nil) {
                    thirdPickerArray = dict[province][city];
                } else {
                    thirdPickerArray = nil;
                }
            } else {
                subPickerArray = nil;
                thirdPickerArray = nil;
            }
            [picker selectedRowInComponent:SubComponent];
            [picker reloadComponent:SubComponent];
            [picker selectedRowInComponent:ThirdComponent];
            [picker reloadComponent:ThirdComponent];
            break;
        case SubComponent:
            city = subPickerArray[row];
            if (dict[province][city]!=nil) {
                thirdPickerArray = dict[province][city];
            } else {
                thirdPickerArray = nil;
            }
            [picker selectRow:0 inComponent:ThirdComponent animated:YES];
            [picker reloadComponent:ThirdComponent];
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
