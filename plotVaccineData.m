clear
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot ethnicity-specific vaccine data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Age bands for plotting (indices of relevant 5 year age groups)
indPlotGroups = [2 4 14 16 17];


% Pop data file name (for plotting)
fNamePop = 'data/HSU_by_age_eth.csv';

% Vaccination data file names
fNameM = "data/vaccine_data_Maori_2023-06-06.csv";
fNameP = "data/vaccine_data_Pacific_2023-06-06.csv";
fNameA = "data/vaccine_data_Asian_2023-06-06.csv";
fNameO = "data/vaccine_data_EuropeanOther_2023-06-06.csv";
ethGroupNames = ["Euro/other", "Māori", "Pacific", "Asian"];

% Load pop data and get totals by ethnicity
HSUData = readtable(fNamePop);
HSUData = HSUData(~isnan(HSUData.Age), :);
popAll = [HSUData.EuropeanorOther, HSUData.Maori, HSUData.PacificPeoples, HSUData.Asian];
popAll(16, :) = sum(popAll(16:end, :));
popAll(17:end, :) = [];

% Load vaccine data
tblM = readtable(fNameM);
tblP = readtable(fNameP);
tblA = readtable(fNameA);
tblO = readtable(fNameO);

dts = tblM.dates;

nDates = length(dts);
nAges = 16;
nEth = 4;

[doses1, doses2, doses3, doses4] = deal(zeros(nAges, nDates, nEth));

doses1(:, :, 1) = table2array(tblO(:, 2:17))';
doses2(:, :, 1) = table2array(tblO(:, 18:33))';
doses3(:, :, 1) = table2array(tblO(:, 34:49))';
doses4(:, :, 1) = table2array(tblO(:, 50:65))';

doses1(:, :, 2) = table2array(tblM(:, 2:17))';
doses2(:, :, 2) = table2array(tblM(:, 18:33))';
doses3(:, :, 2) = table2array(tblM(:, 34:49))';
doses4(:, :, 2) = table2array(tblM(:, 50:65))';

doses1(:, :, 3) = table2array(tblP(:, 2:17))';
doses2(:, :, 3) = table2array(tblP(:, 18:33))';
doses3(:, :, 3) = table2array(tblP(:, 34:49))';
doses4(:, :, 3) = table2array(tblP(:, 50:65))';

doses1(:, :, 4) = table2array(tblA(:, 2:17))';
doses2(:, :, 4) = table2array(tblA(:, 18:33))';
doses3(:, :, 4) = table2array(tblA(:, 34:49))';
doses4(:, :, 4) = table2array(tblA(:, 50:65))';


figure(1);
nGroupsPlot = length(indPlotGroups)-1;
tiledlayout(nGroupsPlot, 4, "TileSpacing", "compact");

for iGroup = 1:nGroupsPlot
    ind = indPlotGroups(iGroup):indPlotGroups(iGroup+1)-1;
    popSize = sum( popAll(ind, :), 1 );

    nexttile;
    plot(dts, squeeze(sum(doses1(ind, :, 1:4 ), 1))./popSize )
    ylim([0 1])
    grid on
    if iGroup < nGroupsPlot
        title(sprintf('age %i-%i, 1st doses', 5*(ind(1)-1), 5*ind(end)-1 ));
    else
        title(sprintf('age %i+, 1st doses', 5*(ind(1)-1)));
    end
    ylabel('doses per capita')


    nexttile;
    plot(dts, squeeze(sum(doses2(ind, :, 1:4 ), 1))./popSize )
    ylim([0 1])
    grid on
    if iGroup < nGroupsPlot
        title(sprintf('age %i-%i, 2nd doses', 5*(ind(1)-1), 5*ind(end)-1 ));
    else
        title(sprintf('age %i+, 2nd doses', 5*(ind(1)-1)));
    end


    nexttile;
    plot(dts, squeeze(sum(doses3(ind, :, 1:4 ), 1))./popSize )
    ylim([0 1])
    grid on
    if iGroup < nGroupsPlot
        title(sprintf('age %i-%i, 3rd doses', 5*(ind(1)-1), 5*ind(end)-1 ));
    else
        title(sprintf('age %i+, 3rd doses', 5*(ind(1)-1)));
    end

    nexttile;
    plot(dts, squeeze(sum(doses4(ind, :, 1:4 ), 1))./popSize )
    ylim([0 1])
    grid on
    if iGroup < nGroupsPlot
        title(sprintf('age %i-%i, 4th doses', 5*(ind(1)-1), 5*ind(end)-1 ));
    else
        title(sprintf('age %i+, 4th doses', 5*(ind(1)-1)));
    end
    if iGroup == nGroupsPlot
        legend(ethGroupNames(1:4), 'Location', 'northwest');
    end
end

