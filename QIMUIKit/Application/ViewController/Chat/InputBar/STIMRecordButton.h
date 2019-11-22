
#import "STIMCommonUIFramework.h"

@class STIMRecordButton;

typedef void (^RecordTouchDown)         (STIMRecordButton *recordButton);
typedef void (^RecordTouchUpOutside)    (STIMRecordButton *recordButton);
typedef void (^RecordTouchUpInside)     (STIMRecordButton *recordButton);
typedef void (^RecordTouchDragEnter)    (STIMRecordButton *recordButton);
typedef void (^RecordTouchDragInside)   (STIMRecordButton *recordButton);
typedef void (^RecordTouchDragOutside)  (STIMRecordButton *recordButton);
typedef void (^RecordTouchDragExit)     (STIMRecordButton *recordButton);

@interface STIMRecordButton : UIButton

@property (nonatomic, copy) RecordTouchDown         recordTouchDownAction;
@property (nonatomic, copy) RecordTouchUpOutside    recordTouchUpOutsideAction;
@property (nonatomic, copy) RecordTouchUpInside     recordTouchUpInsideAction;
@property (nonatomic, copy) RecordTouchDragEnter    recordTouchDragEnterAction;
@property (nonatomic, copy) RecordTouchDragInside   recordTouchDragInsideAction;
@property (nonatomic, copy) RecordTouchDragOutside  recordTouchDragOutsideAction;
@property (nonatomic, copy) RecordTouchDragExit     recordTouchDragExitAction;

- (void)setButtonStateWithRecording;
- (void)setButtonStateWithNormal;

@end
