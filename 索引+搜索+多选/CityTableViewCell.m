//
//  CityTableViewCell.m
//  BDNM
//
//  Created by md on 16/5/13.
//  Copyright © 2016年 HKQ. All rights reserved.
//

#import "CityTableViewCell.h"

@implementation CityTableViewCell
{
    UILabel *titleLab;
    UILabel *pinyinLable;

}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        titleLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 40)];
        titleLab.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:titleLab];
        
        
        pinyinLable = [[UILabel alloc] initWithFrame:CGRectMake(155, 0, 200, 40)];
        pinyinLable.font = [UIFont systemFontOfSize:20];
        [self.contentView addSubview:pinyinLable];
    }
    return self;
}


- (void)contentCityTableViewCell:(CityModel *)model
{
    titleLab.text = model.city_name;
    pinyinLable.text = model.city_pinyin;
}



@end
