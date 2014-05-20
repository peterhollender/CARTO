function ResHandle = drawResdata(CARTO,Frameset,FieldName,maxImageSize)
Frames = CARTO.Frames;
for setIdx = 1:length(Frameset)
    FramesetIdx = Frameset(setIdx);
    for FrameIdx = 1:length(Frames{FramesetIdx})
        Frame = Frames{FramesetIdx}(FrameIdx);
        resfile = fullfile(CARTO.UserMapIndex.resFilePaths{FramesetIdx},CARTO.UserMapIndex.resFileNames{FramesetIdx}{FrameIdx});
        
        
        timestamp = RetrieveTimeStamp(resfile);
        CARTO.roiPath = fullfile(fileparts(fileparts(fileparts(CARTO.UserMapIndex.resFilePaths{FramesetIdx}))),'roi');
        roiFileName = fullfile(CARTO.roiPath,sprintf('roi_%s.mat',timestamp));
        im = load(resfile);
        if exist(roiFileName,'file')
            roiData = load(roiFileName);
            BW = roipoly(im.theta,im.axial,ones(length(im.axial),length(im.theta)),roiData.theta,roiData.axial);
        else
            x0 = CARTO.Contours{FramesetIdx}(FrameIdx).X;
            y0 = CARTO.Contours{FramesetIdx}(FrameIdx).Y;
            z0 = CARTO.Contours{FramesetIdx}(FrameIdx).Z;
            [xc yc zc] = applyTransformation(x0,y0,z0,inv(CARTO.Frames{FramesetIdx}(FrameIdx).XducerToWorldMatrix')');
            th = atand(zc./(yc-im.apex));
            r = yc./cosd(th);
            BW = roipoly(im.theta,im.axial,ones(length(im.axial),length(im.theta)),th,r);
        end
        
        switch lower(FieldName)
            case 'ct_smurf'
            %cdata = mediannan(im.CT_SMURF(1:end,1:end-1),[5 5]);
            cdata = mediannan(nanmedian(im.CT_SMURF,3),[3 3]);
            %im.theta = 0.5*(im.theta(1:end-1)+im.theta(2:end));
            clim = [0 8];
            case 'ct_dttps'
            cdata = mediannan(nanmedian(im.CT_DTTPS,3),[3 3]);
            clim = [0 8];
            case 'arfidata'
            cdata = mediannan(nanmax(double(im.arfidata(:,:,10:20)).*im.arfi_scale,[],3),[5 5]);
            clim = [0 10];
            case 'ct_ncc'
            filepath = fileparts(fileparts(fileparts(resfile)));
            ccmethod = 'progressive_swei';
            dxdtFile = fullfile(filepath,'dxdt',ccmethod,sprintf('dxdt_%s.mat',timestamp));
            dxdt = load(dxdtFile);
            cdata = squeeze(nansum(dxdt.cc_coef.*dxdt.dxdt,3)./nansum(~isnan(dxdt.dxdt).*dxdt.cc_coef,3));
            %cdata(nanmean(dxdt.cc_coef,3)<100) = nan;
            clim = [0 8];       
            im.theta = dxdt.theta1;
            BW = roipoly(im.theta,im.axial,ones(length(im.axial),length(im.theta)),roiData.theta,roiData.axial);
        end
        
        cdata(cdata<0) = nan;
        while any(isnan(cdata(:)))
            cdata1 = mediannan(cdata,[3 3]);
            cdata(isnan(cdata)) = cdata1(isnan(cdata));
        end
        
        if exist('maxImageSize','var')
            cdata = interpft(interpft(cdata,maxImageSize(1)),maxImageSize(2),2);
            im.axial = interp1(im.axial,linspace(1,length(im.axial),maxImageSize(1)));
            im.theta = interp1(im.theta,linspace(1,length(im.theta),maxImageSize(2)));
            BW = (interpft(interpft(double(BW),maxImageSize(1)),maxImageSize(2),2))>0.5;
        end
            
        cdata(~BW) = nan;
        cdata = mediannan(cdata,[3 3]);
        
        
        axidx = find(any(~isnan(cdata),2));
        thidx = find(any(~isnan(cdata),1));

        ResHandle{setIdx}(FrameIdx) = imagesurf(im.theta(thidx),im.axial(axidx),im.apex,cdata(axidx,thidx),clim);
        set(ResHandle{setIdx}(FrameIdx),'AlphaData',double(BW(axidx,thidx)));
        xd = get(ResHandle{setIdx}(FrameIdx),'zData');
        yd = get(ResHandle{setIdx}(FrameIdx),'yData');
        zd = get(ResHandle{setIdx}(FrameIdx),'xData');
        [xdt ydt zdt] = applyTransformation(xd,yd,zd,CARTO.Frames{FramesetIdx}(FrameIdx).XducerToWorldMatrix);
        set(ResHandle{setIdx}(FrameIdx),'XData',xdt,'YData',ydt,'ZData',zdt);
        set(ResHandle{setIdx}(FrameIdx),'FaceLighting','none','FaceAlpha','Flat')
    end
end
fprintf('\n')
end

function imh = imagesurf(th,r,apex,im,cax)
th = th(:);
r = r(:);
r = [r;r(end)+diff(r(end-1:end))];
th = [th;th(end)+diff(th(end-1:end))];
r = r-mean(diff(r))/2;
th = th-mean(diff(th))/2;
[TH R] = meshgrid(th,r);
x = R.*sind(TH) - apex*tand(TH);
y = R.*cosd(TH);
IM = padarray(im,[1 1 0],'post');
IM(isnan(IM)) = -inf;
imh = surf(x,y,0*y,double(IM));
set(imh,'edgecolor','none');
if exist('cax','var')
    caxis(cax);
end
end
