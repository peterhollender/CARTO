function [FramePhi]= getRelativePhi(XducerToWorldMatrix,imageFocalDepthZ,imageApexZ)
if ~exist('imageApexZ','var')
    imageApexZ = 0;
end
if ~exist('imageFocalDepthZ','var')
    imageFocalDepthZ = 20;
end
numFrames = size(XducerToWorldMatrix,3);
 [GlobalApex GlobalNormal GlobalVector FrameApex FrameNormals FrameVectors] = getCommonApex(XducerToWorldMatrix,imageApexZ);    
  if length(imageFocalDepthZ) == 1
      imageFocalDepthZ = repmat(imageFocalDepthZ,[numFrames,1]);
  end
  
    for frameIndex = 1:numFrames
        [Xt Yt Zt] = applyTransformation(0,imageFocalDepthZ(frameIndex),0,XducerToWorldMatrix(:,:,frameIndex));
    CenterVec = [Xt Yt Zt];
        ProjVec(frameIndex,:) = dot(GlobalNormal,CenterVec-GlobalApex)*GlobalNormal+dot(GlobalVector,CenterVec-GlobalApex)*GlobalVector;
        ProjVec(frameIndex,:) = ProjVec(frameIndex,:)/norm(ProjVec(frameIndex,:));
        FramePhi(frameIndex) = acosd(dot(ProjVec(frameIndex,:),GlobalNormal));
    end
    