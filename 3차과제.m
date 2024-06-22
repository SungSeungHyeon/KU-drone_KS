clear all;

% 이미지 이진화를 위한 기준 값들
channel1Min = [0.293, 0.275, 0.290, 0.306, 0.290];
channel1Max = [0.364, 0.386, 0.374, 0.390, 0.388];

channel2Min = [0.424, 0.497, 0.363, 0.394, 0.446];
channel2Max = [0.708, 0.816, 1.000, 0.728, 0.786];

channel3Min = [0.293, 0.316, 0.241, 0.271, 0.249];
channel3Max = [1.000, 1.000, 0.632, 0.781, 0.715];

% 중심값을 저장할 배열
centeroid_result = zeros(5,2);

for i = 1:5
    % 1. 이미지를 불러온다.
    img_file_name = sprintf('img%d.png', i);
    image = imread(img_file_name);
    % 2. hsv 값의 경계값(Threshold)를 찾고, 이것을 기준으로 이미지를 이진화한다
    [BW,maskedRGBImage] = createMask(image, ...
        channel1Min(i), channel1Max(i), ...
        channel2Min(i), channel2Max(i), ...
        channel3Min(i), channel3Max(i));

    % 3. 이진화된 이미지에서 엣지(canny)를 검출한다
    edge_BW = edge(BW, 'Canny', 0.8);                % canny 엣지 검출 시 인자 0.8
    edge_fill_img = imfill(edge_BW,'holes');        % 검출된 엣지 안을 채운다
    filter_img = medfilt2(edge_fill_img,[15 15]);   % 쓸데없는 엣지들을 필터링한다.(median 필터를 통한 노이즈 제거)

    % 4. 다각형의 경계선(boundary)을 찾고, 표시한다.
    boundaries = bwboundaries(filter_img);

    % 5. 사각형을 검출하고, 그에 대한 중심 좌표를 찾는다.
    % matlab 함수를 사용하였다.
    stats = regionprops(filter_img, 'Centroid', 'Area');

    % 가장 큰 사각형의 중심 좌표 선택
    if ~isempty(stats)
        areas = [stats.Area];
        [~, idx] = max(areas);
        centroid = stats(idx).Centroid;
        centeroid_result(i,1) = centroid(1);
        centeroid_result(i,2) = centroid(2);
    else
        centeroid_result(i,:) = [NaN, NaN];
    end
end
