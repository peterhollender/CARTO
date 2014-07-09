function [GlobalApex GlobalNormal GlobalVector FrameApex FrameNormals FrameVectors]= getCommonApex(XducerToWorldMatrix,imageApexZ)
if ~exist('imageApexZ','var')
    imageApexZ = 0;
end
for frameIdx = 1:size(XducerToWorldMatrix,3)
    [xa(frameIdx) ya(frameIdx) za(frameIdx)] = applyTransformation(0,imageApexZ,0,XducerToWorldMatrix(:,:,frameIdx));
end
GlobalApex = [mean(xa) mean(ya) mean(za)];
for frameIdx = 1:size(XducerToWorldMatrix,3)
    [xb(frameIdx) yb(frameIdx) zb(frameIdx)] = applyTransformation(1,imageApexZ,0,XducerToWorldMatrix(:,:,frameIdx));
    [xc(frameIdx) yc(frameIdx) zc(frameIdx)] = applyTransformation(0,1,0,XducerToWorldMatrix(:,:,frameIdx));
end
GlobalNormal = [mean(xb) mean(yb) mean(zb)];
GlobalNormal = GlobalNormal-GlobalApex;
GlobalNormal = GlobalNormal/norm(GlobalNormal);
GlobalVector = [mean(xc-xa) mean(yc-ya) mean(zc-za)];
GlobalVector = GlobalVector./norm(GlobalVector);
FrameApex = [xa(:) ya(:) za(:)];
FrameNormals = [xb(:) yb(:) zb(:)] - FrameApex;
FrameNormals = FrameNormals./repmat(sqrt(sum(FrameNormals.^2,2)),1,3);
FrameVectors = [xc(:) yc(:) zc(:)] - FrameApex;
FrameVectors = FrameVectors./repmat(sqrt(sum(FrameVectors.^2,2)),1,3);
    
    