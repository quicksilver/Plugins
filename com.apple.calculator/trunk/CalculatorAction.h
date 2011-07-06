//
//  CalculatorAction.h
//  Quicksilver
//
// Created by Kevin Ballard, modified by Patrick Robertson
// Copyright QSApp.com 2011

#define CalculatorCalculateAction @"CalculatorCalculateAction"

@interface CalculatorActionProvider : QSActionProvider {
}

- (QSObject *)calculate:(QSObject *)dObject;
- (QSObject *)performCalculation:(QSObject *)dObject;
@end
