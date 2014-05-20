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
    aData = {aData};
else
    cellOutput = 1;
end
imHandles = {};       
[X Z] = meshgrid(linspace(x(1),x(end),2),linspace(z(1),z(end),2));
for cellIdx = 1:length(Frames)
    for frameIdx = 1:length(Frames{cellIdx});
         imHandle{cellIdx}(frameIdx) = surf(X,Z,0*Z,cData{cellIdx}(:,:,frameIdx),'edgecolor','none','FaceColor','texture');
         if numel(aData{cellIdx}) == 1
         set(imHandle{cellIdx}(frameIdx),'FaceAlpha',aData{cellIdx});
         else
         set(imHandle{cellIdx}(frameIdx),'alphadata',aData{cellIdx}(:,:,frameIdx),'FaceAlpha','texture');
         end
         set(imHandle{cellIdx}(frameIdx),'alphadatamapping','none');
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
