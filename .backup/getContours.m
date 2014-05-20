function Contours = getContours(xmlData,MapIndex)
Maps = xmlData.Children(strcmpi({xmlData.Children(:).Name},'Maps'));
idx = find(strcmpi({Maps.Children(:).Name},'Map'));
Map = Maps.Children(idx(MapIndex));
Contours = Map.Children(strcmpi({Map.Children(:).Name},'Contours'));
if ~isempty(Contours)
NumContours = str2num(Contours.Attributes(strcmpi({Contours.Attributes(:).Name},'Count')).Value);
for ContourIdx = 1:NumContours
Contour = Contours.Children(ContourIdx);
Strokes = Contour.Children(strcmpi({Contour.Children(:).Name},'Stroke'));
PointIndices = find(strcmpi({Strokes.Children(:).Name},'Point'));
NumPoints = length(PointIndices);
Position3D = zeros(NumPoints,3);
for i = 1:NumPoints
    Point = Strokes.Children(PointIndices(i));
    Position3Dstr = Point.Attributes(strcmpi({Point.Attributes(:).Name},'Position3D')).Value;
    Position3D(i,:) = str2num(Position3Dstr);
end
Contours(ContourIdx).X = Position3D(:,1);
Contours(ContourIdx).Y = Position3D(:,2);
Contours(ContourIdx).Z = Position3D(:,3);
end
end