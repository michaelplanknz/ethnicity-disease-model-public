function tblOut = removePrefix(tbl)

% Function to remove prefixes "foo_" from the variable names of an input
% table 'tbl'
% Returns an table 'tblOut' with identical content but new variable names
% This is useful to modify the output of varfun
% e.g. varfun(@mean, tbl) returns a table whose variable names all have the
% prefix "mean_", calling removePrefix will remove these prefixes returning
% a table with the same variable names as the original

% Extract string array of the table's variable names
s = string(tbl.Properties.VariableNames);

% Split s at "_"
s_split = split(s, "_");

% Retain only last portion of each name (after the final "_")
sNew = s_split(:, :, end);

% Copy tbl to tblOut
tblOut = tbl;

% Set the variable names of tblOut
tblOut.Properties.VariableNames = sNew;

