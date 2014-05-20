function matFileName = convertCartoData(xmlFileName,matFileName)
tic;
if ~exist('matFileName','var')
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
end
[pth fname ext] = fileparts(matFileName);
matFileName = fullfile(pth,[fname '.mat']);
toc1 = toc;
fprintf('Parsing %s...',xmlFileName);
%matFileName = xml2mat(xmlFileName,matFileName);
xmlData = parseXML(xmlFileName);
fprintf('\nSaving %s...',matFileName);
save(matFileName,'-struct','xmlData');
fprintf('done %0.1fs\n',toc-toc1);
