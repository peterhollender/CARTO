function Handles = displayCartoStudy(CARTO,figureHandle)
Handles.all = [];
if ~exist('figureHandle','var');
    Handles.figureHandle = 200;
else
    Handles.figureHandle = figureHandle;
end
figure(Handles.figureHandle);clf;
Handles.ActivationTimeRange = {[-180 -140],[-20 10]};
ActivationColorMap = activationTime(Handles.ActivationTimeRange{1},Handles.ActivationTimeRange{2},jet(256));
if isfield(CARTO,'Mesh')
Handles.MeshHandle = [];
    for MeshIndex = 1:length(CARTO.Mesh)
        Handles.MeshHandle(MeshIndex) = drawCartoMesh(CARTO.Mesh(MeshIndex),'LAT',[Handles.ActivationTimeRange{1}(1) Handles.ActivationTimeRange{2}(2)],ActivationColorMap,'facelight','gouraud','EdgeColor','none');
    end
end
Handles.all = [Handles.all;Handles.MeshHandle(:)];
colormap(activationTime([-180 -140],[-20 10],jet(256)))
hold on
colormap jet
axis image
axis xy
cameratoolbar('show')
set(gca,'color','k')

%resFiles = dir(fullfile(CARTO.resFileDataPath,'res*'));  
%NumFrames = length(CARTO.Frames);
%NumRes = length(resFiles);
%NumContours = length(CARTO.Contours);

% if NumRes == NumFrames && NumRes == NumContours
%     fprintf('Frames, Contours, and ARFI Data Align!\n')
%     FrameIndices = 1:NumFrames;
%     ContourIndices = 1:NumContours;
%     ResIndices = 1:NumRes;
%     if isfield(CARTO.UserMapIndex,'ResIndices')
%     FrameIndices = CARTO.UserMapIndex.ResIndices;
%     ContourIndices = CARTO.UserMapIndex.ResIndices;
%     ResIndices = CARTO.UserMapIndex.ResIndices;
%     end    
% elseif NumRes == NumFrames && NumRes ~= NumContours
%     fprintf('Frames and ARFI data align, but Contours do not. Attempting to extract timestamps from Contours...\n')
%     Comments = {CARTO.Contours.Comment}';
%     ContourIndices = 1:NumContours;
%     ResIndices = zeros(1,NumContours);
%         for ResIdx = 1:NumRes
%             resFileName = resFiles(ResIdx).name;
%             timeidx = regexp(resFileName,'\d\d\d\d\d\d\d\d\d\d\d\d\d');
%             endidx = timeidx +13;
%             resTimeStamp{ResIdx} = char(resFileName(timeidx:endidx));
%         end
%         for CIdx = 1:NumContours
%             Comment = Comments{CIdx};
%             timeidx = regexp(Comment,'\d\d\d\d\d\d\d\d\d\d\d\d\d');
%             if ~isempty(timeidx)
%             endidx = timeidx +13;
%             contourTimeStamp{CIdx} = char(Comment(timeidx:endidx));
%             ResIndices(CIdx) = find(strcmpi(contourTimeStamp{CIdx},resTimeStamp));
%             else
%             contourTimeStamp{CIdx} = '';
%             end
%         end
%         validIdx = find(ResIndices);
%         ResIndices1 = ResIndices;
%         for i = 1:NumContours
%             if ResIndices(i) == 0;
%                 lookback = find(ResIndices(i:-1:1),1,'first');
%                 if isempty(lookback)
%                     lookforward = find(ResIndices(i:end),1,'first');
%                     ResIndices1(i) = ResIndices(i+lookforward-1)-lookforward+1;
%                 else
%                     ResIndices1(i) = ResIndices(i-lookback+1)+lookback-1;
%                 end
%             else
%                 ResIndices1(i) = ResIndices(i);
%             end
%         end
%         ResIndices = ResIndices1;
%         clear ResIndices1;
%         FrameIndices = ResIndices;
% else
%     ResIndices = [];
%     FrameIndices = 1:NumFrames;
%     ContourIndices = 1:NumContours;
% end
%    
Handles.FrameHandle = drawFrameOutline(CARTO.Frames);
Handles.BmodeHandle = drawBmode(CARTO.Frames,CARTO.CartoDataPath);
Handles.all = [Handles.all;[Handles.FrameHandle{:}]'];
Handles.all = [Handles.all;[Handles.BmodeHandle{:}]'];
Handles.ContourHandle = {};

for ii = 1:length(CARTO.Contours)
for ContourIdx = 1:length(CARTO.Contours{ii});
Contour = CARTO.Contours{ii}(ContourIdx);
Handles.ContourHandle{ii}(ContourIdx) = plot3(Contour.X,Contour.Y,Contour.Z,'w-','linewidth',1);
end
end
Handles.all = [Handles.all;[Handles.ContourHandle{:}]'];
axis image
% ARFIHandle = zeros(1,length(ResIndices));
% 
% fprintf('Transforming Image %02.0f',0);
% for i = 1:length(ResIndices);
%     fprintf('\b\b%02.0f',i)
% ResIdx = ResIndices(i);
% if ~resFiles(ResIdx).isdir
%     resFileName = fullfile(CARTO.resFileDataPath,resFiles(ResIdx).name);
%     timestamp = RetrieveTimeStamp(resFiles(ResIdx).name);
%     CARTO.roiPath = fullfile(fileparts(fileparts(CARTO.resFileDataPath)),'roi');
%     roiFileName = fullfile(CARTO.roiPath,sprintf('roi_%s.mat',timestamp));
% im = load(resFileName);
%     if exist(roiFileName,'file')
%         roiData = load(roiFileName);
% %        BW = roiData.ROI;
%         BW = roipoly(im.theta,im.axial,ones(length(im.axial),length(im.theta)),roiData.theta,roiData.axial);
%     else
% x0 = CARTO.Contours(ResIdx).X;
% y0 = CARTO.Contours(ResIdx).Y;
% z0 = CARTO.Contours(ResIdx).Z;
% [xc yc zc] = applyTransformation(x0,y0,z0,inv(CARTO.Frames(ResIdx).XducerToWorldMatrix')');
% th = atand(zc./(yc-im.apex));
% r = yc./cosd(th);
% BW = roipoly(im.theta,im.axial,ones(length(im.axial),length(im.theta)),th,r);
%     end
% if isfield(im,'CT_SMURF')
% cdata = mediannan(im.CT_SMURF(1:end,1:end-1),[5 5]);
% im.theta = 0.5*(im.theta(1:end-1)+im.theta(2:end));
% clim = [0 8];
% colormap sping
% elseif isfield(im,'CT_TTPS')
% cdata = mediannan(nanmedian(im.CT_DTTPS,3),[5 5]);
% clim = [0 8];
% colormap spring
% else
% cdata = nanmax(im.arfidata(:,:,10:20),[],3);
% clim = [0 10];
% colormap cool
% %cdata = cdata.*repmat(exp(im.axial(:)/10),[1 size(cdata,2)]);
% end
% cdata(~BW) = nan;
% axidx = find(any(~isnan(cdata),2));
% thidx = find(any(~isnan(cdata),1));
% % bmodedata0 = interp1(im.btheta,im.bmodedata0',im.theta)';
% % nanmask = 10*db(double(im.cc(:,:,15))/255)+db(bmodedata0)>-30;
% % nanmask = imclose(imopen(nanmask,strel('disk',3)),strel('disk',3));
% % cdata(~nanmask) = nan;
% % axidx = 1:find(im.axial>20,1,'first');
% ARFIHandle(i) = imsurf(im.theta(thidx),im.axial(axidx),im.apex,cdata(axidx,thidx),clim);
% set(ARFIHandle(i),'AlphaData',double(BW(axidx,thidx)));
% xd = get(ARFIHandle(i),'zData');
% yd = get(ARFIHandle(i),'yData');
% zd = get(ARFIHandle(i),'xData');
% [xdt ydt zdt] = applyTransformation(xd,yd,zd,CARTO.Frames(ResIdx).XducerToWorldMatrix);
% set(ARFIHandle(i),'XData',xdt,'YData',ydt,'ZData',zdt);
% set(ARFIHandle(i),'FaceLighting','none','FaceAlpha','Flat')
% end
% end
% fprintf('\n')
% CARTO.ARFIHandle = ARFIHandle(find(ARFIHandle));

%%
if isfield(CARTO,'CartoPoints')
for ii = 1:length(CARTO.CartoPoints)
    if ~isempty(CARTO.CartoPoints{ii})
Handles.PointsHandle{ii} = drawCartoPoints(CARTO.CartoPoints{ii},CARTO.Tags);
    end
end
if isfield(Handles,'PointsHandle')
Handles.PointLegend = legend([Handles.PointsHandle{:}],'location','northeast');
end
end
if isfield(Handles,'PointsHandle')
Handles.all = [Handles.all;[Handles.PointsHandle{:}]'];
end

