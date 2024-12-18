**SERVER EXPORTS**

**Add money in bank**

money -> Amount of money 
bankname -> any of the names in the sql tables

exports["wasvendel_bank"]:AddMoneyInBank(source,bankname,money)

*EXAMPLE*
local bankname = "valentine"
local money = 120
exports["wasvendel_bank"]:AddMoneyInBank(source,bankname,money)

**Remove money in bank**

money -> Amount of money 
bankname -> any of the names in the sql tables

exports["wasvendel_bank"]:RemoveMoneyInBank(source,"valentine",13000)

*EXAMPLE*
local bankname = "valentine"
local money = 120
local _source = source
exports["wasvendel_bank"]:AddMoneyInBank(source,bankname,money)


**Requesting money from the bank**
bankname -> any of the names in the sql tables

exports["wasvendel_bank"]:GetBankMoney(source,bankname)

*EXAMPLE*
local bankname = "valentine"
local test = exports["wasvendel_bank"]:GetBankMoney(source,bankname)
print(test) -> shows how much money is in the bank

**setting money in a particular bank**
money -> Amount of money 
bankname -> any of the names in the sql t

exports["wasvendel_bank"]:SetBankMoney(source,bankname,money)

*EXAMPLE* 
local bankname = "valentine"
local money = 120
exports["wasvendel_bank"]:SetBankMoney(source,bankname,money)

**Is Bank Money Enough**
money -> Amount of money 
bankname -> any of the names in the sql t
exports["wasvendel_bank"]:IsBankMoneyEnough(source,bankname,money)

*EXAMPLE* 
local bankname = "valentine"
local money = 120
local test = exports["wasvendel_bank"]:IsBankMoneyEnough(source,bankname,money)
print(test) TRUE OR FALSE 

**CLIENT EVENT TO CLOSE BANK**

"wasvendel_bank:closebank"