function Contours = getCartoContours(xmlData,MapIndex,ContourIndex)
if MapIndex == 0
    Contours = [];
    return
end
Maps = xmlData.Children(strcmpi({xmlData.Children(:).Name},'Maps'));
idx = find(strcmpi({Maps.Children(:).Name},'Map'));
Map = Maps.Children(idx(MapIndex));
ContoursData = Map.Children(strcmpi({Map.Children(:).Name},'Contours'));
if ~isempty(ContoursData)
NumContours = str2num(ContoursData.Attributes(strcmpi({ContoursData.Attributes(:).Name},'Count')).Value);
if ~exist('ContourIndex','var')
    ContourIndex = 1:NumContours;
end
for Idx = 1:length(ContourIndex)
ContourData = ContoursData.Children(ContourIndex(Idx));
Strokes = ContourData.Children(strcmpi({ContourData.Children(:).Name},'Stroke'));
clear NPoints;
for i = 1:length(Strokes)
NPoints(i) = length(find(strcmpi({Strokes(i).Children(:).Name},'Point')));
end
[NumPoints StrokeIdx] = max(NPoints);
PointIndices = find(strcmpi({Strokes(StrokeIdx).Children(:).Name},'Point'));
%NumPoints = length(PointIndices);
Position3D = zeros(NumPoints,3);
for i = 1:NumPoints
    Point = Strokes(StrokeIdx).Children(PointIndices(i));
    Position3Dstr = Point.Attributes(strcmpi({Point.Attributes(:).Name},'Position3D')).Value;
    Position3D(i,:) = str2num(Position3Dstr);
end
Contours(Idx).X = Position3D(:,1);
Contours(Idx).Y = Position3D(:,2);
Contours(Idx).Z = Position3D(:,3);
Contours(Idx).Attributes = getAttributes(ContourData);
Contours(Idx).Comment = Contours(Idx).Attributes.Comment;
end
end