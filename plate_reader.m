% Read and convert the image to grayscale
img = imread(uigetfile('.jpg'));
grayImg = rgb2gray(img);

% Display the original grayscale image
figure; imshow(grayImg); title('Car');

% Get image size and extract region of interest
[rows, cols, ~] = size(grayImg);
roi = grayImg(round(rows/3):end, 1:cols);

% Display the region of interest (LP Area)
figure; imshow(roi); title('LP Area');

% Threshold the image to create a binary mask
thresholdValue = 150;
binaryMask = roi > thresholdValue;

% Fill holes and apply median filtering
filledMask = imfill(binaryMask, 'holes');
filteredMask = medfilt2(filledMask, [4 4]);

% Apply additional median filtering
for i = 1:4
    filteredMask = medfilt2(filteredMask, [4 4]);
end
filteredMask = medfilt2(filteredMask, [5 5]);

% Display the filtered binary mask
figure; imshow(filteredMask, []);

% Fill holes again
filledMask = imfill(filteredMask, 'holes');

% Label connected components
[labeledMask, numObjects] = bwlabel(filledMask);
stats = regionprops(labeledMask, 'Area', 'Orientation', 'BoundingBox');
disp(numObjects);

% Filter objects by area
areaThreshold = 50000;
for i = 1:numObjects
    if stats(i).Area < areaThreshold
        labeledMask(labeledMask == i) = 0;
    end
end

% Relabel the connected components after removal
[labeledMask, numObjects] = bwlabel(labeledMask);
figure; imshow(labeledMask, []);
stats = regionprops(labeledMask, 'All');

% Display components with positive orientation
if numObjects > 2
    for i = 1:numObjects
        if stats(i).Orientation > 0
            figure; imshow(labeledMask == i);
        end
    end
    disp('exit');
end

% Extract bounding box for the largest object
largestBoundingBox = stats(1).BoundingBox;
xmin = round(largestBoundingBox(2));
xmax = round(largestBoundingBox(2) + largestBoundingBox(4));
ymin = round(largestBoundingBox(1));
ymax = round(largestBoundingBox(1) + largestBoundingBox(3));

% Extract and display the license plate area
lpRegion = roi(xmin+25:xmax-20, ymin+10:ymax-10);
figure; imshow(lpRegion, []);
