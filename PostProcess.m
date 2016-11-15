%%Post-Processing of Pressure Transducer Measurements
% This tool processes data from a specified file in a csv format and provides:
%  Pressure vs time profiles
%  Thrust vs time profile
%       with max values and notable events
%  Table with max and average values
%
% To be implemented:
%   nominal profiles
%   GUI
%   Convert Force thrust from lbs to Newtons
% - Becca Rogers
%  rarogers@usc.edu
% Date Modified: 11/12/2016

%Clear variables used in this script
clear T Tdata Pmax1 Pmax2 Pmax3 Pmax4 Pmax5 Pmax6 Pmax7 Fmax

%Import comma separated value data exactly as is into table variable T
T = readtable('9-17-16 firing.csv');
BurnTextIdx = find(~cellfun('isempty', strfind(T.(2),'Burn')));
BurnTime = str2double(T.(1)(BurnTextIdx(1)))/1000 %seconds

StopTextIdx = find(~cellfun('isempty', strfind(T.(2),'Stop')));
StopTime = str2double(T.(1)(StopTextIdx(1)))/1000 %seconds

Tdata = T;
%Determine if columns hold mixed data types - if yes convert to double data
%type, else leave in double format
%Convert time from milliseconds to seconds
if isnumeric(T.Time_ms_)==0
Tdata.(1) = str2double(T.(1))/1000; %seconds
Tdata.(2) = str2double(T.(2));
else
    Tdata.(1) = T.(1)/1000; 
    Tdata.(2) = T.(2);
end
%Create index for burn and stop events
BurnTimeIdx = find(Tdata.(1)>BurnTime,1,'first')
StopTimeIdx = find(Tdata.(1)>StopTime,1,'first')

time = Tdata.(1);

%Create index to find where data is NaN
%{use isnan function instead of ismissing for 2016a compatibility}
DataEndIdx = find(isnan(time));

%Create zero arrays as place holders for Max Values & Avg Values overall
%and during burn only
MaxValIdx = zeros(width(Tdata),1);
MaxValTime = zeros(width(Tdata),1);
MaxVal = zeros(width(Tdata),1);
MaxBurnValIdx = zeros(width(Tdata),1);
MaxBurnValTime = zeros(width(Tdata),1);
MaxBurnVal = zeros(width(Tdata),1);
AvgValTime = zeros(width(Tdata),1);
AvgBurnTime = zeros(width(Tdata),1);
%Find Max & Avg Values foreach column of data, write to arrays
jCol=2;
for jCol=2:1:width(Tdata)
  DataSum = 0;
  iDataRow=1;
  for iDataRow=1:1:DataEndIdx-1
      DataSum = DataSum + Tdata.(jCol)(iDataRow);
  end
   MaxValIdx(jCol) = find(Tdata.(jCol) == max(Tdata.(jCol)), 1, 'first');
   MaxValTime(jCol) = time(MaxValIdx(jCol));
   MaxVal(jCol) = Tdata.(jCol)(MaxValIdx(jCol));
   AvgVal(jCol) = DataSum/length(Tdata.(jCol));
end
%Create figure with tables of max & avg values
f = figure;   
MaxValTable = uitable(f);
MaxValTable.Data = [MaxValTime(2:end,:),MaxVal(2:end,:)];
MaxValTable.ColumnName = {'Time (s)','Max Value (psi)'};
MaxValTable.RowName = {'PT1','PT2','PT3','PT4','PT5','PT6','PT7','FT'};
MaxValTable.Units = 'Normalized';
MaxValTable.Position = [0 0 .4 1];

AvgValTable = uitable(f);
AvgValTable.Data = [AvgVal(2:end,:)];
AvgValTable.ColumnName = {'Avg Value (psi)'};
AvgValTable.RowName = {'PT1','PT2','PT3','PT4','PT5','PT6','PT7','FT'};
AvgValTable.Units = 'Normalized';
AvgValTable.Position = [0.5 0 .4 1];

%Create new full-window figure
figure('units','normalized','outerposition',[0 0 1 1])
%Clear all annotations
delete(findall(gcf,'Tag','Event 1 Textbox'))
delete(findall(gcf,'Tag','Event 2 Textbox'))
delete(findall(gcf,'Tag','Event 3 Textbox'))

%Manually plot Pressure Transducer 1 data
subplot(4,2,1)
plot(time,Tdata.(2),MaxValTime(2),MaxVal(2),'dr','linewidth',0.75)
legend(char(T.Properties.VariableNames(2)),['P1 max: ' num2str(MaxVal(2)) ' psi'])
xlim([time(1) time(DataEndIdx(1)-1)])
xlabel('Time [s]')
axPos = get(gca,'Position');
ylabel('Pressure [psi]')
title('Pressure Transducer 1')
%Create LHS annotations for Events 1 2 3
annotation('textbox',...
    [(time(DataEndIdx(1)+2)/(time(DataEndIdx(1)-1)))*(axPos(3))+axPos(1), 0.065, 0, 0] ,...
    'string', T.(2)(DataEndIdx(1)+2),...
    'FitBoxToText','on',...
    'HorizontalAlignment','center',...
    'tag', 'Event 1 Textbox')
annotation('textbox',...
    [(time(DataEndIdx(1)+3)/(time(DataEndIdx(1)-1)))*(axPos(3))+axPos(1), 0.065, 0, 0], ...
    'string', T.(2)(DataEndIdx(1)+3),...
    'FitBoxToText','on',...
    'HorizontalAlignment','center',...
    'tag', 'Event 2 Textbox')
annotation('textbox',...
    [(time(DataEndIdx(1)+4)/(time(DataEndIdx(1)-1)))*(axPos(3))+axPos(1), 0.065, 0, 0], ...
    'string', T.(2)(DataEndIdx(1)+4),...
    'FitBoxToText','on',...
    'HorizontalAlignment','center',...
    'tag', 'Event 3 Textbox')

%Create counter for looping through event information
i = DataEndIdx+2;

%Plot events on graph
%% Figure out line function
for i = i:length(time)
line(time(i)*[1 1], get(gca,'YLim'),'Color','r','LineStyle',':')
i+1;
end


%Manually plot Pressure Transducer 2 data
subplot(4,2,3)
plot(time,Tdata.(3),MaxValTime(3),MaxVal(3),'dr','linewidth',0.75)
legend(char(T.Properties.VariableNames(3)),['P2 max: ' num2str(MaxVal(3)) ' psi'])
xlim([time(1) time(DataEndIdx(1)-1)])
xlabel('Time [s]')
ylabel('Pressure [psi]')
title('Pressure Transducer 2')


%Create counter for looping through event information
i = DataEndIdx+2;

%Plot events on graph
% Figure out line function
for i = i:length(time)
line(time(i)*[1 1], get(gca,'YLim'),'Color','r','LineStyle',':')
i+1;
end


%Manually plot Pressure Transducer 3 data
subplot(4,2,5)
plot(time,Tdata.(4),MaxValTime(4),MaxVal(4),'dr','linewidth',0.75)
legend(char(T.Properties.VariableNames(4)),['P3 max: ' num2str(MaxVal(4)) ' psi'])
xlim([time(1) time(DataEndIdx(1)-1)])
xlabel('Time [s]')
ylabel('Pressure [psi]')
title('Pressure Transducer 3')


%Create counter for looping through event information
i = DataEndIdx+2;

%Plot events on graph
% Figure out line function
for i = i:length(time)
line(time(i)*[1 1], get(gca,'YLim'),'Color','r','LineStyle',':')
i+1;
end


%Manually plot Pressure Transducer 4 data
subplot(4,2,7)
plot(time,Tdata.(5),MaxValTime(5),MaxVal(5),'dr','linewidth',0.75)
legend(char(T.Properties.VariableNames(5)),['P4 max: ' num2str(MaxVal(5)) ' psi'])
xlim([time(1) time(DataEndIdx(1)-1)])
xlabel('Time [s]')
ylabel('Pressure [psi]')
title('Pressure Transducer 4')


%Create counter for looping through event information
i = DataEndIdx+2;

%Plot events on graph
% Figure out line function
for i = i:length(time)
line(time(i)*[1 1], get(gca,'YLim'),'Color','r','LineStyle',':')
i+1;
end


%Manually plot Pressure Transducer 5 data
subplot(4,2,2)
plot(time,Tdata.(6),MaxValTime(6),MaxVal(6),'dr','linewidth',0.75)
legend(char(T.Properties.VariableNames(6)),['P5 max: ' num2str(MaxVal(6)) ' psi'])
xlim([time(1) time(DataEndIdx(1)-1)])
xlabel('Time [s]')
ylabel('Pressure [psi]')
title('Pressure Transducer 5')


%Create counter for looping through event information
i = DataEndIdx+2;

%Plot events on graph
% Figure out line function
for i = i:length(time)
line(time(i)*[1 1], get(gca,'YLim'),'Color','r','LineStyle',':')
i+1;
end


%Manually plot Pressure Transducer 6 data
subplot(4,2,4)
plot(time,Tdata.(7),MaxValTime(7),MaxVal(7),'dr','linewidth',0.75)
legend(char(T.Properties.VariableNames(7)),['P6 max: ' num2str(MaxVal(7)) ' psi'])
xlim([time(1) time(DataEndIdx(1)-1)])
xlabel('Time [s]')
ylabel('Pressure [psi]')
title('Pressure Transducer 6')


%Create counter for looping through event information
i = DataEndIdx+2;

%Plot events on graph
% Figure out line function
for i = i:length(time)
line(time(i)*[1 1], get(gca,'YLim'),'Color','r','LineStyle',':')
i+1;
end


%Manually plot Pressure Transducer 7 data
subplot(4,2,6)
plot(time,Tdata.(8),MaxValTime(8),MaxVal(8),'dr','linewidth',0.75)
legend(char(T.Properties.VariableNames(8)),['P7 max: ' num2str(MaxVal(8)) ' psi'])
xlim([time(1) time(DataEndIdx(1)-1)])
xlabel('Time [s]')
axPos = get(gca,'Position');
ylabel('Pressure [psi]')
title('Pressure Transducer 7')

%Create RHS annotations for Events 1 2 3
annotation('textbox',...
    [(time(DataEndIdx(1)+2)/(time(DataEndIdx(1)-1)))*(axPos(3))+axPos(1), 0.065, 0, 0] ,...
    'string', T.(2)(DataEndIdx(1)+2),...
    'FitBoxToText','on',...
    'HorizontalAlignment','center',...
    'tag', 'Event 1 Textbox')
annotation('textbox',...
    [(time(DataEndIdx(1)+3)/(time(DataEndIdx(1)-1)))*(axPos(3))+axPos(1), 0.065, 0, 0], ...
    'string', T.(2)(DataEndIdx(1)+3),...
    'FitBoxToText','on',...
    'HorizontalAlignment','center',...
    'tag', 'Event 2 Textbox')
annotation('textbox',...
    [(time(DataEndIdx(1)+4)/(time(DataEndIdx(1)-1)))*(axPos(3))+axPos(1), 0.065, 0, 0], ...
    'string', T.(2)(DataEndIdx(1)+4),...
    'FitBoxToText','on',...
    'HorizontalAlignment','center',...
    'tag', 'Event 3 Textbox')

%Create counter for looping through event information
i = DataEndIdx+2;

%Plot events on graph
% Figure out line function
for i = i:length(time)
line(time(i)*[1 1], get(gca,'YLim'),'Color','r','LineStyle',':')
i+1;

end


%Manually plot Force data
subplot(4,2,8)
plot(time,Tdata.(9),MaxValTime(9),MaxVal(9),'dr','linewidth',0.75)
legend(char(T.Properties.VariableNames(9)),['Force max: ' num2str(MaxVal(9)) ' [lbs]'])
xlim([time(1) time(DataEndIdx(1)-1)])
xlabel('Time [s]')
ylabel('Force [lbs]')
title('Thrust')

%Reset counter
i = DataEndIdx+2;
%Plot events on graph
for i = i:length(time)
line(time(i)*[1 1], get(gca,'YLim'),'Color','r','LineStyle',':')
i+1;
end
