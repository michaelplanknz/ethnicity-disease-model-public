function plotModelComparison(t, bandsData, bestFitData, tData, realData, ...
    popCountVector, plotToDate, scenario_names, overwriteFig, perCapita, figDir)
% Function that plots a grid of plots (infections, cases, hospital
% admissions, hospital occupancy, and deaths), which include a best fit
% line, confidence bands, real data, and vertical lines representing an
% intervention date

% INPUTS:
% - filenameBands: "folder/filename.mat" for bands data
% - filenameBestFit: "folder/filename.mat" for best fit data
% - plotToDate: datetime variable specifying the upper limit for the horizontal (time) axis for the plots
% - dataComb: data for plotting, as output by getAllData.m
% - scenario_names: vector naming the different runs
% - overwriteFig: set to true to overwrite png plots in results

% OUTPUTS:
% - .png figures in results, if they don't already exist or if overwriteFig
%   set to true


% Subset of scenarios to plot in the next graph (make this 1:nScenarios to
% plot all of them)
scenariosToPlot = [1, 4, 5];

% Collapse by age and ethnicity

bandsData = reshape(sum(sum(bandsData, 4), 3), size(bandsData, [1 2 5 6]));
bestFitData = reshape(sum(sum(bestFitData, 3), 2), size(bestFitData, [1 4 5]));

realData = reshape(sum(realData, 2), size(realData, [1 3])); % collapse over age groups
realData = [realData(:, 1) sum(realData(:, 3:6), 2) sum(realData(:, 7:10), 2)... 
    realData(:, 2) sum(realData(:, 11:14), 2)];

% Rescale to per 100,000 if needed
if perCapita == true
    bandsData = 1e5 * bandsData ./ sum(popCountVector);
    bestFitData = 1e5 * bestFitData ./ sum(popCountVector);
    realData = 1e5 * realData ./ sum(popCountVector);
end

% Write out figure legends
legend_labels = [scenario_names(scenariosToPlot)', "Data"];



% ------------------------------ PLOTS ------------------------------------

plotTitle = 'Comparing all scenarios';

subplotTitles = {'(a) Infections', '(b) Cases', '(c) Admissions', ...
    '(d) Deaths'};
if perCapita
    subplotYaxis = {'new daily infections per 100K', 'new daily cases per 100K', ...
        'new daily admissions per 100K', 'daily deaths per 100K'};
else
    subplotYaxis = {'new daily infections', 'new daily cases', ...
        'new daily admissions', 'daily deaths'};
end
tPlotRange = [datetime(2022, 1, 1), plotToDate+1];
smoothDays = [nan, 7, 14, 21];

f = figure;
set(f, 'WindowStyle', 'normal');
f.Position = [100 100 1000 600];
tiledlayout(2, 2, 'TileSpacing', 'tight', 'padding', 'tight');

line_colours = colororder;


% Skip index 4 (hospital occupancy)
indsToPlot = [1, 2, 3, 5];

for i = 1:length(indsToPlot)
    nexttile
    title(subplotTitles(i))
    hold on
    for j = 1:length(scenariosToPlot)
        kScenario = scenariosToPlot(j);
        plot(t, min(bandsData(:, :, indsToPlot(i), kScenario), [], 2), 'Color', line_colours(kScenario, :), 'LineWidth', 1, 'LineStyle', ':', 'HandleVisibility', 'off')
        plot(t, max(bandsData(:, :, indsToPlot(i), kScenario), [], 2), 'Color', line_colours(kScenario, :), 'LineWidth', 1, 'LineStyle', ':', 'HandleVisibility', 'off')
        plot(t, bestFitData(:, indsToPlot(i), kScenario), 'Color', line_colours(kScenario, :), 'LineWidth', 2)
    end
    if indsToPlot(i) == 1 | indsToPlot(i) == 4
        plot(tData, realData(:, indsToPlot(i)), '.', 'Color', [0 0 0], 'MarkerSize', 10)
    else
        plot(tData, smoothdata(realData(:, indsToPlot(i)), 'movmean', smoothDays(i)), '-',  'Color', [0 0 0], 'LineWidth', 2)
    end

    hold off
    xlim(tPlotRange)
    ylim([0 inf])
    ylabel(subplotYaxis(i))
    grid on
end

nexttile(1);
leg = legend(legend_labels, 'Interpreter', 'none', 'Location', 'northeast');


% Save figure if it doesn't already exist or if overwrite flag is on
figLabel = split(plotTitle, '.mat');
figLabel = append(figDir, figLabel{1}, '_modelComparison.png');
if exist(figLabel, 'file') == 0 || overwriteFig
    saveas(f, figLabel)
end

end