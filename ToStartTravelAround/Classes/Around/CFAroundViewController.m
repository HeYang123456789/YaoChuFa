//
//  CFAroundViewController.m
//  ToStartTravelAround
//
//  Created by mac on 15/7/30.
//  Copyright (c) 2015年 mac. All rights reserved.
//

#import "CFAroundViewController.h"
#import "CFVAroundView.h"
#import "CFDropDownView.h"
#import "CFNetWork.h"
#import "CFThirdTableViewCell.h"
#import "CFDetailViewController.h"
#import "CFSearchController.h"
#import "CFLoadDataView.h"
#import "UIImage+GIF.h"

@interface CFAroundViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    CFVAroundView *_aroundView;
    NSArray *_aroundDataArr;
    CFLoadDataView *_loadView;

}
@property(nonatomic,strong)CFDropDownView *dropDownView;
@property(nonatomic,strong)UIButton *cover;
@property(nonatomic,strong)UIButton *sender;
@end

@implementation CFAroundViewController
#pragma mark =====================懒加载=========================

#pragma mark =====================视图相关=========================
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createView];
    [self createNavSearchButton];
    [self createCover];
    [self createDropDownView];
    [self createBtn];
    [self createLoadDataAnimation];
    [self aroundDataRequest];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.cover.alpha = 0;
    self.dropDownView.frame = CGRectMake(0, 30-200-30, IphoneWidth, 200);
    _sender.selected = NO;

}
- (void)createLoadDataAnimation
{
    _loadView = [[CFLoadDataView alloc]initWithFrame:self.view.bounds];
    _loadView.backgroundColor = [UIColor whiteColor];
    //    [_loadView bringSubviewToFront:_bannerView];
    
    NSString *imageFilePath = [[NSBundle mainBundle]pathForResource:@"pull_refreshing_icon.gif" ofType:nil];
    NSData *imageData = [NSData dataWithContentsOfFile:imageFilePath];
    _loadView.animationImageView.image  = [UIImage sd_animatedGIFWithData:imageData];
    [_loadView addSubview:_loadView.animationImageView];
    
    [self.view addSubview:_loadView];
}

//创建下拉菜单
- (void)createDropDownView
{
    _dropDownView = [[CFDropDownView alloc]initWithFrame:CGRectMake(0, 30-200-30, IphoneWidth, 200)];
    [self.view addSubview:_dropDownView];
}
//创建遮盖层
- (void)createCover
{

    _cover = [[UIButton alloc]initWithFrame:CGRectMake(0, 30, IphoneWidth, IphoneHeight-30-49)];
    [_cover addTarget:self action:@selector(removeCover) forControlEvents:UIControlEventTouchUpInside];
    _cover.backgroundColor = [UIColor blackColor];
    _cover.alpha = 0;
    [self.view addSubview:_cover];
 
}
//移除遮盖层
- (void)removeCover
{
    _sender.selected = NO;

    [UIView animateWithDuration:0.25 animations:^{
        self.cover.alpha = 0;
        self.dropDownView.frame = CGRectMake(0, 30-200-30, IphoneWidth, 200);
    }];
    
}
//创建下拉按钮
- (void)createBtn
{
    NSArray *arr = @[@"地区",@"筛选"];
    for (NSInteger i=0; i<2; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(i*IphoneWidth/2, 0, IphoneWidth/2, 30);
        btn.imageEdgeInsets = UIEdgeInsetsMake(0, IphoneWidth/2-15, 0, 0);
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, btn.imageView.frame.size.width+10);
        [btn setImage:[UIImage imageNamed:@"around_filter_arrow_down"] forState:UIControlStateNormal];
        [btn setTitle:arr[i] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:13];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.layer.borderColor = [UIColor orangeColor].CGColor;
        btn.layer.borderWidth = 0.3;
        btn.tag = i+1;
        [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitleColor:[UIColor orangeColor] forState:UIControlStateSelected];
        [btn setImage:[UIImage imageNamed:@"around_filter_arrow_up_icon"] forState:UIControlStateSelected];
        btn.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:btn];
        
    }

}
//下拉按钮的点击事件
- (void)btnClicked:(UIButton *)sender
{
    _sender = sender;
    __weak typeof(self) weak_self = self;
    switch (sender.tag) {

        case 1:
        {
            NSLog(@"selected : %d",sender.selected);
            if (sender.selected == YES) {
                
                [UIView animateWithDuration:0.25 animations:^{
                    weak_self.cover.alpha = 0;
                    weak_self.dropDownView.frame = CGRectMake(0, 30-200-30, IphoneWidth, 200);
                    
                }];
                
            }
            else
            {
                [UIView animateWithDuration:0.25 animations:^{
                    weak_self.cover.alpha = 0.5;
                    weak_self.dropDownView.frame = CGRectMake(0, 30, IphoneWidth, 200);
                    
                }];
                
                
            }
            sender.selected = !sender.selected;
            
        }
            
            break;
            
        case 2:
            
            break;
            
        default:
            break;
    }

}
//创建View
- (void)createView
{

    _aroundView = [[CFVAroundView alloc]initWithFrame:CGRectMake(0, 0, IphoneWidth, self.view.frame.size.height - 49)];
    self.view = _aroundView;
    _aroundView.tableView.delegate = self;
    _aroundView.tableView.dataSource = self;
}
//创建搜索按钮
- (void)createNavSearchButton
{
    //导航栏右边的按钮
    UIButton *titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    titleBtn.frame = CGRectMake(0, 0, IphoneWidth-20, 25);
    

    UIImage *searchBacImage = [UIImage imageNamed:@"home_search_bar_bg"];
    [titleBtn setBackgroundImage:[searchBacImage resizableImageWithCapInsets:UIEdgeInsetsMake(searchBacImage.size.height/2, searchBacImage.size.width/2, (searchBacImage.size.height/2)+1, (searchBacImage.size.width/2)+1)] forState:UIControlStateNormal];
    titleBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    
    titleBtn.layer.borderColor = CFColor(231, 231, 234).CGColor;
    titleBtn.layer.borderWidth = 1;
    titleBtn.layer.cornerRadius = 4;
    [titleBtn setTitle:@"搜索目的地/景点/酒店等" forState:UIControlStateNormal];
    
    [titleBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    titleBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [titleBtn addTarget:self action:@selector(SearchBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    titleBtn.adjustsImageWhenHighlighted = NO;
    self.navigationItem.titleView = (UIView *)titleBtn;
}

- (void)SearchBtnClicked
{
    CFSearchController *searchVC = [[CFSearchController alloc] init];
    [self.navigationController pushViewController:searchVC animated:YES];

}
#pragma mark =====================数据请求=========================
- (void)aroundDataRequest
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];

    dic[@"province"] = @"1";
    dic[@"pageIndex"] = @"1";
    dic[@"city"] = @"深圳";
    dic[@"system"] = @"ios";
    dic[@"machineCode"] = @"0316B31D-CEAE-4C94-A3F8-F5BB581B0CE3";
    dic[@"channel"] = @"AppStore";
    dic[@"version"] = @"4.2.6";
    dic[@"pageSize"] = @"20";
    dic[@"longitude"] = @"113.9515533447266";
    dic[@"latitude"] = @"22.54096984863281";
    [CFNetWork networkAroundProductRequest:dic whileSuccess:^(id responseObject)
    {
        _aroundDataArr = responseObject;
        [_aroundView.tableView reloadData];
        //移除加载视图
        [UIView animateWithDuration:1.5 animations:^{
            _loadView.alpha = 0;
        }];
        //延迟操作
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_loadView removeFromSuperview];
        });

    } orFail:^(id responseObject) {
        //移除加载视图
        [UIView animateWithDuration:1.5 animations:^{
            _loadView.alpha = 0;
        }];
        //延迟操作
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_loadView removeFromSuperview];
        });

    }];

}
#pragma mark =====================代理方法=========================
#pragma mark - TableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _aroundDataArr.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CFThirdTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"aroundCell" forIndexPath:indexPath];
    [cell fillItemWithAroundModel:_aroundDataArr[indexPath.row]];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}
//点击cell的操作
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CFDetailViewController *detailCtl = [[CFDetailViewController alloc]init];
    detailCtl.productId = [_aroundDataArr[indexPath.row] valueForKey:@"productId"];
    [self.navigationController pushViewController:detailCtl animated:YES];
}
@end
