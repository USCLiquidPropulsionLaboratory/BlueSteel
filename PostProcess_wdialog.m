%%Post-Processing of Pressure Transducer Measurements
% This tool processes data in a csv format from a user chosen file and provides:
%  Pressure vs time profiles
%  Thrust vs time profiles
%       with max values and notable events
%
% To be implemented:
%   tables of max & avg values
%   nominal profiles
%   GUI
% - Becca Rogers
%  rarogers@usc.edu
% Date Modified: 11/12/2016

%Clear variables used in this script and graph annotations
clear T Tdata Pmax1 Pmax2 Pmax3 Pmax4 Pmax5 Pmax6 Pmax7 Fmax

delete(findall(gcf,'Tag','Event 1 Textbox'))
delete(findall(gcf,'Tag','Event 2 Textbox'))
delete(findall(gcf,'Tag','Event 3 Textbox'))
%Get comma separated value from user input
[baseName, folder] = uigetfile('*.csv');
fullFileName = fullfile(folder, baseName)

%Import comma separated value data exactly as is into table variable T
T = readtable(fullFileName);
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

time = Tdata.(1);

%Create index to find where data is NaN
idx = find(ismissing(time)==1);
P1max = find(Tdata.(2) == max(Tdata.(2)));
P2max = find(Tdata.(3) == max(Tdata.(3)));
P3max = find(Tdata.(4) == max(Tdata.(4)));
P4max = find(Tdata.(5) == max(Tdata.(5)));
P5max = find(Tdata.(6) == max(Tdata.(6)));
P6max = find(Tdata.(7) == max(Tdata.(7)));
P7max = find(Tdata.(8) == max(Tdata.(8)));
Fmax  = find(Tdata.(9) == max(Tdata.(9)));

%Create new figure
figure
%Manually plot Pressure Transducer 1 data
plot(time,Tdata.(2),time(P1max),Tdata.(2)(P1max),'dr','linewidth',0.75)
legend(char(T.Properties.VariableNames(2)),['P1 max: ' num2str(Tdata.(2)(P1max)) ' psi'])
xlim([time(1) time(idx(1)-1)])
xlabel('Time [s]')
ylabel('Pressure [psi]')
title('Pressure Transducer 1')
annotation('textbox',[time(idx(1)+2)/time(idx(1)-1)+.1,0.065,0,0] ,...
    'string', T.(2)(idx(1)+2),...
    'FitBoxToText','on',...
    'HorizontalAlignment','center',...
    'tag', 'Event 1 Textbox')
annotation('textbox', [time(idx(1)+3)/time(idx(1)-1)+.05, .065, 0, 0], ...
    'string', T.(2)(idx(1)+3),...
    'FitBoxToText','on',...
    'HorizontalAlignment','center',...
    'tag', 'Event 2 Textbox')
annotation('textbox', [time(idx(1)+4)/time(idx(1)-1), .065, 0, 0], ...
    'string', T.(2)(idx(1)+4),...
    'FitBoxToText','on',...
    'HorizontalAlignment','center',...
    'tag', 'Event 3 Textbox')

%Create counter for looping through event information
i = idx+2;

%Plot events on graph
%% Figure out line function
for i = i:length(time)
line(time(i)*[1 1], get(gca,'YLim'),'Color','r','LineStyle',':')
i+1;
end

%Create new figure
figure
%Manually plot Pressure Transducer 2 data
plot(time,Tdata.(3),time(P2max),Tdata.(3)(P2max),'dr','linewidth',0.75)
legend(char(T.Properties.VariableNames(3)),['P2 max: ' num2str(Tdata.(3)(P2max(1))) ' psi'])
xlim([time(1) time(idx(1)-1)])
xlabel('Time [s]')
ylabel('Pressure [psi]')
title('Pressure Transducer 2')
annotation('textbox',[time(idx(1)+2)/time(idx(1)-1)+.1,0.065,0,0] ,...
    'string', T.(2)(idx(1)+2),...
    'FitBoxToText','on',...
    'HorizontalAlignment','center',...
    'tag', 'Event 1 Textbox')
annotation('textbox', [time(idx(1)+3)/time(idx(1)-1)+.05, .065, 0, 0], ...
    'string', T.(2)(idx(1)+3),...
    'FitBoxToText','on',...
    'HorizontalAlignment','center',...
    'tag', 'Event 2 Textbox')
annotation('textbox', [time(idx(1)+4)/time(idx(1)-1), .065, 0, 0], ...
    'string', T.(2)(idx(1)+4),...
    'FitBoxToText','on',...
    'HorizontalAlignment','center',...
    'tag', 'Event 3 Textbox')

%Create counter for looping through event information
i = idx+2;

%Plot events on graph
% Figure out line function
for i = i:length(time)
line(time(i)*[1 1], get(gca,'YLim'),'Color','r','LineStyle',':')
i+1;
end

%Create new figure
figure
%Manually plot Pressure Transducer 3 data
plot(time,Tdata.(4),time(P3max),Tdata.(4)(P3max),'dr','linewidth',0.75)
legend(char(T.Properties.VariableNames(4)),['P3 max: ' num2str(Tdata.(4)(P3max(1))) ' psi'])
xlim([time(1) time(idx(1)-1)])
xlabel('Time [s]')
ylabel('Pressure [psi]')
title('Pressure Transducer 3')
annotation('textbox',[time(idx(1)+2)/time(idx(1)-1)+.1,0.065,0,0] ,...
    'string', T.(2)(idx(1)+2),...
    'FitBoxToText','on',...
    'HorizontalAlignment','center',...
    'tag', 'Event 1 Textbox')
annotation('textbox', [time(idx(1)+3)/time(idx(1)-1)+.05, .065, 0, 0], ...
    'string', T.(2)(idx(1)+3),...
    'FitBoxToText','on',...
    'HorizontalAlignment','center',...
    'tag', 'Event 2 Textbox')
annotation('textbox', [time(idx(1)+4)/time(idx(1)-1), .065, 0, 0], ...
    'string', T.(2)(idx(1)+4),...
    'FitBoxToText','on',...
    'HorizontalAlignment','center',...
    'tag', 'Event 3 Textbox')

%Create counter for looping through event information
i = idx+2;

%Plot events on graph
% Figure out line function
for i = i:length(time)
line(time(i)*[1 1], get(gca,'YLim'),'Color','r','LineStyle',':')
i+1;
end

%Create new figure
figure
%Manually plot Pressure Transducer 4 data
plot(time,Tdata.(5),time(P4max),Tdata.(5)(P4max),'dr','linewidth',0.75)
legend(char(T.Properties.VariableNames(5)),['P4 max: ' num2str(Tdata.(5)(P4max(1))) ' psi'])
xlim([time(1) time(idx(1)-1)])
xlabel('Time [s]')
ylabel('Pressure [psi]')
title('Pressure Transducer 4')
annotation('textbox',[time(idx(1)+2)/time(idx(1)-1)+.1,0.065,0,0] ,...
    'string', T.(2)(idx(1)+2),...
    'FitBoxToText','on',...
    'HorizontalAlignment','center',...
    'tag', 'Event 1 Textbox')
annotation('textbox', [time(idx(1)+3)/time(idx(1)-1)+.05, .065, 0, 0], ...
    'string', T.(2)(idx(1)+3),...
    'FitBoxToText','on',...
    'HorizontalAlignment','center',...
    'tag', 'Event 2 Textbox')
annotation('textbox', [time(idx(1)+4)/time(idx(1)-1), .065, 0, 0], ...
    'string', T.(2)(idx(1)+4),...
    'FitBoxToText','on',...
    'HorizontalAlignment','center',...
    'tag', 'Event 3 Textbox')

%Create counter for looping through event information
i = idx+2;

%Plot events on graph
% Figure out line function
for i = i:length(time)
line(time(i)*[1 1], get(gca,'YLim'),'Color','r','LineStyle',':')
i+1;
end

%Create new figure
figure
%Manually plot Pressure Transducer 5 data
plot(time,Tdata.(6),time(P5max),Tdata.(6)(P5max),'dr','linewidth',0.75)
legend(char(T.Properties.VariableNames(6)),['P5 max: ' num2str(Tdata.(6)(P5max)) ' psi'])
xlim([time(1) time(idx(1)-1)])
xlabel('Time [s]')
ylabel('Pressure [psi]')
title('Pressure Transducer 5')
annotation('textbox',[time(idx(1)+2)/time(idx(1)-1)+.1,0.065,0,0] ,...
    'string', T.(2)(idx(1)+2),...
    'FitBoxToText','on',...
    'HorizontalAlignment','center',...
    'tag', 'Event 1 Textbox')
annotation('textbox', [time(idx(1)+3)/time(idx(1)-1)+.05, .065, 0, 0], ...
    'string', T.(2)(idx(1)+3),...
    'FitBoxToText','on',...
    'HorizontalAlignment','center',...
    'tag', 'Event 2 Textbox')
annotation('textbox', [time(idx(1)+4)/time(idx(1)-1), .065, 0, 0], ...
    'string', T.(2)(idx(1)+4),...
    'FitBoxToText','on',...
    'HorizontalAlignment','center',...
    'tag', 'Event 3 Textbox')

%Create counter for looping through event information
i = idx+2;

%Plot events on graph
% Figure out line function
for i = i:length(time)
line(time(i)*[1 1], get(gca,'YLim'),'Color','r','LineStyle',':')
i+1;
end

%Create new figure
figure
%Manually plot Pressure Transducer 6 data
plot(time,Tdata.(7),time(P6max),Tdata.(7)(P6max),'dr','linewidth',0.75)
legend(char(T.Properties.VariableNames(7)),['P6 max: ' num2str(Tdata.(7)(P6max(1))) ' psi'])
xlim([time(1) time(idx(1)-1)])
xlabel('Time [s]')
ylabel('Pressure [psi]')
title('Pressure Transducer 6')
annotation('textbox',[time(idx(1)+2)/time(idx(1)-1)+.1,0.065,0,0] ,...
    'string', T.(2)(idx(1)+2),...
    'FitBoxToText','on',...
    'HorizontalAlignment','center',...
    'tag', 'Event 1 Textbox')
annotation('textbox', [time(idx(1)+3)/time(idx(1)-1)+.05, .065, 0, 0], ...
    'string', T.(2)(idx(1)+3),...
    'FitBoxToText','on',...
    'HorizontalAlignment','center',...
    'tag', 'Event 2 Textbox')
annotation('textbox', [time(idx(1)+4)/time(idx(1)-1), .065, 0, 0], ...
    'string', T.(2)(idx(1)+4),...
    'FitBoxToText','on',...
    'HorizontalAlignment','center',...
    'tag', 'Event 3 Textbox')

%Create counter for looping through event information
i = idx+2;

%Plot events on graph
% Figure out line function
for i = i:length(time)
line(time(i)*[1 1], get(gca,'YLim'),'Color','r','LineStyle',':')
i+1;
end

%Create new figure
figure
%Manually plot Pressure Transducer 7 data
plot(time,Tdata.(8),time(P7max),Tdata.(8)(P7max),'dr','linewidth',0.75)
legend(char(T.Properties.VariableNames(8)),['P7 max: ' num2str(Tdata.(8)(P7max)) ' psi'])
xlim([time(1) time(idx(1)-1)])
xlabel('Time [s]')
ylabel('Pressure [psi]')
title('Pressure Transducer 7')
annotation('textbox',[time(idx(1)+2)/time(idx(1)-1)+.1,0.065,0,0] ,...
    'string', T.(2)(idx(1)+2),...
    'FitBoxToText','on',...
    'HorizontalAlignment','center',...
    'tag', 'Event 1 Textbox')
annotation('textbox', [time(idx(1)+3)/time(idx(1)-1)+.05, .065, 0, 0], ...
    'string', T.(2)(idx(1)+3),...
    'FitBoxToText','on',...
    'HorizontalAlignment','center',...
    'tag', 'Event 2 Textbox')
annotation('textbox', [time(idx(1)+4)/time(idx(1)-1), .065, 0, 0], ...
    'string', T.(2)(idx(1)+4),...
    'FitBoxToText','on',...
    'HorizontalAlignment','center',...
    'tag', 'Event 3 Textbox')

%Create counter for looping through event information
i = idx+2;

%Plot events on graph
% Figure out line function
for i = i:length(time)
line(time(i)*[1 1], get(gca,'YLim'),'Color','r','LineStyle',':')
i+1;

end


%Manually plot Force data
figure
plot(time,Tdata.(9),time(Fmax),Tdata.(9)(Fmax),'dr','linewidth',0.75)
legend(char(T.Properties.VariableNames(9)),['Force max: ' num2str(Tdata.(9)(Fmax)) ' [lbs]'])
xlabel('Time [s]')
ylabel('Force [lbs]')
annotation('textbox',[time(idx(1)+2)/time(idx(1)-1)+.1,0.065,0,0] ,...
    'string', T.(2)(idx(1)+2),...
    'FitBoxToText','on',...
    'HorizontalAlignment','center',...
    'tag', 'Event 1 Textbox')
annotation('textbox', [time(idx(1)+3)/time(idx(1)-1)+.05, .065, 0, 0], ...
    'string', T.(2)(idx(1)+3),...
    'FitBoxToText','on',...
    'HorizontalAlignment','center',...
    'tag', 'Event 2 Textbox')
annotation('textbox', [time(idx(1)+4)/time(idx(1)-1), .065, 0, 0], ...
    'string', T.(2)(idx(1)+4),...
    'FitBoxToText','on',...
    'HorizontalAlignment','center',...
    'tag', 'Event 3 Textbox')
%Reset counter
i = idx+2;
%Plot events on graph
for i = i:length(time)
line(time(i)*[1 1], get(gca,'YLim'),'Color','r','LineStyle',':')
i+1;

end