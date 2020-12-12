'''
I.O.Reset

'''




import pyfirmata2
import time

board = pyfirmata2.Arduino(pyfirmata2.Arduino.AUTODETECT)


houseLight = 2
leverLeft = 3
leverRight = 4
feeder = 5

board.digital[houseLight].write(0)
board.digital[leverLeft].write(0)
board.digital[leverRight].write(0)
board.digital[feeder].write(0)

board.exit()


