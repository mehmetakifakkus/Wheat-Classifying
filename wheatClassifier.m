clear;
close all;%Onceki acik uygulamalari kapat
tic;%zaman sayacý baþlat

f = imread('d.jpg'); %Resmi okuyup bir degiskene at

gray = rgb2gray(f);   %Gri resme cevir
gray = imadjust(gray); %Resmin dusuk kontrastini gider

bw = ~im2bw(gray, graythresh(gray)); %thresholdunu al(otomatik uygula)
% bw = ~im2bw(gray, 0.53); %threshol manuel ayarlanabilir

se = strel('disk',3); %birleþtirme aracý seç
bw = imclose(bw,se); %aradaki parçalarý birleþtir

bw = imfill(bw,'holes'); %iç kýsýmdakiiboþluklarý doldur
bw = bwareaopen(bw,180); %belirli deðerde küçük olanlarý sil
cc = bwconncomp(bw, 8);

grain = false(size(bw));    %allocation for grain(temp for buðday olmayanlar)
result = false(size(bw));        %allocation for result(buðday olmayanlarý tutar)   
temp = uint8(zeros(size(gray)));    %allocation for temp(temp for süneli classification)

figure(1)                           %Resim uzerine yazi yazabilmek icin ayarlar
subplot('Position', [0 0 1 1]);
image(f);
truesize
axis off

bugdaydegil = 1;
for i = 1:cc.NumObjects
    grain = false(size(bw));
    grain(cc.PixelIdxList{i}) = true;
    
    x = floor(cc.PixelIdxList{i}(1) / cc.ImageSize(1));
    y = floor(mod(cc.PixelIdxList{i}(1), cc.ImageSize(1)));
    
    STATS = regionprops(grain, 'Eccentricity');
    if STATS.Eccentricity < 0.915 && STATS.Eccentricity > 0.450
        
        temp = uint8(zeros(size(gray))); %resim ile ayni boyutta bos resim olustur
        temp(cc.PixelIdxList{i}) = gray(cc.PixelIdxList{i}); %bir bugday sec
        BW = edge(temp,'canny',0.26);   %kenar bulma algoritmasi ile kenar tespiti
        cc2 = bwconncomp(BW,8);  % 8 komsuluk ile resmi dolas
        
        text(x-10, y-10, strcat('\fontsize{8}\color{red}\it\bf',int2str(i)));
        text(x+10, y-10, strcat('\fontsize{12}\color{green}\it\bf ', int2str(cc2.NumObjects)));
    else
        text(x-10, y-10, strcat('\fontsize{12}\color{white}\it\bf not',int2str(bugdaydegil)));
        bugdaydegil = bugdaydegil+1; % buðday olmayan sayýsýný artýr
%         result(cc.PixelIdxList{i}) = true;
    end;
end;
toc; %zaman sayacý bitir
% figure, imshow(result)
