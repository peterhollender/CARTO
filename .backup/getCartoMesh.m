function mesh = getCartoMesh(xmlData,MapIndex)
Maps = xmlData.Children(strcmpi({xmlData.Children(:).Name},'Maps'));
idx = find(strcmpi({Maps.Children(:).Name},'Map'));
Map = Maps.Children(idx(MapIndex));
MeshFile = Map.Attributes(strcmpi({Map.Attributes(:).Name},'FileNames')).Value;
mesh = loadMesh(fullfile(CARTOdatapath,MeshFile));
