function [X Y Z] = getFrameOrigin(Frames);
for MeshIdx = 1:length(Frames)
    [X{MeshIdx} Y{MeshIdx} Z{MeshIdx}] = deal(zeros(size(Frames{MeshIdx}))); 
    for FrameIdx = 1:length(Frames{MeshIdx})
         Frame = Frames{MeshIdx}(FrameIdx);
         X{MeshIdx}(FrameIdx) = Frame.XducerToWorldMatrix(1,4);
         Y{MeshIdx}(FrameIdx) = Frame.XducerToWorldMatrix(2,4);
         Z{MeshIdx}(FrameIdx) = Frame.XducerToWorldMatrix(3,4);
    end
end