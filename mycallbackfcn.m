function mycallbackfcn(hObject,eventdata)
T = readtable('9-17-16 firing.csv');
BurnTextIdx = find(~cellfun('isempty', strfind(T.(2),'Burn')));
BurnTime = str2double(T.(1)(BurnTextIdx(1)))/1000; %seconds
StopTextIdx = find(~cellfun('isempty', strfind(T.(2),'Stop')));
StopTime = str2double(T.(1)(StopTextIdx(1)))/1000; %seconds
Tdata = T;
if isnumeric(T.Time_ms_)==0
Tdata.(1) = str2double(T.(1))/1000; %seconds
Tdata.(2) = str2double(T.(2));
else
    Tdata.(1) = T.(1)/1000; 
    Tdata.(2) = T.(2);
end
Tdata.(9) = T.(9)*4.44822; % Newtons
T.Properties.VariableNames(9) = {'Force'};
BurnTimeIdx = find(Tdata.(1)>BurnTime,1,'first');
StopTimeIdx = find(Tdata.(1)>StopTime,1,'first');
Tburn = Tdata(BurnTimeIdx:StopTimeIdx,:);
time = Tdata.(1);
timeBurn = Tburn.(1);
DataEndIdx = find(isnan(time));
MaxValIdx = zeros(width(Tdata),1);
MaxValTime = zeros(width(Tdata),1);
MaxVal = zeros(width(Tdata),1);
MaxBurnValIdx = zeros(width(Tdata),1);
MaxBurnValTime = zeros(width(Tdata),1);
MaxBurnVal = zeros(width(Tdata),1);
AvgVal = zeros(width(Tdata),1);
AvgBurnVal = zeros(width(Tdata),1);
AvgTest = zeros(width(Tdata),1);
% Find Max & Avg Values foreach column of data, write to arrays
jCol=2;
for jCol=2:1:width(Tdata)
   MaxValIdx(jCol) = find(Tdata.(jCol) == max(Tdata.(jCol)), 1, 'first');
   MaxValTime(jCol) = time(MaxValIdx(jCol));
   MaxVal(jCol) = Tdata.(jCol)(MaxValIdx(jCol));
   AvgVal(jCol) = mean(Tdata.(jCol),'omitnan');
   MaxBurnValIdx(jCol) = find(Tburn.(jCol) == max(Tburn.(jCol)), 1, 'first');
   MaxBurnValTime(jCol) = Tburn.(1)(MaxBurnValIdx(jCol));
   MaxBurnVal(jCol) = Tburn.(jCol)(MaxBurnValIdx(jCol));
   AvgBurnVal(jCol) = mean(Tburn.(jCol),'omitnan');
end
x=[0,BurnTime,BurnTime,StopTime,StopTime,time(DataEndIdx(1)-1)]
y=[0,0,200,200,0,0]
hFig = get(hObject, 'parent');
if strcmp(get(hFig,'SelectionType'),'open')
figure
plot(time,Tdata.(2),x,y,'-.k', MaxValTime(2),MaxVal(2),'dr','linewidth',0.75)
legend(char(T.Properties.VariableNames(2)),...
    ['Nominal: 200 psi'],['P1 max: ' num2str(MaxVal(2)) ' psi'])
xlim([time(1) time(DataEndIdx(1)-1)])
xlabel('Time [s]')
axPos = get(gca,'Position');
ylabel('Pressure [psi]')
title('Pressure Transducer 1')

%Create counter for looping through event information
i = DataEndIdx+2;
%Plot events on graph
% Vertical line
for i = i:1:length(time)
line(time(i)*[1 1], get(gca,'YLim'),'Color','r','LineStyle',':')
end
end 

