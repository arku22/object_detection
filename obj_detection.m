clc;clear all;close all;
% Read_object
obj = imread('yoyo_3.jpeg');
obj = rgb2gray(obj);
imshow(obj);
title('Object image');
% Read reference_image, from which to find/detect object
ref = imread('pic11.jpeg');
ref = rgb2gray(ref);
figure;
imshow(ref);
title('Reference image');
%%
%Detecting feature points from both images
%from object image
object_pts = detectSURFFeatures(obj);
%from refernce image
refr_pts = detectSURFFeatures(ref);
%Show 50 strongest feature points in object image
figure;
imshow(obj);
hold on
plot(selectStrongest(object_pts, 50));
%Show 100 strongest feature points in the reference image
figure;
imshow(ref);
hold on
plot(selectStrongest(refr_pts, 100));
%Extract feature descriptors from both object and refr image
[boxFeatures, boxPoints] = extractFeatures(obj, object_pts);
[sceneFeatures, scenePoints] = extractFeatures(ref, refr_pts);
%Matching features from object image and reference image
boxPairs = matchFeatures(boxFeatures, sceneFeatures);
%Display matched features.
matchedBoxPoints = boxPoints(boxPairs(:, 1), :);
matchedScenePoints = scenePoints(boxPairs(:, 2), :);
figure;
showMatchedFeatures(obj, ref, matchedBoxPoints, ...
    matchedScenePoints, 'montage');
title('Matched Points (Including Outliers)');
%Locating the object in the reference imagee using these matches.
[tform, inlierBoxPoints, inlierScenePoints] = ...
    estimateGeometricTransform(matchedBoxPoints, matchedScenePoints,...
    'affine');
%display feature matches after eliminating outliers
figure;
showMatchedFeatures(obj, ref, inlierBoxPoints, ...
    inlierScenePoints,'montage');
title('Matched Points (Inliers Only)');
%Get bounding rectangle of reference image
boxPolygon = [1, 1;... 
        size(obj, 2), 1;... 
        size(obj, 2), size(obj, 1);...
        1, size(obj, 1);... 
        1, 1]; 
%Transforming polygon into coordinate system of target image
newBoxPolygon = transformPointsForward(tform, boxPolygon);
%Display final detected object
figure;
imshow(ref);
hold on;
line(newBoxPolygon(:, 1), newBoxPolygon(:, 2), 'Color', 'r','Linewidth',5);
title('Detected Box');

