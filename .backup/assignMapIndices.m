function UserMapIndex = assignMapIndices(xmlData)
    Data = getCartoMapInfo(xmlData);
   
    fields = fieldnames(Data);
    fields = fields(~strcmpi(fields,'MapName'));
    
    for fieldIdx = 1:length(fields);
    parameter = fields{fieldIdx};
    counts = Data.(parameter);
    nonzero = find(counts>0);
    fprintf('______________________________\n')
    if isempty(nonzero) ;
        fprintf('No %s found. Index set to 0.\n',parameter)
        UserMapIndex.(parameter) = 0;
%     elseif length(nonzero) == 1;
%         UserMapIndex.(parameter) = nonzero;
%         fprintf('%s found in Maps [%s\b]\n',parameter,sprintf('%g,',nonzero));
%         fprintf('Auto-Assigning %s to be read from Map %g (%s)\n',parameter,nonzero,Data.MapName{nonzero});
    else
        fprintf('%s found in Maps [%s\b]\n',parameter,sprintf('%g,',nonzero));
        %newIdx = -inf;
        %while ~(any(newIdx == nonzero) || newIdx==0)
        newIdx = input(sprintf('For %s, use Map: ',parameter));    
        %end
        UserMapIndex.(parameter) = newIdx;
        if newIdx == 0;
        fprintf('%s set to be unnassigned (Map 0)\n',parameter);
        else
        fprintf('%s set to be read from Map %s\b (%s\b).\n',parameter,sprintf('%g,',newIdx),sprintf('%s,',Data.MapName{newIdx}))
        end
    end
    end
    
   fprintf('______________________________\n')
    if length(UserMapIndex.Frames) > 1
    defaultstr = sprintf('{%s\b}',sprintf('[1:%g],',Data.Frames(UserMapIndex.Frames)));
    else
    defaultstr = sprintf('[1:%g]',Data.Frames(UserMapIndex.Frames));   
    end
    resIndexStr = input(sprintf('Use Which Res-File Indices? (#) [%s]:',defaultstr),'s');
    if isempty(resIndexStr)
        if length(UserMapIndex.Frames)>1
        for i = 1:length(UserMapIndex.Frames)
        UserMapIndex.ResIndices{i} = 1:Data.Frames(UserMapIndex.Frames(i));
        end
        else
        UserMapIndex.ResIndices = 1:Data.Frames(UserMapIndex.Frames);   
        end
    else
        eval(sprintf('UserMapIndex.ResIndices = %s;',resIndexStr));
    end
    
    
    
        
%UserMapIndex
%save(matFileName,'-append','UserMapIndex');

    