# Mark1 Expert Advisor

Mark1 is an Expert Advisor (EA) for MetaTrader 5 designed to trade based on the Relative Strength Index (RSI) and a trailing Moving Average (MA). This EA is configured to risk 5% of the balance per trade with the goal of gaining 8% per trade.

## Features

- **RSI Signal**: Uses the RSI indicator to generate trade signals.
- **Trailing MA**: Implements a trailing stop based on a Moving Average.
- **Fixed Risk Management**: Risk management is based on a fixed percentage of the account balance.

## Installation

1. Copy `Mark1.mq5` to the `Experts` directory of your MetaTrader 5 installation.
2. Restart MetaTrader 5 or refresh the Navigator panel.

## Inputs

| Input                  | Description                                      | Default Value |
|------------------------|--------------------------------------------------|---------------|
| Expert_Title           | Document name                                    | Mark1         |
| Expert_MagicNumber     | Unique identifier for the EA                     | 27656         |
| Expert_EveryTick       | Process every tick                               | false         |
| Signal_ThresholdOpen   | Signal threshold to open a trade                 | 10            |
| Signal_ThresholdClose  | Signal threshold to close a trade                | 10            |
| Signal_PriceLevel      | Price level to execute a deal                    | 0.0           |
| Signal_StopLevel       | Stop Loss level (in points)                      | 50.0          |
| Signal_TakeLevel       | Take Profit level (in points)                    | 80.0          |
| Signal_Expiration      | Expiration of pending orders (in bars)           | 4             |
| Signal_RSI_PeriodRSI   | RSI period                                       | 15            |
| Signal_RSI_Applied     | RSI applied price                                | PRICE_CLOSE   |
| Signal_RSI_Weight      | RSI weight                                       | 1.0           |
| Trailing_MA_Period     | Period of the Moving Average                     | 50            |
| Trailing_MA_Shift      | Shift of the Moving Average                      | 0             |
| Trailing_MA_Method     | Method of averaging for the Moving Average       | MODE_EMA      |
| Trailing_MA_Applied    | Applied price for the Moving Average             | PRICE_CLOSE   |
| Money_FixRisk_Percent  | Risk percentage per trade                        | 5.0           |

## Usage

1. Attach the EA to a chart.
2. Configure the input parameters as needed.
3. Allow automated trading.

## Strategy

- **RSI**: The EA uses RSI to identify overbought and oversold conditions. When the RSI crosses a specified threshold, the EA generates a buy or sell signal.
- **Trailing MA**: A trailing stop loss based on a moving average is used to protect profits.
- **Risk Management**: The EA risks 5% of the account balance per trade with a target of 8% profit per trade.

## Disclaimer

Trading foreign exchange on margin carries a high level of risk and may not be suitable for all investors. Past performance is not indicative of future results. Always ensure you fully understand the risks involved and seek independent advice if necessary.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contact

For more information, visit [Avanzamos Africa](https://avanzamos.africa).

