//+------------------------------------------------------------------+
//|                                               CSignalManager.mqh |
//|                         Copyright 2024, Avanzamos Africa Pty LTD |
//|                                         https://avanzamos.africa |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Avanzamos Africa Pty LTD"
#property link      "https://avanzamos.africa"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+
// Strategy\CSignalManager.mqh
class CSignalManager
{
private:
    int rsiPeriod;
    ENUM_APPLIED_PRICE rsiApplied;
    double rsiWeight;

public:
    CSignalManager(int rsiPeriod, ENUM_APPLIED_PRICE rsiApplied, double rsiWeight)
    {
        this.rsiPeriod = rsiPeriod;
        this.rsiApplied = rsiApplied;
        this.rsiWeight = rsiWeight;
    }

    bool CheckBuySignal()
    {
        double rsi = iRSI(Symbol(), PERIOD_M5, rsiPeriod, rsiApplied);
        return rsi < 30;
    }

    bool CheckSellSignal()
    {
        double rsi = iRSI(Symbol(), PERIOD_M5, rsiPeriod, rsiApplied);
        return rsi > 70;
    }
};
