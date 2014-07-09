function vData = interpMeshSurf(MeshObject,imData,imageApexZ,Depths,InterpMode,Range)
if strcmpi(InterpMode,'TriScatteredInterp')
[XS YS ZS CS] = extractMeshSurfaceIntersection(MeshObject,imData,imageApexZ,Depths);    
else
[XS YS ZS] = extractMeshSurfaceIntersection(MeshObject,imData,imageApexZ,Depths);
frameIndices = 1:size(imData.XducerToWorldMatrix,3);
[Z X I] = ndgrid(imData.axial,imData.lat,frameIndices);
I(:) = 1:numel(I);
for frameIdx = frameIndices;
    [Xt(:,:,frameIdx) Yt(:,:,frameIdx) Zt(:,:,frameIdx)] = applyTransformation(X(:,:,frameIdx),Z(:,:,frameIdx),0*X(:,:,frameIdx),imData.XducerToWorldMatrix(:,:,frameIdx));
end
Mask = ~isnan(imData.cData) & (imData.alphadata>0);
x = single(Xt(Mask));
y = single(Yt(Mask));
z = single(Zt(Mask));
c = single(imData.cData(Mask));
a = single(imData.alphadata(Mask));
CS = nan(size(XS));
switch lower(InterpMode)
    case 'mean'
        parfor i = 1:numel(CS)
            xs = XS(i);
            ys = YS(i);
            zs = ZS(i);
            d2 = (x-xs).^2+(y-ys).^2+(z-zs).^2;
            msk = d2<=Range^2;
            ai = a(msk)
            ci = c(msk);
            CS(i) = sum(ai.*ci)./sum(ai);
        end
    case 'linear'
        parfor i = 1:numel(CS)
            xs = XS(i);
            ys = YS(i);
            zs = ZS(i);
            d = sqrt((x-xs).^2+(y-ys).^2+(z-zs).^2);
            msk = d<=Range;
            ai = a(msk)
            ci = c(msk);
            di = d(msk);
            wi = 1-di./Range
            CS(i) = sum(wi.*ai.*ci)./sum(ai.*wi);
        end
    case 'gaussian'
        if length(Range) == 1;
            Range = [1 3]*Range;
        end
        parfor i = 1:numel(CS)
            xs = XS(i);
            ys = YS(i);
            zs = ZS(i);
            d = sqrt((x-xs).^2+(y-ys).^2+(z-zs).^2);
            msk = d<=Range(2);
            ai = a(msk)
            ci = c(msk);
            di = d(msk);
            wi = normpdf(di,0,Range(1));
            CS(i) = sum(wi.*ai.*ci)./sum(ai.*wi);
        end
end
end
vData = struct('xData',XS,'yData',YS,'zData',ZS,'cData',CS,'units',imData.units,'name',imData.name);
