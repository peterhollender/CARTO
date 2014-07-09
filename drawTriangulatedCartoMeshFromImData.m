function TriMeshHandle = drawTriangulatedCartoMeshFromImData(MeshObject,imData,imageApexZ,Depths)
%CARTO = CARTO_Pre2;
smoothingKernel = [1 1];
if ~exist('Depths','var')
    Depths = 0;
end

% ResIndices = CARTO.UserMapIndex.ResIndices;
% Apex = [];
% for fileIdx = 1:length(ResIndices);
%     ResIdx = ResIndices(fileIdx);
%     xd = 0;%get(ARFIHandle(i),'zData');
%     yd = -8.54;%get(ARFIHandle(i),'yData');
%     zd = 0;%get(ARFIHandle(i),'xData');
%     [apexX(fileIdx) apexY(fileIdx) apexZ(fileIdx)] = applyTransformation(xd,yd,zd,CARTO.Frames(ResIdx).XducerToWorldMatrix);
% end
% ApexX = mean(apexX);
% ApexY = mean(apexY);
% ApexZ = mean(apexZ);

[GlobalApex GlobalNormal GlobalVector FrameApex FrameNormals FrameVectors] = getCommonApex(imData.XducerToWorldMatrix,imageApexZ);

ApexX = GlobalApex(1);
ApexY = GlobalApex(2);
ApexZ = GlobalApex(3);

x = [];
y = [];
z = [];
c = [];
a = [];


frameIndices = 1:size(imData.XducerToWorldMatrix,3);
[Z X I] = ndgrid(imData.axial,imData.lat,frameIndices); 
I(:) = 1:numel(I);

for frameIdx = frameIndices;
[Xt(:,:,frameIdx) Yt(:,:,frameIdx) Zt(:,:,frameIdx)] = applyTransformation(X(:,:,frameIdx),Z(:,:,frameIdx),0*X(:,:,frameIdx),imData.XducerToWorldMatrix(:,:,frameIdx));
end
Mask = ~isnan(imData.cData) & (imData.alphadata>0);

x = double(Xt(Mask));
y = double(Yt(Mask));
z = double(Zt(Mask));
c = double(imData.cData(Mask));
a = double(imData.alphadata(Mask));

    F = TriScatteredInterp([x y z],c);    
    
    mx = [];
    my = [];
    mz = [];
    for MeshIdx = 1:length(MeshObject)
    mx = [mx;MeshObject(MeshIdx).Vertices.X];
    my = [my;MeshObject(MeshIdx).Vertices.Y];
    mz = [mz;MeshObject(MeshIdx).Vertices.Z];
       end
    
    vectors = [x-ApexX y-ApexY z-ApexZ];
    
    vectorsRel = [dot(vectors,repmat(cross(GlobalNormal,GlobalVector),[length(x) 1]),2) dot(vectors,repmat(GlobalVector,[length(x),1]),2) dot(vectors,repmat(GlobalNormal,[length(x),1]),2)];    
    [th phi r] = cart2sph(vectorsRel(:,1),vectorsRel(:,2),vectorsRel(:,3));
    mvectors = [mx-ApexX my-ApexY mz-ApexZ];
    mvectorsRel = [dot(mvectors,repmat(cross(GlobalNormal,GlobalVector),[length(mx) 1]),2) dot(mvectors,repmat(GlobalVector,[length(mx),1]),2) dot(mvectors,repmat(GlobalNormal,[length(mx),1]),2)];
    [mth mphi mr] = cart2sph(mvectorsRel(:,1),mvectorsRel(:,2),mvectorsRel(:,3));
    
    baseVec = [1 0 0;0 1 0;0 0 1];
    baseRel = [dot(baseVec,repmat(cross(GlobalNormal,GlobalVector),[3 1]),2) dot(baseVec,repmat(GlobalVector,[3 1]),2) dot(baseVec,repmat(GlobalNormal,[3 1]),2)];    
    
            
    angleMargin = 0;
    meshCond = mth>=(min(th)-angleMargin) & mth<=(max(th)+angleMargin) & mphi>=(min(phi)-angleMargin) & mphi<=(max(phi)+angleMargin);
    mthMatch = mth(meshCond);
    mphiMatch = mphi(meshCond);
    mrMatch = mr(meshCond);
    
    FM = TriScatteredInterp([mthMatch,mphiMatch],mrMatch);
    
    Ngrid = 128;
    dth = deg2rad(1);
    dphi = deg2rad(1);
    [TH PHI] = meshgrid(min(th):dth:max(th),min(phi):dphi:max(phi));
    trim = 0;
    TH = TH(trim+1:end-trim,trim+1:end-trim);
    PHI = PHI(trim+1:end-trim,trim+1:end-trim);
    R = FM(TH,PHI);
        
    for depthIdx = 1:length(Depths)
    [XRel YRel ZRel] = sph2cart(TH,PHI,R+Depths(depthIdx));
    X = XRel;
    Y = YRel;
    Z = ZRel;
    X(:) = dot([XRel(:) YRel(:) ZRel(:)],repmat(baseRel(1,:),[numel(XRel),1]),2);
    Y(:) = dot([XRel(:) YRel(:) ZRel(:)],repmat(baseRel(2,:),[numel(XRel),1]),2);
    Z(:) = dot([XRel(:) YRel(:) ZRel(:)],repmat(baseRel(3,:),[numel(XRel),1]),2);

    TriMeshHandle(depthIdx) = surf(X+ApexX,Y+ApexY,Z+ApexZ,mediannan(F(X+ApexX,Y+ApexY,Z+ApexZ),smoothingKernel));
    set(TriMeshHandle(depthIdx),'EdgeColor','none');
    if length(Depths)>1
        hold on
    end
    end