function [dates, doses1, doses2, doses3, doses4plus] = ...
    getVaccineData(myDataPath, vaxDataFname, vaccImmDelay, date0, tEnd)
% Function that reads in vaccination data and projections (if used), and
% outputs arrays of cumulative doses for each age group, shifted by a 
% delay to account for the time it takes for the vaccine to increase 
% immunity, and cropped to match simulation's time array. 
% If projection not used, a flat tail will be added at the end of
% available data.
% INPUTS:
% - myDataPath: path to folder where vaccination data is stored
% - vaxDataFname: filename of vaccination data
% - vaccImmDelay: number of days after which vax dose is assumed to take
%                 effect (as defined in getBasePar.m)
% - date0: datenum corresponding to simulation start date (as defined in
%          getBasePar.m)
% - tEnd: number of simulated days (as defined in getBasePar.m)
% OUTPUTS:
% - dates: array of datenum dates corresponding to delayed vax doses
% - doses1-4plus: arrays of cumulative doses for each shifted date

fName = myDataPath + vaxDataFname;
vaxData = readtable(fName);

% Create appropriate arrays for outputting
dates = datenum(vaxData.dates)';
doses1 = table2array(vaxData(:, 2:17));
doses2 = table2array(vaxData(:, 18:33));
doses3 = table2array(vaxData(:, 34:49));
doses4plus = table2array(vaxData(:, 50:65));


% Shift vaccination dates to allow for delay in taking effect
dates = dates + vaccImmDelay;     

% Find index of vax data line that corresponds to first day of simulation
iDate = find(datenum(dates) == date0);

% Find out how many more (or less) dates there are in the vax data compared
% to the simulations's time array
nPad = tEnd - (length(dates) - iDate);
if nPad > 0
    % If the simulation has more dates than the vax data, add a flat tail
    % at the end of the vax data
    dates = [dates, dates(end)+1:dates(end)+nPad];
    doses1 = [doses1(1:end, :); repmat(doses1(end, :), nPad, 1)];
    doses2 = [doses2(1:end, :); repmat(doses2(end, :), nPad, 1)];
    doses3 = [doses3(1:end, :); repmat(doses3(end, :), nPad, 1)];
    doses4plus = [doses4plus(1:end, :); repmat(doses4plus(end, :), nPad, 1)];
elseif nPad < 0
    % If the simulation has less dates than the vax data, cut vaccination
    % data down to match
    dates = dates(1:end+nPad);
    doses1 = doses1(1:end+nPad, :);
    doses2 = doses2(1:end+nPad, :);
    doses3 = doses3(1:end+nPad, :);
    doses4plus = doses4plus(1:end+nPad, :);
end

% Crop out excess dates from beginning of vax data, if any
dates = dates(iDate:end);
doses1 = doses1(iDate:end, :);
doses2 = doses2(iDate:end, :);
doses3 = doses3(iDate:end, :);
doses4plus = doses4plus(iDate:end, :);




end


