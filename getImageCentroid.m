function [CenterVec Xt Yt Zt] = getImageCentroid(im)
    [imZ, imX, imPhi] = ndgrid(im.axial,im.lat,1:size(im.XducerToWorldMatrix,3));
    C = im.cData;
    A = im.alphadata;
    A(isnan(C)) = 0;
    imZ(A==0) = nan;
    Z1 = nansum(imZ.*(A),1)./nansum((A),1);
    for frameIndex = 1:size(im.XducerToWorldMatrix,3)
        [Xt(:,frameIndex), Yt(:,frameIndex), Zt(:,frameIndex)] = applyTransformation(0*imX(1,:,frameIndex),Z1(1,:,frameIndex),imX(1,:,frameIndex),im.XducerToWorldMatrix(:,:,frameIndex));
    end
    CenterVec = [nanmean(Xt)' nanmean(Yt)' nanmean(Zt)'];
    