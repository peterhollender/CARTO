function MASK = manualSegment(dataPath,overwriteMask)
    if ~exist('overwriteMask','var')
        overwriteMask = 0;
    end
    resPath = fullfile(dataPath,'res');
    compiledImDataFile = fullfile(resPath,'compiledImData.mat');
    scanconvertedImDataFile = fullfile(resPath,'scanconvertedImData.mat');
    maskFile = fullfile(resPath,'MASK.mat');
    if ~exist(maskFile,'file') || overwriteMask;
        if exist(scanconvertedImDataFile,'file')
           fprintf('loading %s...',scanconvertedImDataFile);
           imDataSC = load(scanconvertedImDataFile);
           fprintf('done\n');
        else
            if ~exist(compiledImDataFile,'file')
                if exist(fullfile(fileparts(dataPath),'cartoData'),'dir')
                    compileImData(fileparts(dataPath),1);
                    imData = load(compiledImDataFile);
                else
                    imData = compileImDataOE(dataPath,1);
                end
            else
            fprintf('loading %s...',compiledImDataFile);
            imData = load(compiledImDataFile);
            fprintf('done\n');
            end
            fprintf('scan-converting...')
            imDataSC = scanconvertImData(imData,[-20 20 0 35],0.1);
            fprintf('done\n');
            fprintf('saving %s...',scanconvertedImDataFile)
            save(scanconvertedImDataFile,'-struct','imDataSC');
            fprintf('done\n');
        end
            MASK = segmentationGUI([],imDataSC);
            save(maskFile,'-struct','MASK');
    else
        fprintf('loading %s...',maskFile)
        MASK = load(maskFile);
        fprintf('done\n');
    end
    