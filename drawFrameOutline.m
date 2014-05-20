function FrameHandle = drawFrameOutline(FrameCell)
for ii = 1:length(FrameCell)
for FrameIdx = 1:length(FrameCell{ii})
Frame = FrameCell{ii}(FrameIdx);
[xt yt zt] = applyTransformation(Frame.X,Frame.Y,Frame.Z,Frame.XducerToWorldMatrix);
FrameHandle{ii}(FrameIdx) = patch(xt,yt,zt,'c','faceColor','none','edgecolor','c','edgealpha',0.5,'linewidth',1);
end
end

   