addpath /getlab/pjh7/SC2000/arfiProcCode_v4/
resFileDataPath_Post = '/getlab/pjh7/SC2000/data/20130219_RA_PostAblation/res/Pesavento';
CartoXMLfile = '/getlab/pjh7/SC2000/data/20130219_RA_MechanicalMMode/carto/SC2000_C3 02_20_2013 16-21-31.xml';
UserMapIndex_Post = load(fullfile(resFileDataPath_Post,'CartoMapIndexData.mat'));
CARTO = processCartoStudy(CartoXMLfile,resFileDataPath_Post,UserMapIndex_Post);
%%

newpointX = [25.1833 24.6128 24.8758 25.3126 28.1807 27.5444 28.1878 26.4299 25.0439 24.3454 26.1352 27.0055];
newpointY = [79.9537 79.7713 80.6385 81.4203 81.6531 82.0651 84.3055 84.2316 85.0130 86.3305 86.7563 87.5584];
newpointZ = [90.4172 88.8716 87.1927 85.1340 83.8185 82.6909 80.4583 79.1037 77.8489 75.9040 74.8054 72.5618];
MovieFrameIdx = [];

for i = 1:length(newpointX);
    CARTO.CartoPoints(i).Position3D = [newpointX(i) newpointY(i) newpointZ(i)];
end
CartoPointIndex = [1:12];
colordef black
CARTO.UserMapIndex.ResIndices = 1:2:24;
CARTO.figureHandle = 50;
figure(CARTO.figureHandle);clf;
CARTO.ActivationTimeRange = {[-180 -140],[-20 10]};
ActivationColorMap = activationTime(CARTO.ActivationTimeRange{1},CARTO.ActivationTimeRange{2},jet(256));
ax = axes;
hold on
grid on
axis equal
axis([0 100.2320  -10.5060  120.2170   56.1510  143.4120])
    CameraPosition = [-368.16 218.805 867.124];
	CameraTarget = [58.1068 63.771 98.1203];
    CameraUpVector = [0 1 0];
	CameraViewAngle = [8.37419];
    set(ax,'CameraPosition',CameraPosition,'CameraTarget',CameraTarget,'CameraUpVector',CameraUpVector,'CameraViewAngle',CameraViewAngle);
    set(ax,'color','k','xcolor',[0.6 0.6 0.6],'ycolor',[0.6 0.6 0.6],'zcolor',[0.6 0.6 0.6]);
    set(ax,'XTickLabel',{},'YTickLabel',{},'ZTickLabel',{})
    MOV = getframe(gcf);
    MovieFrameIdx = [MovieFrameIdx length(MOV)*ones(1,30)];
    TextHandle = text(-14,140,50,'The NaviStar maps the geometry of the atrium','color','w','FontSize',16,'FontWeight','Bold','VerticalAlignment','top');
    p3(1) = plot3(CARTO.Mesh(1).Vertices.X,CARTO.Mesh(1).Vertices.Y,CARTO.Mesh(1).Vertices.Z,'c.');
    MOV(end+1) = getframe(gcf);
    MovieFrameIdx = [MovieFrameIdx length(MOV)*ones(1,30)];
    pause(0.25)
    set(TextHandle,'String','The NaviStar can map the ventricle, as well.')
    p3(2) = plot3(CARTO.Mesh(2).Vertices.X,CARTO.Mesh(2).Vertices.Y,CARTO.Mesh(2).Vertices.Z,'r.');
    MOV(end+1) = getframe(gcf);
    MovieFrameIdx = [MovieFrameIdx length(MOV)*ones(1,30)];

    pause(1)
%%    
set(TextHandle,'String','The electrical activity of the heart is recorded,')

for MeshIndex = 1:length(CARTO.Mesh)
%CARTO.MeshHandle(MeshIndex) = drawCartoMesh(CARTO.Mesh(MeshIndex),'LAT',[CARTO.ActivationTimeRange{1}(1) CARTO.ActivationTimeRange{2}(2)],ActivationColorMap,'EdgeColor','interp','FaceColor','none');
CARTO.MeshHandle(MeshIndex) = drawCartoMesh(CARTO.Mesh(MeshIndex),'LAT',[CARTO.ActivationTimeRange{1}(1) CARTO.ActivationTimeRange{2}(2)],'EdgeColor','interp','FaceColor','none');
colormap(activationTime([-180 -140],[-20 10],jet(256)))
end

set(p3,'visible','off')
set(CARTO.MeshHandle,'FaceColor','interp','EdgeColor','w','edgealpha',0.1)

colormap([bone;flipud(bone)])
clim = linspace(-200,20,50);
for i = 1:length(clim)
    caxis(clim(i)+[-5 5]);
    pause(0.05)    
    MOV(end+1) = getframe(gcf);   
    MovieFrameIdx = [MovieFrameIdx length(MOV)*ones(1,1)];

end
delete(CARTO.MeshHandle);
%%
set(TextHandle,'String',sprintf('The electrical activity of the heart is recorded,\nand the local activation time (LAT) is mapped to the geometry.'))

for MeshIndex = 1:length(CARTO.Mesh)
CARTO.MeshHandle(MeshIndex) = drawCartoMesh(CARTO.Mesh(MeshIndex),'LAT',[CARTO.ActivationTimeRange{1}(1) CARTO.ActivationTimeRange{2}(2)],ActivationColorMap,'EdgeColor','none','FaceColor','interp');
%CARTO.MeshHandle(MeshIndex) = drawCartoMesh(CARTO.Mesh(MeshIndex),'LAT',[CARTO.ActivationTimeRange{1}(1) CARTO.ActivationTimeRange{2}(2)],'EdgeColor','interp','FaceColor','none');
colormap(activationTime([-180 -140],[-20 10],jet(256)))
end
set(p3,'visible','off')
MOV(end+1) = getframe(gcf);
MovieFrameIdx = [MovieFrameIdx length(MOV)*ones(1,30)];

%%
set(TextHandle,'String','For an ablation, we only need to focus on the atrium.')
MOV(end+1) = getframe(gcf);   
MovieFrameIdx = [MovieFrameIdx length(MOV)*ones(1,30)];

set(TextHandle,'visible','off')
    CameraPosition1 = [-218.876 62.5134 384.051];
	CameraTarget1 = [27.3268 81.2287 94.6903];
	CameraUpVector1 = [-0.031883 0.998789 0.0374719];
F = panCameraTo(CameraPosition1,CameraTarget1,CameraUpVector1,20,0.05);
MovieFrameIdx = [MovieFrameIdx length(MOV)+(1:length(F))];
MOV = [MOV F];

%%
set(TextHandle,'Visible','on','String','A region of the atrium is ablated and the locations of the ablation sites are recorded.','position',[9 115 60])
set(CARTO.MeshHandle,'FaceColor','none','EdgeColor','interp','EdgeAlpha',0.1)
CARTO.PointsHandle = drawCartoPoints(CARTO.CartoPoints,CARTO.Tags);
set(CARTO.PointsHandle,'visible','off')
set(CARTO.PointsHandle,'FaceAlpha',0.1,'EdgeColor','y','EdgeAlpha',0.1,'FaceColor','y');
    MOV(end+1) = getframe(gcf);        
    MovieFrameIdx = [MovieFrameIdx length(MOV)*ones(1,20)];

for i = 1:length(CartoPointIndex)
    set(CARTO.PointsHandle(CartoPointIndex(i)),'Visible','on')
    pause(0.25)
        MOV(end+1) = getframe(gcf);
        MovieFrameIdx = [MovieFrameIdx length(MOV)*ones(1,10)];

end

pause(1)
%%
set(TextHandle,'String',sprintf('The region surrounding the ablation is imaged with a series of 2D images'))
MOV(end+1) = getframe(gcf);    
MovieFrameIdx = [MovieFrameIdx length(MOV)*ones(1,20)];

for i = 1:length(CARTO.UserMapIndex.ResIndices)
ResIdx = CARTO.UserMapIndex.ResIndices(i);
Frame = CARTO.Frames(ResIdx);
[xt yt zt] = applyTransformation(Frame.X,Frame.Y,Frame.Z,Frame.XducerToWorldMatrix);
set(CARTO.FrameHandle(1:i-1),'FaceColor','none')
CARTO.FrameHandle(i) = patch(xt,yt,zt,'c','faceAlpha',0.1,'edgecolor','c','edgealpha',0.5,'linewidth',1);
pause(0.25)
MOV(end+1) = getframe(gcf);
MovieFrameIdx = [MovieFrameIdx length(MOV)*ones(1,10)];

end
set(CARTO.FrameHandle,'FaceColor','none')
pause(1)
MOV(end+1) = getframe(gcf);
MovieFrameIdx = [MovieFrameIdx length(MOV)*ones(1,20)];

%%
CARTO.ARFIHandle = [];
set(TextHandle,'String',sprintf('Each image records IQ ultrasound data,'))
set(CARTO.PointsHandle,'visible','off')
colormap gray
caxis([0 1]);
MOV(end+1) = getframe(gcf);
MovieFrameIdx = [MovieFrameIdx length(MOV)*ones(1,20)];

resFiles = dir(fullfile(CARTO.resFileDataPath,'res*'));
for i = 1:length(CARTO.UserMapIndex.ResIndices)
ResIdx = CARTO.UserMapIndex.ResIndices(i);
resFileName = fullfile(CARTO.resFileDataPath,resFiles(ResIdx).name);
    timestamp = RetrieveTimeStamp(resFiles(ResIdx).name);
    CARTO.roiPath = fullfile(fileparts(fileparts(CARTO.resFileDataPath)),'roi');
    roiFileName = fullfile(CARTO.roiPath,sprintf('roi_%s.mat',timestamp));
        im = load(resFileName);
        roiData = load(roiFileName);
        BW = roipoly(im.theta,im.axial,ones(length(im.axial),length(im.theta)),roiData.theta,roiData.axial);
        CARTO.ARFIHandle(i) = imsurf_nocamera(im.btheta,im.axial,im.apex,im.bmodedata0.^1.2);
        xd = get(CARTO.ARFIHandle(i),'zData');
        yd = get(CARTO.ARFIHandle(i),'yData');
        zd = get(CARTO.ARFIHandle(i),'xData');
        [xdt ydt zdt] = applyTransformation(xd,yd,zd,CARTO.Frames(ResIdx).XducerToWorldMatrix);
        set(CARTO.ARFIHandle,'Visible','off')
        set(CARTO.ARFIHandle(i),'XData',xdt,'YData',ydt,'ZData',zdt,'Visible','on');
pause(0.05)
MOV(end+1) = getframe(gcf);
MovieFrameIdx = [MovieFrameIdx length(MOV)*ones(1,10)];

end
pause(1);
%%
set(TextHandle,'String',sprintf('Each image records IQ ultrasound data,\nused to track induced displacements to make ARFI images'))
colormap cool
caxis([0 5])
set(CARTO.ARFIHandle,'visible','off','FaceAlpha',1);
MOV(end+1) = getframe(gcf);
MovieFrameIdx = [MovieFrameIdx length(MOV)*ones(1,20)];

cb = colorbar('location','south');
set(cb,'FontSize',14,'FontWeight','bold')
xlabel(cb,'Displacment (\mum)')
for i = 1:length(CARTO.UserMapIndex.ResIndices)
ResIdx = CARTO.UserMapIndex.ResIndices(i);
        resFileName = fullfile(CARTO.resFileDataPath,resFiles(ResIdx).name);
        timestamp = RetrieveTimeStamp(resFiles(ResIdx).name);
        CARTO.roiPath = fullfile(fileparts(fileparts(CARTO.resFileDataPath)),'roi');
        roiFileName = fullfile(CARTO.roiPath,sprintf('roi_%s.mat',timestamp));
        roiData = load(roiFileName);
        BW = roipoly(im.theta,im.axial,ones(length(im.axial),length(im.theta)),roiData.theta,roiData.axial);
        BW = padarray(BW,[1 1],'post');
        cdata = get(CARTO.ARFIHandle(i),'cdata');
        xd = get(CARTO.ARFIHandle(i),'xData');
        yd = get(CARTO.ARFIHandle(i),'yData');
        zd = get(CARTO.ARFIHandle(i),'zData');
        clear d;
        for j = 1:length(CartoPointIndex)
        d(:,:,j) = sqrt(...
        (xd-CARTO.CartoPoints(CartoPointIndex(j)).Position3D(1)).^2 +...
        (yd-CARTO.CartoPoints(CartoPointIndex(j)).Position3D(2)).^2 +...
        (zd-CARTO.CartoPoints(CartoPointIndex(j)).Position3D(3)).^2);
        end
        d = min(d,[],3);
        cdata = 6-max(1,min(5,5*exp(-2.*(d-3))));
        cdata(~BW) = 3+15*(rand(sum(~BW(:)),1)-0.5);
        cdata = cdata + 0.15*(rand(size(cdata))-0.5);
        cdata = filter2(ones(5,3),cdata,'same')./filter2(ones(5,3),ones(size(cdata)),'same');
        set(CARTO.ARFIHandle,'Visible','off');
        set(CARTO.ARFIHandle(i),'cdata',cdata,'Visible','on');
        pause(0.5)
        MOV(end+1) = getframe(gcf);
        MovieFrameIdx = [MovieFrameIdx length(MOV)*ones(1,10)];

end
pause(1)
%%
set(TextHandle,'String',sprintf('Each image records IQ ultrasound data,\nused to track induced displacements to make ARFI images,\nas well as Shear Wave Images (SWI).'))
colormap spring
caxis([0 5])
set(CARTO.ARFIHandle,'visible','off','FaceAlpha',1);
xlabel(cb,'Shear Wave Velocity (m/s)')
MOV(end+1) = getframe(gcf);
        MovieFrameIdx = [MovieFrameIdx length(MOV)*ones(1,20)];

for i = 1:length(CARTO.UserMapIndex.ResIndices)
        ResIdx = CARTO.UserMapIndex.ResIndices(i);
        resFileName = fullfile(CARTO.resFileDataPath,resFiles(ResIdx).name);
        timestamp = RetrieveTimeStamp(resFiles(ResIdx).name);
        CARTO.roiPath = fullfile(fileparts(fileparts(CARTO.resFileDataPath)),'roi');
        roiFileName = fullfile(CARTO.roiPath,sprintf('roi_%s.mat',timestamp));
        roiData = load(roiFileName);
        BW = roipoly(im.theta,im.axial,ones(length(im.axial),length(im.theta)),roiData.theta,roiData.axial);
        BW = padarray(BW,[1 1],'post');
        cdata = get(CARTO.ARFIHandle(i),'cdata');
        xd = get(CARTO.ARFIHandle(i),'xData');
        yd = get(CARTO.ARFIHandle(i),'yData');
        zd = get(CARTO.ARFIHandle(i),'zData');
        clear d
        for j = 1:length(CartoPointIndex)
        d(:,:,j) = sqrt(...
        (xd-CARTO.CartoPoints(CartoPointIndex(j)).Position3D(1)).^2 +...
        (yd-CARTO.CartoPoints(CartoPointIndex(j)).Position3D(2)).^2 +...
        (zd-CARTO.CartoPoints(CartoPointIndex(j)).Position3D(3)).^2);
        end
        d = min(d,[],3);
        cdata = max(1,min(5,5*exp(-2.*(d-3.5))));
        cdata(~BW) = 3+10*(rand(sum(~BW(:)),1)-0.5);        
        cdata = cdata + 0.25*(rand(size(cdata))-0.5);
        cdata = filter2(ones(5,3),cdata,'same')./filter2(ones(5,3),ones(size(cdata)),'same');
        set(CARTO.ARFIHandle,'Visible','off');
        set(CARTO.ARFIHandle(i),'cdata',cdata,'Visible','on');
        pause(0.5)
        MOV(end+1) = getframe(gcf);
        MovieFrameIdx = [MovieFrameIdx length(MOV)*ones(1,10)];
end
set(CARTO.ARFIHandle,'FaceAlpha',0.1,'visible','on')
set(CARTO.PointsHandle,'visible','off')
pause(1)
%%
set(TextHandle,'String',sprintf('The myocardium is segmented in the images'))
MOV(end+1) = getframe(gcf);
        MovieFrameIdx = [MovieFrameIdx length(MOV)*ones(1,20)];

for i = 1:length(CARTO.UserMapIndex.ResIndices)
ResIdx = CARTO.UserMapIndex.ResIndices(i);
resFileName = fullfile(CARTO.resFileDataPath,resFiles(ResIdx).name);
    timestamp = RetrieveTimeStamp(resFiles(ResIdx).name);
    CARTO.roiPath = fullfile(fileparts(fileparts(CARTO.resFileDataPath)),'roi');
    roiFileName = fullfile(CARTO.roiPath,sprintf('roi_%s.mat',timestamp));
        roiData = load(roiFileName);
        BW = roipoly(im.theta,im.axial,ones(length(im.axial),length(im.theta)),roiData.theta,roiData.axial);
        BW = padarray(BW,[1 1],'post');
        cdata = get(CARTO.ARFIHandle(i),'cdata');
        cdata(~BW) = nan;
        set(CARTO.ARFIHandle(i),'cdata',cdata);
        set(CARTO.ARFIHandle(i),'Visible','on','FaceAlpha',1)
        pause(0.1)
        MOV(end+1) = getframe(gcf);
        MovieFrameIdx = [MovieFrameIdx length(MOV)*ones(1,10)];

end
pause(1)
%%
set(TextHandle,'String',sprintf('The myocardium is segmented in the images,\n and the ARFI or SWI data are interpolated onto the endocardium from the EAM.'))
set(CARTO.FrameHandle,'visible','off')
drawnow
MOV(end+1) = getframe(gcf);        
MovieFrameIdx = [MovieFrameIdx length(MOV)*ones(1,20)];

CARTO.TriMesh = drawTriangulatedCartoMesh(CARTO,[-1:0.25:2]);
set(CARTO.ARFIHandle,'visible','off')
set(CARTO.TriMesh(2:end),'visible','off')
pause(1)
MOV(end+1) = getframe(gcf);
MovieFrameIdx = [MovieFrameIdx length(MOV)*ones(1,40)];

%%
set(TextHandle,'visible','off')
set(CARTO.TriMesh(2:end),'visible','off')
	CameraPosition2 = [-73.0847 -31.5372 123.694];
	CameraTarget2 = [22.2633 81.487 83.4795];
	CameraUpVector2 = [-0.679585 0.675285 0.286626];
    F = panCameraTo(CameraPosition2,CameraTarget2,CameraUpVector2,20,0.05);
   MovieFrameIdx = [MovieFrameIdx length(MOV)+(1:length(F))];
    MOV = [MOV F];
    pause(1)
   %%
set(TextHandle,'Visible','on','String',sprintf('Additional layers are interpolated out to the epicardium to image transmurality'),'position',[-5 75 79])
MOV(end+1) = getframe(gcf);
MovieFrameIdx = [MovieFrameIdx length(MOV)*ones(1,30)];

for i = 2:length(CARTO.TriMesh);
    set(CARTO.TriMesh(i),'visible','on')
    pause(0.5)
    MOV(end+1) = getframe(gcf);
    MovieFrameIdx = [MovieFrameIdx length(MOV)*ones(1,10)];

end
%%
set(TextHandle,'String',sprintf('Additional layers are interpolated out to the epicardium to image transmurality,\nfilling in the 3-D volume.'))
pause(1)    
MOV(end+1) = getframe(gcf);
MovieFrameIdx = [MovieFrameIdx length(MOV)*ones(1,20)];
set(CARTO.TriMesh,'FaceAlpha',0.25)
set(CARTO.TriMesh(1),'FaceAlpha',1)
MOV(end+1) = getframe(gcf);
MovieFrameIdx = [MovieFrameIdx length(MOV)*ones(1,20)];
set(TextHandle,'String',sprintf('Looks like we''ll need to fill in that gap.\nThe lesion is contiguous on the endocardium, but not the epicardium.'))
MOV(end+1) = getframe(gcf);
MovieFrameIdx = [MovieFrameIdx length(MOV)*ones(1,40)];
pause(1)
set(TextHandle,'Visible','off')
F = panCameraTo(CameraPosition,CameraTarget,CameraUpVector,50,0.05);
MovieFrameIdx = [MovieFrameIdx length(MOV)+(1:length(F))];
MOV = [MOV F];
set(CARTO.MeshHandle,'FaceAlpha',0.2,'FaceColor','interp')
MOV(end+1) = getframe(gcf);   
MovieFrameIdx = [MovieFrameIdx length(MOV)*ones(1,10)];
set(TextHandle,'Visible','on','String',sprintf('This system could reduce procedure times and increase procedure efficacy,\nby identifying potential conduction gaps, or even regions of electrically stunned myocardium.%s',[10*ones(1,35), 169 'Peter Hollender' 10 '2013, Duke University']),'Position',[-14,140,50])
MOV(end+1) = getframe(gcf);
MovieFrameIdx = [MovieFrameIdx length(MOV)*ones(1,40)];
