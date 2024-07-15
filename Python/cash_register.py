"""Homework assignment in Python from NYU"""

FIRST = 0
SECOND = 0
MEMBER = 0

FIRST = float(input("Enter price of the FIRST item: "))
SECOND = float(input("Enter price of the SECOND item: "))

base_price = FIRST + SECOND

MEMBER = input("Does customer have a club card? (Y/N): ")

taxrate = float(input("Enter tax rate, e.g. 5.5 for 5.5% tax: "))

DISCOUNT = 0

if FIRST > SECOND :
    DISCOUNT += round((SECOND / 2), 2)
else:
    DISCOUNT += round((FIRST / 2), 2)

if 'y' == MEMBER or 'Y' == MEMBER :
    DISCOUNT += round(((base_price - DISCOUNT) * .10), 2)

price_after = base_price - DISCOUNT
price_after = round(price_after, 2)
total = price_after + (price_after * (taxrate/100))
total = round(total, 2)

print("Base price = %2.2f" % base_price)
print("Price after DISCOUNTs = %2.2f" % price_after)
print("Total price = %2.2f" % total)
