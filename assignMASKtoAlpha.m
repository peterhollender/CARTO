function imDataMasked = assignMASKtoAlpha(imData,flag);
if ~exist('flag','var')
    flag = 'overwrite';
end
fields = fieldnames(imData);
if ~any(strcmpi('MASK',fields))
    warning('no MASK data found.');
    imDataMasked = imData;
    return
end
MASK = imData.MASK;
imDataMasked = rmfield(imData,'MASK');
fields = fieldnames(imDataMasked);
for fieldIdx = 1:length(fields);
    switch lower(flag)
        case 'overwrite'
        imDataMasked.(fields{fieldIdx}).alphadata = MASK.alphadata & ~isnan(imDataMasked.(fields{fieldIdx}).cData);
        case 'multiply'
        imDataMasked.(fields{fieldIdx}).alphadata = MASK.alphadata.*imDataMasked.(fields{fieldIdx}).alphadata.*(~isnan(imDataMasked.(fields{fieldIdx}).cData));
        otherwise
        imDataMasked.(fields{fieldIdx}).alphadata = ((1-flag)+flag.*MASK.alphadata).*(imDataMasked.(fields{fieldIdx}).alphadata).*(~isnan(imData.(fields{fieldIdx}).cData));
    end
end
