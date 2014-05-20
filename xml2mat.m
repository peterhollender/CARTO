function matFileName = xml2mat(xmlFileName,matFileName);
tic;
[pth fname ext] = fileparts(xmlFileName);
if ~exist('matFileName','var')
    matFileName = fullfile(pth,fname);
end
toc1 = toc;
fprintf('Parsing %s...',xmlFileName);
xmlStruct = parseXML(xmlFileName);
fprintf('done %0.2fs\n',toc-toc1);
toc1 = toc;
fprintf('Saving %s...',matFileName);
save(matFileName,'-struct','xmlStruct');
fprintf('done %0.2fs\n',toc-toc1);

