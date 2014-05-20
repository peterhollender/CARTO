function F = panCameraTo(CameraPosition,CameraTarget,CameraUpVector,N,PauseTime)
CameraPosition0 = get(gca,'CameraPosition');
CameraTarget0 = get(gca,'CameraTarget');
CameraUpVector0 = get(gca,'CameraUpVector');
if ~exist('PauseTime','var')
    PauseTime = 0.1;
end
if ~exist('N','var')
    N = 20;
end
for i = linspace(0,1,N);
    tic
set(gca,...
    'CameraPosition',CameraPosition0*(1-i)+CameraPosition*(i),...
    'CameraTarget',CameraTarget0*(1-i)+CameraTarget*(i),...
    'CameraUpvector',CameraUpVector0*(1-i)+CameraUpVector*(i));
drawnow;
if nargout>0
    if i == 0
        F = getframe(gcf);
    else
        F(end+1) = getframe(gcf);
    end
end
while(toc<(PauseTime));end
end
