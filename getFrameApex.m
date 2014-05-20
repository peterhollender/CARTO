function FrameApex = getFrameApex(Frames)
for FrameIdx = 1:length(Frames)
    xd = 0;
    yd = -8.54;
    zd = 0;
    [ApexX(FrameIdx) ApexY(FrameIdx) ApexZ(FrameIdx)] = applyTransformation(xd,yd,zd,Frames(FrameIdx).XducerToWorldMatrix);
end
FrameApex = [ApexX;ApexY;ApexZ];