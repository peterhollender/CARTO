function CARTO = processCartoStudy(xmlFileName)
tic;
[CartoDataPath FileName ext] = fileparts(xmlFileName);
C0 = textscan(FileName,'%s%s%s%s%s%s%s%s%s',1,'delimiter',' _-.','MultipleDelimsAsOne',1);
C1 = [C0{:}];
timeStamp = sprintf('%s',C1{[5,3,4,6,7,8]});
clear C1 C0
matFileName = fullfile(CartoDataPath,sprintf('CARTO_%s.mat',timeStamp));
[pth fname ext] = fileparts(matFileName);
matFileName = fullfile(pth,[fname '.mat']);
if ~exist(matFileName,'file')
toc1 = toc;
%fprintf('Parsing %s...',xmlFileName);
matFileName = xml2mat(xmlFileName,matFileName);
fprintf('done %0.1fs\n',toc-toc1);
end
toc1 = toc;
fprintf('Loading %s...',matFileName);
xmlData = load(matFileName);
fprintf('done (%0.2fs)\n',toc-toc1)

%%
if ~isfield(xmlData,'UserMapIndex')
    assignMapIndices(matFileName)
end

toc1 = toc;
clear CARTO
MeshFile = getCartoMeshFile(xmlData,1);
fprintf('Retrieving Mesh...')
CARTO.Mesh = loadMesh(fullfile(CartoDataPath,MeshFile));
fprintf('Tags...')
CARTO.Tags = getCartoTags(xmlData);
fprintf('Points...')
CARTO.CartoPoints = getCartoPoints(xmlData,1);
fprintf('Contours...')
CARTO.Contours = getCartoContours(xmlData,3);
fprintf('Frames...')
CARTO.Frames = getCartoFrames(xmlData,3);
fprintf('done (%0.2fs)\n',toc-toc1)


