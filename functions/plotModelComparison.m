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

legend_labels = strings(1, 2*numel(scenario_names)+1);
for j = 1:numel(scenario_names)
    legend_labels((j*2-1):2*j) = ["", scenario_names(j)]; % append name of scenario
end
legend_labels(end) = 'Data';



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
tiledlayout(2, 2);

%line_colours = hsv(numel(scenario_names)+1); % use colormap
%line_colours(1, :) = []; % Remove the first row

line_colours = hsv(numel(scenario_names)); % use colormap

shade_colours = line_colours;


% Skip index 4 (hospital occupancy)
indsToPlot = [1, 2, 3, 5];

for i = 1:length(indsToPlot)
    nexttile
    title(subplotTitles(i))
    hold on
    for j = 1:numel(scenario_names)
        fill([t, fliplr(t)], [min(bandsData(:, :, indsToPlot(i), j), [], 2); ...
            flipud(max(bandsData(:, :, indsToPlot(i), j), [], 2))], ...
            "", "FaceColor", shade_colours(j, :), 'FaceAlpha', 0.1, 'EdgeColor', 'none');
        plot(t, bestFitData(:, indsToPlot(i), j), 'Color', line_colours(j, :), 'LineWidth', 1)
    end
    if indsToPlot(i) == 1 | indsToPlot(i) == 4
        plot(tData, realData(:, indsToPlot(i)), '.', 'Color', [0.2 0.2 0.2])
    else
        plot(tData, smoothdata(realData(:, indsToPlot(i)), 'movmean', smoothDays(i)), '-',  'Color', [0 0 0 0.5], 'LineWidth', 1)
    end

    hold off
    xlim(tPlotRange)
    ylim([0 inf])
    ylabel(subplotYaxis(i))
    grid on
    grid minor
end


leg = legend(legend_labels, 'Interpreter', 'none');
leg.Layout.Tile = 'South';


% Save figure if it doesn't already exist or if overwrite flag is on
figLabel = split(plotTitle, '.mat');
figLabel = append(figDir, figLabel{1}, '_modelComparison.png');
if exist(figLabel, 'file') == 0 || overwriteFig
    saveas(f, figLabel)
end

end