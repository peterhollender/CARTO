function CartoPoints = getCartoPoints(xmlData,MapIndex)
if MapIndex == 0
    CartoPoints = [];
    return
end
Maps = xmlData.Children(strcmpi({xmlData.Children(:).Name},'Maps'));
idx = find(strcmpi({Maps.Children(:).Name},'Map'));
Map = Maps.Children(idx(MapIndex));
CartoPointsMap = Map.Children(strcmpi({Map.Children(:).Name},'CartoPoints'));
if ~isempty(CartoPointsMap);
Points = CartoPointsMap.Children(strcmpi({CartoPointsMap.Children(:).Name},'Point'));
NumCartoPoints = length(Points);
clear CartoPoints
for i = 1:NumCartoPoints
    CartoPoint = getAttributes(Points(i));
    Tags = Points(i).Children(strcmpi({Points(i).Children(:).Name},'Tags'));
    if ~isempty(Tags)
        CartoPoint.Tags = str2num(Tags.Children.Data);
    else
        CartoPoint.Tags = [];
    end
    CartoPoint.VirtualPoint = getAttributes(Points(i).Children(strcmpi({Points(i).Children(:).Name},'VirtualPoint')));
    CartoPoints(i) = CartoPoint; 
end
else
CartoPoints = struct;
warning('No CARTO Points Found!');
end