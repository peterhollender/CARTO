% Super hacky tool for detecting lost frames when you have a bunch of res
% files and a bunch of saved CARTO frames. Searches through each saved
% bitmap in the CARTO export for the point where the command window has
% printed the timestamp (literally 2-D cross correlating for "2014") and
% shows the cropped part of the command window for each frame, titled with
% the corresponding res file index and timestamp. You'll probably be
% missing a few timestamps in the bitmaps, but this gives you a decent
% sense of the alignment if you have enough frames that show the timestamp.
% If you still have ambiguity, start comparing the
% CARTO.Frames{i}(j).Attributes.Timestamp values against the res file
% timestamps.

% Peter Hollender

FramesetIdx = 1; % Which set of Frames/ResFiles you want to align (set to 1 if you only have one pair)

numCartoFrames = length(CARTO.Frames{FramesetIdx});
resIndices = 1:numCartoFrames; %Default 1:1 matching
%resIndices = [1:15 17:33]

%resIndices = [5:14 16:37 40:43]; % Your guess for which res file indices will align with the CARTO Frames
%% Load "2014" template to search the saved CARTO BMP for the command window and the location of the timestamp
%You'll need a new one in 2015, and imaging at 8:14 pm or 20 minutes and 14
%seconds passed the hour might get a bit screwed up. In future iterations,
%I'd recommend writing something unique to the command window right after
%the timestamp... say a blue devil?


 %     |_|   ,
 %    ('.') ///
 %    <(_)`-/'
 %<-._/J L /  -bf-

% Anyway, this is what we have.
% tmp was originally a .png file cut from one of the bitmaps, but for portability, I've just manually
% stuck in the values from that file, since it was only 16x31.
tmp = uint8([...
 239  230  234  236  236  238  239  240  240  241  241  241  243  243  243  243  243  244  244  244  244  244  244  244  244  244  244  245  244  245  245;...
  129   12   14   10  151  238  227  229  125   17   17   11    9  151  238  227  230  232  127  159  249  235  237  238  238  240  240  132   24  165  250;...
   14  150  239  121   12  154  241  124   16  154  243  232  127   17  157  247  232  127   18  159  247  233  235  236  237  239  133   23   22  158  246;...
   14  149  239  123   12  152  241  125   15  152  243  127   16   14  150  135    9    9    7  147  238  226  229  232  234  131   21   19   14  152  241;...
  240  231  234  128   19  160  246  125   18  157  133   14   14    8  151  240  226  122   16  158  244  232  234  234  128   22  162  133   16  160  243;...
  240  230  130   19  153  246  232  131   18  154  142  148  141   12  152  245  230  131   18  153  247  233  234  132   21  158  248  130   19  155  246;...
  240  130   17  148  245  231  234  135   19   19   14  143  141    9  143  241  229  134   17  147  247  233  234  135   20   19   14   10    8    6  138;...
  141   12  146  244  230  233  233  136   21   20  146  245  132   16  147  245  232  134   18  150  248  233  234  235  238  239  239  139   25  156  250;...
   14  150  239  121   14  154  241  124   16  154  243  232  127   16  157  246  232  127   18  158  246  233  234  235  238  239  239  133   24  163  249;...
   12    8    6    5    4  148  235  224  119   12   14    9    8  151  236  116   11   11    8    7    6  149  235  226  229  230  123   19   18   12  157;...
  239  231  233  236  237  238  239  240  240  241  243  241  243  243  244  243  244  244  244  244  244  244  245  245  245  245  245  245  245  245  245]);
tmp = double(tmp)/255;
tmp = tmp-mean(tmp(:));
%%
sp = subplots(ceil(numCartoFrames/floor(sqrt(numCartoFrames))),floor(sqrt(numCartoFrames)),[0.03 0.05],[0.1 0.1 0.1 0.1]);
for frameIdx = 1:min(numCartoFrames,length(resIndices));
    bmpFile = fullfile(CARTO.CartoDataPath,CARTO.Frames{FramesetIdx}(frameIdx).Attributes.FileName);
    resFile = CARTO.UserMapIndex.resFileNames{FramesetIdx}{resIndices(frameIdx)};
    im = cartoBMPread(bmpFile);
    im = im(:,:,[2 1 3]);
    srch = filter2(tmp,double(im(:,:,2)),'same');
    if max(abs(srch(:)))>30;
        [i j] = find(abs(srch) == max(abs(srch(:))));
        axLim = [j+[-19 101] i+[-7 6]];
    else
        axLim = ([70 190 532 545]); 
    end    
    subplot(sp(frameIdx));
    image(im);
    axis image
    pause(0.1);
    axis(axLim);
    title(sprintf('(%g) %s',resIndices(frameIdx),strrep(resFile(end-17:end-4),'_','\_')),'fontsize',16)
    ylabel(frameIdx)
end
set(sp,'XTick',[],'YTick',[])
    

fprintf('\nUserMapIndex.resFileNames{FramesetIdx} = UserMapIndex.resFileNames{FramesetIdx}(resIndices);\n')

