%% Baseline Regression (1948Q2 to 2001Q1)
t_base = readtable('datasets/km2007_stage2_input.csv');
y_base = t_base.delta_p * 4;       % Annualized CPI inflation
x_base = t_base.u_cyclical;        % Cyclical unemployment gap (u_t - u_t*)
mdl_base = fitlm(x_base, y_base);
disp('================ BASELINE (to 2001) ================')
disp(mdl_base)

%% Extended Regression (1948Q2 to 2010Q1)
t_ext = readtable('datasets/km2007_stage2_input_extended.csv');
y_ext = t_ext.delta_p * 4;         % Annualized CPI inflation
x_ext = t_ext.u_cyclical;          % Cyclical unemployment gap (u_t - u_t*)
mdl_ext = fitlm(x_ext, y_ext);
disp('================ EXTENDED (to 2010) ================')
disp(mdl_ext)