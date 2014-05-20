function im = cartoBMPread(fileName);
fid = fopen(fileName,'r');
s = fread(fid);
fclose(fid);
im = (reshape(s(54+[1:795*579*3]),3,795,[]));
im = permute(im./max(im(:)),[3 2 1]);
im = im(:,:,[2 3 1]);

