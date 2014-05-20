function newstruct = getAttributes(xmlstruct)
    if length(xmlstruct) == 0
        newstruct = struct;
    else
    fields = {xmlstruct.Attributes(:).Name};
    for j = 1:length(fields);
    tempstr = (xmlstruct.Attributes(strcmpi({xmlstruct.Attributes(:).Name},fields(j))).Value);
    if isempty(str2num(tempstr))
        newstruct.(fields{j}) = tempstr;
    else
        newstruct.(fields{j}) = str2num(tempstr);
    end
    end
    end