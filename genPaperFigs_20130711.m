UserMapIndexFile_Post = '/getlab/pjh7/SC2000/data/20130219_RA_PostAblation/UserMapIndex.mat';
UserMapIndexFile_Pre = '/getlab/pjh7/SC2000/data/20130219_RA_PreAblation/UserMapIndex.mat';
CARTO_Pre = processCartoStudy(matFileName,UserMapIndexFile_Pre,'y');
CARTO_Post = processCartoStudy(matFileName,UserMapIndexFile_Post,'y');
CARTO_Post.roiPath = fullfile(fileparts(fileparts(fileparts(CARTO_Post.UserMapIndex.resFilePaths{FramesetIdx}))),'roi');
CARTO_Pre.roiPath = fullfile(fileparts(fileparts(fileparts(CARTO_Pre.UserMapIndex.resFilePaths{FramesetIdx}))),'roi');
makeGIF = 0;
modeIndices = [1:2];
timeIndices = [1:2];
clim = [0 10;0 6];

% ccmethod = 'progressive_swei';
% for CARTO = [CARTO_Pre,CARTO_Post];
%     for FrameSetIdx = 2%1:length(CARTO.UserMapIndex.resFilePaths)
%         for FrameIdx = 1:length(CARTO.UserMapIndex.resFileNames{FrameSetIdx})
%             resFile = fullfile(CARTO.UserMapIndex.resFilePaths{FrameSetIdx},CARTO.UserMapIndex.resFileNames{FrameSetIdx}{FrameIdx});
%             filepath = fileparts(fileparts(fileparts(CARTO.UserMapIndex.resFilePaths{1})));
%             timestamp = RetrieveTimeStamp(resFile);
%             dxdtFile = fullfile(filepath,'dxdt',ccmethod,sprintf('dxdt_%s.mat',timestamp));
%             if ~exist(dxdtFile,'file');
%                 dxdtFile = progressiveNCC(resFile,ccmethod);
%             end
%
%         end
%     end
% end
%%
figH = figure(201);
clf
set(figH,'color','k','invertHardcopy','off')
Handles.ActivationTimeRange = {[-180 -140],[-20 10]};
ActivationColorMap = activationTime(Handles.ActivationTimeRange{1},Handles.ActivationTimeRange{2},jet(256));

Handles.MeshHandle = drawCartoMesh(CARTO.Mesh,'LAT',[Handles.ActivationTimeRange{1}(1) Handles.ActivationTimeRange{2}(2)],ActivationColorMap,'facelight','none','EdgeColor','k','edgealpha',0.1,'facecolor',[0.5 0.5 0.5],'facealpha',0.25);
hold on
Handles.PointsHandle{1} = drawCartoPoints(CARTO_Post.CartoPoints{1}(2:end-1),CARTO.Tags);

FrameApex_post_ARFI = mean(getFrameApex(CARTO_Post.Frames{1}),2);
FrameApex_post_SWI = mean(getFrameApex(CARTO_Post.Frames{2}),2);
FrameApex_pre_ARFI = mean(getFrameApex(CARTO_Pre.Frames{1}),2);
FrameApex_pre_SWI = mean(getFrameApex(CARTO_Pre.Frames{2}),2);

ResHandle_post_ARFI = drawResdata(CARTO_Post,1,'arfidata');
ResHandle_post_SWI = drawResdata(CARTO_Post,2,'CT_DTTPS');
ResHandle_pre_ARFI = drawResdata(CARTO_Pre,1,'arfidata');
ResHandle_pre_SWI = drawResdata(CARTO_Pre,2,'CT_DTTPS');

ResHandles = {ResHandle_pre_ARFI,ResHandle_pre_SWI;ResHandle_post_ARFI,ResHandle_post_SWI};
FrameApex = {FrameApex_pre_ARFI,FrameApex_pre_SWI;FrameApex_post_ARFI,FrameApex_post_SWI};

%%

    CameraPosition = [-24.9185 93.2235 179.852]
	%CameraPositionMode = manual
	CameraTarget = [28.1925 88.6422 78.8897]
	%CameraTargetMode = manual
	CameraUpVector = [-0.884277 0.0248641 -0.4663]
	%CameraUpVectorMode = manual
	CameraViewAngle = [8.82708]
set(gca,'CameraPosition',CameraPosition,'CameraTarget',CameraTarget,'CameraUpVector',CameraUpVector,'CameraViewAngle',CameraViewAngle);

%%
for i = 1:4
    set([ResHandles{i}{:}],'visible','off')
end
axis image
cameratoolbar show
axis off
L = camlight('right');

set(Handles.PointsHandle{1},'visible','on')
for i = 1:71;
    camorbit(-5,0,'y','camera');
    camlight(L,'right');
    M(i) = getframe(figH);
    pause(0.1);
end
gifFile = fullfile('~/Dropbox/Documents/20130725_IEEE/Fusion/figures/gif/AblationSites.gif');
mov2gif(M,gifFile,20);
camorbit(-5,0,'y','camera');
set(Handles.PointsHandle{1},'visible','off')
cb = colorbar('location','east');
set(cb,'FontSize',24,'FontWeight','bold')
units = {'Displacement (\mum)','Velocity (m/s)'};
modality = {'ARFI','SWI'};
time = {'pre','post'};
%%
%%
for i = 1:4
    set([ResHandles{i}{:}],'visible','off')
end
for midx = 1:length(modality);
    
    for tidx = 1:length(time);
        if tidx == 1
            CARTO = CARTO_Pre;
            set(Handles.PointsHandle{1},'visible','off');
        else
            CARTO = CARTO_Post;
            set(Handles.PointsHandle{1},'visible','on','facealpha',0,'edgealpha',0.5,'edgecolor','m');
            
        end
        ResHandle = ResHandles{tidx,midx}{1};
        TriMeshHandle{tidx,midx} = drawTriangulatedCartoMesh(CARTO.Mesh,ResHandle,FrameApex{tidx,midx},[-5:0.25:3]);
        set(TriMeshHandle{tidx,midx},'visible','off')
    end
end
%%
for i = 1:4
    set(TriMeshHandle{i},'visible','off')
end
for midx = modeIndices;
    set(cb,'xcolor','w','ycolor','w')
    ylabel(cb,units{midx});
    
    for tidx = timeIndices;
        for i = 1:4
            set([ResHandles{i}{:}],'visible','off')
        end
        ResHandle = ResHandles{tidx,midx}{1};
        for j = 1:length(ResHandle)
            set(ResHandle(j),'visible','on','alphadata',1.*(get(ResHandle(j),'alphadata')>0))
        end
        if tidx==1
            set(Handles.PointsHandle{1},'visible','off');
        else
            set(Handles.PointsHandle{1},'visible','on','facealpha',0,'edgealpha',0.5,'edgecolor','m');
        end
        caxis(clim(midx,:));
        
        epsFile = fullfile('~/Dropbox/Documents/20130725_IEEE/Fusion/figures/eps/',sprintf('Planes_%s_%s.eps',time{tidx},modality{midx}));
        print('-depsc',epsFile);
        if makeGIF
            for i = 1:71;
                camorbit(-5,0,'y','camera');
                camlight(L,'right');
                M(i) = getframe(figH);
                pause(0.1);
            end
            gifFile = fullfile('~/Dropbox/Documents/20130725_IEEE/Fusion/figures/gif/',sprintf('Planes_%s_%s.gif',time{tidx},modality{midx}));
            mov2gif(M,gifFile,20);
            camorbit(-5,0,'y','camera')
        end
    end
end

%%
for midx = modeIndices;
    set(cb,'xcolor','w','ycolor','w')
    ylabel(cb,units{midx});
    for tidx = timeIndices;
        caxis(clim(midx,:));
        ResHandle = ResHandles{tidx,midx}{1};
        for i = 1:4
            set(TriMeshHandle{i},'visible','off')
            set([ResHandles{i}{:}],'visible','off')
        end
        for j = 1:length(ResHandle)
            set(ResHandle(j),'visible','on','alphadata',0.1.*(get(ResHandle(j),'alphadata')>0))
        end
        if tidx==1
            set(Handles.PointsHandle{1},'visible','off');
        else
            set(Handles.PointsHandle{1},'visible','on','facealpha',0,'edgealpha',0.5,'edgecolor','m');
        end
        set(TriMeshHandle{tidx,midx},'visible','on','facealpha',0.1);
        epsFile = fullfile('~/Dropbox/Documents/20130725_IEEE/Fusion/figures/eps/',sprintf('Volume_%s_%s.eps',time{tidx},modality{midx}));
        print('-depsc',epsFile);
        if makeGIF
            for i = 1:71;
                camorbit(-5,0,'y','camera');
                camlight(L,'right');
                M(i) = getframe(figH);
                pause(0.1);
            end
            gifFile = fullfile('~/Dropbox/Documents/20130725_IEEE/Fusion/figures/gif/',sprintf('Volume_%s_%s.gif',time{tidx},modality{midx}));
            mov2gif(M,gifFile,20);
            camorbit(-5,0,'y','camera')
        end
    end
end
%%
surfidx = [10,10;10,10];
for midx = modeIndices;
   set(cb,'xcolor','w','ycolor','w')
   ylabel(cb,units{midx});
    for tidx = timeIndices;
        if tidx==1
            set(Handles.PointsHandle{1},'visible','off');
        else
            set(Handles.PointsHandle{1},'visible','on','facealpha',0,'edgealpha',0.5,'edgecolor','m');
        end
        caxis(clim(midx,:));
        ResHandle = ResHandles{tidx,midx}{1};
        for i = 1:4
            set(TriMeshHandle{i},'visible','off')
            set([ResHandles{i}{:}],'visible','off')
        end
        set(TriMeshHandle{tidx,midx}(surfidx(tidx,midx)),'visible','on','facealpha',1);
        epsFile = fullfile('~/Dropbox/Documents/20130725_IEEE/Fusion/figures/eps/',sprintf('Surf_%s_%s.eps',time{tidx},modality{midx}));
        print('-depsc',epsFile);
        if makeGIF
            for i = 1:71;
                camorbit(-5,0,'y','camera');
                camlight(L,'right');
                M(i) = getframe(figH);
                pause(0.1);
            end
            gifFile = fullfile('~/Dropbox/Documents/20130725_IEEE/Fusion/figures/gif/',sprintf('Surf_%s_%s.gif',time{tidx},modality{midx}));
            mov2gif(M,gifFile,20);
            camorbit(-5,0,'y','camera')
        end
    end
end