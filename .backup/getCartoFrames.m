function Frames = getCartoFrames(xmlData,MapIndex)
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
for FrameIdx = 1:NumFrames
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
Frames(FrameIdx).X = Position3D(:,1);
Frames(FrameIdx).Y = Position3D(:,2);
Frames(FrameIdx).Z = Position3D(:,3);
Frames(FrameIdx).CenterPosition = CenterPosition3D;
Frames(FrameIdx).XducerToWorldMatrix = reshape(str2num(FanModel.Children(strcmpi({FanModel.Children.Name},'TransducerToWorldMatrix')).Children.Data),4,4)';
Frames(FrameIdx).ImageToWorldMatrix = reshape(str2num(FanModel.Children(strcmpi({FanModel.Children.Name},'ImageToWorldMatrix')).Children.Data),4,4)';
Frames(FrameIdx).WorldToImageMatrix = reshape(str2num(FanModel.Children(strcmpi({FanModel.Children.Name},'WorldToImageMatrix')).Children.Data),4,4)';
Frames(FrameIdx).Xducer = Xducer;
Frames(FrameIdx).RawSensor = RawSensor;
Frames(FrameIdx).XducerTip = Tip;
Frames(FrameIdx).Attributes = getAttributes(FrameData);
end
else
Frames = struct;
warning('No Frame Data Found!');
end