k1 = get(sp1(1),'Children');
k2 = get(sp1(2),'Children');
c1c = [get(k1,'Color')];
c2c = [get(k2,'Color')];
c1 = reshape([c1c{:}]',3,[])';
c2 = reshape([c2c{:}]',3,[])';
Pigs = {'G426','G430','G432','G433'};
Colors = {'011','100','010','110'};
CSpec = {'c','r','g','y'};
clear arfi sws
dummy = struct('t',[],'sys',[],'dias',[]);
for i = 1:4
    arfi.(Pigs{i}) = dummy;
    sws.(Pigs{i}) = dummy;
end
for i = 1:length(c1);
    cstr = sprintf('%g',c1(i,:));
    Pig = Pigs{strcmpi(cstr,Colors)};
    t = get(k1(i),'XData');
    arfi.(Pig).t(end+1) = t(1);
    arfi.(Pig).sys(end+1) = min(get(k1(i),'Ydata'));
    arfi.(Pig).dias(end+1) = max(get(k1(i),'Ydata'));
     t = get(k2(i),'XData');
    sws.(Pig).t(end+1) = t(1);
    sws.(Pig).sys(end+1) = max(get(k2(i),'Ydata'));
    sws.(Pig).dias(end+1) = min(get(k2(i),'Ydata'));
end
figure(11);clf
subplot(211)
hold on
subplot(212)
hold on
for i =1:length(Pigs)
    [tsort idx] = sort(arfi.(Pigs{i}).t);
    subplot(211)
    plot(tsort-tsort(1),arfi.(Pigs{i}).dias(idx)./arfi.(Pigs{i}).sys(idx),CSpec{i},'Marker','.','LineStyle','none');
    [tsort idx] = sort(sws.(Pigs{i}).t);
    subplot(212)
    plot(tsort-tsort(1),sws.(Pigs{i}).sys(idx)./sws.(Pigs{i}).dias(idx),CSpec{i},'Marker','.','LineStyle','none');
end