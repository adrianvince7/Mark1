//+------------------------------------------------------------------+
//|                                         CustomBollingerBands.mqh |
//|                         Copyright 2024, Avanzamos Africa Pty LTD |
//|                                         https://avanzamos.africa |
//+------------------------------------------------------------------+
#include <Expert\ExpertSignal.mqh>

class CSignalBollingerBands : public CExpertSignal
  {
public:
   double BollingerBandsUpper, BollingerBandsLower, BollingerBandsMiddle;

   //--- constructor
   CSignalBollingerBands(void)
     {
      BollingerBandsUpper = 0;
      BollingerBandsLower = 0;
      BollingerBandsMiddle = 0;
     }

   //--- signal initialization
   virtual bool Init( void )
     {
      // Example of initializing parameters if needed
      return(true);
     }

   //--- calculate signal
   virtual double Calculate( void )
     {
      int limit = 100;
      double upper[], lower[], middle[];
      ArrayResize(upper, limit);
      ArrayResize(lower, limit);
      ArrayResize(middle, limit);

      // Calculate Bollinger Bands
      CopyBuffer(iBands(NULL, PERIOD_CURRENT, 14, 2.0, 0, PRICE_CLOSE), 1, 0, limit, upper);
      CopyBuffer(iBands(NULL, PERIOD_CURRENT, 14, 2.0, 0, PRICE_CLOSE), 2, 0, limit, lower);
      CopyBuffer(iBands(NULL, PERIOD_CURRENT, 14, 2.0, 0, PRICE_CLOSE), 0, 0, limit, middle);

      BollingerBandsUpper = upper[limit-1];
      BollingerBandsLower = lower[limit-1];
      BollingerBandsMiddle = middle[limit-1];

      return(0.0);
     }
  };
