'''
I.O.Test

IO Test

'''




import pyfirmata2
import time

board = pyfirmata2.Arduino(pyfirmata2.Arduino.AUTODETECT)

def test2(equipmentName):
    board.digital[equipmentName].write(1)
    time.sleep(1)
    board.digital[equipmentName].write(0)
    time.sleep(1)
    board.digital[equipmentName].write(1)
    time.sleep(1)
    board.digital[equipmentName].write(0)
    time.sleep(1)
    pass

houseLight = 2
leverLeft = 3
leverRight = 4
feeder = 5

test2(houseLight)
board.digital[houseLight].write(1)
test2(leverLeft)
test2(leverRight)
test2(feeder)


board.digital[houseLight].write(0)
board.digital[leverLeft].write(0)
board.digital[leverRight].write(0)
board.digital[feeder].write(0)

board.exit()



