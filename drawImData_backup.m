function imHandle = drawImData(x,z,cData,aData,Frames)
NextPlot = get(gca,'NextPlot');
cellOutput = 0;
if ~iscell(Frames)
    Frames = {Frames};
else
    cellOutput = 1;
end
if ~iscell(cData)
    cData = {cData};
else
    cellOutput = 1;
end
imHandles = {};
fields = fieldnames(imData{1}(1));
fieldIdx = find(strcmpi(imField,fields),1,'first');
imField = fields{fieldIdx};

for cellIdx = 1:length(Frames)
    Frame = Frames{cellIdx};
    cData0 = imData{cellIdx}(1).(imField).cData;
    aData0 = imData{cellIdx}(1).(imField).alphadata;
    for frameIdx = 1:length(Frame);
    cData0(:,:,frameIdx) = imData{cellIdx}(frameIdx).(imField).cData;
    %aData0(:,:,frameIdx) = imData{cellIdx}(frameIdx).(imField).alphadata;
    bData0 = imData{cellIdx}(frameIdx).('BMODE').cData;
    aData0(:,:,frameIdx) = bData0(:,(1:size(cData0,2))+round((size(bData0,2)-size(cData0,2))/2))>0.1;
    
    end
    im = imData{cellIdx}(1).(imField);
    scanconvertOpts = struct(...
    'latmin',1e-3*sind(min(im.theta))*(max(im.axial)-im.apex),...  1e-2*sin(min(btheta))*par.imagingdepth,...
    'latmax',1e-3.*sind(max(im.theta))*(max(im.axial)-im.apex),... 1e-2*sin(max(btheta))*par.imagingdepth,...
    'latinc',.1e-3,...
    'axialmin',-1e-3*im.apex,...
    'axialmax',1e-3*(max(im.axial)) - 1e-3*im.apex,...
    'axialinc',.1e-3,...
    'min_phi',min(im.theta),...
    'span_phi',max(im.theta)-min(im.theta),...
    'apex',0.1*im.apex,...
    'fsiq',770/mean(diff(im.axial))*1e3...
    );
    [cData z x] = Scan_Convert_Sector(cData0,scanconvertOpts);
    [aData z x] = Scan_Convert_Sector(aData0,scanconvertOpts);
    [X Z] = meshgrid(linspace(x(1),x(end),2),linspace(z(1),z(end),2));
    %[X Z] = meshgrid(x,z);
    for frameIdx = 1:length(Frame);    
        imHandle{cellIdx}(frameIdx) = surf(X,Z,0*Z,cData(:,:,frameIdx),'edgecolor','none','FaceColor','texture');
        set(imHandle{cellIdx}(frameIdx),'alphadata',aData(:,:,frameIdx),'FaceAlpha','texture');
%        imHandle{cellIdx}(frameIdx) = imsurf(im.theta,im.axial,im.apex,im.cData,im.clim);
%         set(imHandle{cellIdx}(frameIdx),'alphadata',abs(im.alphadata),'facealpha','texture','alphadatamapping','none')
         xd = get(imHandle{cellIdx}(frameIdx),'zData');
         yd = get(imHandle{cellIdx}(frameIdx),'yData');
         zd = get(imHandle{cellIdx}(frameIdx),'xData');
         [xdt ydt zdt] = applyTransformation(xd,yd,zd,Frames{cellIdx}(frameIdx).XducerToWorldMatrix);
         set(imHandle{cellIdx}(frameIdx),'XData',xdt,'YData',ydt,'ZData',zdt);
         %set(imHandle{cellIdx}(frameIdx),'FaceLighting','none','FaceAlpha','Flat')
        if cellIdx == 1 && frameIdx == 1;
            set(gca,'NextPlot','add');
        end
    end
end
if ~cellOutput;
    imHandle = imHandle{1};
end
set(gca,'NextPlot',NextPlot);
% 
% 
% 
% 
% 
% 
% 
% CARTO,Frameset,FieldName,maxImageSize)
% Frames = CARTO.Frames;
% for cellIdx = 1:length(Frameset)
%     FramecellIdx = Frameset(cellIdx);
%     for frameIdx = 1:length(Frames{FramecellIdx})
%         Frame = Frames{FramecellIdx}(frameIdx);
%         resfile = fullfile(CARTO.UserMapIndex.resFilePaths{FramecellIdx},CARTO.UserMapIndex.resFileNames{FramecellIdx}{frameIdx});
%         timestamp = RetrieveTimeStamp(resfile);
%         CARTO.roiPath = fullfile(fileparts(fileparts(fileparts(CARTO.UserMapIndex.resFilePaths{FramecellIdx}))),'roi');
%         roiFileName = fullfile(CARTO.roiPath,sprintf('roi_%s.mat',timestamp));
%         im = load(resfile);
%         if exist(roiFileName,'file')
%             roiData = load(roiFileName);
%             BW = roipoly(im.theta,im.axial,ones(length(im.axial),length(im.theta)),roiData.theta,roiData.axial);
%         else
%             x0 = CARTO.Contours{FramecellIdx}(frameIdx).X;
%             y0 = CARTO.Contours{FramecellIdx}(frameIdx).Y;
%             z0 = CARTO.Contours{FramecellIdx}(frameIdx).Z;
%             [xc yc zc] = applyTransformation(x0,y0,z0,inv(CARTO.Frames{FramecellIdx}(frameIdx).XducerToWorldMatrix')');
%             th = atand(zc./(yc-im.apex));
%             r = yc./cosd(th);
%             BW = roipoly(im.theta,im.axial,ones(length(im.axial),length(im.theta)),th,r);
%         end
%         
%         switch lower(FieldName)
%             case 'ct_smurf'
%             %cdata = mediannan(im.CT_SMURF(1:end,1:end-1),[5 5]);
%             cdata = mediannan(nanmedian(im.CT_SMURF,3),[3 3]);
%             %im.theta = 0.5*(im.theta(1:end-1)+im.theta(2:end));
%             clim = [0 8];
%             case 'ct_dttps'
%             cdata = mediannan(nanmedian(im.CT_DTTPS,3),[3 3]);
%             clim = [0 8];
%             case 'arfidata'
%             cdata = mediannan(nanmax(double(im.arfidata(:,:,10:20)).*im.arfi_scale,[],3),[5 5]);
%             clim = [0 10];
%             case 'ct_ncc'
%             filepath = fileparts(fileparts(fileparts(resfile)));
%             ccmethod = 'progressive_swei';
%             dxdtFile = fullfile(filepath,'dxdt',ccmethod,sprintf('dxdt_%s.mat',timestamp));
%             dxdt = load(dxdtFile);
%             cdata = squeeze(nansum(dxdt.cc_coef.*dxdt.dxdt,3)./nansum(~isnan(dxdt.dxdt).*dxdt.cc_coef,3));
%             %cdata(nanmean(dxdt.cc_coef,3)<100) = nan;
%             clim = [0 8];       
%             im.theta = dxdt.theta1;
%             BW = roipoly(im.theta,im.axial,ones(length(im.axial),length(im.theta)),roiData.theta,roiData.axial);
%         end
%         
%         cdata(cdata<0) = nan;
%         while any(isnan(cdata(:)))
%             cdata1 = mediannan(cdata,[3 3]);
%             cdata(isnan(cdata)) = cdata1(isnan(cdata));
%         end
%         
%         if exist('maxImageSize','var')
%             cdata = interpft(interpft(cdata,maxImageSize(1)),maxImageSize(2),2);
%             im.axial = interp1(im.axial,linspace(1,length(im.axial),maxImageSize(1)));
%             im.theta = interp1(im.theta,linspace(1,length(im.theta),maxImageSize(2)));
%             BW = (interpft(interpft(double(BW),maxImageSize(1)),maxImageSize(2),2))>0.5;
%         end
%             
%         cdata(~BW) = nan;
%         cdata = mediannan(cdata,[3 3]);
%         
%         
%         axidx = find(any(~isnan(cdata),2));
%         thidx = find(any(~isnan(cdata),1));
% 
%         ResHandle{cellIdx}(frameIdx) = imagesurf(im.theta(thidx),im.axial(axidx),im.apex,cdata(axidx,thidx),clim);
%         set(ResHandle{cellIdx}(frameIdx),'AlphaData',double(BW(axidx,thidx)));
%         xd = get(ResHandle{cellIdx}(frameIdx),'zData');
%         yd = get(ResHandle{cellIdx}(frameIdx),'yData');
%         zd = get(ResHandle{cellIdx}(frameIdx),'xData');
%         [xdt ydt zdt] = applyTransformation(xd,yd,zd,CARTO.Frames{FramecellIdx}(frameIdx).XducerToWorldMatrix);
%         set(ResHandle{cellIdx}(frameIdx),'XData',xdt,'YData',ydt,'ZData',zdt);
%         set(ResHandle{cellIdx}(frameIdx),'FaceLighting','none','FaceAlpha','Flat')
%     end
% end
% fprintf('\n')
% end
% 
% function imh = imagesurf(th,r,apex,im,cax)
% th = th(:);
% r = r(:);
% r = [r;r(end)+diff(r(end-1:end))];
% th = [th;th(end)+diff(th(end-1:end))];
% r = r-mean(diff(r))/2;
% th = th-mean(diff(th))/2;
% [TH R] = meshgrid(th,r);
% x = R.*sind(TH) - apex*tand(TH);
% y = R.*cosd(TH);
% IM = padarray(im,[1 1 0],'post');
% IM(isnan(IM)) = -inf;
% imh = surf(x,y,0*y,double(IM));
% set(imh,'edgecolor','none');
% if exist('cax','var')
%     caxis(cax);
% end
% end
