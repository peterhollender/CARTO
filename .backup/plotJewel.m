function h = plotJewel(x,y,z,CSpec,Scale,N);
if ~exist('N','var')
    N = 10;
end
[xx yy zz] = sphere(N);
xx = xx*Scale;
yy = yy*Scale;
zz = zz*Scale;
for i = 1:length(x);
h(i) = surf(xx+x(i),yy+y(i),zz+z(i));
end
set(h,'EdgeColor','None','FaceLighting','gouraud','FaceColor',CSpec);