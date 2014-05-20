function ROI = defineROI(resFileName,roiPath)
[pth fname ext] = fileparts(resFileName);
timestamp = RetrieveTimeStamp(fname);
if ~exist('roiPath','var')
    roiPath = pth;
end
outFileName = fullfile(roiPath,sprintf('roi_%s.mat',timestamp));
    
im = load(resFileName);
fields = fieldnames(im);
fig = figure(555);clf
out.apex = im.apex;
        bimh = imsurf(im.btheta,im.axial,im.apex,im.bmodedata0(:,:,[1 1 1]));
        hold on
        axis ij
        axis image
        imh = imsurf(im.theta,im.axial,im.apex,double(im.arfidata(:,:,1)));
%        set(imh,'zdata',get(imh,'zdata')+1e-10);
        caxis([0 8]);
        if exist(outFileName,'file')
        fprintf('Loading ROI data from %s...',outFileName);
        out0 = load(outFileName);
        fprintf('done\n');
        p0 = patch(out0.xc,out0.zc,'c','FaceColor','none','EdgeColor','c','LineWidth',2);
        s = 'r1';
        else
        s = 'y1';
        end
        while any(strcmpi(s,{'y1','r1'}))
        set(imh,'visible','on')        
        set(imh,'facealpha',1)
        for i = [1:size(im.arfidata,3) 16];
            tic
            set(imh,'cdata',padarray(double(im.arfidata(:,:,i)),[1 1],'post'))
            drawnow
            while(toc<0.05);end
        end
        set(imh,'facealpha',0.1)

        while ~any(strcmpi(s,{'y','n','','r'}));
                s = input('Draw New ROI? y/n [n]','s');
        end
        if strcmpi(s,'r')
            s = 'r1';
        end
        end
        switch lower(s)
            case {'n',''}
             if exist('out0','var')
                ROI = out0.ROI;
             else
                 return
             end
            case 'y'
        [out.xc out.zc] = getline('closed');
        p = patch(out.xc,out.zc,'y','FaceColor','none','EdgeColor','y','LineWidth',2);
        out.theta = atand(out.xc./(out.zc-im.apex));
        out.axial = out.zc./cosd(out.theta);
        out.ROI = roipoly(im.theta,im.axial,im.arfidata(:,:,1),out.theta,out.axial);
        cdata = double(im.arfidata(:,:,16));
        cdata(~out.ROI) = nan;
        imh2 = imsurf(im.theta,im.axial,im.apex,cdata);
        %set(imh,'visible','on','cdata',padarray(cdata,[1 1],'post'));
        save(outFileName,'-struct','out')
        fprintf('ROI saved to %s\n',outFileName);
        ROI = out.ROI;
        end
        
        
        