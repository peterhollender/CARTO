function [Value D Xt Yt Zt]= interpMeshValue(X,Y,Z,Mesh,Param);
        [Value D Xt Yt Zt] = deal(nan(size(X)));
        parfor PointIdx = 1:length(X(:))
        d = sqrt((Mesh.Vertices.X - X(PointIdx)).^2+(Mesh.Vertices.Y - Y(PointIdx)).^2+(Mesh.Vertices.Z - Z(PointIdx)).^2);
        [D(PointIdx) idx] = min(d);
        Value(PointIdx) = Mesh.VerticesColors.(Param)(idx);
        Xt(PointIdx) = Mesh.Vertices.X(idx);
        Yt(PointIdx) = Mesh.Vertices.Y(idx);
        Zt(PointIdx) = Mesh.Vertices.Z(idx);
        end