function MeshFile = getCartoMeshFile(xmlData,MapIndex)
if MapIndex == 0
    MeshFile = '';
    return
end
Maps = xmlData.Children(strcmpi({xmlData.Children(:).Name},'Maps'));
idx = find(strcmpi({Maps.Children(:).Name},'Map'));
Map = Maps.Children(idx(MapIndex));
MeshFile = Map.Attributes(strcmpi({Map.Attributes(:).Name},'FileNames')).Value;

