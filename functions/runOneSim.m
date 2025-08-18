function  epiVarsCompact = runOneSim(t, parBase, Theta, odeOptions )

% Function to run one model simulation with a specified parameter set
% (defined in the usual way by a table of [0,1] variables Theta, which
% should consist of a single row)
%
% Inputs:
% t is the vector of time points at which to return the model solution
% parBase shoudl be a structure containing the base parameters
% Theta - table with a single row of values in [0,1] and variable names
% corresponding to the fitted parameters
% odeOptions - options for the ODE solver
%
% Outputs:
% epiVarsCompact - structure with several Nt x Ng arrays for various model
% variables, where Nt is the number of time points and Ng is the number of
% groups (age x ethnicity)



% Get parameter structure for the specified value of Theta
parInd = getParUnified(Theta, parBase);

% Concatenate with parBase to get a unified parameter sturcture
parTemp = catstruct(parBase, parInd);

% Initial condition
IC = getIC(parTemp);

% Solve ODEs
[~, Y] = ode45(@(t, y) myODEs2(t, y, parTemp), t, IC, odeOptions);

% Retain a compact structure of variables rather than the full Y
epiVarsCompact= extractEpiVarsCompact(t, Y, parTemp);

