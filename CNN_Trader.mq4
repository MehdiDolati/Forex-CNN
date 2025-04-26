//+------------------------------------------------------------------+
//|                                                   CNN_Trader.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//--- input parameters
input int      ATRPeriod=24;
input int      WindowSize=240;
input int      MaxLookBack=120;
input string   outputFilePath="bin/Debug/net5.0-windows/";
input string   predictionFilePath="bin/Debug/net5.0-windows/";
input int      responseTiimer=5;
input double   threshold = 0.5;
input double   LotSize=0.1;
input bool     MoneyManagement=true;
input int      MagicNumber=20211011;


datetime lastSignalTime=0;
double   orderBound=0;
double   buy=0;
double   hold=0;
double   sell=0;
double   StopLoss=0;
double   TakeProfit=0;
enum signal
  {
   Buy,
   Hold,
   Sell
  };
signal   lastSignal=Hold;
datetime       Trigger;
string outputFileName;
string predictionFileName;
string resultFileName;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(responseTiimer);
   outputFileName=outputFilePath+"CNN_"+Symbol()+Period()+".csv";
   predictionFileName=predictionFilePath+"CNNPrediction_"+Symbol()+Period()+".csv";
   resultFileName=outputFilePath+"CNNSingle_"+Symbol()+Period()+".csv";
   FileDelete(predictionFileName);
   Trigger = Time[0];
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if(Time[0] != Trigger)
     {
      Trigger = Time[0];
      int Handle=FileOpen(outputFileName,FILE_ANSI|FILE_CSV|FILE_WRITE,",");
      if(Handle<0)
        {
         Alert("Error while opening file " + outputFileName);
         PlaySound("Bzrrr.wav");
         return;
        }
      FileWrite(Handle,"DateTime", "Open", "High", "Low", "Close", "Volume");
      for(int i=(WindowSize + MaxLookBack); i >0; i--)
         FileWrite(Handle, TimeToStr(Time[i]), Open[i], High[i], Low[i], Close[i], Volume[i]);
      FileClose(Handle);
      Handle=FileOpen(resultFileName,FILE_ANSI|FILE_CSV|FILE_WRITE,",");
      if(Handle<0)
        {
         Alert("Error while opening file " + resultFileName);
         PlaySound("Bzrrr.wav");
         return;
        }
      FileWrite(Handle,TimeToStr(Time[1]), Open[1], High[1], Low[1], Close[1], Volume[1]);
      FileClose(Handle);
     }
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   int Handle=FileOpen(predictionFileName,FILE_ANSI|FILE_CSV|FILE_READ,",");
   if(Handle>0)
     {
      datetime fileTime = FileReadDatetime(Handle);
      if(fileTime > lastSignalTime)
        {
         lastSignalTime = fileTime;
         buy = StrToDouble(FileReadString(Handle));
         hold = StrToDouble(FileReadString(Handle));
         sell = StrToDouble(FileReadString(Handle));
         orderBound = StrToDouble(FileReadString(Handle));
         TakeProfit = NormalizeDouble(StrToDouble(FileReadString(Handle)), Digits);
         StopLoss = NormalizeDouble(StrToDouble(FileReadString(Handle)), Digits);
         if(buy > hold)
            if(buy > sell)
               lastSignal=Buy;
            else
               lastSignal=Sell;
         else
            if(hold > sell)
               lastSignal=Hold;
            else
               lastSignal=Sell;
         //Alert("Buy= " + buy + " Sell= " + sell + " Hold= "+hold);
         HandleOrders();
        }
      FileClose(Handle);
      FileDelete(predictionFileName);
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
double GetLots()
  {
   if(MoneyManagement)
     {
      return LotSize;
     }
   return LotSize;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void HandleOrders()
  {
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS)==true)
         if(OrderSymbol()==Symbol() && OrderMagicNumber() == MagicNumber)
            return;
     }
   int ticket;
   double Lots = GetLots();
   if(lastSignal==Buy)
     {
      //StopLoss = Low[1] - orderBound * Point();
      //TakeProfit = High[1] + orderBound * Point();
      while(true)
        {
         ticket = OrderSend(Symbol(), OP_BUY, Lots, Ask, 20, StopLoss, TakeProfit, WindowExpertName(), MagicNumber, 0, Green);
         if(ticket > 0)
           {
            break;
           }
         if(Fun_Error(GetLastError())==1)
            continue;
         else
            return;
        }
     }
   else
      if(lastSignal==Sell)
        {
         //StopLoss = High[1] + orderBound * Point();
         //TakeProfit = Low[1] - orderBound * Point();
         while(true)
           {
            ticket = OrderSend(Symbol(), OP_SELL, Lots, Bid, 20, StopLoss, TakeProfit, WindowExpertName(), MagicNumber, 0, Blue);
            if(ticket > 0)
              {
               break;
              }
            if(Fun_Error(GetLastError())==1)
               continue;
            else
               return;
           }
        }
  }
//+------------------------------------------------------------------+
int Fun_Error(int Error)                        // Function of processing errors
  {
   switch(Error)
     {
      // Not crucial errors
      case  4:
         Alert("Trade server is busy. Trying once again..");
         Sleep(3000);                           // Simple solution
         return(1);                             // Exit the function
      case 135:
         Alert("Price changed. Trying once again..");
         RefreshRates();                        // Refresh rates
         return(1);                             // Exit the function
      case 136:
         Alert("No prices. Waiting for a new tick..");
         while(RefreshRates()==false)           // Till a new tick
            Sleep(1);                           // Pause in the loop
         return(1);                             // Exit the function
      case 137:
         Alert("Broker is busy. Trying once again..");
         Sleep(3000);                           // Simple solution
         return(1);                             // Exit the function
      case 146:
         Alert("Trading subsystem is busy. Trying once again..");
         Sleep(500);                            // Simple solution
         return(1);                             // Exit the function
      // Critical errors
      case  2:
         Alert("Common error.");
         return(0);                             // Exit the function
      case  5:
         Alert("Old terminal version.");
         return(0);                             // Exit the function
      case 64:
         Alert("Account blocked.");
         return(0);                             // Exit the function
      case 133:
         Alert("Trading forbidden.");
         return(0);                             // Exit the function
      case 134:
         Alert("Not enough money to execute operation.");
         return(0);                             // Exit the function
      case 128:
         Alert("Trade timeout");
         return(0);                             // Exit the function
      default:
         Alert("Error occurred: ",Error);       // Other variants
         return(0);                                // Exit the function
     }
  }
//+------------------------------------------------------------------+
