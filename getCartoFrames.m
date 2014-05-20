function Frames = getCartoFrames(xmlData,MapIndex,FramesIndex)
if MapIndex == 0
    Frames = [];
    return
end
Maps = xmlData.Children(strcmpi({xmlData.Children(:).Name},'Maps'));
idx = find(strcmpi({Maps.Children(:).Name},'Map'));
Map = Maps.Children(idx(MapIndex));
FramesData = Map.Children(strcmpi({Map.Children(:).Name},'Frames'));
if ~isempty(FramesData);
NumFrames = length(FramesData.Children);
if ~exist('FramesIndex','var')
    FramesIndex = 1:NumFrames;
end
for ii = 1:length(FramesIndex)
    FrameIdx = FramesIndex(ii);
FrameData = FramesData.Children(FrameIdx);
TipPositionStr = FrameData.Attributes(strcmpi({FrameData.Attributes(:).Name},'ULSTipLocation')).Value;
XducerPositionStr = FrameData.Attributes(strcmpi({FrameData.Attributes(:).Name},'ULSTransducerLocation')).Value;
RawSensorPositionStr = FrameData.Attributes(strcmpi({FrameData.Attributes(:).Name},'RawSensorLocation')).Value;
C = textscan(TipPositionStr,'%f%f%f%f%f%f',1,'Delimiter',',() ','MultipleDelimsAsOne',1);
Tip.X = [C{1};C{4}];
Tip.Y = [C{2};C{5}];
Tip.Z = [C{3};C{6}];
C = textscan(XducerPositionStr,'%f%f%f%f%f%f',1,'Delimiter',',() ','MultipleDelimsAsOne',1);
Xducer.X = [C{1};C{4}];
Xducer.Y = [C{2};C{5}];
Xducer.Z = [C{3};C{6}];
C = textscan(RawSensorPositionStr,'%f%f%f%f%f%f',1,'Delimiter',',() ','MultipleDelimsAsOne',1);
RawSensor.X = [C{1};C{4}];
RawSensor.Y = [C{2};C{5}];
RawSensor.Z = [C{3};C{6}];
FanModel = FrameData.Children;
Outline = FanModel.Children(strcmpi({FanModel.Children.Name},'Outline'));
FanCenterPos = FanModel.Children(strcmpi({FanModel.Children.Name},'FanCenterPos'));
CenterPosition3D = str2num(FanCenterPos.Attributes(strcmpi({FanCenterPos.Attributes(:).Name},'Position3D')).Value);
NumOutlinePoints = length(Outline.Children);
Position3D = zeros(NumOutlinePoints,3);
for i = 1:NumOutlinePoints
    OutlinePoint = Outline.Children(i);
    Position3Dstr = OutlinePoint.Attributes(strcmpi({OutlinePoint.Attributes(:).Name},'Position3D')).Value;
    Position3D(i,:) = str2num(Position3Dstr);
end
Frames(ii).X = Position3D(:,1);
Frames(ii).Y = Position3D(:,2);
Frames(ii).Z = Position3D(:,3);
Frames(ii).CenterPosition = CenterPosition3D;
Frames(ii).XducerToWorldMatrix = reshape(str2num(FanModel.Children(strcmpi({FanModel.Children.Name},'TransducerToWorldMatrix')).Children.Data),4,4)';
Frames(ii).ImageToWorldMatrix = reshape(str2num(FanModel.Children(strcmpi({FanModel.Children.Name},'ImageToWorldMatrix')).Children.Data),4,4)';
Frames(ii).WorldToImageMatrix = reshape(str2num(FanModel.Children(strcmpi({FanModel.Children.Name},'WorldToImageMatrix')).Children.Data),4,4)';
Frames(ii).Xducer = Xducer;
Frames(ii).RawSensor = RawSensor;
Frames(ii).XducerTip = Tip;
Frames(ii).Attributes = getAttributes(FrameData);
end
else
Frames = struct;
warning('No Frame Data Found!');
end