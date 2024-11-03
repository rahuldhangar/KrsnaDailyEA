# KrsnaDailyEA
KrsnaDailyEA is an Expert Advisor (EA) designed for the MetaTrader 5 platform.

## Overview
The Krsna-Off Expert Advisor (EA) is a custom trading tool designed for the MetaTrader 5 platform. This EA plots custom daily candles based on a user-defined starting hour and provides additional features such as displaying differences between the highs and lows of consecutive candles, tooltips with detailed information, and automated trading based on specific conditions.

## Features
1. **Custom Daily Candles**:
   - Plots custom daily candles on the chart based on a user-defined starting hour.
   - Customizable candle body width and high-low line width.
   - Customizable colors and transparency for the candle bodies.

2. **Tooltips**:
   - Displays detailed tooltips with open, high, low, close prices, and time for each custom candle.
   - Displays differences between the highs and lows of consecutive candles as tooltips.

3. **Text Display**:
   - Displays the difference between the highs of the previous two candles above the current candle.
   - Displays the difference between the lows of the previous two candles below the current candle.

4. **Automated Trading**:
   - Places a buy limit order based on specific conditions:
     - If the high of the current custom candle is higher than the high of the previous custom candle.
     - If the low of the current custom candle is higher than the low of the previous custom candle.
     - The buy limit order is placed at the 60% retracement level of the current custom candle.
   - The buy limit order includes a stop loss and take profit based on user-defined multipliers.
   - The order is set to expire one day later.

## Input Parameters
- `LotSize`: Lot size, default is 0.1 lot.
- `tpMultiplier`: Risk : Reward ratio.
- `slAboveHighOrBelowLow`: Place SL above high / below low.
- `StartHour`: Starting hour of the custom daily candle.
- `CandleBodyWidth`: Width of the candle body.
- `HighLowLineWidth`: Width of the high-low line.
- `CandleShift`: Shift amount for the custom candles.
- `rectGreenColor`: Rectangle color for green candle.
- `rectRedColor`: Rectangle color for red candle.
- `rectAlpha`: Transparency level for the candle body.

## Usage
1. **Compile the EA**:
   - Save the EA code to a file named `KrsnaDailyEA.mq5`.
   - Open MetaEditor and compile the EA.

2. **Attach to Chart**:
   - Open MetaTrader 5 and attach the EA to a chart.
   - Set the input parameters as desired.

3. **Monitor the Chart**:
   - The EA will plot custom daily candles based on the specified starting hour.
   - Tooltips and text displaying the differences between the highs and lows of consecutive candles will be shown on the chart.

4. **Automated Trading**:
   - The EA will place a buy limit order based on the specified conditions.
   - The order will include a stop loss and take profit based on user-defined multipliers.
   - The order will expire one day later.