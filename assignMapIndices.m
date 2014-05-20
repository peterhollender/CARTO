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
    else
        fprintf('%s found in Maps [%s\b]\n',parameter,sprintf('%g,',nonzero));
        newIdx = input(sprintf('For %s, use Map: ',parameter));
        if isempty(newIdx)
            newIdx = 0;
        end
        if iscell(newIdx)
            newIdx = [newIdx{:}];
        end
        UserMapIndex.(parameter) = newIdx;
        if newIdx == 0;
        fprintf('%s set to be unnassigned (Map 0)\n',parameter);
        UserMapIndex.([parameter 'Index']){1} = [];  
        else
        fprintf('%s set to be read from Map %s\b (%s\b).\n',parameter,sprintf('%g,',newIdx),sprintf('%s,',Data.MapName{newIdx}))
        switch lower(parameter)
            case {'cartopoints','contours','frames'}
                for ii = 1:length(newIdx)
                    numpar = Data.(parameter)(UserMapIndex.(parameter)(ii));
                    if numpar>0
                      defaultstr = sprintf('[1:%g]',numpar); 
                      parIdxstr = input(sprintf('Use which %s from %s? (#) [%s]:',parameter,Data.MapName{UserMapIndex.(parameter)(ii)},defaultstr),'s');
                      if isempty(parIdxstr)
                      parIdxstr = defaultstr;
                      end
                      eval(sprintf('UserMapIndex.%sIndex{ii} = %s;',parameter,parIdxstr))
                    else
                      UserMapIndex.([parameter 'Index']){ii} = [];  
                    end
                end
            otherwise
        end
        end
    end
    end
    
   fprintf('______________________________\n')
   
   for ii = 1:length(UserMapIndex.Frames)
   [filenames pathname] = uigetfile('*.mat',sprintf('Select res-files associated with %s',Data.MapName{UserMapIndex.Frames(ii)}),'MultiSelect','on');
   if pathname
   UserMapIndex.resFilePaths{ii} = pathname;
   UserMapIndex.resFileNames{ii} = filenames;
   else
   UserMapIndex.resFilePaths{ii} = '';
   UserMapIndex.resFileNames{ii} = {[]};
   end
   end
       