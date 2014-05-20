function CARTO = processCartoStudy(xmlFileName,resFileDataPath,UserMapIndex)
tic;
fprintf('XML:\n',xmlFileName)


[CartoDataPath FileName ext] = fileparts(xmlFileName);
C0 = textscan(FileName,'%s%s%s%s%s%s%s%s%s',1,'delimiter',' _-.','MultipleDelimsAsOne',1);
C1 = [C0{:}];
c = regexp(C1,'20++');
for i = 1:length(c)
match(i) = ~isempty(c{i}) & length(C1{i})==4;
end
timeStamp = sprintf('%s',C1{find(match)+[5,3,4,6,7,8]-5});
clear C1 C0
matFileName = fullfile(CartoDataPath,sprintf('CARTO_%s.mat',timeStamp));
[pth fname ext] = fileparts(matFileName);
matFileName = fullfile(pth,[fname '.mat']);
if ~exist(matFileName,'file')
toc1 = toc;
fprintf('Parsing %s...',xmlFileName);
%matFileName = xml2mat(xmlFileName,matFileName);
xmlData = parseXML(xmlFileName);
fprintf('Saving %s...',matFileName);
save(matFileName,'-struct','xmlData');
fprintf('done %0.1fs\n',toc-toc1);
else
toc1 = toc;
fprintf('Loading %s...',matFileName);
xmlData = load(matFileName);
fprintf('done (%0.2fs)\n',toc-toc1)
end

%%
if ~exist('UserMapIndex','var')
UserMapIndexFile = fullfile(resFileDataPath,'CartoMapIndexData.mat');
if exist(UserMapIndexFile,'file')
    UserMapIndex = load(UserMapIndexFile);
    fprintf('Map Index Data Found!\n')
    getCartoMapInfo(xmlData);
    UserMapIndex
    s = 'x';
    while ~any(strcmpi(s,{'y','n',''}));
        s = input('Proceed with this map y/n [y]:','s');
    end
    if strcmpi(s,'n')
    UserMapIndex = assignMapIndices(xmlData);
    save(UserMapIndexFile,'-struct','UserMapIndex');     
    end
else
    UserMapIndex = assignMapIndices(xmlData);
    save(UserMapIndexFile,'-struct','UserMapIndex');
end
else
    UserMapIndex
end

toc1 = toc;
clear CARTO
for MeshIndex = 1:length(UserMapIndex.Meshes)
MeshFile{MeshIndex} = getCartoMeshFile(xmlData,UserMapIndex.Meshes(MeshIndex));
fprintf('Retrieving Mesh...')
CARTO.Mesh(MeshIndex) = loadMesh(fullfile(CartoDataPath,MeshFile{MeshIndex}));
end
fprintf('Tags...')
CARTO.Tags = getCartoTags(xmlData);
fprintf('Points...')
CARTO.CartoPoints = getCartoPoints(xmlData,UserMapIndex.CartoPoints);
fprintf('Contours...')
CARTO.Contours = getCartoContours(xmlData,UserMapIndex.Contours);
fprintf('Frames...')
CARTO.Frames = getCartoFrames(xmlData,UserMapIndex.Frames);
fprintf('done (%0.2fs)\n',toc-toc1)

CARTO.resFileDataPath = resFileDataPath;
CARTO.UserMapIndex = UserMapIndex;
