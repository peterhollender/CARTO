FramesetIdx = 2;
for FrameIdx = 1:length(CARTO.UserMapIndex.resFileNames{FramesetIdx})
        Frame = CARTO.Frames{FramesetIdx}(FrameIdx);
        resfile = fullfile(CARTO.UserMapIndex.resFilePaths{FramesetIdx},CARTO.UserMapIndex.resFileNames{FramesetIdx}{FrameIdx});
        timestamp = RetrieveTimeStamp(resfile);
        CARTO.roiPath = fullfile(fileparts(fileparts(fileparts(CARTO.UserMapIndex.resFilePaths{FramesetIdx}))),'roi');
        roiFileName = fullfile(CARTO.roiPath,sprintf('roi_%s.mat',timestamp));
        res(FrameIdx) = load(resfile);
        roiData(FrameIdx) = load(roiFileName);
        BW(:,:,FrameIdx) = roipoly(res(FrameIdx).theta,res(FrameIdx).axial,ones(length(res(FrameIdx).axial),length(res(FrameIdx).theta)),roiData(FrameIdx).theta,roiData(FrameIdx).axial);
end
%%

%%
clf
hold on
im = imsurf(res(1).theta,res(1).axial,res(1).apex,nanmedian(res(1).CT_SMURF,3),[0 8]);
im2 = imsurf(res(1).theta,res(1).axial,res(1).apex,max(double(res(1).arfidata(:,:,[10:20]))*res(1).arfi_scale,[],3),[0 10]);
bim = imsurf(res(1).theta,res(1).axial,res(1).apex,double(res(1).bmodedata0(:,:,[1 1 1]))/255);
set(im2,'xdata',get(im2,'xdata')-30)
set(bim,'xdata',get(bim,'xdata')+30);
axis image
for i = 1:length(res);
    set(im,'cdata',nanmedian(res(i).CT_SMURF,3),'alphadata',max(0.5,double(BW(:,:,i))),'facealpha','flat','alphaDataMapping','none');
    set(im2,'cdata',max(double(res(i).arfidata(:,:,[10:20]))*res(1).arfi_scale,[],3),'alphadata',max(0.5,double(BW(:,:,i))),'facealpha','flat','alphaDataMapping','none');
    set(bim,'cdata',double(res(i).bmodedata0(:,:,[1 1 1]))/255);
    pause(1);
end