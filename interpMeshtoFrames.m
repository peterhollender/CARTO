function [Values Xt Yt Zt X Y Z] = interpMeshtoFrames(CARTO,Param)
[Values D Xt Yt Zt] = deal(cell(size(CARTO.Mesh)));
for MeshIdx = 1:length(CARTO.Mesh)
    [X{MeshIdx} Y{MeshIdx} Z{MeshIdx} X0{MeshIdx} Y0{MeshIdx} Z0{MeshIdx}] = deal(zeros(size(CARTO.Frames{MeshIdx}))); 
    for FrameIdx = 1:length(CARTO.Frames{MeshIdx})
         Frame = CARTO.Frames{MeshIdx}(FrameIdx);
           [X{MeshIdx}(FrameIdx) Y{MeshIdx}(FrameIdx) Z{MeshIdx}(FrameIdx)] = applyTransformation(mean(Frame.X),mean(Frame.Y),mean(Frame.Z),Frame.XducerToWorldMatrix);
           [X0{MeshIdx}(FrameIdx) Y0{MeshIdx}(FrameIdx) Z0{MeshIdx}(FrameIdx)] = applyTransformation(0,0,0,Frame.XducerToWorldMatrix);
    f0 = [0:99]/99;
    f1 = 1-f0;
    [v d xt yt zt] = interpMeshValue(X{MeshIdx}(FrameIdx)*f0+X0{MeshIdx}(FrameIdx)*f1,Y{MeshIdx}(FrameIdx)*f0+Y0{MeshIdx}(FrameIdx)*(f1),Z{MeshIdx}(FrameIdx)*f0+Z0{MeshIdx}(FrameIdx)*(f1),CARTO.Mesh(MeshIdx),Param);
    [dmin minidx] = min(d);
    Values{MeshIdx}(FrameIdx) = v(minidx);
    D{MeshIdx}(FrameIdx) = d(minidx);
    Xt{MeshIdx}(FrameIdx) = xt(minidx);
    Yt{MeshIdx}(FrameIdx) = yt(minidx); 
    Zt{MeshIdx}(FrameIdx) = zt(minidx);
    end
end