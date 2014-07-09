function interpFunction = build3DIndexMapCarto(imDataSC,field);
if ~exist('field','var') || ~isfield(imDataSC,field);
    fields = fieldnames(imDataSC);
    field = fields{1};
end
im = imDataSC.(field);
frameIndices = 1:size(im.XducerToWorldMatrix,3);
[Z X I] = ndgrid(im.axial,im.lat,frameIndices); 
I(:) = 1:numel(I);
for frameIdx = frameIndices;
[Xt(:,:,frameIdx) Yt(:,:,frameIdx) Zt(:,:,frameIdx)] = applyTransformation(X(:,:,frameIdx),0*X(:,:,frameIdx),Z(:,:,frameIdx),im.XducerToWorldMatrix(:,:,frameIdx));
end
Mask = ~isnan(im.cData) & (im.alphadata>0);
interpFunction = TriScatteredInterp([Xt(Mask) Yt(Mask) Zt(Mask)],I(Mask),'nearest');