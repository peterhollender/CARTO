function TriMeshHandle = drawTriangulatedCartoMesh(CARTO,Depths)
%CARTO = CARTO_Pre2;
smoothingKernel = [1 1];
if ~exist('Depths','var')
    Depths = 0;
end

ResIndices = CARTO.UserMapIndex.ResIndices;
Apex = [];
for fileIdx = 1:length(ResIndices);
    ResIdx = ResIndices(fileIdx);
    xd = 0;%get(ARFIHandle(i),'zData');
    yd = -8.54;%get(ARFIHandle(i),'yData');
    zd = 0;%get(ARFIHandle(i),'xData');
    [apexX(fileIdx) apexY(fileIdx) apexZ(fileIdx)] = applyTransformation(xd,yd,zd,CARTO.Frames(ResIdx).XducerToWorldMatrix);
end
ApexX = mean(apexX);
ApexY = mean(apexY);
ApexZ = mean(apexZ);

x = [];
y = [];
z = [];
c = [];
a = [];

for imageIdx = 1:length(CARTO.ARFIHandle)
    xdata = get(CARTO.ARFIHandle(imageIdx),'xdata');
    ydata = get(CARTO.ARFIHandle(imageIdx),'ydata');
    zdata = get(CARTO.ARFIHandle(imageIdx),'zdata');
    cdata = get(CARTO.ARFIHandle(imageIdx),'cdata');
    if length(get(CARTO.ARFIHandle(imageIdx),'alphadata')) == 1
        adata = ~isnan(cdata);
    else
        adata = padarray(get(CARTO.ARFIHandle(imageIdx),'alphadata'),[1 1],'post');
    end
    cdata = mediannan(cdata,smoothingKernel);
    x = [x;xdata(:)];
    y = [y;ydata(:)];
    z = [z;zdata(:)];
    c = [c;cdata(:)];
    a = [a;adata(:)];
end

    x = x(a>0);
    y = y(a>0);
    z = z(a>0);
    c = c(a>0);
    a = a(a>0);
    
    F = TriScatteredInterp([x y z],c);
    
    
    mx = [];
    my = [];
    mz = [];
    
    for MeshIdx = 1:length(CARTO.Mesh)
    mx = [mx;CARTO.Mesh(MeshIdx).Vertices.X];
    my = [my;CARTO.Mesh(MeshIdx).Vertices.Y];
    mz = [mz;CARTO.Mesh(MeshIdx).Vertices.Z];
    end
    
        [th phi r] = cart2sph(x-ApexX,y-ApexY,z-ApexZ);
    [mth mphi mr] = cart2sph(mx-ApexX,my-ApexY,mz-ApexZ);
    
    
    if mean(abs(th))>pi/2
        th = mod(th,2*pi);
        mth = mod(mth,2*pi);
    end
    if mean(abs(phi)>pi/2)
        phi = mod(phi,2*pi);
        mphi = mod(mphi,2*pi);
    end
        
    angleMargin = pi/16;
    meshCond = mth>=(min(th)-angleMargin) & mth<=(max(th)+angleMargin) & mphi>=(min(phi)-angleMargin) & mphi<=(max(phi)+angleMargin);
    mth = mth(meshCond);
    mphi = mphi(meshCond);
    mr = mr(meshCond);
    
    FM = TriScatteredInterp([mth,mphi],mr);
    
    Ngrid = 128;
    [TH PHI] = meshgrid(linspace(min(th),max(th),Ngrid(1)),linspace(min(phi),max(phi),Ngrid(end)));
    trim = 4;
    TH = TH(trim+1:end-trim,trim+1:end-trim);
    PHI = PHI(trim+1:end-trim,trim+1:end-trim);
    R = FM(TH,PHI);
        
    for depthIdx = 1:length(Depths)
    [X Y Z] = sph2cart(TH,PHI,R+Depths(depthIdx));
    TriMeshHandle(depthIdx) = surf(X+ApexX,Y+ApexY,Z+ApexZ,mediannan(F(X+ApexX,Y+ApexY,Z+ApexZ),smoothingKernel));
    set(TriMeshHandle(depthIdx),'EdgeColor','none');
    if length(Depths)>1
        hold on
    end
    end