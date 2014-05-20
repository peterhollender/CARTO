addpath /getlab/pjh7/SC2000/arfiProcCode_v4/
resFileDataPath = '/wolf/ClinicalData/CardiacAblationClinicalPatients/CAP1_20130410/20130410/res/';
CartoDataPath = '/wolf/ClinicalData/CardiacAblationClinicalPatients/CAP1_20130410/Patient 2013_04_10/AFL/Export_AFL-04_10_2013-12-07-28/';
matFileName = fullfile(CartoDataPath,'CARTO_20130108135546');
[pth fname ext] = fileparts(matFileName);
matFileName = fullfile(pth,[fname '.mat']);
CartoXMLfile = fullfile(CartoDataPath,'AFL 04_10_2013 12-07-28.xml');
CARTO = processCartoStudy(CartoXMLfile,resFileDataPath);
CARTO = displayCartoStudy(CARTO,200)
%%
Depths = [0:0.02:0.25];
CARTO_Post = displayCartoStudy(CARTO_Post,201);
set(201,'Name','Post-Ablation')
CARTO_Post.TriMesh = drawTriangulatedCartoMesh(CARTO_Post,Depths);
set(CARTO_Post.ContourHandle,'visible','off')
CARTO_Pre = displayCartoStudy(CARTO_Pre,202);
set(202,'Name','Pre-Ablation')
CARTO_Pre.TriMesh = drawTriangulatedCartoMesh(CARTO_Pre,Depths);
set(CARTO_Pre.ContourHandle,'visible','off')
set(CARTO_Post.MeshHandle,'FaceColor','none','EdgeColor','interp','edgealpha',0.1)
set(CARTO_Pre.MeshHandle,'FaceColor','none','EdgeColor','interp','edgealpha',0.1)
set(CARTO_Post.PointsHandle,'Visible','off')
set(CARTO_Post.ARFIHandle,'visible','off')
set(CARTO_Pre.ARFIHandle,'visible','off')
figure(CARTO_Post.figureHandle);
legend off
ax1 = get(CARTO_Post.figureHandle,'Children');
ax2 = get(CARTO_Pre.figureHandle,'Children');
axis([ax1 ax2],[0 80 0 130 50 130])
set([CARTO_Post.MeshHandle(2) CARTO_Pre.MeshHandle(2)],'visible','off');
set([CARTO_Post.MeshHandle(1) CARTO_Pre.MeshHandle(1)],'FaceAlpha',1,'FaceColor','interp','EdgeColor','none');
%CameraPosition = [-24.5464 107.708 120.224];
%CameraTarget = [44.0377 78.6607 71.2062];	
%CameraPosition = [-117.478 165.592 90.4687];
%CameraTarget = [43.4269 63.0276 89.0347];
CameraPosition = [-33.1284 118.689 44.8813]
	CameraTarget = [46.8144 75.4261 92.8477]
	CameraUpVector = [-0.628486 -0.520954 0.577591]
	
set([ax1 ax2],'CameraUpVector',CameraUpVector)
set([ax1 ax2],'CameraTarget',CameraTarget);
set([ax1 ax2],'CameraViewAngle',30)
set([ax1 ax2],'Projection','perspective')
campos(ax1,CameraPosition);
campos(ax2,CameraPosition);
cb1 = colorbar('peer',ax1,'northoutside');
cb2 = colorbar('peer',ax2,'northoutside');
set([cb1,cb2],'xcolor','w','ycolor','w','FontSize',14)
xlabel(cb1,'Shear Wave Velocity (m/s)','color','w')
xlabel(cb2,'Shear Wave Velocity (m/s)','color','w')
colormap(CARTO_Post.figureHandle,spring);
colormap(CARTO_Pre.figureHandle,spring);
set([ax1 ax2],'CLim',[0 2.5]);
cb1a = colorbar('peer',ax1,'south','fontsize',14,'xcolor','w','ycolor','w');
im1a = get(cb1a,'Children');
cb2a = colorbar('peer',ax2,'south','fontsize',14,'xcolor','w','ycolor','w');
im2a = get(cb2a,'Children');
ActivationColorMap1 = activationTime(CARTO_Post.ActivationTimeRange{1},CARTO_Post.ActivationTimeRange{2},jet(256));
ActivationColorMap2 = activationTime(CARTO_Pre.ActivationTimeRange{1},CARTO_Pre.ActivationTimeRange{2},jet(256));
set(im1a,'CData',permute(ActivationColorMap1,[3 1 2]),'XData',[CARTO_Post.ActivationTimeRange{1}(1),CARTO_Post.ActivationTimeRange{2}(2)]);
set(cb1a,'XLim',[CARTO_Post.ActivationTimeRange{1}(1),CARTO_Post.ActivationTimeRange{2}(2)])
set(im2a,'CData',permute(ActivationColorMap2,[3 1 2]),'XData',[CARTO_Pre.ActivationTimeRange{1}(1),CARTO_Pre.ActivationTimeRange{2}(2)]);
set(cb2a,'XLim',[CARTO_Pre.ActivationTimeRange{1}(1),CARTO_Pre.ActivationTimeRange{2}(2)])
set([cb1a cb2a],'position',[0.15 0.02 0.7 0.03])
xlabel(cb1a,'Local Activation Time (ms)')
xlabel(cb2a,'Local Activation Time (ms)')
set(CARTO_Post.FrameHandle(CARTO_Post.UserMapIndex.ResIndices),'EdgeColor','w')
set(CARTO_Pre.FrameHandle(CARTO_Pre.UserMapIndex.ResIndices),'EdgeColor','w')
set([CARTO_Post.figureHandle CARTO_Pre.figureHandle],'color','k')
%set([CARTO_Post.TriMesh(:) CARTO_Pre.TriMesh(:)],'FaceLighting','gouraud','FaceAlpha',1)
drawnow
%axes(ax1);
%L(1) = camlight(0,45);
%axes(ax2);
%L(2) = camlight(0,45);
set(CARTO_Post.figureHandle,'children',[cb1;cb1a;ax1]);
set(CARTO_Pre.figureHandle,'children',[cb2;cb2a;ax2]);

%set([ax1 ax2],'color','none','xcolor','none','ycolor','none','zcolor','none')