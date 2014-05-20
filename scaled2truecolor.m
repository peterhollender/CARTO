function trueColorCData = scaled2truecolor(scaledCData,CLim,ColorMap)
if ischar(ColorMap);
    CMap = colormap(ColorMap);
else
    CMap = ColorMap;
end
directCData = max(0,min(size(CMap,1)-1,((double(scaledCData) - CLim(1))/diff(CLim))*(size(CMap,1)-1)));
indexCData = floor(directCData)+1;
sz = size(scaledCData);
trueColorCData = cat(length(sz)+1,CMap(indexCData,1),CMap(indexCData,2),CMap(indexCData,3));
