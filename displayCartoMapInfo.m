function Data = displayCartoMapInfo(xmlData)
    Maps = xmlData.Children(strcmpi({xmlData.Children(:).Name},'Maps'));
    idx = find(strcmpi({Maps.Children(:).Name},'Map'));
    fprintf('Found %g Maps.\n',length(idx));
    fprintf('| %3s | %-32s| %-6s | %-6s | %-8s | %-6s |\n','Map','Name','Meshes','Points','Contours','Frames');
    for MapIndex = 1:length(idx);
    Map = Maps.Children(idx(MapIndex));
    MeshFiles = {Map.Attributes(strcmpi({Map.Attributes(:).Name},'FileNames')).Value};
    Data.Meshes(MapIndex) = length(MeshFiles);
    CartoPointsMap = Map.Children(strcmpi({Map.Children(:).Name},'CartoPoints'));
    if ~isempty(CartoPointsMap) && ~isempty(CartoPointsMap.Children);
    Points = CartoPointsMap.Children(strcmpi({CartoPointsMap.Children(:).Name},'Point'));
    Data.CartoPoints(MapIndex) = length(Points);
    else
    Data.CartoPoints(MapIndex) = 0;
    end
    ContoursData = Map.Children(strcmpi({Map.Children(:).Name},'Contours'));
    if ~isempty(ContoursData)
    Data.Contours(MapIndex) = str2num(ContoursData.Attributes(strcmpi({ContoursData.Attributes(:).Name},'Count')).Value);
    else
    Data.Contours(MapIndex) = 0;
    end
    FramesData = Map.Children(strcmpi({Map.Children(:).Name},'Frames'));
    if ~isempty(FramesData);
    Data.Frames(MapIndex) = length(FramesData.Children);
    else
    Data.Frames(MapIndex) = 0;
    end
    Data.MapName{MapIndex} = Map.Attributes(strcmpi({Map.Attributes(:).Name},'Name')).Value;
    fprintf('| %3g | %-32s| %6g | %6g | %8g | %6g |\n',MapIndex,Data.MapName{MapIndex},Data.Meshes(MapIndex),Data.CartoPoints(MapIndex),Data.Contours(MapIndex),Data.Frames(MapIndex));
    end