function [Mesh] = loadMesh(MeshFile)
fid = fopen(MeshFile,'r');
s = fgetl(fid);
while isempty(strfind(s,'NumVertex'))
    s = fgetl(fid);
end
NumVertex = str2num(s(strfind(s,'=')+1:end));
while isempty(strfind(s,'NumTriangle'))
    s = fgetl(fid);
end
NumTriangle = str2num(s(strfind(s,'=')+1:end));

while isempty(strfind(s,'[VerticesSection]'));
    s = fgetl(fid);
end
Names = textscan(fid,'%s%s%s%s%s%s%s%s',1,'Delimiter','= ','MultipleDelimsAsOne',1);
C = textscan(fid,'%d%f%f%f%f%f%f%d',NumVertex,'Delimiter','= ','MultipleDelimsAsOne',1);
clear Vertices
for i = 1:length(C);
fieldName = Names{i}{1};
if strcmpi(fieldName,';');
    fieldName = 'index';
end
Vertices.(fieldName) = C{i};
end
while isempty(strfind(s,'[TrianglesSection]'));
    s = fgetl(fid);
end
Names = textscan(fid,'%s%s%s%s%s%s%s%s',1,'Delimiter','= ','MultipleDelimsAsOne',1);
C = textscan(fid,'%d%d%d%d%f%f%f%d',NumTriangle,'Delimiter','= ','MultipleDelimsAsOne',1);
clear Triangles
for i = 1:length(C);
fieldName = Names{i}{1};
if strcmpi(fieldName,';');
    fieldName = 'index';
end
Triangles.(fieldName) = C{i};
end
while isempty(strfind(s,'[VerticesColorsSection]'));
    s = fgetl(fid);
end
s = fgetl(fid);
Names = textscan(fid,'%s%s%s%s%s%s%s%s%s%s%s%s%s',1,'Delimiter','= ','MultipleDelimsAsOne',1);
C =     textscan(fid,'%d%f%f%f%f%f%f%f%f%f%f%f%f',NumVertex,'Delimiter','= ','MultipleDelimsAsOne',1);
clear VerticesColors
for i = 1:length(C);
fieldName = Names{i}{1};
if strcmpi(fieldName,';');
    fieldName = 'index';
end
if ~isempty(fieldName)
VerticesColors.(strrep(fieldName,'-','minus')) = C{i};
end
end

while isempty(strfind(s,'[VerticesAttributesSection]'));
    s = fgetl(fid);
end
for i = 1:4
    fgetl(fid);
end
fieldNames = {'Index','Scar','EML'};
C =     textscan(fid,'%d%d%d',NumVertex,'Delimiter','= ','MultipleDelimsAsOne',1);
clear VerticesAttributes
for i = 1:length(C);
VerticesAttributes.((fieldNames{i})) = C{i};
end


fclose(fid);
Mesh.Vertices = Vertices;
Mesh.Triangles = Triangles;
Mesh.VerticesColors = VerticesColors;
Mesh.VerticesAttributes = VerticesAttributes;