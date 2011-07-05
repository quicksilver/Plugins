//
//  CalculatorAction.h
//  Quicksilver
//

#define CalculatorCalculateAction @"CalculatorCalculateAction"

@interface CalculatorActionProvider : QSActionProvider {
}

- (QSObject *)calculate:(QSObject *)dObject;
- (QSObject *)performCalculation:(QSObject *)dObject;
@end
