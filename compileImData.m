function imData = compileImData(dataPath,saveImData)
if ~exist('saveImData','var')
    saveImData = 0;
end

[success, hostname] = system('hostname');
switch deblank(hostname)
    case 'gudenaa.egr.duke.edu'
    addpath '~/Dropbox/scanconversion/';
    addpath '~/Dropbox/arfiProcCode_v6_dev/';
    addpath '/tethys/pjh7/SC2000/CARTO';
    case 'Animal'
    addpath 'C:\Users\pjh7\Dropbox\scanconversion\';
    addpath 'C:\Users\pjh7\Dropbox\arfiProcCode_v6_dev\';
    addpath 'F:\git\CARTO';
end

%% Load CARTO data

cartoPath = fullfile(dataPath,'cartoData');
if isempty(dir(fullfile(cartoPath,'CARTO*.mat')))
xmlFileName = deblank(ls(fullfile(cartoPath,'Study*.xml')));
cartoMATFile = convertCartoData(fullfile(cartoPath,xmlFileName));
else
    d = dir(fullfile(cartoPath,'CARTO*.mat'));
    cartoMATFile = fullfile(cartoPath,d(1).name);
end
cartoUserMapIndexFile = fullfile(cartoPath,'UserMapIndex.mat');
CARTO = processCartoStudy(cartoMATFile,cartoUserMapIndexFile);    

for i = 1:length(CARTO.UserMapIndex.resFilePaths)    
    resDataDir = CARTO.UserMapIndex.resFilePaths{i};
    fprintf('Compiling %s...',resDataDir);
    imDataAllFile = fullfile(resDataDir,'compiledImData.mat');
    imDataFileName = fullfile(resDataDir,sprintf('imData_%s.mat',RetrieveTimeStamp(CARTO.UserMapIndex.resFileNames{i}{1})));
    imData = load(imDataFileName);
    fields = fieldnames(imData);
    for j = 1:length(CARTO.UserMapIndex.resFileNames{i})
        imDataFileName = fullfile(resDataDir,sprintf('imData_%s.mat',RetrieveTimeStamp(CARTO.UserMapIndex.resFileNames{i}{j})));
        imData1 = load(imDataFileName);
        for fidx = 1:length(fields);
            imData.(fields{fidx}).cData(:,:,j) = imData1.(fields{fidx}).cData;
            imData.(fields{fidx}).alphadata(:,:,j) = imData1.(fields{fidx}).alphadata;
            imData.(fields{fidx}).XducerToWorldMatrix(:,:,j) = CARTO.Frames{i}(j).XducerToWorldMatrix;
        end
    end  
    fprintf('done\n');
    if saveImData
    fprintf('saving %s...',imDataAllFile);
    save(imDataAllFile,'-struct','imData');
    fprintf('done\n');
    end
end