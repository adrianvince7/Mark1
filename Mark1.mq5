//+------------------------------------------------------------------+
//|                                                        Mark1.mq5 |
//|                         Copyright 2024, Avanzamos Africa Pty LTD |
//|                                         https://avanzamos.africa |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Avanzamos Africa Pty LTD"
#property link      "https://avanzamos.africa"
#property version   "1.05"
//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include <Expert\Expert.mqh>
//--- available signals
#include <Expert\Signal\SignalRSI.mqh>
#include <Expert\Signal\SignalMA.mqh>
#include <Expert\Signal\SignalMACD.mqh>
#include <Expert\Signal\SignalCCI.mqh>
//--- available trailing
#include <Expert\Trailing\TrailingMA.mqh>
//--- available money management
#include <Expert\Money\MoneyFixedRisk.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string             Expert_Title         ="Mark1";     // Document name
ulong                    Expert_MagicNumber   =27656;       //
bool                     Expert_EveryTick     =false;       //
//--- inputs for main signal
input int                Signal_ThresholdOpen =20;          // Signal threshold value to open [0...100]
input int                Signal_ThresholdClose=20;          // Signal threshold value to close [0...100]
input double             Signal_PriceLevel    =0.0;         // Price level to execute a deal
input double             Signal_StopLevel     =100.0;       // Stop Loss level (in points)
input double             Signal_TakeLevel     =150.0;       // Take Profit level (in points)
input int                Signal_Expiration    =4;           // Expiration of pending orders (in bars)
input int                Signal_RSI_PeriodRSI =14;          // Relative Strength Index(14,...) Period of calculation
input ENUM_APPLIED_PRICE Signal_RSI_Applied   =PRICE_CLOSE; // Relative Strength Index(14,...) Prices series
input double             Signal_RSI_Weight    =1.0;         // Relative Strength Index(14,...) Weight [0...1.0]
//--- inputs for trailing
input int                Trailing_MA_Period   =50;          // Period of MA
input int                Trailing_MA_Shift    =0;           // Shift of MA
input ENUM_MA_METHOD     Trailing_MA_Method   =MODE_EMA;    // Method of averaging
input ENUM_APPLIED_PRICE Trailing_MA_Applied  =PRICE_CLOSE; // Prices series
//--- inputs for money
input double             Money_FixRisk_Percent=0.5;         // Risk percentage
input int                ATR_Period           =14;          // ATR period for dynamic position sizing
input double             ATR_Multiplier       =1.0;         // ATR multiplier for position sizing
//--- inputs for additional filters
input ENUM_TIMEFRAMES    Filter_MA_Period     =PERIOD_M5;   // Period of the Moving Average for trend filter
input ENUM_MA_METHOD     Filter_MA_Method     =MODE_SMA;    // Method of averaging for trend filter
input double             Max_Drawdown_Percent =30.0;        // Max drawdown percentage before halting trading
//--- inputs for trading hours
input int                Trade_Start_Hour     =6;           // Start hour for trading
input int                Trade_End_Hour       =20;          // End hour for trading
//+------------------------------------------------------------------+
//| Global expert object                                             |
//+------------------------------------------------------------------+
CExpert ExtExpert;
double initial_balance;
double max_drawdown_allowed;
double atr_value;
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
//--- Creating signal
   CExpertSignal *signal=new CExpertSignal;
   if(signal==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating signal");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//---
   ExtExpert.InitSignal(signal);
   signal.ThresholdOpen(Signal_ThresholdOpen);
   signal.ThresholdClose(Signal_ThresholdClose);
   signal.PriceLevel(Signal_PriceLevel);
   signal.StopLevel(Signal_StopLevel);
   signal.TakeLevel(Signal_TakeLevel);
   signal.Expiration(Signal_Expiration);
//--- Creating filter CSignalRSI
   CSignalRSI *filter0=new CSignalRSI;
   if(filter0==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter0");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter0);
//--- Set filter parameters
   filter0.PeriodRSI(Signal_RSI_PeriodRSI);
   filter0.Applied(Signal_RSI_Applied);
   filter0.Weight(Signal_RSI_Weight);
//--- Creating MA trend filter
   CSignalMA *trendFilter=new CSignalMA;
   if(trendFilter==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating trend filter");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   trendFilter.Period(Filter_MA_Period); // Correct enum type for Period
   trendFilter.Method(Filter_MA_Method);
   signal.AddFilter(trendFilter);
//--- Creating MACD filter
   CSignalMACD *macdFilter=new CSignalMACD;
   if(macdFilter==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating MACD filter");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(macdFilter);
//--- Creating CCI filter
   CSignalCCI *cciFilter=new CSignalCCI;
   if(cciFilter==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating CCI filter");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(cciFilter);
//--- Creation of trailing object
   CTrailingMA *trailing=new CTrailingMA;
   if(trailing==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating trailing");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Add trailing to expert (will be deleted automatically)
   if(!ExtExpert.InitTrailing(trailing))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing trailing");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Set trailing parameters
   trailing.Period(Trailing_MA_Period);
   trailing.Shift(Trailing_MA_Shift);
   trailing.Method(Trailing_MA_Method);
   trailing.Applied(Trailing_MA_Applied);
//--- Creation of money object with dynamic position sizing
   CMoneyFixedRisk *money=new CMoneyFixedRisk;
   if(money==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating money");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Add money to expert (will be deleted automatically)
   if(!ExtExpert.InitMoney(money))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing money");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Set money parameters
   money.Percent(Money_FixRisk_Percent);
//--- Check all trading objects parameters
   if(!ExtExpert.ValidationSettings())
     {
      //--- failed
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Tuning of all necessary indicators
   if(!ExtExpert.InitIndicators())
     {
      //--- failed
      printf(__FUNCTION__+": error initializing indicators");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Calculate ATR for dynamic position sizing
   atr_value = iATR(Symbol(), PERIOD_M5, ATR_Period) * ATR_Multiplier;
//--- ok
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Deinitialization function of the expert                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ExtExpert.Deinit();
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

   ExtExpert.OnTick();
  }
//+------------------------------------------------------------------+
//| "Trade" event handler function                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
   ExtExpert.OnTrade();
  }
//+------------------------------------------------------------------+
//| "Timer" event handler function                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   ExtExpert.OnTimer();
  }
//+------------------------------------------------------------------+
