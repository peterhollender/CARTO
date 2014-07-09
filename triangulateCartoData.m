function NewMesh = triangulateCartoData(ARFIHandle,Mesh)
x = [];
y = [];
z = [];
c = [];
a = [];
for imageIdx = 1:length(ARFIHandle)
    xdata = get(ARFIHandle(imageIdx),'xdata');
    ydata = get(ARFIHandle(imageIdx),'ydata');
    zdata = get(ARFIHandle(imageIdx),'zdata');
    cdata = get(ARFIHandle(imageIdx),'cdata');
    adata = padarray(get(ARFIHandle(imageIdx),'alphadata'),[1 1],'post');
    if size(xdata,2)<size(cdata,2);
        for i = 1:size(xdata,1)
            xdata1(i,:) = linspace(xdata(i,1),xdata(i,end),size(cdata,2));
            ydata1(i,:) = linspace(ydata(i,1),ydata(i,end),size(cdata,2));
            zdata1(i,:) = linspace(zdata(i,1),zdata(i,end),size(cdata,2));
        end
        for i = 1:size(xdata1,2)
            xdata2(:,i) = linspace(xdata1(1,i),xdata(1,end),size(cdata,1));
            ydata2(:,i) = linspace(xdata1(1,i),ydata(1,end),size(cdata,1));
            zdata2(:,i) = linspace(xdata1(1,i),zdata(1,end),size(cdata,1));
        end
        xdata = xdata2;
        ydata = ydata2;
        zdata = zdata2;
        clear xdata1 ydata1 zdata1 xdata2 ydata2 zdata2
            
    end
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
    
    VertexIndices = Mesh.Vertices.X>min(x) & ...
                    Mesh.Vertices.X<max(x) & ...
                    Mesh.Vertices.Y>min(y) & ...
                    Mesh.Vertices.Y<max(y) & ...
                    Mesh.Vertices.Z>min(z) & ...
                    Mesh.Vertices.Z<max(z);
    NewMesh = Mesh;
    fields = fieldnames(NewMesh.Vertices);
    for i = 1:length(fields)
    NewMesh.Vertices.(fields{i}) = NewMesh.Vertices.(fields{i})(VertexIndices);
    end
    fields = fieldnames(NewMesh.VerticesColors);
    for i = 1:length(fields)
    NewMesh.VerticesColors.(fields{i}) = NewMesh.VerticesColors.(fields{i})(VertexIndices);
    end
    for i = 1:length(NewMesh.Vertices.index);
        good0(:,i) = NewMesh.Triangles.Vertex0 == NewMesh.Vertices.index(i);
        good1(:,i) = NewMesh.Triangles.Vertex1 == NewMesh.Vertices.index(i);
        good2(:,i) = NewMesh.Triangles.Vertex2 == NewMesh.Vertices.index(i);
    end
    TriIndices = any([any(good0,2) any(good1,2) any(good2,2)],2);
    fields = fieldnames(NewMesh.Triangles);
    for i = 1:length(fields)
    NewMesh.Triangles.(fields{i}) = NewMesh.Triangles.(fields{i})(TriIndices);
    end
    F = TriScatteredInterp([x y z],c);
    NewMesh.Vertices = Mesh.Vertices;
    NewMesh.VerticesColors.ARFI = F(NewMesh.Vertices.X,NewMesh.Vertices.Y,NewMesh.Vertices.Z);