%% Debris Size Distribution (DSD) map
%
% When you use DSD map code in your work, please reference this 
% publication:
%
% Giaccone E., Lambiel C., Mariéthoz G., submitted. Large scale debris
% size mapping in alpine environment using UAVs imagery. Geomorphology.
%
% 
% Specify your current folder and select variables:

% Variables to upload:
SiteName_template='Martinets'; % write 'Outans' for the other focus site
cd(SiteName_template)
% - orthoimage (img, tiff format)
img=geotiffread(strcat(SiteName_template,'_img.tif')); 
% - roughness (tiff format)
roughness=imread(strcat(SiteName_template,'_roughness.tif')); 
% - NDVI (tiff format)
veg=imread(strcat(SiteName_template,'_ndvi.tif')); 
% - snow mask (tiff format)
snow=imread(strcat(SiteName_template,'_snow.tif')); %not present for Outans
% - glacier mask (tiff format)
glacier=imread(strcat(SiteName_template,'_glacier.tif')); %not present for Outans

%
% Parameters to define:
% rr = tile pixels per row 
rr = 5000;
% cc = tile pixels per column 
cc = 5000;
% xx = overlapping pixels per row
xx = 300;
% yy = overlapping pixels per column
yy = 300;
% valueR = number of tiles in vertical
valueR = 6; %martinets = 6; outans = 2
% valueC = number of tiles on horizontal
valueC = 5; %martinets = 5; outans = 2
% pixel = pixel resolution on cm of the UAV image 
pixel = 0.0575; %martinets = 0.0575; outans = 0.03
% smallestarea = detection limit for UAV imagery
smallestarea = 0.10;
% calibr_a = for the calibration, following the expression y = ax + b
calibr_a = 0.4764; %martinets = 0.4764; outans = 0.6825
% calibr_b = for the calibration, following the expression y = ax + b
calibr_b = 1.4043; %martinets = 1.4043; outans = 0.2309
% aream > value_calibr = define the value above which calibration is needed
value_calibr = 4.95; %martinets = 4.95; outans = 3.5
% coarsening = coarsening factor
coarsening = 30;
% radius = radius of pixels inside which calculate median and st.dev.
radius = 30;
% nx = define grid of x pixels
nx = 25000; %martinets = 25000; outans = 10000
% ny = define grid of y pixels
ny = 30000; %martinets = 30000; outans = 10000
% To add the masks, please specify the following parameters: 
%ndvi_val = NDVI threshold to accentuate grassland
ndvi_val = 0.25; %martinets = 0.25; outans = 0.16
% rough_val = roughness value to identify the area with low surface irregularity
rough_val = 0.025; %martinets = 0.025; outans = 0.012


%% Split orthophoto image into overlapping blocks

img(end+1000, :) = 0;   % new row at end
img(:, end+1000) = 0;   % new column at end

[row,col]=size(img);

numBlocksYY = numel(1:rr-xx:(row-(rr-1)));
numBlocksXX = numel(1:cc-yy:(col-(cc-1)));
[numBlocksYY, numBlocksXX];
C = cell(numBlocksYY*numBlocksXX,1);
counter = 1;
for ii=1:rr-xx:(row-(rr-1))
    for jj=1:cc-yy:(col-(cc-1))
        fprintf('[%d:%d, %d:%d]\n',ii,ii+rr-1,jj,jj+cc-1);
        C{counter} =  img(ii:(ii+rr-1), jj:(jj+cc-1), : );
        counter = counter + 1;
    end
    fprintf('\n');
end

figure(1);clf
for ii=1:numBlocksYY*numBlocksXX
    subplot(numBlocksYY,numBlocksYY,ii), imagesc( C{ii} ); axis image; colormap gray;
end

%% Save tiles in .png

for ii=1:counter-1
    baseFileName = sprintf('%d.png', ii); 
    imwrite(uint8(C{ii,1}), baseFileName);
end

%% After Basegrain process and saving output as .xlsx file, after also validation and eventually calibration,
% assemble single tile and  compute grain size

counter = 0;

my_Tab=[];
temp=[];

row=rr*valueR;
col=cc*valueC;

for ii=1:rr-xx:(row-(rr-1))
    for jj=1:cc-yy:(col-(cc-1))
        fprintf('[%d:%d, %d:%d]\n',ii,ii+rr-1,jj,jj+cc-1);
        counter = counter + 1;
        
        my_FileName = sprintf('%d_P00.xlsx', counter); 
        
        if isfile(my_FileName)
            points=xlsread(my_FileName,'fully detected elements');
            
            area=points(:,6);
            aream=area*pixel*pixel;
            xpts=points(:,7)+jj+64; % Basegrain cut 64 px at the borders of the tile
            ypts=row-(ii+points(:,8)+64);
            
            aream0=find(aream<smallestarea);
            aream(aream0)=[];
            xpts(aream0)=[];
            ypts(aream0)=[];
            
            if aream > value_calibr 
                aream = (aream-calibr_b)/calibr_a;
            end
            
            temp=[xpts ypts aream]; 
            my_Tab=[my_Tab;temp];
        end
    end
end
%% Visualize points
figure(2);clf
plot(my_Tab(:,1),my_Tab(:,2),'.')
axis equal

%% Calculate debris size distribution map

nx=ceil(nx/coarsening); 
ny=ceil(ny/coarsening);

xpts=my_Tab(:,1);
ypts=my_Tab(:,2);
aream=my_Tab(:,3);

xpts=xpts./coarsening;
ypts=ypts./coarsening;
radius=radius./coarsening;

image=nan(nx,ny);
uncert=nan(nx,ny);

for x=1:size(image,1)
    for y=1:size(image,2)
        d=sqrt( (x-xpts).^2 + (y-ypts).^2 );
        ind=(d<=radius);
        if sum(ind)==0;
            image(x,y)=nan;
        else
            image(x,y)=median(aream(ind)); % calculate median
        end
        uncert(x,y)=std(aream(ind)); % calculate standard deviation
       
    end
end


%% Visualization subplot

imagerot = imrotate(image,90);
uncertrot=imrotate(uncert,90);

figure(3);clf
subplot(2,1,1)
imagesc(imagerot)
axis equal tight
caxis([0 1.5])
colorbar

subplot(2,1,2)
imagesc(uncertrot)
axis equal tight
caxis([0 1.5])
colorbar


%% Fix the grid on meters and visualize DSD map

% cut empty borders if NaN in imagerot and uncertrot

V_Nan_l=zeros(length(imagerot(:,1)),1);
for i=1:length(imagerot(:,1))
    V_Nan_l(i)=length(imagerot(1,:))-sum(isnan(imagerot(i,:)));
end

V_Nan_c=zeros(length(imagerot(1,:)),1);
for i=1:length(imagerot(1,:))
    V_Nan_c(i)=length(imagerot(:,1))-sum(isnan(imagerot(:,i)));
end

imagerot=imagerot(V_Nan_l>0,V_Nan_c>0);

V_Nan_l=zeros(length(uncertrot(:,1)),1);
for i=1:length(uncertrot(:,1))
    V_Nan_l(i)=length(uncertrot(1,:))-sum(isnan(uncertrot(i,:)));
end

V_Nan_c=zeros(length(uncertrot(1,:)),1);
for i=1:length(uncertrot(1,:))
    V_Nan_c(i)=length(uncertrot(:,1))-sum(isnan(uncertrot(:,i)));
end

uncertrot=uncertrot(V_Nan_l>0,V_Nan_c>0);

% Fix the grid on meters (1 px = 1 m)

[rows,cols]=size(roughness);
[nx,ny]=size(imagerot);
stepy=ny/cols;
stepx=nx/rows;

[xtarget,ytarget]=meshgrid(1:stepy:ny,1:stepx:nx);
[xorig,yorig]=meshgrid(1:ny,1:nx);
fin_grid_median=interp2(xorig,yorig,imagerot,xtarget,ytarget);
fin_grid_std=interp2(xorig,yorig,uncertrot,xtarget,ytarget);

% Visualize

figure(4);clf
imagesc(fin_grid_median)
axis equal tight
caxis([0 5])
c = colorbar;
c.Label.String='square meters';
c.FontSize=18;
c.Label.FontSize = 18;
ylabel('meters','FontSize',18)
xlabel('meters','FontSize',18)
title('DSD map - Median','FontSize',22)
set(gca,'FontSize',18)

figure(5);clf
imagesc(fin_grid_std)
axis equal tight
caxis([0 5])
c = colorbar;
c.Label.String='square meters';
c.FontSize=18;
c.Label.FontSize = 18;
ylabel('meters','FontSize',18)
xlabel('meters','FontSize',18)
title('DSD map - St. Dev.','FontSize',22)
set(gca,'FontSize',18)

%% Create masks 

rough=double(roughness);
rough(rough>=rough_val)=1;
rough(rough<rough_val)=0;
rough(rough==1)=3;
rough(rough==0)=1;
rough(rough==3)=0;

veg=double(veg);
veg(veg>=ndvi_val)=1;
veg(veg<ndvi_val)=0;

snow=double(snow);
veg(snow==3)=NaN;
snow(snow==3)=200;

glacier=double(glacier);
glacier(glacier==0)=1;
glacier(glacier==-999)=NaN;

%% Visualize DSD map with masks 

fig=figure(6);clf
set(fig,'Position',[0 0 1000 1000])
imagesc(fin_grid_median)
axis equal tight
caxis ([0 5])
title('DSD map','FontSize',22)
ylabel('meters','FontSize',18)
xlabel('meters','FontSize',18)
c = colorbar;
c.Label.String='square meters';
c.FontSize=18;
c.Label.FontSize = 18;
set(gca,'FontSize',18)

pos=get(c,'Position');
pos(1)=pos(1)+0.05;
set(c,'Position',pos)

ax=axes
imagesc(rough*0,'AlphaData',rough);
axis off
axis equal tight
cmap=[[1 1 1];[1 1 1]]
colormap(ax,cmap)
linkaxes

ax=axes
imagesc(veg*0,'AlphaData',veg);
axis off
axis equal tight
cmap=[[0 1 0]]
colormap(ax,cmap)
linkaxes

ax=axes
imagesc(snow*0,'AlphaData',snow);
axis off
axis equal tight
cmap=[[1 1 1];[1 1 1]]
colormap(ax,cmap)
linkaxes

ax=axes
imagesc(glacier*0,'AlphaData',glacier);
axis off
axis equal tight
cmap=[[1 1 1];[1 1 1]]
colormap(ax,cmap)
linkaxes

cd('..')