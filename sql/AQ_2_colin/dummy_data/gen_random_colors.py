import random

for i in range(41):
    r = lambda: random.randint(0,255)
    print('%02X%02X%02X' % (r(),r(),r()))