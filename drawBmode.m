function BmodeHandle = drawBmode(Frames,imageDataPath)
for ii = 1:length(Frames)
    for FrameIdx = 1:length(Frames{ii})
        Frame = Frames{ii}(FrameIdx);
        if exist('imageDataPath','var')
            fid = fopen(fullfile(imageDataPath,Frame.Attributes.FileName),'r');
        else
            if exist(Frame.Attributes.FileName,'file')
                fid = fopen(Frame.Attributes.FileName,'r');
            else
                error('Could not find image data on the MATLAB path. Please specifiy the data path or add the location to the MATLAB path.')
            end
        end
        s = fread(fid);
        fclose(fid);
        sz = [Frame.Attributes.Height Frame.Attributes.Width];
        im3 = (uint8(permute(reshape(s(length(s)-(sz(1)*sz(2)*3)+1:end),3,sz(2),sz(1)),[3 2 1])));
        im3 = im3(:,:,[3 2 1]);
        ipos = [Frame.Attributes.ULSImageLocationX1 Frame.Attributes.ULSImageLocationX2 Frame.Attributes.ULSImageLocationX3 Frame.Attributes.ULSImageLocationX4];
        jpos = [Frame.Attributes.ULSImageLocationY1 Frame.Attributes.ULSImageLocationY2 Frame.Attributes.ULSImageLocationY3 Frame.Attributes.ULSImageLocationY4];
        iref = Frame.Attributes.ULSTransducer2D_x;
        jref = Frame.Attributes.ULSTransducer2D_y;
        zim = ((0:sz(2)-1)-iref)*Frame.Attributes.MmPerPixelX;
        yim = ((0:sz(1)-1)-jref)*Frame.Attributes.MmPerPixelY;
        [Zim Yim] = meshgrid(zim,yim);
        bw = roipoly(zim,yim,im3,Frame.Z,Frame.Y);
        [Ximt Yimt Zimt] = applyTransformation(0*Zim,Yim,Zim,Frame.XducerToWorldMatrix);
        im4 = double(im3)/255;
        im4(~bw(:,:,[1 1 1])) = nan;
        BmodeHandle{ii}(FrameIdx) = surf(Ximt,Yimt,Zimt,im4,'edgecolor','none');
    end
end