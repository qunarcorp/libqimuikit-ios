//
//  TodoListSearchTableViewCell.m
//  qunarChatIphone
//
//  Created by 李露 on 2017/8/1.
//
//
#if __has_include("STIMNoteManager.h")
#import "TodoListSearchTableViewCell.h"
#import "STIMNoteModel.h"
#import "STIMNoteUICommonFramework.h"

@interface TodoListSearchTableViewCell ()

@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) STIMNoteModel *model;

@end

@implementation TodoListSearchTableViewCell

- (void)setTodoListModel:(STIMNoteModel *)model {
    _model = model;
    [self refreshUI];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)refreshUI {
    self.textLabel.text = self.model.q_title;
    NSString *timeStr = [[NSDate stimDB_dateWithTimeIntervalInMilliSecondSince1970:self.model.q_time] stimDB_formattedDateDescription];
    self.timeLabel.text = [NSString stringWithFormat:@"%@", timeStr];
}

@end
#endif
