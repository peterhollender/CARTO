function makeManySliceFig(datapath);
imDataSC = load(fullfile(datapath,'res','scanconvertedImData'));
load(fullfile(datapath,'FrameIndices'));
imDataSC.ARFI.clim = [0 10];
figure(1);clf
colordef(1,'white')
set(1,'color','w')
set(1,'position',[2481 49 1352 2027]);
set(1,'invertHardcopy','off','paperpositionMode','auto');
set(1,'defaultaxesfontsize',14,'defaultaxesfontweight','bold')
imDataSC.MASK = load(fullfile(datapath,'res','MASK'));
imDataSC = assignMASKtoAlpha(imDataSC);
XducerToWorldMatrix = imDataSC.BMODE.XducerToWorldMatrix(:,:,FrameIndices);
[GlobalApex GlobalNormal GlobalVector FrameApex FrameNormals FrameVectors] = getCommonApex(XducerToWorldMatrix,-8.54);
CenterVec = getImageCentroid(imDataSC.BMODE);
CenterVec = CenterVec(FrameIndices,:);
%CenterVec = 30*FrameVectors + repmat(GlobalApex,[size(FrameVectors,1),1]);
 for frameIndex = 1:size(XducerToWorldMatrix,3)
                ProjVec(frameIndex,:) = dot(GlobalNormal,CenterVec(frameIndex,:)-GlobalApex)*GlobalNormal+dot(GlobalVector,CenterVec(frameIndex,:)-GlobalApex)*GlobalVector;
                ProjVec(frameIndex,:) = ProjVec(frameIndex,:)/norm(ProjVec(frameIndex,:));
                Phi0(frameIndex) = acosd(dot(ProjVec(frameIndex,:),GlobalNormal));
            end
[Phi sortOrder] = sort(Phi0);
[imHandle, sp] = draw_moreimData(imDataSC,FrameIndices(sortOrder),'bmode',[3 3]);
set(sp,'ylim',[11 23])
set(sp,'YTick',[12 21]);
for i = 1:size(sp,1)
    subplot(sp(i,1));
    hold on
    h(i) = addCornerText(sprintf('\\phi = %0.1f^\\circ',Phi(i)-mean(Phi)),14,'northwest');
    set(h(i),'position',get(h(i),'position').*[1 1 0 0]+[0 0 0.1 0])
end
set(sp,'color','k')
epsDir = fullfile(datapath,'figures','eps');
figName = fullfile(epsDir,'ManySlices');
fprintf('writing %s...',figName);
print('-depsc',figName);
fprintf('done\n');
