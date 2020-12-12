#!/usr/bin/python3

# Copyright (c) 2012, Fabian Affolter <fabian@affolter-engineering.ch>
# Copyright (c) 2018, Bernd Porr <mail@berndporr.me.uk>
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# * Neither the name of the pyfirmata team nor the names of its contributors
#   may be used to endorse or promote products derived from this software
#   without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ''AS IS'' AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Warning: this code won't provide precise timing as it's using a
# delay opertation.

import pyfirmata2
import time

# Adjust that the port match your system, see samples below:
# On Linux: /dev/tty.usbserial-A6008rIF, /dev/ttyACM0,
# On Windows: \\.\COM1, \\.\COM2
# PORT = '/dev/ttyACM0'
PORT = pyfirmata2.Arduino.AUTODETECT

# Creates a new board
board = pyfirmata2.Arduino(PORT)
print("Setting up the connection to the board ...")
# default sampling interval of 19ms
board.samplingOn()

houseLight = 2
leverLeft = 3
leverRight = 4
feeder = 5

leverLeftAct = 'd:6:i'
leverRightAct = 'd:7:i'

# Setup the digital pin
# digital_0 = board.get_pin(leverLeftAct)
digital_0 = board.get_pin(leverRightAct)
digital_0.enable_reporting()

board.digital[houseLight].write(1)
board.digital[leverLeft].write(1)
board.digital[leverRight].write(1)



try:
    while (True):
        if str(digital_0.read()) == 'True':
            print("Button pressed")
        elif str(digital_0.read()) == 'False':
            print("Button not pressed")
        else:
            print("Button has never been pressed")
        time.sleep(0.01)

except KeyboardInterrupt:
    board.digital[houseLight].write(0)
    board.digital[leverLeft].write(0)
    board.digital[leverRight].write(0)
    board.digital[feeder].write(0)
    board.exit()
