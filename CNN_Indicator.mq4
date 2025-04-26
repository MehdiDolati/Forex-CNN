//+------------------------------------------------------------------+
//|                                                CNN_Indicator.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
//--- input parameters
input int ATR=24;
input int WindowSize=240;
input int MaxLookBack=120;

#property indicator_buffers 2
#property indicator_plots   2
//--- plot UpperBand
#property indicator_label1  "UpperBand"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrSpringGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot LowerBand
#property indicator_label2  "LowerBand"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- indicator buffers
double ExtATRBuffer[];
double ExtTRBuffer[];
double UpperBandBuffer[];
double LowerBandBuffer[];
datetime Trigger;
string outputFileName="";
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorBuffers(4);
//--- indicator buffers mapping
   SetIndexBuffer(0,UpperBandBuffer);
   SetIndexBuffer(1,LowerBandBuffer);
   SetIndexBuffer(2,ExtATRBuffer);
   SetIndexBuffer(3,ExtTRBuffer);

   string short_name;
   IndicatorDigits(Digits);
//--- indicator line
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   short_name="ATR("+IntegerToString(ATR)+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
   SetIndexLabel(1,short_name);
//--- check for input parameter
   if(ATR<=0)
     {
      Print("Wrong input parameter ATR Period=",ATR);
      return(INIT_FAILED);
     }
//---
   SetIndexDrawBegin(0,ATR);
   outputFileName="CNN_"+Symbol()+Period()+".csv";
//---
   Trigger = Time[0];
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(Time[0] != Trigger)
     {
      Trigger = Time[0];
      int Handle=FileOpen(outputFileName,FILE_ANSI|FILE_CSV|FILE_WRITE,",");
      if(Handle<0)
        {
         Alert("Error while opening file " + outputFileName);
         PlaySound("Bzrrr.wav");
         return(-1);
        }
      FileWrite(Handle,"DateTime", "Open", "High", "Low", "Close", "Volume");
      for(int i=1; i < (WindowSize + MaxLookBack + 1); i++)
         FileWrite(Handle, TimeToStr(Time[i]), Open[i], High[i], Low[i], Close[i], Volume[i]);
      FileClose(Handle);
     }
   int i,limit;
//--- check for bars count and input parameter
   if(rates_total<=ATR|| ATR<=0)
      return(0);
//--- counting from 0 to rates_total
   ArraySetAsSeries(ExtATRBuffer,false);
   ArraySetAsSeries(ExtTRBuffer,false);
   ArraySetAsSeries(UpperBandBuffer,false);
   ArraySetAsSeries(LowerBandBuffer,false);
   ArraySetAsSeries(open,false);
   ArraySetAsSeries(high,false);
   ArraySetAsSeries(low,false);
   ArraySetAsSeries(close,false);
//--- preliminary calculations
   if(prev_calculated==0)
     {
      ExtTRBuffer[0]=0.0;
      ExtATRBuffer[0]=0.0;
      UpperBandBuffer[0]=0.0;
      LowerBandBuffer[0]=0.0;
      //--- filling out the array of True Range values for each period
      for(i=1; i<rates_total; i++)
         ExtTRBuffer[i]=MathMax(high[i],close[i-1])-MathMin(low[i],close[i-1]);
      //--- first AtrPeriod values of the indicator are not calculated
      double firstValue=0.0;
      for(i=1; i<=ATR; i++)
        {
         ExtATRBuffer[i]=0.0;
         UpperBandBuffer[i]=0.0;
         LowerBandBuffer[i]=0.0;
         firstValue+=ExtTRBuffer[i];
        }
      //--- calculating the first value of the indicator
      firstValue/=ATR;
      ExtATRBuffer[ATR]=firstValue;
      UpperBandBuffer[ATR]=firstValue+open[i];
      LowerBandBuffer[ATR]=open[i]-firstValue;
      limit=ATR+1;
     }
   else
      limit=prev_calculated-1;
//--- the main loop of calculations
   for(i=limit; i<rates_total; i++)
     {
      ExtTRBuffer[i]=MathMax(high[i],close[i-1])-MathMin(low[i],close[i-1]);
      ExtATRBuffer[i]=ExtATRBuffer[i-1]+(ExtTRBuffer[i]-ExtTRBuffer[i-ATR])/ATR;
      UpperBandBuffer[i]=ExtATRBuffer[i-1]+(ExtTRBuffer[i]-ExtTRBuffer[i-ATR])/ATR+open[i];
      LowerBandBuffer[i]=open[i]-ExtATRBuffer[i-1]+(ExtTRBuffer[i]-ExtTRBuffer[i-ATR])/ATR;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+