%function makeRenderedFigures(locPath)
locPath = pwd;
addpath F:\git\CARTO\
addpath C:\Users\pjh7\Dropbox\scanconversion\
addpath C:\Users\pjh7\Dropbox\arfiProcCode_v6_dev\
imageApexZ = -8.54;
dataPath = {};
print_on = 1;
print_tex = 0;
overwrite_movie = 1;
overwrite_mesh = 0;
[rootpath datepath] = fileparts(fileparts(locPath));
cartoDataPath = fullfile(locPath,'cartoData');
renderStyles = {'Slices','Cloud'};
 
CARTO_MAT_files = dir(fullfile(cartoDataPath,'CARTO*.mat'));
if isempty(CARTO_MAT_files);
    xmlFiles = dir(fullfile(cartoDataPath,'Study*.xml'));
    xmlFileName = fullfile(cartoDataPath,xmlFiles(1).name);
    matFileName = convertCartoData(xmlFileName);
else
    matFileName = fullfile(cartoDataPath,CARTO_MAT_files.name);
end
UserMapIndexFile = fullfile(cartoDataPath,'UserMapIndex.mat');
CARTO = processCartoStudy(matFileName,UserMapIndexFile,'y');

expPaths = {'Baseline_ARFISWEI','RFA_ARFISWEI'};

for eidx = 1:length(expPaths);
    dataPath{eidx} = fullfile(locPath,expPaths{eidx});
end

fprintf('loading imData....')
for ii = 1:length(dataPath);
    imDataFiles{ii} = fullfile(dataPath{ii},'res','scanconvertedImData.mat');
    imDataSC = load(imDataFiles{ii});
 %   imDataSC.STL.clim = [0 8];
 %   imDataSC.MTL.clim = [0 8];
    MaskFile = fullfile(dataPath{ii},'res','MASK.mat');
    imDataSC.MASK = load(MaskFile);
    imDataMasked(ii) = assignMASKtoAlpha(imDataSC);
end
fprintf('done\n');

%%
for setIdx = 2;
    imDataMask = imDataMasked(setIdx);
    fields = fieldnames(imDataMask);
    imData = imDataMask.(fields{1});
    %[ptmask heatmap]= mapCartoPointsToImage(imData,CARTO.CartoPoints{1},CARTO.Tags);
    epsdir = fullfile(dataPath{setIdx},'figures','eps');
    pngdir = fullfile(dataPath{setIdx},'figures','png');
    frameIndexFile = fullfile(dataPath{setIdx},'FrameIndices.mat');
    if exist(frameIndexFile,'file')
        load(frameIndexFile,'FrameIndices')
    else
        disp('CHECK FRAMEINDICES')
        figure(3);
        for i = 1:size(imDataMask.cData,3);draw_imData(imDataMask,i,'bmode');suptitle(sprintf('%0.0f',i));pause;end
        FrameIndices = 1:size(imData.cData,3);
        return
    end
        for fieldidx = 1:length(fields);
           imDataMask.(fields{fieldidx}).cData =  imDataMask.(fields{fieldidx}).cData(:,:,FrameIndices);
           imDataMask.(fields{fieldidx}).alphadata =  imDataMask.(fields{fieldidx}).alphadata(:,:,FrameIndices);
           imDataMask.(fields{fieldidx}).XducerToWorldMatrix = imDataMask.(fields{fieldidx}).XducerToWorldMatrix(:,:,FrameIndices);
        end
        
        for midx = 1:length(renderStyles);
            renderStyle = renderStyles{midx};
            movieFile{midx} = fullfile(dataPath{setIdx},'figures',sprintf('movieFrames_%s.mat',renderStyle));
        end
   
        if ~exist(epsdir,'dir')
            mkdir(epsdir);
        end
        if ~exist(pngdir,'dir')
            mkdir(pngdir);
        end
        nrow = 3;
        ncol = 6;
        camInc = 360/(nrow*ncol);
    
        if ~all(cellfun(@(s)exist(s,'file'),movieFile)) || overwrite_movie
        figH = 1;
        if ishandle(figH);
            close(figH);
        end
        figure(figH);clf
        opengl('software');
        colordef(figH,'black')
        colormap gray
        set(figH,'defaultaxesfontsize',14,'defaultaxesfontweight','bold')
        set(figH,'invertHardcopy','off','PaperPositionMode','auto');
        set(figH,'windowstyle','normal','position',[45 237 602 665]);
        hold on
        set(gcf,'color',[0.1 0.15 0.2]);
        fields = fieldnames(imDataMasked);
        %imDataFlat = flattenImDataSC(imDataMask,imageApexZ);
                
        for fieldidx = 1:length(fields);
            im = imDataMask.(fields{fieldidx});
            [GlobalApex GlobalNormal GlobalVector FrameApex FrameNormals FrameVectors] = getCommonApex(im.XducerToWorldMatrix,imageApexZ);
            CenterVec = getImageCentroid(im);
            for frameIndex = 1:size(im.XducerToWorldMatrix,3)
                ProjVec(frameIndex,:) = dot(GlobalNormal,CenterVec(frameIndex,:)-GlobalApex)*GlobalNormal+dot(GlobalVector,CenterVec(frameIndex,:)-GlobalApex)*GlobalVector;
                ProjVec(frameIndex,:) = ProjVec(frameIndex,:)/norm(ProjVec(frameIndex,:));
                Phi0(frameIndex) = acosd(dot(ProjVec(frameIndex,:),GlobalNormal));
            end
            [Phi sortOrder] = sort(Phi0);
            
            fprintf('drawing %s slices...',fields{fieldidx});
            sliceHandles{fieldidx} = draw3DImDataSC(imDataMask,fields{fieldidx});
            fprintf('done\n');
        end
        set([sliceHandles{:}],'visible','off');
        
        meshSurfFile = fullfile(dataPath{setIdx},'res','meshSurfData.mat');
        if exist(meshSurfFile,'file') && ~overwrite_mesh
            fprintf('loading %s...',meshSurfFile);
            surfData = load(meshSurfFile);
            fprintf('done\n');
        else
        for fieldidx = 1:length(fields);    
            fprintf('interpolating data to mesh %s...',fields{fieldidx});
            %surfData.(fields{fieldidx}) = interpMeshSurf(CARTO.Mesh,imDataMask.(fields{fieldidx}),imageApexZ,[0:0.25:3],'Gaussian',[0.15 2]);
            surfData.(fields{fieldidx}) = interpMeshSurf(CARTO.Mesh,imDataMask.(fields{fieldidx}),imageApexZ,[0:0.25:3],'TriScatteredInterp');
            fprintf('done\n');
        end
            fprintf('saving %s...',meshSurfFile);
            save(meshSurfFile,'-struct','surfData');
            fprintf('done\n');
        end
        
        for fieldidx = 1:length(fields);    
            im = surfData.(fields{fieldidx});
            for depthIdx = 1:size(im.zData,3);
            TriMeshHandle{fieldidx}(depthIdx) = surf(im.xData(:,:,depthIdx),im.yData(:,:,depthIdx),im.zData(:,:,depthIdx),im.cData(:,:,depthIdx),'edgecolor','none');
            end
        end
        set([TriMeshHandle{:}],'facealpha',0.1);
        set([TriMeshHandle{:}],'visible','off');
        
        for pointIndex = 1:length(CARTO.CartoPoints);
            PointsHandle{pointIndex} = drawCartoPoints(CARTO.CartoPoints{pointIndex},CARTO.Tags);
        end
        set([PointsHandle{:}],'facecolor','r','edgecolor','none','facealpha',0.25);

        for MeshIndex = 1:length(CARTO.Mesh);
            MeshHandle(MeshIndex) = drawCartoMesh(CARTO.Mesh(MeshIndex));
        end
        set(MeshHandle,'edgecolor','c','edgealpha',0.1,'facecolor','none');
        
        axis image
        set(gca,'CameraTarget',mean(CenterVec),'CameraPosition',mean(CenterVec)+50*GlobalVector,'CameraUpVector',cross(GlobalVector,GlobalNormal),'CameraViewAngle',20,'Projection','perspective')
        set(gca,'XTick',[],'YTick',[],'ZTick',[],'box','on')
        axColor = 0.8*[1 1 1];
        set(gca,'xcolor',axColor,'ycolor',axColor,'zcolor',axColor);
        axis off
        end
       %%
       
        for midx = 1:length(renderStyles);
            renderStyle = renderStyles{midx};
       
        if exist(movieFile{midx},'file') && ~overwrite_movie
            fprintf('reading movie frames from %s...',movieFile{midx});
            MovieFrames = load(movieFile{midx});
            fprintf('done\n');
        else
        
        figure(figH);
        for fieldidx = 1:length(fields);
                switch renderStyle
                    case 'Slices'
                set([sliceHandles{:}],'Visible','off');
                set([TriMeshHandle{:}],'visible','off')
                set(sliceHandles{fieldidx},'Visible','on');
                    case 'Cloud'
                set([sliceHandles{:}],'Visible','off');
                set([TriMeshHandle{:}],'visible','off')
                set(TriMeshHandle{fieldidx},'visible','on');
                end
                set(gca,'clim',imDataMask.(fields{fieldidx}).clim);
                for orbitidx = (1:360/camInc)
                camphi(orbitidx) = (orbitidx-1)*camInc;
                camorbit(camInc,0,'camera','y')
                drawnow
                pause(0.02);
                movframe = getframe(gcf);
                MovieFrames.(fields{fieldidx})(orbitidx) = movframe;
            end
        end
            MovieFrames.camphi = camphi;
            fprintf('saving movie frames to %s...',movieFile{midx});
            save(movieFile{midx},'-struct','MovieFrames');
            fprintf('done\n');
        end
        %%
        for black = 0:1;
        %% Render Figure
        figH2 = 2;
        figure(figH2);clf
        if black
            colordef(figH2,'black')
            set(figH2,'color','k')
        else
            colordef(figH2,'white')
            set(figH2,'color','w')
        end
        set(figH2,'defaultaxesfontsize',14,'defaultaxesfontweight','bold')
        set(figH2,'invertHardcopy','off','PaperPositionMode','auto');
        set(figH2,'windowstyle','normal');
        set(figH2,'position',[182 740 1782 1302]);

        sp = subplots([1 nrow nrow nrow nrow],nrow*ncol,[0.02 0.01],[0.01 0.01 0.01 0.08]);
      
        colormap gray
        sp1 = zeros(4,ncol);
        for i = 1:4
            for j = 1:ncol
                sp1(i,j) = mergeAxes(sp(1+i,(j-1)*nrow+[1:nrow]));
            end
        end
        sp = sp(1,:);
        for j = 1:size(sp,2);
            subplot(sp(j));
            image(MovieFrames.BMODE(j).cdata);
        end
        for i = 1:4
        for j = 1:ncol
            subplot(sp1(i,j))
            tmpH = imagesc(1,1,0,imDataMask.(fields{i}).clim);
            hold on
            set(tmpH,'visible','off')
            image(MovieFrames.(fields{i})((j-1)*nrow+1).cdata);
        end
        end
        set(sp,'XTick',[],'Ytick',[])
        set(sp1(:),'XTick',[],'Ytick',[]);
        axis(sp(:),'image')
        axis(sp1(:),'image');
        for i = 1:4
        for j = 1:ncol
            subplot(sp1(i,j))
            if i==1
                addCornerText(sprintf('%0.0f^\\circ',MovieFrames.camphi((j-1)*nrow+1)),16,'northeast');
            end
            if j == 1
               addCornerText(imDataMask.(fields{i}).name,16,'northwest'); 
            end
            if j == ncol
                pos = get(sp1(i,end),'position');
                cb = colorbar;
                set(sp1(i,end),'position',pos);
                ylabel(cb,imDataMask.(fields{i}).units);
            end
        end
        end
            figname = sprintf('%s_%s_%s',renderStyle,datepath,expPaths{setIdx});
                if print_on
                    if black
                    fprintf('printing %s...',fullfile(pngdir,[figname '.png']));
                    print('-dpng',fullfile(pngdir,figname));
                    fprintf('done\n');
                    else
                    fprintf('printing %s...',fullfile(epsdir,[figname '.eps']));
                    print('-depsc',fullfile(epsdir,figname));
                    fprintf('done\n');
                    end
                end
                
        end  
                
                
    end
end

%%
% for frameIndex = 1:size(imDataMask.BMODE.cData,3);
% sp = subplots(2,2,[0.05 0.15],[0.03 0.07 0.08 0.12]);
% for fieldIdx = 1:4
%     subplot(sp(fieldIdx))
%     imData = imDataMask.(fields{fieldIdx});
%     if fieldIdx == 1;
%     %drawColorized(imData.lat,imData.axial,ptmask(:,:,frameIndex),(0.3+0.7*(min(1,ptmask(:,:,frameIndex)/3))).*(ptmask(:,:,frameIndex)>0),imDataMasked(2).BMODE.cData(:,:,frameIndex),jet,[0 1]);        
%     drawColorized(imData.lat,imData.axial,heatmap(:,:,frameIndex),heatmap(:,:,frameIndex).^2,imDataMasked(setIdx).BMODE.cData(:,:,frameIndex),jet,[0 1]);            
%     axis image
%     else
%     imh = imagesc(imData.lat,imData.axial,imData.cData(:,:,frameIndex),imData.clim);
%     hold on
%     drawColorized(imData.lat,imData.axial,medfilt2(imData.cData(:,:,frameIndex),[3 3]),(0.9+0.1*(imData.alphadata(:,:,frameIndex))).*(~isnan(imData.cData(:,:,frameIndex))),imDataMask.BMODE.cData(:,:,frameIndex),jet,imData.clim);
%     set(imh,'visible','off')
%     set(sp(fieldIdx),'clim',imData.clim);
%     axis image
%     pos = get(sp(fieldIdx),'position');
%     cb = colorbar;
%     set(sp(fieldIdx),'position',pos);
%     ylabel(cb,imData.units);
%     end
%     addCornerText(imData.name,16,'NorthWest');
% end
% linkprop(sp,{'xlim','ylim','zlim'});
% set(sp(1:end-1,:),'XtickLabel',{})
% set(sp(:,2:end),'YTickLabel',{});
% for i = 1:size(sp,1)
%     ylabel(sp(i,1),'z (mm)');
% end
% for j = 1:size(sp,2);
%     xlabel(sp(end,j),'x (mm)');
% end
% 
% if print_on
%     figname = sprintf('images_%s_%s_frame_%03.0f',datepath,expPaths{setIdx},frameIndex);
%     if black
%         print('-dpng',fullfile(pngdir,figname));
%     else
%         print('-depsc',fullfile(epsdir,figname));
%     end
%     set(sp,'xlim',[-12 12],'ylim',[0 20]);
%     sprintf('zoomed_%s_%s_frame_%03.0f',datepath,expPaths{setIdx},frameIndex);
%     if black
%         print('-dpng',fullfile(pngdir,figname));
%     else
%         print('-depsc',fullfile(epsdir,figname));
%     end
% end
% end
