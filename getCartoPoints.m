function CartoPoints = getCartoPoints(xmlData,MapIndex,PointIndex)
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
if ~exist('PointIndex','var')
PointIndex = 1:NumCartoPoints;
end
for ii = 1:length(PointIndex)
    Idx = PointIndex(ii);
    CartoPoint = getAttributes(Points(Idx));
    Tags = Points(Idx).Children(strcmpi({Points(Idx).Children(:).Name},'Tags'));
    if ~isempty(Tags)
        CartoPoint.Tags = str2num(Tags.Children.Data);
    else
        CartoPoint.Tags = [];
    end
    CartoPoint.VirtualPoint = getAttributes(Points(Idx).Children(strcmpi({Points(Idx).Children(:).Name},'VirtualPoint')));
    CartoPoints(ii) = CartoPoint; 
end
else
CartoPoints = struct;
warning('No CARTO Points Found!');
end