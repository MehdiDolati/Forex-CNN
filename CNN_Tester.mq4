//+------------------------------------------------------------------+
//|                                                   CNN_Tester.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//--- input parameters
input string   filename="predictions.csv";
input string   resulfilename="results.csv";
int MagicNumber=13990101;
enum signal
  {
   Buy = 1,
   Hold = 2,
   Sell = 3
  };
datetime Trigger = 0;
struct point
  {
   datetime time;
   double signal;
   double buy;
   double hold;
   double sell;
   double orderBound;
   double TakeProfit;
   double StopLoss;
  };
struct result
  {
   datetime time;
   point p;
   int outcome;
   int ticket;
  };
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
point points[];
result results[];
int resultHandle=0;
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   int Handle=FileOpen(filename,FILE_ANSI|FILE_CSV|FILE_READ,",");
   if(Handle<0)
     {
      Alert("Error while opening file " + filename);
      PlaySound("Bzrrr.wav");
      return 1;
     }
   if(Handle>0)
     {
      while(!FileIsEnding(Handle))
        {
         ArrayResize(points, ArraySize(points) + 1);
         point p;
         p.time = FileReadDatetime(Handle);
         p.signal = StrToDouble(FileReadString(Handle));
         p.buy = StrToDouble(FileReadString(Handle));
         p.hold = StrToDouble(FileReadString(Handle));
         p.sell = StrToDouble(FileReadString(Handle));
         p.orderBound = StrToDouble(FileReadString(Handle));
         p.TakeProfit = NormalizeDouble(StrToDouble(FileReadString(Handle)), Digits);
         p.StopLoss = NormalizeDouble(StrToDouble(FileReadString(Handle)), Digits);
         points[ArraySize(points) - 1] = p;
        }
      Alert(ArraySize(points));
      FileClose(Handle);
     }
//---
   resultHandle=FileOpen(resulfilename,FILE_ANSI|FILE_CSV|FILE_WRITE,",");
   FileWrite(Handle, "Ticket", "DateTime", "Signal", "Buy", "Hold", "Sell", "Order Bound", "TP", "Stop", "Close Time", "Close Price", "Result");
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   double orderresult = 0;
   datetime closetime = 0;
   double closeprice = 0;
   for(int i=0;i<ArraySize(results);i++)
     {
      if(OrderSelect(results[i].ticket, SELECT_BY_TICKET))
      {
         orderresult = OrderProfit();
         closetime = OrderCloseTime();
         closeprice = OrderClosePrice();
      }
      else
      {
         orderresult = 0;
         closetime = 0;
         closeprice = 0;
      }
      FileWrite(resultHandle, results[i].ticket, results[i].time, results[i].p.signal, results[i].p.buy, results[i].p.hold, results[i].p.sell, results[i].p.orderBound, results[i].p.TakeProfit, results[i].p.StopLoss, closetime, closeprice, orderresult);
     }
   FileClose(resultHandle);
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
      ArrayResize(results, ArraySize(results) + 1);
      result r;
      r.ticket = 0;
      r.time = Time[0];
      r.p.time = 0;
      r.p.signal = 0;
      r.p.buy = 0;
      r.p.hold = 0;
      r.p.sell = 0;
      r.p.orderBound = 0;
      r.p.TakeProfit = 0;
      r.p.StopLoss = 0;
      for(int i=0;i<ArraySize(points);i++)
        {
         if (points[i].time == Time[0])
         {
            r.ticket = HandleOrder(i);
            //r.p = points[i];
            r.p.time = points[i].time;
            r.p.signal = points[i].signal;
            r.p.buy = points[i].buy;
            r.p.hold = points[i].hold;
            r.p.sell = points[i].sell;
            r.p.orderBound = points[i].orderBound;
            r.p.TakeProfit = points[i].TakeProfit;
            r.p.StopLoss = points[i].StopLoss;
            break;
         }
        }
      results[ArraySize(results) - 1] = r;
     }
  }
int HandleOrder(int i)
{
   int ticket=0;
   double Lots = 0.1;
   if(points[i].signal==Buy)
     {
      //StopLoss = Low[1] - orderBound * Point();
      //TakeProfit = High[1] + orderBound * Point();
      while(true)
        {
         ticket = OrderSend(Symbol(), OP_BUY, Lots, Ask, 20, points[i].StopLoss, points[i].TakeProfit, WindowExpertName(), MagicNumber, 0, Green);
         if(ticket > 0)
           {
            break;
           }
         if(Fun_Error(GetLastError())==1)
            continue;
         else
            return -1;
        }
     }
   else
      if(points[i].signal==Sell)
        {
         //StopLoss = High[1] + orderBound * Point();
         //TakeProfit = Low[1] - orderBound * Point();
         while(true)
           {
            ticket = OrderSend(Symbol(), OP_SELL, Lots, Bid, 20, points[i].StopLoss, points[i].TakeProfit, WindowExpertName(), MagicNumber, 0, Blue);
            if(ticket > 0)
              {
               break;
              }
            if(Fun_Error(GetLastError())==1)
               continue;
            else
               return -1;
           }
        }
   return ticket;
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   
  }
//+------------------------------------------------------------------+

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
