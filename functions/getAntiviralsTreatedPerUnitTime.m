function [antiviralsTreatedPropNow] = getAntiviralsTreatedPerUnitTime(t, antiviralData)
% Function that takes the timeseries vector of age-split testing
% probabilities and returns the current value
% INPUTS:
% - t: current time
% - date0: start of simulation, defined in getPar
% - tEnd: end of simulation, defined in getPar
% - dailyTreatedProp: timeseries age-split vector of proportion of daily 
%                     treated cases
% OUTPUTS:
% - antiviralsTreatedNow: current age-split vector of treated cases

antiviralsTreatedPropNow = interp1(antiviralData.dt_num, antiviralData.daily_treatcaseratio, t)';

