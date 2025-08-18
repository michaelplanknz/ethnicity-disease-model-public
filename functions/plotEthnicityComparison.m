function plotEthnicityComparison(t, bandsData, bestFitData, tData, realData, ...
    popByEth, plotToDate, eth_names, scenario_names, scenario_pick, ...
    overwriteFig, perCapita, figDir)
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


% Use function here

% [t, bandsData, bestFitData, tData, realData] = ...
%     summariseScenarioRuns(filenameBands, filenameBestFit, dataComb);

nEthnicities = size(bandsData, 4);

% Trim down to one scenario only

layer_pick = scenario_pick == scenario_names; % layer needed
bandsData = reshape(bandsData(:, :, :, :, :, layer_pick), size(bandsData, [1 2 3 4 5]));
bestFitData = reshape(bestFitData(:, :, :, :, layer_pick), size(bestFitData, [1 2 3 4]));

% Now collapse by age

bandsDataByEth = reshape(sum(bandsData, 3), size(bandsData, [1 2 4 5]));
bestFitDataByEth = reshape(sum(bestFitData, 2), size(bestFitData, [1 3 4]));
realDataByEth = reshape(sum(realData, 2), size(realData, [1 3])); % collapse over age groups

% Rescale to per 100,000 if needed

if perCapita == true
    bandsDataByEth = 1e5 * bandsDataByEth ./ reshape(popByEth, 1, 1, 4, 1);
    bestFitDataByEth = 1e5 * bestFitDataByEth ./ reshape(popByEth, 1, 4, 1);
    realDataByEth(:, 3:end) = 1e5 * realDataByEth(:, 3:end) ./ repmat(popByEth, 1, 3);
end


% ------------------------------ PLOTS ------------------------------------

plotTitle = sprintf('Compare ethnicities (%s)', scenario_pick);

if perCapita
    subplotTitles = {'new daily infections per 100,000', 'new daily cases per 100,000', ...
        'new daily hospital admissions per 100,000', 'hospital occupancy per 100,000', ...
        'daily deaths per 100,000'};
    subplotYaxis = {'new daily infections per 100K', 'new daily cases per 100K', ...
        'new daily admissions per 100K', 'hospital occupancy per 100K', ...
        'daily deaths per 100K'};
else
    subplotTitles = {'new daily infections', 'new daily cases', ...
        'new daily admissions', 'hospital occupancy', ...
        'daily deaths'};
    subplotYaxis = subplotTitles;
end


smoothDays = [0, 7, 14, 7, 21];
tPlotRange = [datetime(2022, 1, 1), plotToDate+1];

f = figure;
set(f, 'WindowStyle', 'normal');
f.Position = [100 100 1000 800];
tiledlayout(3, 2);
sgtitle(plotTitle);

line_colours = parula(numel(eth_names)); % use colormap
shade_colours = line_colours;

for i = 1:size(bandsDataByEth, 4)
    nexttile
    title(subplotTitles(i))
    hold on
    for j = 1:nEthnicities
        fill([t, fliplr(t)], [min(bandsDataByEth(:, :, j, i), [], 2); ...
            flipud(max(bandsDataByEth(:, :, j, i), [], 2))], ...
            "", "FaceColor", shade_colours(j, :), 'FaceAlpha', 0.1, 'EdgeColor', 'none');
        %         plot(t, bandsDataAll(1:round(size(bandsDataAll, 1)/10), :, i), 'Color', shade_colours(j, :))
        plot(t, bestFitDataByEth(:, j, i), 'Color', line_colours(j, :), 'LineWidth', 2)
    end

    % Plotting data (ignore infections for now)
    if ismember(i, [2 3 5]) % not infections or hospital occupancy
        if i == 2
            first_col_pick = 2;
        elseif i == 3
            first_col_pick = 6;
        elseif i == 5
            first_col_pick = 10;
        end
        for j = 1:nEthnicities
            plot(tData, realDataByEth(:, first_col_pick+j), '.', 'Color', line_colours(j, :))
            plot(tData, smoothdata(realDataByEth(:, first_col_pick+j), 'movmean', smoothDays(i)), '-', 'Color', line_colours(j, :), 'LineWidth', 1)
        end
    end




    hold off
    xlim(tPlotRange)
    ylim([0 inf])
    ylabel(subplotYaxis(i))
    grid on
    grid minor
end



legend_labels = strings(1, 2 * numel(eth_names)+1);
legend_labels(2:2:end-1) = eth_names;
legend_labels(end) = 'Data';
leg = legend(legend_labels, 'Interpreter', 'none');
leg.Layout.Tile = 6;


% Save figure if it doesn't already exist or if overwrite flag is on
figLabel = append(figDir, plotTitle, '.png');
if exist(figLabel, 'file') == 0 || overwriteFig
    saveas(f, figLabel)
end

end