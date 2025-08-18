function plotEthnicityComparisonAgeSplit(t, bandsData, bestFitData, tData, realData, ...
    popByEth, popCountMatrix10, plotToDate, eth_names, scenario_names, scenario_pick, ...
    overwriteFig, perCapita, figDir)
% Function that plots a grid of plots (cases, hospital
% admissions, and deaths), which include a best fit
% line, confidence bands, real data, and vertical lines representing an
% intervention date for each 10year age band

% INPUTS:
% - filenameBands: "folder/filename.mat" for bands data
% - filenameBestFit: "folder/filename.mat" for best fit data
% - plotToDate: datetime variable specifying the upper limit for the horizontal (time) axis for the plots
% - dataComb: data for plotting, as output by getAllData.m
% - parsToFit: list of parameter names, as defined at the top of the main file
% - scenario_names: vector naming the different runs
% - overwriteFig: set to true to overwrite png plots in results

% OUTPUTS:
% - .png figures in results, if they don't already exist or if overwriteFig
%   set to true

% Set to 1 to plot best fit lines:
plotBestFit = 1;

% Use function here

% [t, bandsData, bestFitData, tData, realData] = ...
%     summariseScenarioRuns(filenameBands, filenameBestFit, dataComb);

nEthnicities = size(bandsData, 4);

% Trim down to one scenario only

layer_pick = scenario_pick == scenario_names; % layer needed
bandsData = reshape(bandsData(:, :, :, :, :, layer_pick), size(bandsData, [1 2 3 4 5]));
bestFitData = reshape(bestFitData(:, :, :, :, layer_pick), size(bestFitData, [1 2 3 4]));

% Now collapse by age for initial plots on left

bandsDataByEth = reshape(sum(bandsData, 3), size(bandsData, [1 2 4 5]));
bestFitDataByEth = reshape(sum(bestFitData, 2), size(bestFitData, [1 3 4]));
realDataByEth = reshape(sum(realData, 2), size(realData, [1 3])); % collapse over age groups


if perCapita == true

    % totals
    bandsDataByEth = 1e5 * bandsDataByEth ./ reshape(popByEth, 1, 1, numel(popByEth), 1);
    bestFitDataByEth = 1e5 * bestFitDataByEth ./ reshape(popByEth, 1, numel(popByEth), 1);
    realDataByEth(:, 3:end) = 1e5 * realDataByEth(:, 3:end) ./ repmat(popByEth, 1, 3);

    % age split
    bandsData = 1e5 * bandsData ./ ...
        reshape(popCountMatrix10, 1, 1, size(popCountMatrix10, 1), size(popCountMatrix10, 2), 1);
    bestFitData = 1e5 * bestFitData ./ ...
        reshape(popCountMatrix10, 1, size(popCountMatrix10, 1), size(popCountMatrix10, 2), 1);
    realData(:, :, 3:end) = 1e5 * realData(:, :, 3:end) ./ ...
        reshape(repmat(popCountMatrix10, 1, 3), 1, size(popCountMatrix10, 1), ...
        3*size(popCountMatrix10, 2));

    bestFitDataByEth(:, :, 6:7) = 1e-5 * bestFitDataByEth(:, :, 6:7);
    bestFitData(:, :, :, 6:7) = 1e-5 * bestFitData(:, :, :, 6:7);

else
    
    % Rescale for cumulative per capita exposure
    bestFitDataByEth(:, :, 6:7) = bestFitDataByEth(:, :, 6:7) ./ ...
        reshape(popByEth, 1, numel(popByEth), 1);
    bestFitData(:, :, :, 6:7) = bestFitData(:, :, :, 6:7) ./ ...
        reshape(popCountMatrix10, 1, size(popCountMatrix10, 1), size(popCountMatrix10, 2), 1);
end


% ------------------------------ PLOTS ------------------------------------

plotTitle = sprintf('Compare ethnicities age split (%s)', scenario_pick);
if perCapita
    subplotYaxis = {'infections per 100K', 'cases per 100K', 'adms per 100K', ...
    'deaths per 100K', 'inf per capita'};
else
subplotYaxis = {'daily infections', 'daily cases', 'daily admissions', ...
    'daily deaths', 'inf per capita'};
end

age_groups = {'0-9', '10-19', '20-29', '30-39', '40-49', '50-59', '60-69', '70+'};
smoothDays = [7, 14, 21, 14, 7];
tPlotRange = [datetime(2022, 1, 1), plotToDate+1];
layer_pick = [1 2 3 5 6]; % choosing correct metrics (not occupancy)

line_colours = parula(numel(eth_names)); % use colormap
shade_colours = line_colours;

f = figure;
set(f, 'WindowStyle', 'normal');
f.Position = [50 0 1800 700];
tiledlayout(5, 9);
sgtitle(plotTitle);



for i = 1:numel(subplotYaxis)
    for ag = 0:size(age_groups, 2)
        nexttile
        hold on
        if ag == 0
            title('all ages')
            for j = 1:nEthnicities
                if i < numel(subplotYaxis) % no bands for cumulative infections per capita
                    fill([t, fliplr(t)], [min(bandsDataByEth(:, :, j, layer_pick(i)),[], 2); ...
                        flipud(max(bandsDataByEth(:, :, j, layer_pick(i)),[], 2))], ...
                        '', 'FaceColor', shade_colours(j, :), 'FaceAlpha', 0.2, 'EdgeColor', 'none');
                end
                if plotBestFit == 1
                    plot(t, bestFitDataByEth(:, j, layer_pick(i)), 'Color', line_colours(j, :))
                    % On the final row of plots (cumulative infectoins),
                    % also plot the 7th 'layer' (which is total first infections
                    % plus reinfections) as dashed lines:
                    if i == numel(subplotYaxis)
                        plot(t, bestFitDataByEth(:, j, layer_pick(i)+1), '--', 'Color', line_colours(j, :));
                    end
                end

                % plotting real data

                if ismember(i, [2 3 4]) % not infections or cumulative infections per capita
                    if i == 2 % cases
                        first_col_pick = 2;
                    elseif i == 3 % admissions
                        first_col_pick = 6;
                    else % deaths
                        first_col_pick = 10;
                    end
                    plot(tData, realDataByEth(:, first_col_pick+j), '.', 'Color', line_colours(j, :));
                end

            end

        else
            title(age_groups(ag))
            for j = 1:nEthnicities
                if i < numel(subplotYaxis) % no bands for cumulative infections per capita
                    fill([t, fliplr(t)], [min(bandsData(:, :, ag, j, layer_pick(i)), [], 2); ...
                        flipud(max(bandsData(:, :, ag, j, layer_pick(i)), [], 2))], ...
                        '', 'FaceColor', shade_colours(j, :), 'FaceAlpha', 0.2, 'EdgeColor', 'none');
                end
                if plotBestFit == 1
                    plot(t, bestFitData(:, ag, j, layer_pick(i)), 'Color', line_colours(j, :));
                    % On the final row of plots (cumulative infectoins),
                    % also plot the 7th 'layer' (which is total first infections
                    % plus reinfections) as dashed lines:
                    if i == numel(subplotYaxis)
                        plot(t, bestFitData(:, ag, j, layer_pick(i)+1), '--', 'Color', line_colours(j, :));
                    end
                end

                % plotting real data

                if ismember(i, [2 3 4])
                    if i == 2 % cases
                        first_col_pick = 2;
                    elseif i == 3 % admissions
                        first_col_pick = 6;
                    else % deaths
                        first_col_pick = 10;
                    end
                    plot(tData, smoothdata(realData(:, ag, first_col_pick+j), ...
                        'movmean', smoothDays(i)), ':', 'Color', line_colours(j, :), ...
                        'LineWidth', 0.5);
                end
            end
        end

        hold off
        xlim(tPlotRange)
        ylabel(subplotYaxis(i))
        grid on
        grid minor

    end
end

legend_labels = strings(1, 2 * numel(eth_names));
legend_labels(2:2:end) = eth_names;
leg = legend(legend_labels, 'Interpreter', 'none');
leg.Layout.Tile = 'South';


% Save figure if it doesn't already exist or if overwrite flag is on
figLabel = append(figDir, plotTitle, '.png');
if exist(figLabel, 'file') == 0 || overwriteFig
    pause(0.1)
    saveas(f, figLabel)
end

end