function ROI = tmpdefineROI(resFileName,roiPath)
[pth fname ext] = fileparts(resFileName);
timestamp = RetrieveTimeStamp(fname);
if ~exist('roiPath','var')
    roiPath = pth;
end
outFileName = fullfile(roiPath,sprintf('roi_%s.mat',timestamp));
    
res = load(resFileName);
clf
hold on
im2 = imsurf(res(1).theta,res(1).axial,res(1).apex,max(double(res(1).arfidata(:,:,[10:20]))*res(1).arfi_scale,[],3),[0 10]);
if isfield(res(1),'CT_SMURF');
im = imsurf(res(1).theta,res(1).axial,res(1).apex,nanmedian(res(1).CT_DTTPS,3),[0 5]);
set(im,'xdata',get(im,'xdata')-30)
else
im = im2;
end
bim = imsurf(res(1).theta,res(1).axial,res(1).apex,double(res(1).bmodedata0(:,:,[1 1 1]))/255);
set(bim,'xdata',get(bim,'xdata')+30);
axis image
%fields = fieldnames(im);
%fig = figure(555);clf
out.apex = res.apex;
        if exist(outFileName,'file')
        fprintf('Loading ROI data from %s...',outFileName);
        out0 = load(outFileName);
        out0.theta = atand(out0.xc./(out0.zc-out.apex));
        out0.axial = out0.zc./cosd(out0.theta);
        out0.ROI = roipoly(res.theta,res.axial,res.arfidata(:,:,1),out0.theta,out0.axial);
        set([im im2 bim],'alphadata',max(double(out0.ROI),0.6),'alphadatamapping','none','facealpha','flat');
        fprintf('done\n');
        p0(1) = patch(out0.xc,out0.zc,'c','FaceColor','none','EdgeColor','c','LineWidth',2);
        p0(2) = patch(out0.xc+30,out0.zc,'c','FaceColor','none','EdgeColor','c','LineWidth',2);
        p0(3) = patch(out0.xc-30,out0.zc,'c','FaceColor','none','EdgeColor','c','LineWidth',2);
        s = 'r1';
        else
        s = 'y1';
        end
        while any(strcmpi(s,{'y1','r1'}))
        %set(imh,'visible','on')        
        %set(imh,'facealpha',1)
       % for i = [1:size(im.arfidata,3) 16];
       %     tic
       %     set(imh,'cdata',padarray(double(im.arfidata(:,:,i))*im.arfi_scale,[1 1],'post'))
       %     drawnow
       %     while(toc<0.05);end
       % end
       % set(imh,'facealpha',0.1)

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
        out.xc = mod(out.xc+15,30)-15;
        p(1) = patch(out.xc,out.zc,'y','FaceColor','none','EdgeColor','y','LineWidth',2);
        p(2) = patch(out.xc+30,out.zc,'y','FaceColor','none','EdgeColor','y','LineWidth',2);
        p(3) = patch(out.xc-30,out.zc,'y','FaceColor','none','EdgeColor','y','LineWidth',2);
        
        out.theta = atand(out.xc./(out.zc-res.apex));
        out.axial = out.zc./cosd(out.theta);
        out.ROI = roipoly(res.theta,res.axial,res.arfidata(:,:,1),out.theta,out.axial);
        set([im bim im2],'alphadata',max(0.5,double(out.ROI)),'alphadatamapping','none','facealpha','flat');
        %cdata = double(im.arfidata(:,:,16))*im.arfi_scale;
        %cdata(~out.ROI) = nan;
        %imh2 = imsurf(im.theta,im.axial,im.apex,cdata);
        %set(imh,'visible','on','cdata',padarray(cdata,[1 1],'post'));
        save(outFileName,'-struct','out')
        fprintf('ROI saved to %s\n',outFileName);
        ROI = out.ROI;
        end
        
        
        