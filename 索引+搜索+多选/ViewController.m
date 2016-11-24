//
//  ViewController.m
//  CityListDemo
//
//  Created by md on 16/6/1.
//  Copyright © 2016年 HKQ. All rights reserved.
//

#import "ViewController.h"
#import "CityTableViewCell.h"
#import "HttpRequestManager.h"

#define kDocumentPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
{
    NSMutableArray *totalArr;
    UITableView *mTableView;
    NSMutableDictionary *cityDict;
    NSMutableArray *searchArr;//搜索到的内容
    NSMutableArray *citys;
    NSMutableArray *saveArr;//要保存的数据
    UISearchBar *mSearchBar;
    NSMutableArray *selectIndexs;//多选选中的行
}


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    selectIndexs = [NSMutableArray array];
    //搜索按钮
    mSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 50)];
    mSearchBar.delegate = self;
    mSearchBar.placeholder = @"请输入城市中文名或者拼音";
    mSearchBar.searchBarStyle = UISearchBarStyleDefault;
    //在键盘上部添加一个隐藏按钮
    UIView *inputView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    inputView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(inputView.frame.size.width-50, 0, 50, inputView.frame.size.height);
    [btn setTitle:@"隐藏" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn addTarget:self action:@selector(onHideKeyboard) forControlEvents:UIControlEventTouchUpInside];
    [inputView addSubview:btn];
    mSearchBar.inputAccessoryView = inputView;
    [self.view addSubview:mSearchBar];
    
    totalArr = [[NSMutableArray alloc] initWithCapacity:10];
    cityDict = [[NSMutableDictionary alloc] init];
    citys = [[NSMutableArray alloc] init];
    searchArr = [[NSMutableArray alloc] init];
    saveArr = [[NSMutableArray alloc] init];
    
    //创建一个tableView
    mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, mSearchBar.frame.size.height+20, self.view.frame.size.width, self.view.frame.size.height - 20 - 50)];
    mTableView.delegate = self;
    mTableView.dataSource = self;
    mTableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:mTableView];
    //获取本地数据
    [self LoadFromLocal];
    if (totalArr.count > 0) {
        citys = totalArr;
        //将首字母相同的放在一起
        [self getAllCitys];
        [mTableView reloadData];
    }else{
        //数据请求
        [self requestDataFromServer];
    }
}
- (void)onHideKeyboard {
    [self.view endEditing:NO];
}

#pragma mark - 将首字母相同的放在一起
- (void)getAllCitys
{
    //遍历
    for (CityModel *model in totalArr) {
        NSMutableArray *letterArr = cityDict[model.m_letter];
        //判断数组里是否有元素，如果为nil，则实例化该数组，并在cityDict字典中插入一条新的数据
        if (letterArr == nil) {
            letterArr = [[NSMutableArray alloc] init];
            [cityDict setObject:letterArr forKey:model.m_letter];
        }
        //将新数据放到数组里
        [letterArr addObject:model];
    }
}

#pragma mark - 获得所有的key值并排序，并返回排好序的数组
- (NSArray *)getCityDictAllKeys
{
    //获得cityDict字典里的所有key值，
    NSArray *keys = [cityDict allKeys];
    //打印
    //    NSLog(@"keys = %@",[keys sortedArrayUsingSelector:@selector(compare:)]);
    //按升序进行排序（A B C D……）
    return [keys sortedArrayUsingSelector:@selector(compare:)];
}

#pragma mark - tableView--delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

#pragma mark - 引入索引的一个代理方法
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSArray *keys = [self getCityDictAllKeys];//获得所有的key值
    return keys;
}
#pragma mark - section上的标题（A B C D……Z）
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray *keys = [self getCityDictAllKeys];//获得所有的key值（A B C D……Z）
    return keys[section];
}
#pragma mark - section的个数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSArray *keys = [self getCityDictAllKeys];//获得所有的key值
    return keys.count;
}
#pragma mark - 每个section对应的cell的个数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *keys = [self getCityDictAllKeys];//获得所有的key值
    NSString *keyStr = keys[section];//（A B C D……Z）
    NSArray *array = [cityDict objectForKey:keyStr];//所有section下key值所对应的value的值
    return array.count;
}
#pragma mark - 返回cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

#pragma mark - Cell内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"cell";
    CityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (cell == nil) {
        cell = [[CityTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identify];
    }
    NSArray *keys = [self getCityDictAllKeys];//获得所有的key值
    NSString *keyStr = keys[indexPath.section];
    NSArray *array = [cityDict objectForKey:keyStr];//所有section下key值所对应的value的值,array就是value值，存放的是model模型
    CityModel *model = [array objectAtIndex:indexPath.row];
    [cell contentCityTableViewCell:model];
    
#warning 多选设置,调用的是系统方法
    cell.accessoryType = UITableViewCellAccessoryNone;
    for (NSIndexPath *index in selectIndexs) {
        if (index == indexPath) { //改行在选择的数组里面有记录
            cell.accessoryType = UITableViewCellAccessoryCheckmark; //打勾
            break;
        }
    }
    
    
    return cell;
}

#pragma mark - Cell点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //获取到点击的cell
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) { //如果为选中状态
        cell.accessoryType = UITableViewCellAccessoryNone; //切换为未选中
        [selectIndexs removeObject:indexPath]; //数据移除
        NSLog(@"未选中");
    }else { //未选中
        cell.accessoryType = UITableViewCellAccessoryCheckmark; //切换为选中
        [selectIndexs addObject:indexPath]; //添加索引数据到数组
        NSLog(@"选中");
    }
}



#pragma mark - UISearchBar - delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    BOOL isSearch = YES;//有编辑内容时为YES
    if (searchText.length <= 0) {
        isSearch = NO;//被清空时为NO
    }
    NSString *searchStr = mSearchBar.text;
    [searchArr removeAllObjects];//清空searchDataArr，防止显示之前搜索的结果内容
    //把这个文本与数据源进行比较
    //把数据源中类似的数据取出，存入searchDataArr
    for (NSInteger i= 0;i < totalArr.count ; i ++)
    {
        CityModel *model = totalArr[i];
        searchStr = [searchStr lowercaseString];//转换成小写
        BOOL isHas = [model.city_name hasPrefix:searchStr];//判断model.city_name是否以字符串searchStr开头
        if(isHas)
        {
            [searchArr addObject:model];
        }else{
            isHas = [model.city_pinyin hasPrefix:searchStr];
            if (isHas) {
                [searchArr addObject:model];
            }
        }
    }
    if (searchStr.length>0) {
        [cityDict removeAllObjects];
        //遍历
        for (CityModel *model in searchArr) {
            NSMutableArray *letterArr = cityDict[model.m_letter];
            //判断数组里是否有元素，如果为nil，则实例化该数组，
            if (letterArr == nil) {
                letterArr = [[NSMutableArray alloc] init];
                [cityDict setObject:letterArr forKey:model.m_letter];
            }
            [letterArr addObject:model];
        }
        
    }else{
        //遍历
        for (CityModel *model in totalArr) {
            NSMutableArray *letterArr = cityDict[model.m_letter];
            //判断数组里是否有元素，如果为nil，则实例化该数组，
            if (letterArr == nil) {
                letterArr = [[NSMutableArray alloc] init];
                [cityDict setObject:letterArr forKey:model.m_letter];
            }
            [letterArr addObject:model];
        }
    }
    [mTableView reloadData];
}

#pragma mark - 返回按钮触发事件
- (void)backBtnClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 数据请求
- (void)requestDataFromServer
{
    NSString *urlStr = [NSString stringWithFormat:@"http://apis.baidu.com/baidunuomi/openapi/cities"];
    NSMutableDictionary *headDict = [[NSMutableDictionary alloc] init];
    [headDict setObject:@"2304cdaee07aa52690475edf3776cce6" forKey:@"apikey"];
    
#warning 这里的请求方法,根据AFN需要,自己封装再调用即可,headers是因为这个请求需要请求的headers,不跟其他方式挂钩
    [HttpRequestManager HttpGetCallack:urlStr Parameters:nil headers:headDict success:^(id responseObject) {
        
        NSLog(@"%@",responseObject);
        NSDictionary *dict = responseObject;
        //获取所有的城市
        NSArray *array = [dict objectForKey:@"cities"];
        //saveArr是要保存的数组，里面的元素和array一样
        saveArr = [NSMutableArray arrayWithArray:array];
        for (NSDictionary *mDictionary in array) {
            CityModel *model = [[CityModel alloc] init];
            model.city_id = [mDictionary objectForKey:@"city_id"];//城市id
            model.city_name = [mDictionary objectForKey:@"city_name"];//城市名称
            model.city_pinyin = [mDictionary objectForKey:@"city_pinyin"];//城市拼音
            model.short_name = [mDictionary objectForKey:@"short_name"];//城市名称简称
            model.short_pinyin = [mDictionary objectForKey:@"short_pinyin"];//拼音简称
            //获取首字,uppercaseString是将首字母转换成大写
            NSString *letterStr = [[model.city_pinyin substringWithRange:NSMakeRange(0, 1)] uppercaseString];
            model.m_letter = letterStr;
            [totalArr addObject:model];
        }
        //判断数组里是否有元素
        if (totalArr.count > 0) {
            [self SaveToLocal];
        }
        citys = totalArr;
        //将首字母相同的放在一起
        [self getAllCitys];
        [mTableView reloadData];
        
    } failure:^(NSError *error) {
        NSLog(@"网络不给力");
    }];
    
}


#pragma mark - 保存到本地
- (void)SaveToLocal {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:10];
    for (NSDictionary *dict in saveArr) {
        [array addObject:dict];
    }
    //保存到MyCitylist.plist文件里
    NSString *name = [NSString stringWithFormat:@"MyCitylist.plist"];
    [array writeToFile:[kDocumentPath stringByAppendingPathComponent:name] atomically:YES];
}


#pragma mark - 获取本地数据
- (void)LoadFromLocal {
    //先清空数组里的元素
    [totalArr removeAllObjects];
    [saveArr removeAllObjects];
    NSString *name = [NSString stringWithFormat:@"MyCitylist.plist"];
    //获取本地数据,放到数组里
    NSMutableArray *array = [NSMutableArray arrayWithContentsOfFile:[kDocumentPath stringByAppendingPathComponent:name]];
    for (NSDictionary *info in array) {
        [saveArr addObject:info];
    }
    for (NSDictionary *mDictionary in saveArr) {
        CityModel *model = [[CityModel alloc] init];
        model.city_id = [mDictionary objectForKey:@"city_id"];
        model.city_name = [mDictionary objectForKey:@"city_name"];
        model.city_pinyin = [mDictionary objectForKey:@"city_pinyin"];
        model.short_name = [mDictionary objectForKey:@"short_name"];
        model.short_pinyin = [mDictionary objectForKey:@"short_pinyin"];
        NSString *letterStr = [[model.city_pinyin substringWithRange:NSMakeRange(0, 1)] uppercaseString];//获取首字母并转换成大写
        model.m_letter = letterStr;
        [totalArr addObject:model];
    }
}




@end
