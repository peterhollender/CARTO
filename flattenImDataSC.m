function imDataFlat = flattenImDataSC(imDataSC,imageApexZ);
if ~exist('imageApexZ','var')
    imageApexZ = 0;
end
%imDataFlat = imDataSC;
fields = fieldnames(imDataSC);
for fieldidx = 1:length(fields);
    im = imDataSC.(fields{fieldidx});
    [GlobalApex GlobalNormal GlobalVector FrameApex FrameNormals FrameVectors] = getCommonApex(im.XducerToWorldMatrix,imageApexZ);    
    
    
    [imZ imX imPhi] = ndgrid(im.axial,im.lat,1:size(im.XducerToWorldMatrix,3));
    C = im.cData;
    A = im.alphadata;
    XducerToWorldMatrix = im.XducerToWorldMatrix;
    A(isnan(C)) = 0;
    C(A==0) = nan;
    imZ(A==0) = nan;
    C1 = nansum(C.*A,1)./nansum(A,1);
    A1 = nansum(A.*(A>0),1)./nansum(A>0,1);
    A1(isnan(C1)|(A1==0)) = nan;
    Z1 = nansum(imZ.*(A>0),1)./nansum((A>0),1);
    for frameIndex = 1:size(im.XducerToWorldMatrix,3)
        [Xt(:,frameIndex) Yt(:,frameIndex) Zt(:,frameIndex)] = applyTransformation(0*imX(1,:,frameIndex),Z1(1,:,frameIndex),imX(1,:,frameIndex),XducerToWorldMatrix(:,:,frameIndex));
    end
    CenterVec = [nanmean(Xt)' nanmean(Yt)' nanmean(Zt)'];
    
    for frameIndex = 1:size(im.XducerToWorldMatrix,3)
    ProjVec(frameIndex,:) = dot(GlobalNormal,CenterVec(frameIndex,:)-GlobalApex)*GlobalNormal+dot(GlobalVector,CenterVec(frameIndex,:)-GlobalApex)*GlobalVector;
    ProjVec(frameIndex,:) = ProjVec(frameIndex,:)/norm(ProjVec(frameIndex,:));
    Phi0(frameIndex) = acosd(dot(ProjVec(frameIndex,:),GlobalNormal));
    end
    
    [Phi sortOrder] = sort(Phi0);
    
    
    
    imDataFlat.(fields{fieldidx}) = struct('xdata',Xt(:,sortOrder),'ydata',Yt(:,sortOrder),'zdata',Zt(:,sortOrder),'cdata',squeeze(C1(:,:,sortOrder)),'alphadata',squeeze(A1(:,:,sortOrder)),'FramePhi',Phi(:),'GlobalApex',GlobalApex,'GlobalNormal',GlobalNormal','GlobalVector',GlobalVector,'FrameApex',FrameApex(sortOrder,:),'FrameNormals',FrameNormals(sortOrder,:),'FrameVectors',FrameVectors(sortOrder,:));
    extraParams = {'clim','units','name'};
    for pidx = 1:length(extraParams)
        if isfield(im,extraParams{pidx})
            imDataFlat.(fields{fieldidx}).(extraParams{pidx}) = im.(extraParams{pidx});
        end
    end
end
    
    
    
    