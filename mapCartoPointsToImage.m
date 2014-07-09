function [ptmask heatmap] = mapCartoPointsToImage(imData,CartoPoints,Tags);
IDs = [Tags.ID];
numFrames = size(imData.XducerToWorldMatrix,3);
ptmask = zeros(size(imData.cData));
heatmap = ptmask;
[Xf Zf] = meshgrid(imData.lat,imData.axial);
disp_on = 0;
for frameIndex = 1:numFrames;
    ptmaski = zeros(size(Xf));
    heatmapi = ptmaski;
    if disp_on
        cla
        s = surf(Xf,Zf,0*Zf,imData.cData(:,:,frameIndex),'facecolor','texture','edgecolor','none');
        hold on
    end
    for pointIndex = 1:length(CartoPoints)
        CartoPoint = CartoPoints(pointIndex);
        if ~isempty(CartoPoint.Tags)
            Tag = Tags(IDs==CartoPoint.Tags);
        else
            Tag = struct('Color',[0.5 0.5 0.5 1],'Full_Name','Undefined','ID',[],'Radius',2,'Short_Name','NA');
        end
        xp = CartoPoint.Position3D(1);
        yp = CartoPoint.Position3D(2);
        zp = CartoPoint.Position3D(3);
        [yf zf xf] = applyTransformation(xp,yp,zp,inv(imData.XducerToWorldMatrix(:,:,frameIndex)));
        distFromPoint = sqrt((xf-Xf).^2+yf^2+(zf-Zf).^2);
        ptmaski(distFromPoint<Tag.Radius) = ptmaski(distFromPoint<Tag.Radius)+1;
        heatmapi(distFromPoint<Tag.Radius*3) = max(heatmapi(distFromPoint<Tag.Radius*3),min(1,Tag.Radius./distFromPoint(distFromPoint<Tag.Radius*3)));
        FramePoint(pointIndex,:,frameIndex) = [xf zf yf];
        if disp_on
            [xx yy zz] = sphere(20);
            xx = xx*Tag.Radius;
            yy = yy*Tag.Radius;
            zz = zz*Tag.Radius;
            h(pointIndex) = surf(xx+xf,zz+zf,yy+yf,'facecolor','r','edgecolor','none','facealpha',0.2);
        end
        %     pointIndex(h(pointIndex),'FaceColor',Tag.Color(1:3),'EdgeColor','none','FaceAlpha',Tag.Color(4),'FaceLighting','gouraud');
        %     pointIndex(h(pointIndex),'DisplayName',sprintf('#%g (%s)',CartoPoint.Id,Tag.Full_Name));
        %     hold on
    end
    ptmask(:,:,frameIndex) = ptmaski;
    heatmap(:,:,frameIndex) = heatmapi;
    if disp_on
        axis image
        pause(0.1);
    end
end