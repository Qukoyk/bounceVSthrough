'''
trainingRandomRepeat.py

トレーニング・交差反発ランダム誤答反復版

'''

__author__ = "Qukoyk"
__contacts__ = "quruoheng@hiroshima-u.ac.jp"



###################################
###################################
######                      #######
######　↓↓↓要変更↓↓↓  #######
######                      #######
###################################
###################################


answer2 = 'testR'


###################################
###################################
######                      #######
######　↑↑↑要変更↑↑↑  #######
######                      #######
###################################
###################################





x = 3 # FR(x)
iti = 20
timeMax = 90 * 60 # 最大実験時間
trialsMax = 60 # 最大試行数
import pyfirmata2
import pygame
import time
import csv
import math, random, numpy
import sys,os


# Arduino設定
print('\n'"Setting up the connection to the board ...")
PORT = pyfirmata2.Arduino.AUTODETECT
board = pyfirmata2.Arduino(PORT)
print('\n'"Arduino connected"'\n')
# default sampling interval of 19ms
board.samplingOn()
# 出力ポート
houseLight = 2
leverLeftMove = 3
leverRightMove = 4
feeder = 5
# 入力ポート
leverLeftAct = board.get_pin('d:6:i')
leverRightAct = board.get_pin('d:7:i')
leverLeftAct.enable_reporting()
leverRightAct.enable_reporting()
# リセット
board.digital[houseLight].write(0)
board.digital[leverLeftMove].write(0)
board.digital[leverRightMove].write(0)
board.digital[feeder].write(0)
time.sleep(0.5)



'''
変数宣言部分

変数やリストなどを事前宣言、設定するところ
'''
# データ関係
leverPressData = [] # レバーが押されたら記録をする（全反応）
leverActData = [] # 目標行動とその種類を表記（例えばFI10に10s後最初の反応）
leverData = [] # 押されたレバーは左か右かを記録
latencyData = [] # 潜時リストを記録
timeData = [] # 反応時間を記録
randomData = []

dataTransfer = [] # 行列変換用リスト
dataPosition = 0 # leverPressDataの最後の数字を基づいて，データをほかのリストに挿入する際に順番とする

randList = []

listPosition = 0
leverPressCounter = 0



'''
視覚刺激部分
'''
# pygmae初期化
pygame.init()
# 解像度設定
size = [1000,740]
# ball
movementSpeed = 5
WHITE = (255,255,255)
BLACK = (0,0,0)
GREY1 = (64,64,64)
GREY2 = (107,107,107)
GREY3 = (150,150,150)
GREY4 = (191,191,191)
screen = pygame.display.set_mode(size,vsync=1)
# pygame.mouse.set_visible(False)


# ファイルの保存先（ディレクトリ）
os.chdir('C:/Desktop/kyoku/shapingData/')

# 変数関係
leftRight = 0

react = 0
reactLeft = 0
reactRight = 0

reinforceYN = False # 強化するか否か。
reinforcers = 0 # 強化子の数を表す。

leverLeftTrial = 0 # 左レバー押しのカウンター
leverRightTrial = 0 # 右レバー押しのカウンター

trial = 0
timeStart = time.time()  # 始まりの時間
timeNow = time.time()
timePast = 0
timeLatency = 0
timeTrialBlock = time.time()
timeTrialLever = time.time()

randPosition = 0
randCounter = 0



'''
関数部分

いろんな関数を事前宣言するところ
'''

# 乱数生成関数
def ransu():
    sum0 = 0
    # 初期的乱数列を生成
    for i in range(30):
        randList.append(random.randint(0,1))
        i = i + 1
        pass
    # 4連以上しないように次の項目を調整
    for i in range(27):
        sum0 = randList[i] + randList[i+1] + randList[i+2]
        if sum0 == 0: # 0が3連になると次の項目を1に変わる
            randList[i+3] = 1
            pass
        if sum0 == 3: # 1が3連になると次の項目を0に変わる
            randList[i+3] = 0
            pass
        pass
    pass

# 0と1が「半々」であるか否かを検証
def ransuTest():
    sumRand = 0
    # tempList = randList
    global randList
    # 「半々」じゃないとずっと繰り返す
    while sumRand != 15:
        # リセット
        randList = []
        sumRand = 0
        # 新しい乱数列を再生成
        ransu()
        for i in range(30):
            sumRand = sumRand + randList[i]
            pass
        pass
    pass


def through(ballLeftColor,ballRightColor):
    ballLeftPosition = int(256)
    ballRightPosition = int(768)
    height = int(360)

    screen.fill(BLACK)
    ballLeft = pygame.draw.circle(screen, ballLeftColor, [ballLeftPosition,height], 30, 0)
    ballRight = pygame.draw.circle(screen, ballRightColor, [ballRightPosition,height], 30, 0)
    pygame.display.update()
    time.sleep(0.5)

    while True:

        for event in pygame.event.get():
            if event.type == pygame.QUIT: sys.exit()

        screen.fill(BLACK)
        ballLeft = pygame.draw.circle(screen, ballLeftColor, [ballLeftPosition,height], 30, 0)
        ballRight = pygame.draw.circle(screen, ballRightColor, [ballRightPosition,height], 30, 0)
        
        if ballLeftPosition > 768 or ballRightPosition < 256:
            break
        else:
            ballLeftPosition = ballLeftPosition + movementSpeed
            ballRightPosition = ballRightPosition - movementSpeed
        pygame.display.update()
        # pygame.mouse.set_visible(False)
        pygame.time.Clock().tick(75)

        pass

    screen.fill(BLACK)
    ballLeft = pygame.draw.circle(screen, ballLeftColor, [ballLeftPosition,height], 30, 0)
    ballRight = pygame.draw.circle(screen, ballRightColor, [ballRightPosition,height], 30, 0)
    pygame.display.update()
    time.sleep(0.5)
    
    pass

def bounce(ballLeftColor,ballRightColor):
    stage = ""
    threshold = 0 # physics: 55
    ballLeftPosition = int(256)
    ballRightPosition = int(768)
    height = int(360)

    screen.fill(BLACK)
    ballLeft = pygame.draw.circle(screen, ballLeftColor, [ballLeftPosition,height], 30, 0)
    ballRight = pygame.draw.circle(screen, ballRightColor, [ballRightPosition,height], 30, 0)
    pygame.display.update()
    time.sleep(0.5)

    while True:

        for event in pygame.event.get():
            if event.type == pygame.QUIT: sys.exit()

        screen.fill(BLACK)
        ballLeft = pygame.draw.circle(screen, ballLeftColor, [ballLeftPosition,height], 30, 0)
        ballRight = pygame.draw.circle(screen, ballRightColor, [ballRightPosition,height], 30, 0)
        
        if ballRightPosition - ballLeftPosition >= threshold and stage != "back":
            ballLeftPosition += movementSpeed
            ballRightPosition -= movementSpeed
            pass
        if ballRightPosition - ballLeftPosition < threshold:
            ballLeftPosition -= movementSpeed
            ballRightPosition += movementSpeed
            stage = "back"
            pass
        if ballRightPosition - ballLeftPosition >= threshold and stage == "back":
            ballLeftPosition -= movementSpeed
            ballRightPosition += movementSpeed
            pass

        if ballRightPosition == 768 or ballLeftPosition == 256 and stage == "back":
            break

        pygame.display.update()
        # pygame.mouse.set_visible(False)
        pygame.time.Clock().tick(75)
        
    screen.fill(BLACK)
    ballLeft = pygame.draw.circle(screen, ballLeftColor, [ballLeftPosition,height], 30, 0)
    ballRight = pygame.draw.circle(screen, ballRightColor, [ballRightPosition,height], 30, 0)
    pygame.display.update()
    time.sleep(0.5)
    pass

# pygameの監視関数
def listen():
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            sys.exit()
            bye()
            pass
        pass
    pass

# レバー格納関数
def leverRetract(lever):
    board.digital[lever].write(0)
    pass

# レバー引き出し関数
def leverOut(lever):
    board.digital[lever].write(1)
    pass

# チャタリング防止関数
def protect():
    while leverLeftAct.read() == True or leverRightAct.read() == True:
        listen()
        time.sleep(0.01)
    pass

# CPUの使用率を下げる関数
def coolDown():
    time.sleep(0.01)
    pass

def reinforce(mount):
    # mountは強化量/粒数
    for i in range(mount):
        board.digital[feeder].write(1)
        time.sleep(0.5)
        board.digital[feeder].write(0)
        pass
    pass

# ITI関数
def ITI(itiTime):
    print("ITI中")
    for i in range(iti,0,-1):
        listen()
        print(i,"秒")
        # time.sleep(1)
        pygame.time.Clock().tick(1)
        # i = i - 1
        pass
    print('\n'+'===================='+'\n')
    pass

# データ保存関数
def dataSaving():
    # データを保存
    dataTransfer = [leverPressData, leverData, timeData, leverActData, latencyData, randomData]
    dataTransfer = list(zip(*dataTransfer))
    with open(answer2 + '.csv', 'a+') as myfile:
        writer = csv.writer(myfile)
        writer.writerows(dataTransfer)
    # 生成された乱数列を保存
    # randomList = list(zip(*randList))
    with open(answer2 + '_randomColorList.csv', 'a+') as myfile2:
        writer2 = csv.writer(myfile2)
        writer2.writerow(randList)
        pass
    with open(answer2 + '_randomMovementList.csv', 'a+') as myfile3:
        writer3 = csv.writer(myfile3)
        writer3.writerow(btList)
    pass

# 「後片付け」関数
def bye():
    dataSaving()
    board.digital[houseLight].write(0)
    board.digital[leverLeftMove].write(0)
    board.digital[leverRightMove].write(0)
    board.exit()
    pygame.quit()
    pass


# # 実験開始プロセス
# answer2 = input("今回の番号は？:\n")
# print("始めますか？")
# answer = input("Press Space then Enter:\n")
# waiting = True

# while waiting:
#     listen()
#     if answer == " ":
#         print('\n'+"========START!========"+'\n')
#         waiting = False
#     pygame.time.Clock().tick(75)

# 表頭書き込み
headers = ['Counter', 'LeverSide', 'Time', 'Trial', 'Latency', 'Big/Small']
with open(answer2 + '.csv', 'a+') as myfile:
    writer = csv.writer(myfile)
    writer.writerow(headers)
    pass

# 空き空間生成
for i in range(1000):
    leverActData.append('')
    latencyData.append('')
    randomData.append('')
    pass


# 乱数生成・1が3連以上存在しないか否かを検証
print("乱数生成中")
ransuTest()
# for bounce
while True:
    listen()
    if randList[randPosition] == 1 and randList[randPosition+1] == 1 and randPosition < 29:
        randCounter = randCounter + 1
    if randList[randPosition] == 0:
        randCounter = 0
    randPosition = randPosition + 1
    if randCounter >= 3:
        print("1が3連以上あり　やり直し中")
        randList = []
        ransuTest()
        randPosition = 0
        randCounter = 0
    if randPosition >= 29:
        break

randTemp1 = []
randTemp1 = randList
randList = []
randPosition = 0
ransu()
# for through
while True:
    listen()
    if randList[randPosition] == 1 and randList[randPosition+1] == 1 and randPosition < 29:
        randCounter = randCounter + 1
    if randList[randPosition] == 0:
        randCounter = 0
    randPosition = randPosition + 1
    if randCounter >= 3:
        print("1が3連以上あり　やり直し中")
        randList = []
        ransuTest()
        randPosition = 0
        randCounter = 0
    if randPosition >= 29:
        break

randTemp2 = []
randTemp2 = randList

randList = []
randList = randTemp1 + randTemp2
print("灰白リスト生成されました", '\n', randList)

# Through/Bounce list
btList = []
sumRand = 0
# 「半々」じゃないとずっと繰り返す
while sumRand != 30:
    # リセット
    btList = []
    sumRand = 0
    # 新しい乱数列を再生成
    sum0 = 0
    # 初期的乱数列を生成
    for i in range(60):
        btList.append(random.randint(0,1))
        i = i + 1
        pass
    # 4連以上しないように次の項目を調整
    for i in range(57):
        sum0 = btList[i] + btList[i+1] + btList[i+2]
        if sum0 == 0: # 0が3連になると次の項目を1に変わる
            btList[i+3] = 1
            pass
        if sum0 == 3: # 1が3連になると次の項目を0に変わる
            btList[i+3] = 0
            pass
        pass
    for i in range(60):
        sumRand = sumRand + btList[i]
        pass
    pass
print("Through/Bounceリスト生成されました", '\n', btList)


# 点灯！！
# board.digital[houseLight].write(1)
# Enterで実験開始
while True:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            sys.exit()
            bye()

    if pygame.key.get_pressed()[pygame.K_RETURN]:
        break

    time.sleep(0.01)


# 本実験
try:
    while timeNow - timeStart < timeMax:
        listen()
        timeNow = time.time()
        gogogo = 0

        # 最大試行数になったか否か
        if leverLeftTrial + leverRightTrial >= trialsMax:
            print("最大試行数に達して終了")
            print(timePast, "秒かかった")
            print("左レバー　", leverLeftTrial, "　回")
            print("右レバー　", leverRightTrial, "　回")
            break
            dataSaving()
            bye()
        
        # 消灯
        board.digital[houseLight].write(0)
        # 試行始まりのStart Button
        startbutton = pygame.draw.rect(screen, WHITE, [300,360,400,200])
        pygame.display.update()

        # 加速ループ
        while gogogo == 0:
            # Touching 探測
            mouse = pygame.mouse.get_pos()
            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    sys.exit()
                    bye()
                    pass
                # touching検出
                if event.type == pygame.MOUSEBUTTONDOWN:
                    # button反応？
                    if 300 <= mouse[0] <= 700 and 360 <= mouse[1] <= 560:
                        gogogo = 1
                        itiMask = pygame.draw.rect(screen, BLACK, [0,0,1280,720])
                        pygame.display.update()
                        time.sleep(0.5)
                pass

        # 乱数列から読み取って，0/1によって視覚刺激を呈示
        if btList[listPosition] == 0:
            if randList[listPosition] == 0:
                through(GREY1,WHITE)
                pass
            else:
                through(WHITE,GREY1)
                pass
            pass
        else:
            if randList[listPosition] == 0:
                bounce(GREY1,WHITE)
                pass
            else:
                bounce(WHITE,GREY1)
                pass
            pass
    

        # 正しくtouchingしたら
        while gogogo == 1:
            
            # 提示後大きな真っ黒四角マスキング
            itiMask = pygame.draw.rect(screen, BLACK, [0,0,1280,720])
            pygame.display.update()
            # 点灯
            board.digital[houseLight].write(1)
            # レバー呈示
            time.sleep(0.5)
            leverOut(leverLeftMove)
            leverOut(leverRightMove)
            # if btList[listPosition] == 0:
            #     leverOut(leverLeftMove)
            #     pass
            # else:
            #     leverOut(leverRightMove)
            #     pass
            timeTrialLever = time.time()
            rightAnswer = btList[listPosition]

            # レバー押しを測る
            while react != x: # 加速ループ → この部分に絞る
                listen()
                if reactLeft == x or reactRight == x:
                    react = x
                    reactLeft = 0
                    reactRight = 0
                    pass
                if leverLeftAct.read() == True:
                    # 回数の累進
                    leverPressCounter = leverPressCounter + 1
                    reactLeft = reactLeft + 1
                    # 時間を計って保存
                    timeNow = time.time()
                    timePast = round(timeNow - timeStart, 2)
                    timeData.append(timePast)
                    timeLatency = round(timeNow - timeTrialLever, 2)
                    latencyData.insert(leverPressCounter - 1, timeLatency)
                    # reactRight = 0 # 片方は不連続的なレバーを押しても認めるとコメントする
                    # レバー押しの回数を保存
                    leverPressData.append(leverPressCounter)
                    # 左右を判明して保存
                    leftRight = 'left'
                    leverData.append(leftRight)
                    print("反応", leverPressCounter)
                    print("左レバー ", reactLeft, "/", x, '\n')
                    protect()
                    pass
                elif leverRightAct.read() == True:
                    # 回数の累進
                    leverPressCounter = leverPressCounter + 1
                    reactRight = reactRight + 1
                    # 時間を計って保存
                    timeNow = time.time()
                    timePast = round(timeNow - timeStart, 2)
                    timeData.append(timePast)
                    timeLatency = round(timeNow - timeTrialLever, 2)
                    latencyData.insert(leverPressCounter - 1, timeLatency)
                    # reactLeft = 0 # 片方は不連続的なレバーを押しても認めるとコメントする
                    # レバー押しの回数を保存
                    leverPressData.append(leverPressCounter)
                    # 左右を判明して保存
                    leftRight = 'right'
                    leverData.append(leftRight)
                    print("反応", leverPressCounter)
                    print("右レバー ", reactRight, "/", x, '\n')
                    protect()
                    pass
                coolDown()

            # FRを達成したら：
            if leftRight == 'right' and react == x and rightAnswer == 1: # 右
                leverRetract(leverLeftMove)
                leverRetract(leverRightMove)
                react = 0
                leftRight = ''
                # 試行を累進
                trial = trial + 1
                leverRightTrial = leverRightTrial + 1
                leverActData.insert(leverPressCounter - 1, leverRightTrial)
                # モニターに表せ
                print("反発レバー", leverRightTrial)
                print("反応時間", timePast)
                print("反応潜時", timeLatency)
                print('\n'+'===================='+'\n')
                # 餌やり
                reinforce(1)
                # レバー引き込みとITI
                ITI(iti)
                timeTrialBlock = time.time()
                # 乱数列累進
                listPosition = listPosition + 1
                break
            elif leftRight == 'left' and react == x and rightAnswer == 0: # 左
                leverRetract(leverLeftMove)
                leverRetract(leverRightMove)
                react = 0
                leftRight = ''
                # 試行を累進する
                trial = trial + 1
                leverLeftTrial = leverLeftTrial + 1
                leverActData.insert(leverPressCounter - 1, leverLeftTrial)
                randomData.insert(leverPressCounter - 1, reinforcers)
                # モニターに表せ
                print("交差レバー", leverLeftTrial)
                print("反応時間", timePast)
                print("反応潜時", timeLatency)
                print('\n'+'===================='+'\n')
                # 餌やり
                reinforce(1)
                # レバー引き込みとITI
                ITI(iti)
                timeTrialBlock = time.time()
                # 乱数列累進
                listPosition = listPosition + 1
                break
            elif leftRight == 'left' and react == x and rightAnswer == 1: # 右が正解なのに左が押された場合
                leverRetract(leverLeftMove)
                leverRetract(leverRightMove)
                react = 0
                leftRight = ''
                board.digital[houseLight].write(0)
                print("反発試行に交差レバーを選んだ　誤反応")
                print("反応時間", timePast)
                print("反応潜時", timeLatency)
                print('\n'+'===================='+'\n')
                timeTrialBlock = time.time()
                time.sleep(0.5)
                break
            elif leftRight == 'right' and react == x and rightAnswer == 0: # 左が正解なのに右が押された場合
                leverRetract(leverLeftMove)
                leverRetract(leverRightMove)
                react = 0
                leftRight = ''
                board.digital[houseLight].write(0)
                print("交差試行に反発レバーを選んだ　誤反応")
                print("反応時間", timePast)
                print("反応潜時", timeLatency)
                print('\n'+'===================='+'\n')
                timeTrialBlock = time.time()
                time.sleep(0.5)
                break


        time.sleep(0.01)

    
    # 最大時間になったか否か
    else:
        print("最大時間に達して終了")
        print("左レバー　", leverLeftTrial, "　回")
        print("右レバー　", leverRightTrial, "　回")
        dataSaving()
        bye()
        pass

except KeyboardInterrupt:
    pass
    
dataSaving()
bye()
