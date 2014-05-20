tic;
CartoDataPath = 'C:\pjh7\SC2000\data\20130108_Dog\carto\Study 1\';
CartoDataPath = '/wolf/ClinicalData/CardiacAblationClinicalPatients/CAP1_20130410/Patient 2013_04_10/AFL/Export_AFL-04_10_2013-12-07-28/';
matFileName = fullfile(CartoDataPath,'CARTO_20130108135546');
%matFileName = fullfile(CartoDataPath,'CARTO_20130410120728');
[pth fname ext] = fileparts(matFileName);
matFileName = fullfile(pth,[fname '.mat']);
if ~exist(matFileName,'file')
xmlFileName = fullfile(CartoDataPath,'\Study 1 01_08_2013 13-55-46.xml');
xmlFileName = fullfile(CartoDataPath,'AFL 04_10_2013 12-07-28.xml');
toc1 = toc;
fprintf('Parsing %s...',xmlFileName);
matFileName = xml2mat(xmlFileName,matFileName);
fprintf('done %0.1fs\n',toc-toc1);
end
toc1 = toc;
fprintf('Loading %s...',matFileName);
xmlData = load(matFileName);
fprintf('done (%0.2fs)\n',toc-toc1)

%%
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
CARTO.Contours = getCartoContours(xmlData,1);
fprintf('Frames...')
CARTO.Frames = getCartoFrames(xmlData,1);
fprintf('done (%0.2fs)\n',toc-toc1)


