function CARTO = processCartoStudy(matFileName,UserMapIndexFile,QueryResponse)
tic;
toc1 = toc;
fprintf('Loading %s...',matFileName);
xmlData = load(matFileName);
fprintf('done (%0.2fs)\n',toc-toc1)
CARTO.CartoDataPath = fileparts(matFileName);

%%
if ~exist('UserMapIndexFile','var') || ~exist(UserMapIndexFile,'file')
    UserMapIndex = assignMapIndices(xmlData);
    if ~exist('UserMapIndexFile','var')
    [filename pathname] = uiputfile('*.mat','Save Study Indices to','UserMapIndex.mat');
    if filename
    UserMapIndexFile = fullfile(pathname,filename);
    fprintf('Saving %s...\n',UserMapIndexFile)
    save(UserMapIndexFile,'-struct','UserMapIndex');
    fprintf('done\n')
    end
    else
    fprintf('Saving %s...\n',UserMapIndexFile)
    save(UserMapIndexFile,'-struct','UserMapIndex');
    fprintf('done\n')
    end
else
    UserMapIndex = load(UserMapIndexFile);
    fprintf('Map Index Data Found!\n')
    getCartoMapInfo(xmlData);
    UserMapIndex
    s = 'x';
    if exist('QueryResponse','var')
        s = QueryResponse;
    end
    while ~any(strcmpi(s,{'y','n',''}));
        s = input('Proceed with this map y/n [y]:','s');
    end
    if strcmpi(s,'n')
    UserMapIndex = assignMapIndices(xmlData);
    fprintf('Saving %s...\n',UserMapIndexFile)
    save(UserMapIndexFile,'-struct','UserMapIndex');     
    fprintf('done\n')
   end
end

toc1 = toc;
for MeshIndex = 1:length(UserMapIndex.Meshes)
MeshFile{MeshIndex} = getCartoMeshFile(xmlData,UserMapIndex.Meshes(MeshIndex));
fprintf('Retrieving Mesh...')
CARTO.Mesh(MeshIndex) = loadMesh(fullfile(CARTO.CartoDataPath,MeshFile{MeshIndex}));
end
fprintf('Tags...')
CARTO.Tags = getCartoTags(xmlData);
fprintf('Points...')
for ii = 1:length(UserMapIndex.CartoPoints)
CARTO.CartoPoints{ii} = getCartoPoints(xmlData,UserMapIndex.CartoPoints(ii),UserMapIndex.CartoPointsIndex{ii});
end
fprintf('Contours...')
for ii = 1:length(UserMapIndex.Contours)
CARTO.Contours{ii} = getCartoContours(xmlData,UserMapIndex.Contours(ii),UserMapIndex.ContoursIndex{ii});
end
fprintf('Frames...')
for ii = 1:length(UserMapIndex.Frames)
CARTO.Frames{ii} = getCartoFrames(xmlData,UserMapIndex.Frames(ii),UserMapIndex.FramesIndex{ii});
fprintf('done (%0.2fs)\n',toc-toc1)
end
%CARTO.resFileDataPath = resFileDataPath;
CARTO.UserMapIndex = UserMapIndex;
