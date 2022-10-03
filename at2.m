clc;

clear all;

img=imread('C:\Users\YOON\Desktop\working\images\210627Lectin\210627CD31\CD31 C=0 Z=22.jpg');

%img=rgb2gray(img);

%figure(1);

%eqim=histeq(img);

eqim=adapthisteq(img);

figure, imshow(eqim);

T=adaptthresh(eqim,0.58);

bwor=imbinarize(eqim,T);

figure, imshow(bwor);

se = strel('disk',8);

closeBW = imclose(bwor,se);

figure, imshow(closeBW);

se = strel('disk',5);

openBW=imopen(closeBW,se);

figure, imshow(openBW);

h = fspecial('average', [15 15]);

imav = imfilter(openBW, h);

figure, imshow(imav);

imav=imcomplement(imav);

CC = bwconncomp(imav);

BW2=bwareaopen(imav,15000);

%BW2=imcomplement(BW);

out = imoverlay(eqim, BW2,[1 0 0]);

figure, imshow(out);