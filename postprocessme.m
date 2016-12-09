%%Post-Processing of Pressure Transducer Measurements
% This tool calls a user interface to provide test data and nominal data
% from user specified files and allows user to choose:
%  Individaul Pressure vs time profiles
%  Individual Thrust vs time profile
%       with max values and notable events
%  Subplots of Force and Pressure plots
%  Table with max and average values
%  Graph of ISP
%
% To be implemented:
%   more accurate nominal profiles
%   Improved labels for PTs
%   interface with DAQ GUI
% - Becca Rogers
%  rarogers@usc.edu
% Date Modified: 12/2/2016z

%Clear variables used in this script
clc
clear
%run GUI and wait for user to hit Go
simpleGUI
uiwait

%Import comma separated value data exactly as is into table variable T
global fullFileName
T = readtable(fullFileName);
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
global fullNomFileName
NominalTable = readtable(fullNomFileName);
Nominal = zeros(1,width(Tdata));
for iCol=2:1:width(Tdata)
Nominal(iCol) = NominalTable{1,iCol};
end

%Convert force from lbs to Newtons
Tdata.(9) = T.(9)*4.44822; % Newtons
Nominal(9) = Nominal(9)*4.44822; %Newtons
T.Properties.VariableNames(9) = {'Force'};

%Create logical array for table of values and ISP graph
global yesTable
%Create logical array for individual PT & Force plots over all time
global yesGraph
%Create logical array for PT & Force plots over burn time
global yesGraphBurn

% Set mass flow variables and gravitational constant
mdot = 1.055; %kg/s
ge = 9.80665; %m/s^2

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
if yesTable(1) == 1

    %Create figure with tables of max & avg values
f2 = figure('position',[100, 100, 575, 225]);
Table2 = uitable(f2);
Table2.Data = [MaxValTime(2:end,:),MaxVal(2:end,:),AvgVal(2:end,:),...
    MaxBurnValTime(2:end,:),MaxBurnVal(2:end,:),AvgBurnVal(2:end,:)];
Table2.ColumnName = {'Time (s)','Max Value', 'Avg Value',...
    'Time (s)','Max Burn Value', 'Avg Burn Value'};
Table2.RowName = {'PT1 (psi)','PT2 (psi)','PT3 (psi)','PT4 (psi)',...
    'PT5 (psi)','PT6 (psi)','PT7 (psi)','FT (N)'};
Table2.Units = 'Normalized';
Table2.Position = [0 0 1 1];

end
%%
%First loop plot Force & PTs 1 to 7 for all burn time as subplot
%Second loop plot Force & PTs 1 to 7 as individual plots
for iLoop = 1:1:2 %Run twice
    if iLoop==1 & yesGraph(1)==1
        %Create new full window figure
        figure('units','normalized','outerposition',[0 0 1 1])
        %prepare subplot
        subplot(4,2,1)
    elseif iLoop==2 & yesGraph(9)==1
        figure;
    end
    
    if iLoop==1 & yesGraph(1)==1 | iLoop==2 & yesGraph(9)==1
    
    plot(time,Tdata.(9),NomTime,NomGraph(9,:),'-.k',...
        MaxValTime(9),MaxVal(9),'dr','linewidth',0.75)
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

     if iLoop==2
        %Create individual plot annotations for Events 1 2 3
        %iEvent = 2
        for iEvent = 2:1:4
        annotation('textbox',...
            [time(DataEndIdx(1)+iEvent)/time(DataEndIdx(1)-1)+.07,0.065,0,0] ,...
            'string', T.(2)(DataEndIdx(1)+iEvent),...
            'FitBoxToText','on',...
            'HorizontalAlignment','center',...
            'tag', 'Event 1 Textbox')
        end
     end
    end

    %For Loop 1 plot all colummns as subplot
    %For Loop 2 plot each column as individual plot
    for iCol = 2:1:8 %For all columns of PT data
        if iLoop == 1 & yesGraph(1)==1
            subplot(4,2,iCol)
        elseif iLoop == 2 & yesGraph(iCol)==1
            figure;
        end
    if iLoop==1 & yesGraph(1)==1 | iLoop==2 & yesGraph(iCol)==1
    plot(time,Tdata.(iCol),NomTime,NomGraph(iCol,:),'-.k',...
        MaxValTime(iCol),MaxVal(iCol),'dr','linewidth',0.75)
    legend(char(T.Properties.VariableNames(iCol)),...
        ['Nominal: ' num2str(Nominal(iCol)) ' psi'],['P2 max: ' num2str(MaxVal(iCol)) ' psi'])
    xlim([time(1) time(DataEndIdx(1)-1)])
    xlabel('Time [s]')
    axPos = get(gca,'Position');
    ylabel('Pressure [psi]')
    title(['Pressure Transducer ' num2str(iCol-1)])
    %Create counter for looping through event information
    i = DataEndIdx+2;
    %Plot events on graph
    for i = i:length(time)
    line(time(i)*[1 1], get(gca,'YLim'),'Color','r','LineStyle',':');
    end
    if iLoop==1
        %Create RHS & LHS subplot annotations for Events 1 2 3
        for iEvent = 2:1:4
        annotation('textbox',...
            [(time(DataEndIdx(1)+iEvent)/(time(DataEndIdx(1)-1)))*(axPos(3))+axPos(1), 0.065, 0, 0] ,...
            'string', T.(2)(DataEndIdx(1)+iEvent),...
            'FitBoxToText','on',...
            'HorizontalAlignment','center',...
            'tag', 'Event 1 Textbox')
        end
    end
      if iLoop==2
            %Create individual plot annotations for Events 1 2 3
            %iEvent = 2
            for iEvent = 2:1:4
            annotation('textbox',...
                [time(DataEndIdx(1)+iEvent)/time(DataEndIdx(1)-1)+.07,0.065,0,0] ,...
                'string', T.(2)(DataEndIdx(1)+iEvent),...
                'FitBoxToText','on',...
                'HorizontalAlignment','center',...
                'tag', 'Event 1 Textbox')
            end
      end
     end
    end
end

%%
%First loop plot PTs 1 to 7 for burn time only as subplot
%Second loop plot PTs 1 to 7 as individual plots
for iLoop = 1:1:2 %Run twice
    if iLoop==1 & yesGraphBurn(1)==1
        %Create new full size figure window
        figure('units','normalized','outerposition',[0 0 1 1])
        %Prepare subplot
        subplot(4,2,1)
    elseif iLoop==2 & yesGraphBurn(9)==1
        figure;
    end
        
    %During loop 1 plot Force as first plot of subplot
    %During loop 2 plot Force as individual graph
    if iLoop==1 & yesGraphBurn(1)==1 | iLoop==2 & yesGraphBurn(9)==1
        
    plot(timeBurn,Tburn.(9), NomTime,NomGraph(9,:),'-.k',MaxBurnValTime(9),MaxBurnVal(9),'dr','linewidth',0.75)
    legend(char(T.Properties.VariableNames(9)),...
    ['Nominal: ' num2str(Nominal(9)) ' N'],['Force max: ' num2str(MaxBurnVal(9)) ' N'])
    xlim([timeBurn(1) time(end)])
    xlabel('Time [s]')
    ylabel('Force [N]')
    title('Thrust during Burn Time')
    %Reset counter
    i = DataEndIdx+2;
    %Plot events on graph
    for i = i:1:length(time)
    line(time(i)*[1 1], get(gca,'YLim'),'Color','r','LineStyle',':')
    end
    if iLoop==2
        %Create individual plot annotations for Events 1 2 3
        %iEvent = 2
        for iEvent = 2:1:4
        annotation('textbox',...
            [time(DataEndIdx(1)+iEvent)/time(DataEndIdx(1)-1)+.07,0.065,0,0] ,...
            'string', T.(2)(DataEndIdx(1)+iEvent),...
            'FitBoxToText','on',...
            'HorizontalAlignment','center',...
            'tag', 'Event 1 Textbox')
        end
    end
    end
    
    for iCol = 2:1:8 %For all columns of PT data
        if iLoop == 1 & yesGraphBurn(1)==1
            subplot(4,2,iCol)
        elseif iLoop == 2 & yesGraphBurn(iCol)==1
            figure;
        end
    if iLoop==1 & yesGraphBurn(1)==1 | iLoop==2 & yesGraphBurn(iCol)==1
    plot(timeBurn,Tburn.(iCol),NomTime,NomGraph(iCol,:),'-.k',...
        MaxBurnValTime(iCol),MaxBurnVal(iCol),'dr','linewidth',0.75)
    legend(char(T.Properties.VariableNames(iCol)),...
        ['Nominal: ' num2str(Nominal(iCol)) ' psi'],['P ' num2str(iCol-1) ' max: ' num2str(MaxBurnVal(iCol)) ' psi'])
    xlim([timeBurn(1) time(end)])
    xlabel('Time [s]')
    axPos = get(gca,'Position');
    ylabel('Pressure [psi]')
    title(['Pressure Transducer ' num2str(iCol-1) ' during Burn'])
    end
    end

end
%%
% Create graph to plot ISP = F_T/(mdot*ge) %seconds
if yesTable(2)==1
    figure;
    plot(time,Tdata.(9)/(mdot*ge))
    legend('ISP')
    xlim([time(1) time(DataEndIdx(1)-1)])
    xlabel('Time [s]')
    ylabel('ISP [s]')
    title('ISP')
end
