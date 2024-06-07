//+------------------------------------------------------------------+
//|                                                 MoneyManager.mqh |
//|                         Copyright 2024, Avanzamos Africa Pty LTD |
//|                                         https://avanzamos.africa |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Avanzamos Africa Pty LTD"
#property link      "https://avanzamos.africa"
#property version   "1.00"
// MoneyManagement\CMoneyManager.mqh
class CMoneyManager
{
   private:
       double riskPercent;
       double atrMultiplier;
       int atrPeriod;
   
   public:
       CMoneyManager(double riskPercent, int atrPeriod, double atrMultiplier)
       {
           this.riskPercent = riskPercent;
           this.atrPeriod = atrPeriod;
           this.atrMultiplier = atrMultiplier;
       }
   
       double CalculateLotSize()
       {
           double atrValue = iATR(Symbol(), PERIOD_M5, atrPeriod) * atrMultiplier;
           double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
           double riskAmount = accountBalance * (riskPercent / 100.0);
           double pipValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
           double pipSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
           double riskPerLot = (atrValue / pipSize) * pipValue;
           return NormalizeDouble(riskAmount / riskPerLot, 2);
       }
};
