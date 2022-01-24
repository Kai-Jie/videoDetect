# videoDetect


Main flow:
start from setUpAssetVideoCapture()


Thread 1:setUpAssetVideoCapture() -> assetVideoCapture.setUp() -> assetVideoCapture.start() -> assetVideoCapture.runVideo()+Object Identification

Thread 2:detect person -> set need record flag

Thread 3:if need record flag setted ->assetVideoRecord?.setUp()->recordVideo() 10s ->save video file

<img width="697" alt="截圖 2022-01-25 上午6 19 02" src="https://user-images.githubusercontent.com/6987553/150874609-683ec88d-bc92-4d6b-92b6-2c1a57f14fd5.png">
