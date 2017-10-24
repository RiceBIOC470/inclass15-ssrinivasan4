%% step 1: write a few lines of code or use FIJI to separately save the
% nuclear channel of the image Colony1.tif for segmentation in Ilastik

%image is already the DAPI channel
%% step 2: train a classifier on the nuclei
% try to get the get nuclei completely but separe them where you can
% save as both simple segmentation and probabilities

%done in ilastik
%% step 3: use h5read to read your Ilastik simple segmentation
% and display the binary masks produced by Ilastik 
step3im=h5read('inclass15.h5', '/exported_data');
step3im=squeeze(step3im);
imshow(step3im, []);
% (datasetname = '/exported_data')
% Ilastik has the image transposed relative to matlab
% values are integers corresponding to segmentation classes you defined,
% figure out which value corresponds to nuclei

%% step 3.1: show segmentation as overlay on raw data
img=imread('48hColony1_DAPI.tif');
imshow(img, []);
hold on;
imshow(step3im, []);
hold off;
%% step 4: visualize the connected components using label2rgb
% probably a lot of nuclei will be connected into large objects
step4im=label2rgb(img);
imshow(step4im);

%% step 5: use h5read to read your Ilastik probabilities and visualize
step5im=h5read('Prediction for Label 2.h5', '/exported_data');

step5im=squeeze(step5im);
imshow(step5im);

% it will have a channel for each segmentation class you defined



%% step 6: threshold probabilities to separate nuclei better
step6im=step5im > 0.95;
imshow(step6im);
%% step 7: watershed to fill in the original segmentation (~hysteresis threshold)
step7im = bwconncomp(step6im);
stats_7 = regionprops(step7im,'Area');
area_7 = [stats_7.Area];

img7_sqrt = round(1.2*sqrt(mean(area_7))/pi);
img7_erode = imerode(step6im,strel('disk',img7_sqrt));
img7_outside = ~imdilate(step6im,strel('disk',1));
img7_basin = imcomplement(bwdist(img7_outside));
img7_basin = imimposemin(img7_basin,img7_erode|img7_outside);
img7_watershed = watershed(img7_basin);
imshow(img7_watershed, []);

%% step 8: perform hysteresis thresholding in Ilastik and compare the results
% explain the differences

%hysteresis performed in Ilastik

%between Ilastik and the matlab watershed, Ilastik performed better at edge
%detection and segmentation of areas where the nuclei overlapped. This is
%likely due to the erosion performed during the watershed that eroded some
%of the edges of the nuclei.

%% step 9: clean up the results more if you have time 
% using bwmorph, imopen, imclose etc

