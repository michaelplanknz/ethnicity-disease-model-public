clear
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot ethnicity-specific epi data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get data file names
[myDataPath, dataFileNames] = getDataFileNames(false);

% Read data for plotting
epiData = importEpiData(myDataPath+dataFileNames.epiDataFname); 




% Load pop data and get totals by ethnicity
HSUData = readtable(myDataPath+dataFileNames.popSizeFname);
HSUData = HSUData(~isnan(HSUData.Age), :);
popByEth = [sum(HSUData.Maori), sum(HSUData.PacificPeoples), sum(HSUData.Asian), sum(HSUData.EuropeanorOther)];



t = epiData.date;
tPlot = [datetime(2022, 1, 1), datetime(2023, 6, 30)];

figure(1)
tiledlayout(2, 3, "TileSpacing", "compact");
nexttile;
plot(t, smoothdata(sum(epiData.nCases_O, 2), 'movmean', 7)/popByEth(4)*1e5)
hold on
plot(t, smoothdata(sum(epiData.nCases_M, 2), 'movmean', 7)/popByEth(1)*1e5)
plot(t, smoothdata(sum(epiData.nCases_P, 2), 'movmean', 7)/popByEth(2)*1e5)
plot(t, smoothdata(sum(epiData.nCases_A, 2), 'movmean', 7)/popByEth(3)*1e5)
xlim(tPlot)
ylabel('smoothed daily cases per 100k')
legend('Euro/other', 'Māori', 'Pacific', 'Asian')
grid on
title('(a)')

nexttile;
plot(t, smoothdata(sum(epiData.nHosp_O, 2), 'movmean', 14)/popByEth(4)*1e5)
hold on
plot(t, smoothdata(sum(epiData.nHosp_M, 2), 'movmean', 14)/popByEth(1)*1e5)
plot(t, smoothdata(sum(epiData.nHosp_P, 2), 'movmean', 14)/popByEth(2)*1e5)
plot(t, smoothdata(sum(epiData.nHosp_A, 2), 'movmean', 14)/popByEth(3)*1e5)
xlim(tPlot)
ylabel('smoothed daily hospitalisations per 100k')
grid on
title('(b)')

nexttile;
plot(t, smoothdata(sum(epiData.nDeaths_O, 2), 'movmean', 21)/popByEth(4)*1e5)
hold on
plot(t, smoothdata(sum(epiData.nDeaths_M, 2), 'movmean', 21)/popByEth(1)*1e5)
plot(t, smoothdata(sum(epiData.nDeaths_P, 2), 'movmean', 21)/popByEth(2)*1e5)
plot(t, smoothdata(sum(epiData.nDeaths_A, 2), 'movmean', 21)/popByEth(3)*1e5)
xlim(tPlot)
ylabel('smoothed daily deaths per 100k')
grid on
title('(c)')

nexttile;
plot(t, cumsum(sum(epiData.nCases_O, 2))/popByEth(4)*1e5)
hold on
plot(t, cumsum(sum(epiData.nCases_M, 2))/popByEth(1)*1e5)
plot(t, cumsum(sum(epiData.nCases_P, 2))/popByEth(2)*1e5)
plot(t, cumsum(sum(epiData.nCases_A, 2))/popByEth(3)*1e5)
xlim(tPlot)
ylabel('cumulative cases per 100k')
grid on
title('(d)')

nexttile;
plot(t, cumsum(sum(epiData.nHosp_O, 2))/popByEth(4)*1e5)
hold on
plot(t, cumsum(sum(epiData.nHosp_M, 2))/popByEth(1)*1e5)
plot(t, cumsum(sum(epiData.nHosp_P, 2))/popByEth(2)*1e5)
plot(t, cumsum(sum(epiData.nHosp_A, 2))/popByEth(3)*1e5)
xlim(tPlot)
ylabel('cumulative hospitalisations per 100k')
grid on
title('(e)')

nexttile;
plot(t, cumsum(sum(epiData.nDeaths_O, 2))/popByEth(4)*1e5)
hold on
plot(t, cumsum(sum(epiData.nDeaths_M, 2))/popByEth(1)*1e5)
plot(t, cumsum(sum(epiData.nDeaths_P, 2))/popByEth(2)*1e5)
plot(t, cumsum(sum(epiData.nDeaths_A, 2))/popByEth(3)*1e5)
xlim(tPlot)
ylabel('cumulative deaths per 100k')
grid on
title('(f)')







