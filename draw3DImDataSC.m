function H = draw3DImDataSC(imDataSC,field,frameIndices)
NextPlot = get(gca,'NextPlot');
im = imDataSC.(field);
if exist('frameIndices','var')
    im.cData = im.cData(:,:,frameIndices);
    im.alphadata = im.alphadata(:,:,frameIndices);
    im.XducerToWorldMatrix = im.XducerToWorldMatrix(:,:,frameIndices);
end
[X Z] = meshgrid(linspace(im.lat(1),im.lat(end),2),linspace(im.axial(1),im.axial(end),2));
H = zeros(1,size(im.cData,3));
for frameIdx = 1:size(im.cData,3)
         if strcmpi(field,'bmode')
            H(frameIdx) = surf(X,Z,0*Z,im.cData(:,:,[1 1 1]*frameIdx),'edgecolor','none','FaceColor','texture');
         else
             H(frameIdx) = surf(X,Z,0*Z,im.cData(:,:,frameIdx),'edgecolor','none','FaceColor','texture');
         end
         set(H(frameIdx),'alphadata',double(im.alphadata(:,:,frameIdx)),'FaceAlpha','texture');
         set(H(frameIdx),'alphadatamapping','none');
         xd = get(H(frameIdx),'zData');
         yd = get(H(frameIdx),'yData');
         zd = get(H(frameIdx),'xData');
         [xdt ydt zdt] = applyTransformation(xd,yd,zd,im.XducerToWorldMatrix(:,:,frameIdx));
         set(H(frameIdx),'XData',xdt,'YData',ydt,'ZData',zdt);
        if frameIdx == 1;
            set(gca,'NextPlot','add');
        end
end
set(gca,'clim',im.clim);
set(gca,'NextPlot',NextPlot);
