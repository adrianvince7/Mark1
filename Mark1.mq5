//+------------------------------------------------------------------+
//|                                                      Mark1.mq5   |
//|                         Copyright 2024, Avanzamos Africa Pty LTD |
//|                                         https://avanzamos.africa |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Avanzamos Africa Pty LTD"
#property link      "https://avanzamos.africa"
#property version   "1.07"
//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include <Expert\Expert.mqh>
#include <Trade\Trade.mqh>
#include "\MoneyManagement\CMoneyManager.mqh"
#include "\Strategy\CSignalManager.mqh"

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input string             Expert_Title         ="Mark1";     // Document name
ulong                    Expert_MagicNumber   =27656;       //
bool                     Expert_EveryTick     =false;       //
//--- inputs for signal
input int                Signal_RSI_PeriodRSI =14;          // Relative Strength Index(14,...) Period of calculation
input ENUM_APPLIED_PRICE Signal_RSI_Applied   =PRICE_CLOSE; // Relative Strength Index(14,...) Prices series
input double             Signal_RSI_Weight    =1.0;         // Relative Strength Index(14,...) Weight [0...1.0]
//--- inputs for money management
input double             Money_FixRisk_Percent=0.5;         // Risk percentage
input int                ATR_Period           =14;          // ATR period for dynamic position sizing
input double             ATR_Multiplier       =1.0;         // ATR multiplier for position sizing
//--- inputs for trading hours
input int                Trade_Start_Hour     =6;           // Start hour for trading
input int                Trade_End_Hour       =20;          // End hour for trading
//--- inputs for drawdown control
input double             Max_Drawdown_Percent =30.0;        // Max drawdown percentage before halting trading
//+------------------------------------------------------------------+
//| Global expert object                                             |
//+------------------------------------------------------------------+
CExpert ExtExpert;
CMoneyManager *moneyManager;
CSignalManager *signalManager;
CTrade trade;
double initial_balance;
double max_drawdown_allowed;
//+------------------------------------------------------------------+
//| Initialization function of the expert                            |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Ensure the chart is on the 5-minute timeframe
   if (Period() != PERIOD_M5)
     {
      if(!ChartSetSymbolPeriod(0, NULL, PERIOD_M5))
        {
         printf(__FUNCTION__+": error setting chart to 5-minute timeframe");
         return(INIT_FAILED);
        }
     }
//--- Initializing expert
   if(!ExtExpert.Init(Symbol(),PERIOD_M5,Expert_EveryTick,Expert_MagicNumber))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing expert");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Initializing account balance and drawdown limit
   initial_balance = AccountInfoDouble(ACCOUNT_BALANCE);
   max_drawdown_allowed = initial_balance * (Max_Drawdown_Percent / 100.0);
//--- Initializing money management
   moneyManager = new CMoneyManager(Money_FixRisk_Percent, ATR_Period, ATR_Multiplier);
   if (moneyManager == NULL)
     {
      printf(__FUNCTION__+": error initializing money manager");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Initializing signal manager
   signalManager = new CSignalManager(Signal_RSI_PeriodRSI, Signal_RSI_Applied, Signal_RSI_Weight);
   if (signalManager == NULL)
     {
      printf(__FUNCTION__+": error initializing signal manager");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- ok
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Deinitialization function of the expert                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ExtExpert.Deinit();
   delete moneyManager;
   delete signalManager;
  }
//+------------------------------------------------------------------+
//| "Tick" event handler function                                    |
//+------------------------------------------------------------------+
void OnTick()
  {
   datetime current_time = TimeCurrent();
   MqlDateTime dt;
   TimeToStruct(current_time, dt);
   int current_hour = dt.hour;

   if (current_hour < Trade_Start_Hour || current_hour >= Trade_End_Hour)
     {
      // Skip trading outside of specified hours
      return;
     }

   if (AccountInfoDouble(ACCOUNT_EQUITY) <= (initial_balance - max_drawdown_allowed))
     {
      printf("Max drawdown limit reached. Halting trading.");
      return;
     }

   if (signalManager.CheckBuySignal())
     {
      double lotSize = moneyManager.CalculateLotSize();
      trade.Buy(lotSize, NULL, 0, 0);
     }
   else if (signalManager.CheckSellSignal())
     {
      double lotSize = moneyManager.CalculateLotSize();
      trade.Sell(lotSize, NULL, 0, 0);
     }

   ExtExpert.OnTick();
  }
//+------------------------------------------------------------------+
;