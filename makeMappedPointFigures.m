function makeMappedPointFigures(locPath)
addpath F:\git\CARTO\
addpath C:\Users\pjh7\Dropbox\scanconversion\
addpath C:\Users\pjh7\Dropbox\arfiProcCode_v6_dev\

dataPath = {};

[rootpath datepath] = fileparts(fileparts(locPath));
cartoDataPath = fullfile(locPath,'cartoData');

CARTO_MAT_files = dir(fullfile(cartoDataPath,'CARTO*.mat'));
if isempty(CARTO_MAT_files);
xmlFiles = dir(fullfile(cartoDataPath,'Study*.xml'));
xmlFileName = fullfile(cartoDataPath,xmlFiles(1).name);
matFileName = convertCartoData(xmlFileName);
else
matFileName = fullfile(cartoDataPath,CARTO_MAT_files.name);
end
UserMapIndexFile = fullfile(cartoDataPath,'UserMapIndex.mat');
CARTO = processCartoStudy(matFileName,UserMapIndexFile,'y');

expPaths = {'Baseline_ARFISWEI','RFA_ARFISWEI'};

for eidx = 1:length(expPaths);
    dataPath{eidx} = fullfile(locPath,expPaths{eidx});
end

for ii = 1:length(dataPath);
    imDataFiles{ii} = fullfile(dataPath{ii},'res','scanconvertedImData.mat');
    imDataSC = load(imDataFiles{ii});
    imDataSC.STL.clim = [0 8];
    imDataSC.MTL.clim = [0 8];
    MaskFile = fullfile(dataPath{ii},'res','MASK.mat');
    imDataSC.MASK = load(MaskFile);
    imDataMasked(ii) = assignMASKtoAlpha(imDataSC);
end



for setIdx = 1:2;
    
imDataMask = convert_imData_G(imDataMasked(setIdx));
imDataMask.ARFI_INV.clim = [0.2 2];
imDataMask.STL_SWEI.clim = [0 50];
imDataMask.MTL_SWEI.clim = [0 50];
imDataMask = imDataMasked(setIdx);
fields = fieldnames(imDataMask);
imData = imDataMask.(fields{1});
[ptmask heatmap]= mapCartoPointsToImage(imData,CARTO.CartoPoints{1},CARTO.Tags);
epsdir = fullfile(dataPath{setIdx},'figures','eps');
pngdir = fullfile(dataPath{setIdx},'figures','png');

for black = 0:1;
print_on = 1;
if ~exist(epsdir,'dir')
    mkdir(epsdir);
end
if ~exist(pngdir,'dir')
    mkdir(pngdir);
end

figH = 1;
figure(figH);clf
if black
colordef(figH,'black')
else
colordef(figH,'white')
set(figH,'color','w');
end
set(figH,'defaultaxesfontsize',14,'defaultaxesfontweight','bold')
set(figH,'invertHardcopy','off','PaperPositionMode','auto');
%set(figH,'position',get(figH,'position').*[1 1 0 0] + [0 0 900 600]);
set(figH,'position',[5 1475 900 600]);
for frameIndex = 1:size(imDataMask.BMODE.cData,3);
sp = subplots(2,2,[0.05 0.15],[0.03 0.07 0.08 0.12]);
for fieldIdx = 1:4
    subplot(sp(fieldIdx))
    imData = imDataMask.(fields{fieldIdx});
    if fieldIdx == 1;
    %drawColorized(imData.lat,imData.axial,ptmask(:,:,frameIndex),(0.3+0.7*(min(1,ptmask(:,:,frameIndex)/3))).*(ptmask(:,:,frameIndex)>0),imDataMasked(2).BMODE.cData(:,:,frameIndex),jet,[0 1]);        
    drawColorized(imData.lat,imData.axial,heatmap(:,:,frameIndex),heatmap(:,:,frameIndex).^2,imDataMasked(setIdx).BMODE.cData(:,:,frameIndex),jet,[0 1]);            
    axis image
    else
    imh = imagesc(imData.lat,imData.axial,imData.cData(:,:,frameIndex),imData.clim);
    hold on
    drawColorized(imData.lat,imData.axial,medfilt2(imData.cData(:,:,frameIndex),[3 3]),(0.9+0.1*(imData.alphadata(:,:,frameIndex))).*(~isnan(imData.cData(:,:,frameIndex))),imDataMask.BMODE.cData(:,:,frameIndex),jet,imData.clim);
    set(imh,'visible','off')
    set(sp(fieldIdx),'clim',imData.clim);
    axis image
    pos = get(sp(fieldIdx),'position');
    cb = colorbar;
    set(sp(fieldIdx),'position',pos);
    ylabel(cb,imData.units);
    end
    addCornerText(imData.name,16,'NorthWest');
end
linkprop(sp,{'xlim','ylim','zlim'});
set(sp(1:end-1,:),'XtickLabel',{})
set(sp(:,2:end),'YTickLabel',{});
for i = 1:size(sp,1)
    ylabel(sp(i,1),'z (mm)');
end
for j = 1:size(sp,2);
    xlabel(sp(end,j),'x (mm)');
end

if print_on
    figname = sprintf('images_%s_%s_frame_%03.0f',datepath,expPaths{setIdx},frameIndex);
    if black
        print('-dpng',fullfile(pngdir,figname));
    else
        print('-depsc',fullfile(epsdir,figname));
    end
    set(sp,'xlim',[-12 12],'ylim',[0 20]);
    sprintf('zoomed_%s_%s_frame_%03.0f',datepath,expPaths{setIdx},frameIndex);
    if black
        print('-dpng',fullfile(pngdir,figname));
    else
        print('-depsc',fullfile(epsdir,figname));
    end
end
end
end
end