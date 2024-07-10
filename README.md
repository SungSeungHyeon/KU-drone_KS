1. 대회 진행 전략

대회장의 상세 지도를 확인 후 링과 색간판의 장애물을 지나가는 것을 stage로 간주 stage 별로 전략 진행
맵의 지도를 확인 했을 떄 출발 지점과 색간판의 거리가 4.1m로 확인 됐음을 인지 및 링의 위치를 대략 확인 이후
드론의 카메라를 이용하여 RGB와 HSV의 값을 인식 이후 색간판의 색을 인지 이후 링의 중간지점과 미미한 차이 일 때
드론을 앞으로 진행 그 이후 드론을 회전 시키면서 다음 stage의 링과 간판을 인지하게 한다
이후 stage는 위와 같은 전략으로 진행 이후 착륙 지점은 링과 색간판의 중간지점이므로 그에 맞는 값을 드론에서 제공하여
드론의 착륙진행



2. 알고리즘 설명

사용한 툴 박스
- Image Processing Toolbox

- Ryze Tello Drone Support Package


stage 별 알고리즘 설명

1) stage_1
드론이라는 객체 선언 이후 드론 이륙
드론 이륙 이후 카메라로 링의 중심과 색간판의 HSV와 RGB값을 인식
원의 중심과 사각형을 인식 후 사각형 중점과 center_point 차이가 거의 없을 때 앞으로 진행
필요 지점까지 이동 이후 stage_2 방향으로 드론의 회전 진행

2) stage_2
드론의 회전 이후 원의 중심을 찾기 위한 드론의 회전 전 원의 중심찾기
드론의 전진 이후 stage_2에 있는 원의 중심 찾기
원의 중심을 찾은 뒤 stage_1과 같은 방식으로 원의 중심과 사각형을 인식 후 사각형 중점과 center_point 차이가 거의 없을 때 앞으로 진행
필요 지점까지 이동 이후 stage_3 방향으로 드론의 회전 진행

3) stage_3
드론의 회전 이후 원의 중심 찾기 시작
원의 중심을 찾은 뒤 stage_1과 같은 방식으로 원의 중심과 사각형을 인식 후 사각형 중점과 center_point 차이가 거의 없을 때 앞으로 진행
드론의 목표 지점까지 도달 이후 stage_4를 위한 회전 준비

4) stage_4
stage_4의 방향으로 회전 이후 stage_1의 방식을 통해 카메라로 링의중심과 색간판의 HSV와 RGB 값을 인식
원의 중심을 찾은 뒤 stage_1과 같은 방식으로 원의 중심과 사각형을 인식 후 사각형 중점과 center_point 차이가 거의 없을 때 앞으로 진행
충분히 앞으로 진행 이후 END 지점 도달 이후 드론의 착륙


3.소스코드 설명

중심점 저장하는 배열하는 코드
centroids = [];

영상크기는 960 x 720 그럼 센터점은 각각 1/2지점과 1/3지점
center_pts = [480, 240];

stage마다 다른 count 값을 주기 위해서 count 초기화
count = 0;
repeat_count = 0;

RGB 기준값 
channel1,2,3 순서대로 RGB
색 이진화 앱에서 그대로 들고 온 값
% Define thresholds for channel 1 based on histogram settings
channel1Min = 4.000;
channel1Max = 58.000;
% Define thresholds for channel 2 based on histogram settings
channel2Min = 16.000;
channel2Max = 88.000;
% Define thresholds for channel 3 based on histogram settings
channel3Min = 69.000;
channel3Max = 165.000;

HSV 기준값
channel4,5,6 순서대로 HSV
색 이진화 앱에서 그대로 들고 온 값

% Define thresholds for channel 4 based on histogram settings
channel4Min = 0.318;
channel4Max = 0.701;
% Define thresholds for channel 5 based on histogram settings
channel5Min = 0.650;
channel5Max = 1.000;
% Define thresholds for channel 6 based on histogram settings
channel6Min = 0.000;
channel6Max = 1.000;

객체선언 및 생성 후 이륙
drone = ryze("TELLO-5CB1FD");
    cam = camera(drone, 'FPV');
    takeoff(drone);
드론이 카메라로 영상을 캡처하고, RGB에서 HSV로 변환하여 파란색 범위를 검출합니다. regionprops 함수를 사용하여 검출된 영역의 속성을 측정하고, 가장 큰 영역의 중심점을 계산합니다. 이 중심점과 드론의 현재 위치 차이를 계산하여 드론을 이동시킵니다. 반복 과정을 통해 목표 위치에 도달하면 다음 스테이지로 넘어갑니다.

frame이라는 변수에 현재 카메라 영상 캡처해서 저장
frame = snapshot(cam);

% 카메라 영상 실시간
 preview(cam)
        pause(1);
    
화면 전체를 사각형으로 인식하는 경우 예외 처리
for j = 1:length(areaNemo)
            boxCh = areaNemo(j).BoundingBox; 
            if(boxCh(3) == 960 || boxCh(4) == 720)

가장 큰 영역일 때 속성 추출
areaCh <= areaNemo(j).Area
areaCh = areaNemo(j).Area;
                    centroid = areaNemo(j).Centroid;

원의 중심을 빨간색 + 표시로 마커사이즈 20으로 표시
plot(centroid(1), centroid(2), 'r+', 'MarkerSize', 20, 'LineWidth', 2);
        hold off

  사각형 중점과 center_point 차이
  dis = centroid - center_pts;

  사각형의 중점에서 x축y축이 사이거리 -35, 35안에있으면 while문에서 나온다
  dis(1) <= 35 && dis(1) >= -35 && dis (2) <= 35 && dis(2) >= -35
            disp("stage1 end")
            break

 조건문은 dis(1)과 dis(2)의 절대값이 각각 35 이하인지를 확인합니다. 이는 중심점과 현재 위치의 차이가 특정 범위 내에 있는지를 확인하는 것입니다.
if abs(dis(1)) <= 35 && abs(dis(2)) <= 35
    disp 
    break;
end
