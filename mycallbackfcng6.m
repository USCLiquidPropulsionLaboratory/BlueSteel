function mycallbackfcng6(hObject,eventdata)
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


%Create index to find where data is NaN
%{use isnan function instead of ismissing for 2016a compatibility}

%Create array to hold nominal values, assign them
Nominal = zeros(width(Tdata),1);
Nominal(2) = 200; %Value for PT1 (psi)
Nominal(3) = 400; %Value for PT2 (psi)
Nominal(4) = 400; %Value for PT3 (psi)
Nominal(5) = 400; %Value for PT4 (psi)
Nominal(6) = 400; %Value for PT5 (psi)
Nominal(7) = 400; %Value for PT6 (psi)
Nominal(8) = 400; %Value for PT7 (psi)
Nominal(9) = 400; %Value for FT (N)
%Create time reference to plot nominal values
%Create array with nominal values for plotting, assign correspondingly
NomTime = [0,BurnTime,BurnTime,StopTime,StopTime,time(DataEndIdx(1)-1)];
NomGraph = zeros(width(Tdata),6);
for jCol=2:1:width(Tdata)
NomGraph(jCol,:) = [0,0,Nominal(jCol),Nominal(jCol),0,0];
end
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
hFig = get(hObject, 'parent');
if strcmp(get(hFig,'SelectionType'),'open')
figure
plot(timeBurn,Tburn.(7), NomTime,NomGraph(7,:),'-.k',MaxBurnValTime(7),MaxBurnVal(7),'dr','linewidth',0.75)
legend(char(T.Properties.VariableNames(7)),...
    ['Nominal: ' num2str(Nominal(7)) ' psi'],['P6 max: ' num2str(MaxBurnVal(7)) ' psi'])
xlim([timeBurn(1) time(end)])
xlabel('Time [s]')
ylabel('Pressure [psi]')
title('Pressure Transducer 6  during Burn Time')
end