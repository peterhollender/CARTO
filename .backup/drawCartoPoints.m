function h = drawCartoPoints(CartoPoints,Tags);
IDs = [Tags.ID];
for i = 1:length(CartoPoints)
    CartoPoint = CartoPoints(i);
    if ~isempty(CartoPoint.Tags)
    Tag = Tags(IDs==CartoPoint.Tags);
    else
    Tag = struct('Color',[0.5 0.5 0.5 1],'Full_Name','Undefined','ID',[],'Radius',2,'Short_Name','NA');
    end
    x = CartoPoint.Position3D(1);
    y = CartoPoint.Position3D(2);
    z = CartoPoint.Position3D(3);
    [xx yy zz] = sphere(20);
    xx = xx*Tag.Radius;
    yy = yy*Tag.Radius;
    zz = zz*Tag.Radius;
    h(i) = surf(xx+x,yy+y,zz+z);
    set(h(i),'FaceColor',Tag.Color(1:3),'EdgeColor','none','FaceAlpha',Tag.Color(4),'FaceLighting','gouraud');
    set(h(i),'DisplayName',sprintf('#%g (%s)',CartoPoint.Id,Tag.Full_Name));
    hold on
end
