addpath('C:\pjh7\SC2000\arfiProcCode_v4\');
colordef black
figure(1);
clf
hold all
%%
if isfield(CARTO,'Frames')
for FrameIdx = 1:length(CARTO.Frames);
Frame = CARTO.Frames(FrameIdx);
[xt yt zt] = applyTransformation(Frame.X,Frame.Y,Frame.Z,Frame.XducerToWorldMatrix);
Fan(FrameIdx) = patch(xt,yt,zt,'c','faceColor','none','edgecolor','c','edgealpha',0.5,'linewidth',1);
end

im = load('sampleimagedata');
imh = imsurf(im.theta,im.axial,im.apex,im.arfidata(:,:,15),[0 10]);
xd = get(imh,'zData');
yd = get(imh,'yData');
zd = get(imh,'xData');
[xdt ydt zdt] = applyTransformation(xd,yd,zd,Frame.XducerToWorldMatrix);
set(imh,'XData',xdt,'YData',ydt,'ZData',zdt);
set(imh,'FaceLighting','none','FaceAlpha',0.6)
end
%%
if isfield(CARTO,'Contours')
for ContourIdx = 1:length(CARTO.Contours)
Contour = CARTO.Contours(ContourIdx);
Cntr(ContourIdx) = plot3(Contour.X,Contour.Y,Contour.Z,'w-','linewidth',1);
end
end
%%
if isfield(CARTO,'CartoPoints')
Pts = drawCartoPoints(CARTO.CartoPoints,CARTO.Tags);
end

%%
%%

if isfield(CARTO,'Mesh')
Msh = drawCartoMesh(CARTO.Mesh.Points,CARTO.Mesh.Triangles,'FaceColor','y','FaceAlpha',0.25,'EdgeAlpha',0.05,'EdgeColor','y','facelight','gouraud');
end

axis image
