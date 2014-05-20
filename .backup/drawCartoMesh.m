%drawCartoMesh - Draws Carto Mesh as 3D Patch Surface
%H = drawCartoMesh(Mesh,ColorSource,'parametername','parametervalue'...)
%H = drawCartoMesh(Mesh,ColorSource,ColorAxisLimits,'parametername','parametervalue'...)
%H = drawCartoMesh(Mesh,ColorSource,ColorAxisLimits,ColorMap,'parametername','parametervalue'...)

function H = drawCartoMesh(Mesh,ColorSource,varargin)
H = patch;
set(H,...
        'Faces',[ ...
        Mesh.Triangles.Vertex0+1 ... 
        Mesh.Triangles.Vertex1+1 ...
        Mesh.Triangles.Vertex2+1],...
        'Vertices',...
        [Mesh.Vertices.X ...
        Mesh.Vertices.Y ...
        Mesh.Vertices.Z]);
    
ch = zeros(1,length(varargin));
for i = 1:length(varargin);
    ch(i) = ischar(varargin{i});
end
    
    varargs = varargin(find(ch,1,'first'):end);
    if any(ch)
    colorargs = varargin(1:find(ch,1,'first')-1);
    else
    colorargs = varargin;
    end
    

    ColorFields = fieldnames(Mesh.VerticesColors);
    if any(strcmpi(ColorSource,ColorFields))
    VertexColors = Mesh.VerticesColors.(ColorFields{strcmpi(ColorSource,ColorFields)});
    if length(colorargs) > 0 
        CLim = colorargs{1};
    else
        CLim = [min(VertexColors(:)) max(VertexColors(:))];
    end
    if length(colorargs)>1
        CMap = colorargs{2};
        VertexColors = scaled2truecolor(VertexColors,CLim,CMap);
    else
        caxis(CLim);
    end
    set(H,'FaceVertexCData',squeeze(VertexColors),'FaceColor','interp','CDataMapping','scaled')
    end

if ~isempty(varargs)
        for j = 1:2:length(varargs)
            set(H,varargs{j},varargs{j+1});
        end
end
