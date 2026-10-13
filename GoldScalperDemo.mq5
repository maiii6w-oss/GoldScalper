#include <Trade/Trade.mqh>

input int FastEMA = 50;
input int SlowEMA = 200;
input int RSIPeriod = 14;
input int ATRPeriod = 14;

int fastHandle, slowHandle, rsiHandle, atrHandle;

int OnInit()
{
   fastHandle = iMA(_Symbol, PERIOD_M5, FastEMA,
                    0, MODE_EMA, PRICE_CLOSE);
   slowHandle = iMA(_Symbol, PERIOD_M15, SlowEMA,
                    0, MODE_EMA, PRICE_CLOSE);
   rsiHandle = iRSI(_Symbol, PERIOD_M5, RSIPeriod,
                    PRICE_CLOSE);
   atrHandle = iATR(_Symbol, PERIOD_M5, ATRPeriod);

   if(fastHandle == INVALID_HANDLE ||
      slowHandle == INVALID_HANDLE ||
      rsiHandle == INVALID_HANDLE ||
      atrHandle == INVALID_HANDLE)
      return INIT_FAILED;

   Print("GoldScalperDemo initialized: signals only.");
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   IndicatorRelease(fastHandle);
   IndicatorRelease(slowHandle);
   IndicatorRelease(rsiHandle);
   IndicatorRelease(atrHandle);
}

void OnTick()
{
   double fast[], slow[], rsi[], atr[];

   ArraySetAsSeries(fast, true);
   ArraySetAsSeries(slow, true);
   ArraySetAsSeries(rsi, true);
   ArraySetAsSeries(atr, true);

   if(CopyBuffer(fastHandle, 0, 1, 1, fast) != 1)
      return;
   if(CopyBuffer(slowHandle, 0, 1, 1, slow) != 1)
      return;
   if(CopyBuffer(rsiHandle, 0, 1, 1, rsi) != 1)
      return;
   if(CopyBuffer(atrHandle, 0, 1, 1, atr) != 1)
      return;

   Comment("GoldScalperDemo - SIGNALS ONLY\n",
           "Symbol: ", _Symbol, "\n",
           "M5 EMA 50: ", DoubleToString(fast[0], 2), "\n",
           "M15 EMA 200: ", DoubleToString(slow[0], 2), "\n",
           "RSI: ", DoubleToString(rsi[0], 2), "\n",
           "ATR: ", DoubleToString(atr[0], 3), "\n",
           "No trades will be opened.");
}
