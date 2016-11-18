%%Post-Processing of Pressure Transducer Measurements
% This tool processes data from a specified file in a csv format and provides:
%  Pressure vs time profiles
%  Thrust vs time profile
%       with max values and notable events
%  Table with max and average values
%
% To be implemented:
%   more accurate nominal profiles
%   GUI
%   sub plot vs multi plot
%   statistical analysis
%   ISP graph
%   Improved labels for PTs
% - Becca Rogers
%  rarogers@usc.edu
% Date Modified: 11/16/2016

%Clear variables used in this script
clc
clear

%Import comma separated value data exactly as is into table variable T
T = readtable('9-17-16 firing.csv');
BurnTextIdx = find(~cellfun('isempty', strfind(T.(2),'Burn')));
BurnTime = str2double(T.(1)(BurnTextIdx(1)))/1000; %seconds

StopTextIdx = find(~cellfun('isempty', strfind(T.(2),'Stop')));
StopTime = str2double(T.(1)(StopTextIdx(1)))/1000; %seconds

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

%Convert force from lbs to Newtons
Tdata.(9) = T.(9)*4.44822; % Newtons
T.Properties.VariableNames(9) = {'Force'};

%Create index for burn and stop events
BurnTimeIdx = find(Tdata.(1)>BurnTime,1,'first');
StopTimeIdx = find(Tdata.(1)>StopTime,1,'first');
Tburn = Tdata(BurnTimeIdx:StopTimeIdx,:);
time = Tdata.(1);
timeBurn = Tburn.(1);

%Create index to find where data is NaN
%{use isnan function instead of ismissing for 2016a compatibility}
DataEndIdx = find(isnan(time));
%Create array to hold nominal values, assign them
Nominal = zeros(width(Tdata),1);
Nominal(2) = 200; %Value for PT1 (psi)
Nominal(3) = 1400; %Value for PT2 (psi)
Nominal(4) = 400; %Value for PT3 (psi)
Nominal(5) = 400; %Value for PT4 (psi)
Nominal(6) = 400; %Value for PT5 (psi)
Nominal(7) = 400; %Value for PT6 (psi)
Nominal(8) = 818.9; %Value for PT7 (psi)
Nominal(9) = 4550; %Value for FT (N)
%Create time reference to plot nominal values
%Create array with nominal values for plotting, assign correspondingly
NomTime = [0,BurnTime,BurnTime,StopTime,StopTime,time(DataEndIdx(1)-1)];
NomGraph = zeros(width(Tdata),6);
for jCol=2:1:width(Tdata)
NomGraph(jCol,:) = [0,0,Nominal(jCol),Nominal(jCol),0,0];
end
%%
%Create zero arrays as place holders for Max Values & Avg Values overall
%and during burn only
MaxValIdx = zeros(width(Tdata),1);
MaxValTime = zeros(width(Tdata),1);
MaxVal = zeros(width(Tdata),1);
MaxBurnValIdx = zeros(width(Tdata),1);
MaxBurnValTime = zeros(width(Tdata),1);
MaxBurnVal = zeros(width(Tdata),1);
AvgVal = zeros(width(Tdata),1);
AvgBurnVal = zeros(width(Tdata),1);

%Find Max & Avg Values foreach column of data, write to arrays
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
%%
%Create figure with tables of max & avg values
f2 = figure;
Table2 = uitable(f2);
Table2.Data = [MaxValTime(2:end,:),MaxVal(2:end,:),AvgVal(2:end,:),...
    MaxBurnValTime(2:end,:),MaxBurnVal(2:end,:),AvgBurnVal(2:end,:)];
Table2.ColumnName = {'Time (s)','Max Value', 'Avg Value',...
    'Time (s)','Max Burn Value', 'Avg Burn Value'};
Table2.RowName = {'PT1 (psi)','PT2 (psi)','PT3 (psi)','PT4 (psi)',...
    'PT5 (psi)','PT6 (psi)','PT7 (psi)','FT (N)'};
Table2.Units = 'Normalized';
Table2.Position = [0 0 1 1];
%%
%Create new full-window figure
figure('units','normalized','outerposition',[0 0 1 1])
%Clear all annotations
delete(findall(gcf,'Tag','Event 1 Textbox'))
delete(findall(gcf,'Tag','Event 2 Textbox'))
delete(findall(gcf,'Tag','Event 3 Textbox'))
%Manually plot Pressure Transducer 1 data
subplot(4,2,1)
plot(time,Tdata.(2),NomTime,NomGraph(2,:),'-.k', MaxValTime(2),MaxVal(2),'dr','linewidth',0.75)
legend(char(T.Properties.VariableNames(2)),...
    ['Nominal: ' num2str(Nominal(2)) ' psi'],['P1 max: ' num2str(MaxVal(2)) ' psi'])
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
% Vertical line
for i = i:1:length(time)
line(time(i)*[1 1], get(gca,'YLim'),'Color','r','LineStyle',':')
end

%Manually plot Pressure Transducer 2 data
subplot(4,2,3)
plot(time,Tdata.(3),NomTime,NomGraph(3,:),'-.k',MaxValTime(3),MaxVal(3),'dr','linewidth',0.75)
legend(char(T.Properties.VariableNames(3)),...
    ['Nominal: ' num2str(Nominal(3)) ' psi'],['P2 max: ' num2str(MaxVal(3)) ' psi'])
xlim([time(1) time(DataEndIdx(1)-1)])
xlabel('Time [s]')
ylabel('Pressure [psi]')
title('Pressure Transducer 2')
%Create counter for looping through event information
i = DataEndIdx+2;
%Plot events on graph
% Figure out line function
for i = i:length(time)
line(time(i)*[1 1], get(gca,'YLim'),'Color','r','LineStyle',':');
end

%
%Manually plot Pressure Transducer 3 data
subplot(4,2,5)
plot(time,Tdata.(4),NomTime,NomGraph(4,:),'-.k',MaxValTime(4),MaxVal(4),'dr','linewidth',0.75)
legend(char(T.Properties.VariableNames(4)),...
    ['Nominal: ' num2str(Nominal(4)) ' psi'],['P3 max: ' num2str(MaxVal(4)) ' psi'])
xlim([time(1) time(DataEndIdx(1)-1)])
xlabel('Time [s]')
ylabel('Pressure [psi]')
title('Pressure Transducer 3')
%Create counter for looping through event information
i = DataEndIdx+2;
%Plot events on graph
%Draw vertical lines for events in red
for i = i:1:length(time)
line(time(i)*[1 1], get(gca,'YLim'),'Color','r','LineStyle',':')
end

%
%Manually plot Pressure Transducer 4 data
subplot(4,2,7)
plot(time,Tdata.(5),NomTime,NomGraph(5,:),'-.k',MaxValTime(5),MaxVal(5),'dr','linewidth',0.75)
legend(char(T.Properties.VariableNames(5)),...
    ['Nominal: ' num2str(Nominal(5)) ' psi'],['P4 max: ' num2str(MaxVal(5)) ' psi'])
xlim([time(1) time(DataEndIdx(1)-1)])
xlabel('Time [s]')
ylabel('Pressure [psi]')
title('Pressure Transducer 4')
%Create counter for looping through event information
i = DataEndIdx+2;
%Plot events on graph
% Figure out line function
for i = i:1:length(time)
line(time(i)*[1 1], get(gca,'YLim'),'Color','r','LineStyle',':')
end
%
%Manually plot Pressure Transducer 5 data
subplot(4,2,2)
plot(time,Tdata.(6),NomTime,NomGraph(6,:),'-.k',MaxValTime(6),MaxVal(6),'dr','linewidth',0.75)
legend(char(T.Properties.VariableNames(6)),...
    ['Nominal: ' num2str(Nominal(6)) ' psi'],['P5 max: ' num2str(MaxVal(6)) ' psi'])
xlim([time(1) time(DataEndIdx(1)-1)])
xlabel('Time [s]')
ylabel('Pressure [psi]')
title('Pressure Transducer 5')
%Create counter for looping through event information
i = DataEndIdx+2;
%Plot events on graph
% Figure out line function
for i = i:1:length(time)
line(time(i)*[1 1], get(gca,'YLim'),'Color','r','LineStyle',':')
end
%
%Manually plot Pressure Transducer 6 data
subplot(4,2,4)
plot(time,Tdata.(7),NomTime,NomGraph(7,:),'-.k',MaxValTime(7),MaxVal(7),'dr','linewidth',0.75)
legend(char(T.Properties.VariableNames(7)),...
    ['Nominal: ' num2str(Nominal(7)) ' psi'],['P6 max: ' num2str(MaxVal(7)) ' psi'])
xlim([time(1) time(DataEndIdx(1)-1)])
xlabel('Time [s]')
ylabel('Pressure [psi]')
title('Pressure Transducer 6')
%Create counter for looping through event information
i = DataEndIdx+2;
%Plot events on graph
% Figure out line function
for i = i:1:length(time)
line(time(i)*[1 1], get(gca,'YLim'),'Color','r','LineStyle',':')
end
%
%Manually plot Pressure Transducer 7 data
subplot(4,2,6)
plot(time,Tdata.(8),NomTime,NomGraph(8,:),'-.k',MaxValTime(8),MaxVal(8),'dr','linewidth',0.75)
legend(char(T.Properties.VariableNames(8)),...
    ['Nominal: ' num2str(Nominal(8)) ' psi'],['P7 max: ' num2str(MaxVal(8)) ' psi'])
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
for i = i:1:length(time)
line(time(i)*[1 1], get(gca,'YLim'),'Color','r','LineStyle',':')
end
%
%Manually plot Force data
subplot(4,2,8)
plot(time,Tdata.(9),NomTime,NomGraph(9,:),'-.k',MaxValTime(9),MaxVal(9),'dr','linewidth',0.75)
legend(char(T.Properties.VariableNames(9)),...
    ['Nominal: ' num2str(Nominal(9)) ' N'],['Force max: ' num2str(MaxVal(9)) ' [N]'])
xlim([time(1) time(DataEndIdx(1)-1)])
xlabel('Time [s]')
ylabel('Force [N]')
title('Thrust')
%Reset counter
i = DataEndIdx+2;
%Plot events on graph
for i = i:1:length(time)
line(time(i)*[1 1], get(gca,'YLim'),'Color','r','LineStyle',':')
end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Create new full-window figure for graphs during Burn only
figure('units','normalized','outerposition',[0 0 1 1])
%Manually plot Pressure Transducer 1 data
subplot(4,2,1)
plot(timeBurn,Tburn.(2),NomTime,NomGraph(2,:),'-.k',MaxBurnValTime(2),MaxBurnVal(2),'dr','linewidth',0.75)
legend(char(T.Properties.VariableNames(2)),...
    ['Nominal: ' num2str(Nominal(2)) ' psi'],['P1 max: ' num2str(MaxBurnVal(2)) ' psi'])
xlim([timeBurn(1) time(end)])
xlabel('Time [s]')
axPos = get(gca,'Position');
ylabel('Pressure [psi]')
title('Pressure Transducer 1 during Burn Time')
%
%Manually plot Pressure Transducer 2 data
subplot(4,2,3)
plot(timeBurn,Tburn.(3),NomTime,NomGraph(3,:),'-.k',MaxBurnValTime(3),MaxBurnVal(3),'dr','linewidth',0.75)
legend(char(T.Properties.VariableNames(3)),...
    ['Nominal: ' num2str(Nominal(3)) ' psi'],['P2 max: ' num2str(MaxBurnVal(3)) ' psi'])
xlim([timeBurn(1) time(end)])
xlabel('Time [s]')
ylabel('Pressure [psi]')
title('Pressure Transducer 2 during Burn Time')
%
%Manually plot Pressure Transducer 3 data
subplot(4,2,5)
plot(timeBurn,Tburn.(4),NomTime,NomGraph(4,:),'-.k',MaxBurnValTime(4),MaxBurnVal(4),'dr','linewidth',0.75)
legend(char(T.Properties.VariableNames(4)),...
    ['Nominal: ' num2str(Nominal(4)) ' psi'],['P3 max: ' num2str(MaxBurnVal(4)) ' psi'])
xlim([timeBurn(1) time(end)])
xlabel('Time [s]')
ylabel('Pressure [psi]')
title('Pressure Transducer 3 during Burn Time')
%
%Manually plot Pressure Transducer 4 data
subplot(4,2,7)
plot(timeBurn,Tburn.(5),NomTime,NomGraph(5,:),'-.k',MaxBurnValTime(5),MaxBurnVal(5),'dr','linewidth',0.75)
legend(char(T.Properties.VariableNames(5)),...
    ['Nominal: ' num2str(Nominal(5)) ' psi'],['P4 max: ' num2str(MaxBurnVal(5)) ' psi'])
xlim([timeBurn(1) time(end)])
xlabel('Time [s]')
ylabel('Pressure [psi]')
title('Pressure Transducer 4 during Burn Time')
%
%Manually plot Pressure Transducer 5 data
subplot(4,2,2)
plot(timeBurn,Tburn.(6),NomTime,NomGraph(6,:),'-.k',MaxBurnValTime(6),MaxBurnVal(6),'dr','linewidth',0.75)
legend(char(T.Properties.VariableNames(6)),...
    ['Nominal: ' num2str(Nominal(6)) ' psi'],['P5 max: ' num2str(MaxBurnVal(6)) ' psi'])
xlim([timeBurn(1) time(end)])
xlabel('Time [s]')
ylabel('Pressure [psi]')
title('Pressure Transducer 5 during Burn Time')
%
%Manually plot Pressure Transducer 6 data
subplot(4,2,4)
plot(timeBurn,Tburn.(7), NomTime,NomGraph(7,:),'-.k',MaxBurnValTime(7),MaxBurnVal(7),'dr','linewidth',0.75)
legend(char(T.Properties.VariableNames(7)),...
    ['Nominal: ' num2str(Nominal(7)) ' psi'],['P6 max: ' num2str(MaxBurnVal(7)) ' psi'])
xlim([timeBurn(1) time(end)])
xlabel('Time [s]')
ylabel('Pressure [psi]')
title('Pressure Transducer 6  during Burn Time')
%
%Manually plot Pressure Transducer 7 data
subplot(4,2,6)
plot(timeBurn,Tburn.(8), NomTime,NomGraph(8,:),'-.k',MaxBurnValTime(8),MaxBurnVal(8),'dr','linewidth',0.75)
legend(char(T.Properties.VariableNames(8)),...
    ['Nominal: ' num2str(Nominal(8)) ' psi'],['P7 max: ' num2str(MaxBurnVal(8)) ' psi'])
xlim([timeBurn(1) time(end)])
xlabel('Time [s]')
axPos = get(gca,'Position');
ylabel('Pressure [psi]')
title('Pressure Transducer 7 during Burn Time')
%
%Manually plot Force data
subplot(4,2,8)
plot(timeBurn,Tburn.(9), NomTime,NomGraph(9,:),'-.k',MaxBurnValTime(9),MaxBurnVal(9),'dr','linewidth',0.75)
legend(char(T.Properties.VariableNames(9)),...
    ['Nominal: ' num2str(Nominal(9)) ' N'],['Force max: ' num2str(MaxBurnVal(9)) ' N'])
xlim([timeBurn(1) time(end)])
xlabel('Time [s]')
ylabel('Force [N]')
title('Thrust during Burn Time')
