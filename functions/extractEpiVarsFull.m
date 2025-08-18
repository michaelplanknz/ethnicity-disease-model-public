function [ N, V, S, E, I, A, R, C0, C1, C2, C3, Cr, H0, H1, H2, H3, Hr, F0, F1, F2, F3, Fr] = extractEpiVarsFull(y, par)

% Take a column vector representing the ODE state at a single time point
% and restructure as a set of matrices representing epidemiological
% variables
% Each matrix has 16 rows representing 16 age groups
% or for the four-ethnicity model, 64=16x4 rows representing age-ethnicity
% combinations ordered as follows
% [age_1 eth_1, age_2 eth_1, ... , age_15 eth_4, age_16 eth 4].
%
% Infection states (S, E, I, A, R) have 14 columns corresponding to the 14
% susceptible compartments
% N is a single column (total population size in each age group)
% V has three columns for number of people with at least 1, 2, 3 doses
% Ci, Hi and Fi have a specified number of columns corresponding to the number
% of unobserved+observed states for each of cases, hospitalisations and
% fatalities



% Go through the elements of y block by block and assign them to the
% relevant variables

% In the following, the *comments* assume there are 16x4 = 64 age-ethncity
% combinations

% iCount is an index variable representing the next element of y to be
% assigned
% For each variable to be assigned, nC is the number of elements of y that
% belong to it
iCount = 1;


% Total pop size N: (64 x 1 vector)
nC = par.nAgeGroups * par.nEthnicities;
N = reshape( y(iCount : iCount+nC-1), par.nAgeGroups * par.nEthnicities, 1);

% Number of people V with at least 1, 2 or 3 doses: 64 x 3 matrix
iCount = iCount+nC;    
nC = par.nAgeGroups * par.nEthnicities * par.nVaxComp;
V = reshape( y( iCount : iCount+nC-1 ), par.nAgeGroups * par.nEthnicities, par.nVaxComp);      % column j is the number in each age group who have had at least j doses

% Variables S, E, I and A are all 64 x 14 matrices, where 14 is the number of susceptibility levels:
iCount = iCount+nC;
nC = par.nAgeGroups * par.nEthnicities * par.nSusComp;
S = reshape( y(        iCount : iCount+nC-1), par.nAgeGroups * par.nEthnicities, par.nSusComp);

iCount = iCount+nC;
E = reshape( y(  iCount : iCount+nC-1), par.nAgeGroups * par.nEthnicities, par.nSusComp);

iCount = iCount+nC;
I = reshape( y( iCount : iCount+nC-1), par.nAgeGroups * par.nEthnicities, par.nSusComp);

iCount = iCount+nC;
A = reshape( y( iCount : iCount+nC-1), par.nAgeGroups * par.nEthnicities, par.nSusComp);

% The rcovered compartment that is stored in y (Rpart) is a 64 x 13 matrix,
% because the 14th column of R is inferred from the fact that all the epi
% compartments must sum to pop size N:
iCount = iCount+nC;
nC = par.nAgeGroups * par.nEthnicities * (par.nSusComp-1);
Rpart = reshape( y( iCount : iCount+nC-1), par.nAgeGroups * par.nEthnicities, par.nSusComp-1);
R = [Rpart, max(0, N - sum(S+E+I+A, 2) - sum(Rpart, 2) )];


% Case compartments Ck are each 64 x nCasesComp, where nCasesComp is the
% number of compartments in the progression of case status (from "case to
% be" to reported cases)
% C0, C1, C2, C3, Cr respectively represent individuals who were infected from one of
% the susceptible compartments with 0, 1, 2, or 3 doses, or from one of the
% previously infected compartments
iCount = iCount+nC;
nC = par.nAgeGroups * par.nEthnicities * par.nCaseComp;
C0 = reshape( y( iCount : iCount+nC-1 ), par.nAgeGroups * par.nEthnicities, par.nCaseComp);
iCount = iCount+nC;
C1 = reshape( y( iCount : iCount+nC-1 ), par.nAgeGroups * par.nEthnicities, par.nCaseComp);
iCount = iCount+nC;
C2 = reshape( y( iCount : iCount+nC-1 ), par.nAgeGroups * par.nEthnicities, par.nCaseComp);
iCount = iCount+nC;
C3 = reshape( y( iCount : iCount+nC-1 ), par.nAgeGroups * par.nEthnicities, par.nCaseComp);
iCount = iCount+nC;
Cr = reshape( y( iCount : iCount+nC-1 ), par.nAgeGroups * par.nEthnicities, par.nCaseComp);


% Similar for hospitalisations (with nHospComp compartments from "hospitalisaiton to be" through to
% admitted and then discharged)
iCount = iCount+nC;
nC = par.nAgeGroups * par.nEthnicities * par.nHospComp;
H0 = reshape( y( iCount : iCount+nC-1 ), par.nAgeGroups * par.nEthnicities, par.nHospComp);
iCount = iCount+nC;
H1 = reshape( y( iCount : iCount+nC-1 ), par.nAgeGroups * par.nEthnicities, par.nHospComp);
iCount = iCount+nC;
H2 = reshape( y( iCount : iCount+nC-1 ), par.nAgeGroups * par.nEthnicities, par.nHospComp);
iCount = iCount+nC;
H3 = reshape( y( iCount : iCount+nC-1 ), par.nAgeGroups * par.nEthnicities, par.nHospComp);
iCount = iCount+nC;
Hr = reshape( y( iCount : iCount+nC-1 ), par.nAgeGroups * par.nEthnicities, par.nHospComp);


% Similar for deaths (with nDeathComp compartments from "death to be" through to
% died
iCount = iCount+nC;
nC = par.nAgeGroups * par.nEthnicities * par.nDeathComp;
F0 = reshape( y( iCount : iCount+nC-1 ), par.nAgeGroups * par.nEthnicities, par.nDeathComp);
iCount = iCount+nC;
F1 = reshape( y( iCount : iCount+nC-1 ), par.nAgeGroups * par.nEthnicities, par.nDeathComp);
iCount = iCount+nC;
F2 = reshape( y( iCount : iCount+nC-1 ), par.nAgeGroups * par.nEthnicities, par.nDeathComp);
iCount = iCount+nC;
F3 = reshape( y( iCount : iCount+nC-1 ), par.nAgeGroups * par.nEthnicities, par.nDeathComp);
iCount = iCount+nC;
Fr = reshape( y( iCount : iCount+nC-1 ), par.nAgeGroups * par.nEthnicities, par.nDeathComp);

% Check all elements of y have been used
if iCount+nC-1 ~= length(y)
    error(sprintf('In extractEpiVarsFull: only %i/%i elements of y used', iCount+nC-1, length(y)))
end



