function TagsTable = getCartoTags(xmlData)
Maps = xmlData.Children(strcmpi({xmlData.Children(:).Name},'Maps'));
TagsTableData = Maps.Children(strcmpi({Maps.Children(:).Name},'TagsTable'));
TagIndices = find(strcmpi({TagsTableData.Children(:).Name},'Tag'));
for i = 1:length(TagIndices)
    TagsTable(i) = getAttributes(TagsTableData.Children(TagIndices(i)));
end