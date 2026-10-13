#include <Trade/Trade.mqh>

CTrade trade;

input bool AllowTrading = false;
input double RiskPercent = 0.25;
input double DailyLossLimitPercent = 1.0;

input int FastEMA = 50;
input int SlowEMA = 200;
input int RSIPeriod = 14;
input int ATRPeriod = 14;

input double ATRMultiplier = 2.0;
input double RewardRiskRatio = 1.5;
input int MaxSpreadPoints = 100;
input ulong MagicNumber = 501200;

int fastHandle, slowHandle, rsiHandle, atrHandle;
datetime lastBar = 0;
double dayStartEquity = 0;
int currentDay = 0;

int DayCode()
{
   MqlDateTime t;
   TimeToStruct(TimeCurrent(), t);
   return t.year * 10000 + t.mon * 100 + t.day;
}

int OnInit()
{
   fastHandle = iMA(_Symbol, PERIOD_M5, FastEMA, 0,
                    MODE_EMA, PRICE_CLOSE);
   slowHandle = iMA(_Symbol, PERIOD_M15, SlowEMA, 0,
                    MODE_EMA, PRICE_CLOSE);
   rsiHandle = iRSI(_Symbol, PERIOD_M5, RSIPeriod,
                    PRICE_CLOSE);
   atrHandle = iATR(_Symbol, PERIOD_M5, ATRPeriod);

   if(fastHandle == INVALID_HANDLE ||
      slowHandle == INVALID_HANDLE ||
      rsiHandle == INVALID_HANDLE ||
      atrHandle == INVALID_HANDLE)
      return INIT_FAILED;

   trade.SetExpertMagicNumber(MagicNumber);
   trade.SetTypeFillingBySymbol(_Symbol);

   currentDay = DayCode();
   dayStartEquity = AccountInfoDouble(ACCOUNT_EQUITY);

   Print("GoldScalperDemo loaded. Trading permission: ",
         AllowTrading);

   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   IndicatorRelease(fastHandle);
   IndicatorRelease(slowHandle);
   IndicatorRelease(rsiHandle);
   IndicatorRelease(atrHandle);
   Comment("");
}

double GetVolume(double entry, double stop, ENUM_ORDER_TYPE type)
{
   double riskMoney =
      AccountInfoDouble(ACCOUNT_EQUITY) * RiskPercent / 100.0;

   double profit = 0;
   if(!OrderCalcProfit(type, _Symbol, 1.0, entry, stop, profit))
      return 0;

   double lossPerLot = MathAbs(profit);
   if(lossPerLot <= 0)
      return 0;

   double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);

   if(step <= 0 || minLot <= 0)
      return 0;

   double volume = MathFloor((riskMoney / lossPerLot) / step) * step;
   volume = MathMin
