xmlData = load('CARTO_20130220162131');
mapInfo = getCartoMapInfo(xmlData);
%%
FileTypes = {
    'NAVISTAR_CONNECTOR_Eleclectrode_Positions.txt',...
    'NAVISTAR_CONNECTOR_Eleclectrode_Positions_OnAnnotation.txt',...
    'NAVISTAR_CONNECTOR_Sensor_Positions.txt',...
    'NAVISTAR_CONNECTOR_Sensor_Positions_OnAnnotation.txt',...
    'ULS_CONNECTOR_Sensor_Positions.txt',...
    'ULS_CONNECTOR_Sensor_Positions_OnAnnotation.txt'};
for mapidx = 1:length(mapInfo.MapName);
    ExportFiles{mapidx}  = dir(sprintf('%s*%s',mapInfo.MapName{mapidx},'Point_Export.xml'));
end

%%
mapidx = 1;
mapName = mapInfo.MapName{mapidx};
carFile = sprintf('%s_car.txt',mapName);
fid = fopen(carFile,'r');
CAR = textscan(fid,'%s%u%u%u%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f','HeaderLines',1,'MultipleDelimsAsOne',1,'Delimiter',char(9),'TreatAsEmpty','A');
fclose(fid);
pointidx = 1;
fileName = ExportFiles{mapidx}(pointidx).name;
pointStr = fileName(length(mapName)+2:end-(length('Point_Export.xml')+1));
exportData = xml2struct(fileName);
k = getAttributes(exportData.Children(find(strcmpi({exportData.Children.Name}','ECG'))));
ecgFile = k.FileName;



