//+------------------------------------------------------------------+
//|                                                        CustomVolume.mqh |
//|                         Copyright 2024, Avanzamos Africa Pty LTD |
//|                                         https://avanzamos.africa |
//+------------------------------------------------------------------+
#include <Expert\ExpertSignal.mqh>

class CCustomVolume : public CExpertSignal
  {
public:
   double VolumeValue;

   //--- constructor
   CCustomVolume(void)
     {
      VolumeValue = 0;
     }

   //--- signal initialization
   virtual bool Init( void )
     {
      return(true);
     }

   //--- calculate signal
   virtual double Calculate( void )
     {
      VolumeValue = iVolume(NULL, 0, 0);
      return(VolumeValue);
     }
  };
