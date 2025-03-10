# CurrencyConverter-App
CurrencyConverter App - PayPay

● Develop a currency conversion app that allows a user to view a given amount in a given currency converted into other currencies.

● Platform Requirements
○ Swift
○ Xcode 15

● Functional Requirements
● The required data must be fetched from the open exchange rates service [https://openexchangerates.org/].
○ See the documentation for information on how to use their API [https://docs.openexchangerates.org/reference/api-introduction].
○ You must use a free account - not a paid one.
○ Get a free App ID that will give you access to the Open Exchange Rates API
here [https://openexchangerates.org/signup/free].

● The required data must be persisted locally to permit the application to be used
offline after data has been fetched.
● In order to limit bandwidth usage, the required data can be refreshed from the API no more frequently than once every 30 minutes.
● The user must be able to select a currency from a list of currencies provided by open exchange rates.
● The user must be able to enter the desired amount for the selected currency.
● The user must then be shown a list showing the desired amount in the selected currency converted into amounts in each currency provided by open exchange rates.
○ If exchange rates for the selected currency are not available via open exchange rates, perform the conversions on the app side.
○ When converting, floating point errors are acceptable.
     
 ● The project must contain unit tests that ensure correct operation.
UI Suggestion
● A text entry widget to enter the amount.
● A selection widget to select a currency.
● A list/grid of currency conversions.



NOTE

 ● Unit Test
Writing test code is important.

<img width="305" alt="Screenshot 2025-03-11 at 12 57 27 AM" src="https://github.com/user-attachments/assets/ad9a56cc-e60a-4ad0-8f60-11ed845d8b2b" />

 

