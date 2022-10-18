clc, clear

%% intensity distribution graph 

load('Data_E4B5.BLK.mat');

%% Creating roation and isolation matrices 
coordValues1 = [623, 803, 695, 876; 292, 212, 471, 395];
coordValues2 = [111, 271, 222, 378; 607, 493, 765, 651];
coordValues3 = [493, 657, 576, 757; 831, 733, 1000, 903];

mValue1 = (coordValues1(2,2)-coordValues1(2,1))/(coordValues1(1,2)-coordValues1(1,1));
mValue2 = (coordValues2(2,2)-coordValues2(2,1))/(coordValues2(1,2)-coordValues2(1,1));
mValue3 = (coordValues3(2,2)-coordValues3(2,1))/(coordValues3(1,2)-coordValues3(1,1));

for j = 1:1:3
    mValueI = sprintf('mValue%i',j);
    rotationAngle(j) = atan(eval(mValueI))*180/pi; 
    
end
    



%% 
for i = 0:1:99

fileName = sprintf('c0f%i',i);

figure(1);

subplot(2,3,1);% Shows original image 
imagesc(eval(fileName));
colormap(gray);
title('Original Image');
subplot(2,3,2);
im = imadjust(mat2gray(eval(fileName)));
imshow(im);
title('Adjusted Image');


 % rotates the image 
rotatedImage1 = imrotate(im, rotationAngle(1),'bilinear','crop');
rotatedImage2 = imrotate(im,rotationAngle(2),'bilinear','crop');
rotatedImage3 = imrotate(im,rotationAngle(3),'bilinear','crop');
% imshow(J);

cropLED1 = [698, 358, 887-698, 556-358]; 
cropLED2 = [121, 365, 314-121, 554-365];
cropLED3 = [323, 781, 517-323, 979-781];

croppedImage1 = imcrop(rotatedImage1,cropLED1);
croppedImage2 = imcrop(rotatedImage2,cropLED2);
croppedImage3 = imcrop(rotatedImage3,cropLED3);
 %%
sgtitle(sprintf('LEDs at data acqusition, iteration number: %d',i));
subplot(2,3,4);
imshow(croppedImage1);
title('Red LED');
subplot(2,3,5);
imshow(croppedImage2);
title('Green LED');
subplot(2,3,6);
imshow(croppedImage3);
title('Off LED');

matrix1(:, :, i + 1) = croppedImage1; 
matrix2(:, :, i + 1) = croppedImage2; 
matrix3(:, :, i + 1) = croppedImage3; 

% pause(0.1);
end 
 %% 
figure(3)
subplot(2,3,1);
RED1 = matrix1(:,:,1:2:99);
meanRedOn = mean(RED1, 3); 
h1 = histogram(meanRedOn); h1.NumBins = 60; h1.BinLimits = [0, 1]; 
title('Red LED on');


subplot(2,3,4);
RED2 = matrix1(:,:,2:2:100);
meanRedOff = mean(RED2,3);
h2 = histogram(meanRedOff); h2.NumBins = 60; h2.BinLimits = [0, 1]; 
title('Red LED off');

subplot(2,3,5);
GREEN1 = matrix2(:,:,1:2:99);
meanGreenOff = mean(GREEN1,3);
h3 = histogram(meanGreenOff); h3.NumBins = 60; h3.BinLimits = [0, 1]; 
title('Green LED off');


subplot(2,3,2);

GREEN2 = matrix2(:,:,2:2:100);
meanGreenOn = mean(GREEN2, 3);
h4 = histogram(meanGreenOn); h4.NumBins = 60; h4.BinLimits = [0, 1]; 
title('Green LED on');

subplot(2,3,3);

OFFLED1 = matrix3(:,:,1:2:99);
meanOFFLED1 = mean(OFFLED1,3);
h5 = histogram(meanOFFLED1); h5.NumBins = 60; h5.BinLimits = [0, 1]; 
title('Off LED 1');


subplot(2,3,6);
OFFLED2= matrix3(:,:,2:2:100);
meanOFFLED2 = mean(OFFLED2,3);
h6 = histogram(meanOFFLED2); h6.NumBins = 60; h6.BinLimits = [0, 1]; 
title('OFF LED 2');

% total illumination
redOnTotalIllumination = sum(meanRedOn, 'all'); 
redOffTotalIllumination = sum(meanRedOff, 'all'); 
greenOnTotalIllumination = sum(meanGreenOn, 'all'); 
greenOffTotalIllumination = sum(meanGreenOff, 'all'); 




threshold1 = median(median(meanOFFLED1));
threshold2 = 0.35; 

counterRedOn = 0; 
counterRedOff = 0; 
counterGreenOn = 0; 
counterGreenOff = 0; 
for m = 1:1: size(meanRedOn,1)
    for n = 1:1: size(meanRedOn,2)
        if meanRedOn(m,n) <= threshold1 
            meanRedOn(m,n) = 0;
        end
        if meanRedOn(m,n) >= threshold2
            counterRedOn = counterRedOn + 1;
        end
    end 
end

for m = 1:1: size(meanRedOff,1)
    for n = 1:1: size(meanRedOff,2)
        if meanRedOff(m,n) <= threshold1 
            meanRedOff(m,n) = 0;
        end
        if meanRedOff(m,n) >= 0.35
            counterRedOff = counterRedOff + 1;
        end
    end 
end

for m = 1:1: size(meanGreenOn,1)
    for n = 1:1: size(meanGreenOn,2)
        if meanGreenOn(m,n) <= threshold1 
            meanGreenOn(m,n) = 0;
        end 
        if meanGreenOn(m,n) >= 0.35
            counterGreenOn = counterGreenOn + 1;
        
        end
    end 
end


for m = 1:1: size(meanGreenOff,1)
    for n = 1:1: size(meanGreenOff,2)
        if meanGreenOff(m,n) <= threshold1 
            meanGreenOff(m,n) = NaN;
        end 
        if meanGreenOff(m,n) > 0.35
            counterGreenOff = counterGreenOff + 1;
        
        end
    end 
end



figure(4)
sgtitle('LED Histograms with threshold applied');
subplot(2,2,1);
h1 = histogram(meanRedOn); h1.NumBins = 60; h1.BinLimits = [0, 1]; 
title("Red LED on, number of pixels illuminated: " + counterRedOn);

redOnIlluminationPercent = (counterRedOn * 100)/(size(meanRedOn,1) * size(meanRedOn, 2)); 
xlabel("Red LED On state illumination percentage ="+ redOnIlluminationPercent +"%"); 

subplot(2,2,3);
h2 = histogram(meanRedOff); h2.NumBins = 60; h2.BinLimits = [0, 1]; 
title('Red LED off, number of pixels illuminated: ', counterRedOff);

redOffIlluminationPercent = (counterRedOff * 100)/(size(meanRedOff,1) * size(meanRedOff, 2)); 
xlabel("Red LED Off state illumination percentage ="+ redOffIlluminationPercent +"%"); 

subplot(2,2,4);
h3 = histogram(meanGreenOff); h3.NumBins = 60; h3.BinLimits = [0, 1]; 
title('Green LED off, number of pixels illuminated: ', counterGreenOn);

greenOffIlluminationPercent = (counterGreenOff * 100)/(size(meanGreenOff,1) * size(meanGreenOff, 2)); 
xlabel("Green LED Off state illumination percentage ="+ greenOffIlluminationPercent +"%");  


subplot(2,2,2);
h4 = histogram(meanGreenOn); h4.NumBins = 60; h4.BinLimits = [0, 1]; 
title('Green LED on, number of pixels illuminated: ', counterGreenOff);

greenOnIlluminationPercent = (counterGreenOn * 100)/(size(meanGreenOn,1) * size(meanGreenOn, 2)); 
xlabel("Green LED On state illumination percentage ="+ greenOnIlluminationPercent +"%");  

figure(5)
sgtitle('Images with thresholds applied');
subplot(2,2,1);
imshow(meanRedOn);
title("Red LED on, number of pixels illuminated: " + counterRedOn);

redOnIlluminationPercent = (counterRedOn * 100)/(size(meanRedOn,1) * size(meanRedOn, 2)); 
xlabel("Red LED On state illumination percentage ="+ redOnIlluminationPercent +"%"); 

subplot(2,2,3);
imshow(meanRedOff);  
title('Red LED off, number of pixels illuminated: ', counterRedOff);

redOffIlluminationPercent = (counterRedOff * 100)/(size(meanRedOff,1) * size(meanRedOff, 2)); 
xlabel("Red LED Off state illumination percentage ="+ redOffIlluminationPercent +"%"); 

subplot(2,2,4);
imshow(meanGreenOff);
title('Green LED off, number of pixels illuminated: ', counterGreenOn);

greenOffIlluminationPercent = (counterGreenOff * 100)/(size(meanGreenOff,1) * size(meanGreenOff, 2)); 
xlabel("Green LED Off state illumination percentage ="+ greenOffIlluminationPercent +"%");  


subplot(2,2,2);
imshow(meanGreenOn);
title('Green LED on, number of pixels illuminated: ', counterGreenOff);

greenOnIlluminationPercent = (counterGreenOn * 100)/(size(meanGreenOn,1) * size(meanGreenOn, 2)); 
xlabel("Green LED On state illumination percentage ="+ greenOnIlluminationPercent +"%");  


disp(['Total Illumination Red On = ', num2str(redOnTotalIllumination)] ); 
disp( ['Total Illumination Red Off = ', num2str(redOffTotalIllumination)] );
disp(['Total Illumination Green On =  ', num2str(greenOnTotalIllumination) ]);
disp(['Total Illumination Green Off =  ', num2str(greenOffTotalIllumination)]);