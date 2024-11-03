//+------------------------------------------------------------------+
//|                                                    Krsna-Off.mq5 |
//|                                         Copyright 2024, KrsnaARM |
//|                                         https://www.krsnaarm.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, KrsnaARM"
#property link      "https://www.krsnaarm.com"
#property version   "1.00"
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
#property strict

// Input parameters
input int StartHour = 7;  // Starting hour of the custom daily candle
input int CandleBodyWidth = 3;  // Width of the candle body
input int HighLowLineWidth = 1;  // Width of the high-low line
input int CandleShift = 1;  // Shift amount for the custom candles
input color rectGreenColor = clrNONE;  // Rectangle color for green candle
input color rectRedColor = clrNONE;  // Rectangle color for red candle
input int rectAlpha = 255;

// Indicator buffers
double OpenBuffer[];
double HighBuffer[];
double LowBuffer[];
double CloseBuffer[];

// Last update time
datetime lastUpdateTime = 0;

// Chart ID
long chartID;

// Get the timeframe of the chart
int chartPeriod = ChartPeriod(0);

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Get the chart ID
   chartID = ChartID();
   Print("Chart ID: ", chartID);
   
   chartPeriod = ChartPeriod(0);
   //---Print("Chart timeframe in seconds: ", chartPeriod);

   // Convert the chart period to a readable format
   string periodString = PeriodSecondsToString(chartPeriod);
   Print("Chart timeframe: ", periodString);
   
   if(chartPeriod == PERIOD_D1){
      // Change the chart type to line chart to hide the original candles
      if (!ChartSetInteger(0, CHART_MODE, CHART_LINE))
        {
         Print("Failed to set chart mode to line chart");
         return(INIT_FAILED);
        }
   }
   // Calculate the custom daily candles
   CalculateCustomDailyCandles();
   Print("Custom daily candles calculated");
   //printf(lastUpdateTime);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   // Cleanup code if needed
   ObjectsDeleteAll(0, "Candle_" + IntegerToString(chartID) + "_");
   
   // Change the chart type back to candlestick chart
   ChartSetInteger(0, CHART_MODE, CHART_CANDLES);
  }
//+------------------------------------------------------------------+
//| Function to convert period in seconds to a readable format       |
//+------------------------------------------------------------------+
string PeriodSecondsToString(int periodSeconds)
  {
   switch(periodSeconds)
     {
      case PERIOD_M1: return "1 Minute";
      case PERIOD_M5: return "5 Minutes";
      case PERIOD_M15: return "15 Minutes";
      case PERIOD_M30: return "30 Minutes";
      case PERIOD_H1: return "1 Hour";
      case PERIOD_H4: return "4 Hours";
      case PERIOD_D1: return "1 Day";
      case PERIOD_W1: return "1 Week";
      case PERIOD_MN1: return "1 Month";
      default: return "Unknown Period";
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   // Check if at least 60 minutes has passed since the last update
   datetime currentTime = TimeCurrent();
   if (currentTime - lastUpdateTime >= 3600) //update custom candles every hour
     {
      //printf(lastUpdateTime);  
      // Recalculate the custom daily candles
      CalculateCustomDailyCandles();
      lastUpdateTime = currentTime;
     }
  }
//+------------------------------------------------------------------+
//| Function to calculate custom daily candles                       |
//+------------------------------------------------------------------+
void CalculateCustomDailyCandles()
  {
   // Clear the buffers
   ArrayResize(OpenBuffer, 0);
   ArrayResize(HighBuffer, 0);
   ArrayResize(LowBuffer, 0);
   ArrayResize(CloseBuffer, 0);

   // Delete existing objects
   ObjectsDeleteAll(0, "Candle_" + IntegerToString(chartID) + "_");

   // Get the historical data
   int totalBars = iBars(_Symbol, PERIOD_H1);
   datetime startTime = iTime(_Symbol, PERIOD_H1, totalBars - 1);

   double openPrice = 0;
   double highPrice = 0;
   double lowPrice = 0;
   double closePrice = 0;
   bool newCandle = true;
   
   double prevHigh = 0;
   double prevLow = 0;

   MqlDateTime timeStruct;

   for (int i = totalBars - 1; i >= 0; i--)
     {
      datetime time = iTime(_Symbol, PERIOD_H1, i);
      double open = iOpen(_Symbol, PERIOD_H1, i);
      double high = iHigh(_Symbol, PERIOD_H1, i);
      double low = iLow(_Symbol, PERIOD_H1, i);
      double close = iClose(_Symbol, PERIOD_H1, i);

      TimeToStruct(time, timeStruct);

      if (timeStruct.hour == StartHour)
        {
         if (!newCandle)
           {
            // Save the previous candle
            int size = ArraySize(OpenBuffer);
            ArrayResize(OpenBuffer, size + 1);
            ArrayResize(HighBuffer, size + 1);
            ArrayResize(LowBuffer, size + 1);
            ArrayResize(CloseBuffer, size + 1);

            OpenBuffer[size] = openPrice;
            HighBuffer[size] = highPrice;
            LowBuffer[size] = lowPrice;
            CloseBuffer[size] = closePrice;

            // Plot the candle
            PlotCandle(size, time, openPrice, highPrice, lowPrice, closePrice);
            //Print(size);
           }

         // Start a new candle
         openPrice = open;
         highPrice = high;
         lowPrice = low;
         closePrice = close;
         newCandle = false;
        }
      else
        {
         // Update the current candle
         if (high > highPrice) highPrice = high;
         if (low < lowPrice) lowPrice = low;
         closePrice = close;
        }
     }

   // Save the last candle
   if (!newCandle)
     {
      int size = ArraySize(OpenBuffer);
      ArrayResize(OpenBuffer, size + 1);
      ArrayResize(HighBuffer, size + 1);
      ArrayResize(LowBuffer, size + 1);
      ArrayResize(CloseBuffer, size + 1);

      OpenBuffer[size] = openPrice;
      HighBuffer[size] = highPrice;
      LowBuffer[size] = lowPrice;
      CloseBuffer[size] = closePrice;

      // Plot the last candle
      PlotCandle(size, startTime, openPrice, highPrice, lowPrice, closePrice);
      Print("Number of candles: ",size);
     }
  }
//+------------------------------------------------------------------+
//| Function to plot a candle                                        |
//+------------------------------------------------------------------+
void PlotCandle(int index, datetime time, double open, double high, double low, double close)
  {
   string prefix = "Candle_" + IntegerToString(chartID) + "_" + IntegerToString(index) + "_";
   
   // Plot the body of the candle
   string bodyName = prefix + "Body";
   double bodyTop = MathMax(open, close);
   double bodyBottom = MathMin(open, close);
   int bodyColor = (open > close) ? clrRed : clrGreen;

   //Rahul      
   double prevHigh = 0;
   double prevLow = 0;
   if (index > 1){
      prevHigh = HighBuffer[index-1];// - HighBuffer[index - 2];
      prevLow = LowBuffer[index-1];// - LowBuffer[index - 2];
   }
   //Print("HighBuffer[index]",HighBuffer[index-1]);
   // To set the tooltip with additional details
   string tooltipText = StringFormat("Custom Candle:\n%s\n\nOpen: %.5f\nHigh: %.5f\nLow: %.5f\nClose: %.5f\nTime: %s", bodyName, open, high, low, close, TimeToString(time, TIME_DATE | TIME_MINUTES));
   
   uint fillRectColor = (open > close) ? ColorToARGB(rectRedColor, rectAlpha) : ColorToARGB(rectGreenColor, rectAlpha);
   if(rectGreenColor == clrNONE){
      fillRectColor = ColorToARGB(bodyColor, rectAlpha);
   }
   if(rectRedColor == clrNONE){
      fillRectColor = ColorToARGB(bodyColor, rectAlpha);
   }
   
   if(chartPeriod == PERIOD_H1){
      if (ObjectCreate(0, bodyName+"shade", OBJ_RECTANGLE, 0, time - CandleShift * 60, bodyTop, time - 3600*24 - CandleShift * 60, bodyBottom)) {
         ObjectSetInteger(0, bodyName+"shade", OBJPROP_COLOR, fillRectColor);
         ObjectSetInteger(0, bodyName+"shade", OBJPROP_WIDTH, 1);
         ObjectSetInteger(0, bodyName+"shade",OBJPROP_FILL,true);
         ObjectSetInteger(0, bodyName+"shade",OBJPROP_BACK,true);
         ObjectSetString(0, bodyName+"shade", OBJPROP_TOOLTIP, "Hello Dear");
      }
      else {
         Print("Failed to create body object: ", bodyName+"shade");
      }
      //Print("Done"+index);
   }
   //else{
      //--ObjectCreate(0, bodyName, OBJ_RECTANGLE, 0, time, bodyTop, time + 3600, bodyBottom);
      if (ObjectCreate(0, bodyName, OBJ_RECTANGLE, 0, time - CandleShift * 60, bodyTop, time - 3600 - CandleShift * 60, bodyBottom)) {
         ObjectSetInteger(0, bodyName, OBJPROP_COLOR, bodyColor);
         ObjectSetInteger(0, bodyName, OBJPROP_WIDTH, CandleBodyWidth);  // Use input parameter for candle body width
         ObjectSetString(0, bodyName, OBJPROP_TOOLTIP, tooltipText);
      }
      else {
         Print("Failed to create body object: ", bodyName);
      }
   //}
   
   // Plot the high-low line of the candle
   string lineName = prefix + "Line";
   //--ObjectCreate(0, lineName, OBJ_TREND, 0, time, high, time, low);
   ObjectCreate(0, lineName, OBJ_TREND, 0, time - CandleShift * 60, high, time - CandleShift * 60, low);
   ObjectSetInteger(0, lineName, OBJPROP_COLOR, bodyColor);
   ObjectSetInteger(0, lineName, OBJPROP_WIDTH, HighLowLineWidth);  // Use input parameter for high-low line width
   ObjectSetString(0, lineName, OBJPROP_TOOLTIP, tooltipText);
   
   // Display the differences between the highs and lows
   DisplayText(index, time, high, low, prevHigh, prevLow);
  }
//+------------------------------------------------------------------+
//| Function to display text on the chart                            |
//+------------------------------------------------------------------+
void DisplayText(int index, datetime time, double high, double low, double prevHigh, double prevLow)
  {
   string prefix = "Text_" + IntegerToString(chartID) + "_" + IntegerToString(index) + "_";

   // Calculate the differences
   double highDiff = high - prevHigh;
   double lowDiff = low - prevLow;

   // Display the difference between the highs above the candle
   string highTextName = prefix + "HighDiff";
   //string highText = StringFormat("High Diff: %.5f", highDiff);
   string highText = StringFormat("%.5f", highDiff);
   string highTooltipText = StringFormat("%s\nHigh: %.5f\nPrevHigh: %.5f\nDiff: %.5f", highTextName, high, prevHigh, high - prevHigh);
   ObjectCreate(0, highTextName, OBJ_TEXT, 0, time, high + (high - low) * 0.2);
   ObjectSetString(0, highTextName, OBJPROP_TEXT, highText);
   ObjectSetInteger(0, highTextName, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, highTextName, OBJPROP_FONTSIZE, 7);
   
   ObjectSetString(0, highTextName, OBJPROP_TOOLTIP,highTooltipText);

   // Display the difference between the lows below the candle
   string lowTextName = prefix + "LowDiff";
   //string lowText = StringFormat("Low Diff: %.5f", lowDiff);
   string lowText = StringFormat("%.5f", lowDiff);
   string lowTooltipText = StringFormat("%s\nLow: %.5f\nPrevLow: %.5f\nDiff: %.5f", lowTextName, low, prevLow, low - prevLow);
   ObjectCreate(0, lowTextName, OBJ_TEXT, 0, time, low - (high - low) * 0.1);
   ObjectSetString(0, lowTextName, OBJPROP_TEXT, lowText);
   ObjectSetInteger(0, lowTextName, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, lowTextName, OBJPROP_FONTSIZE, 7);
   
   ObjectSetString(0, lowTextName, OBJPROP_TOOLTIP, lowTooltipText);
  }
//+------------------------------------------------------------------+