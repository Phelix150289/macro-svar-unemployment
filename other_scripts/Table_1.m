%% =========================================================================
%% Table_1.m
%% King & Morley (2007) Replication: Table 1
%% Title: Variance decompositions
%% Journal of Monetary Economics 54 (2007) p. 555
%% =========================================================================
fprintf('Computing Table 1: Structural Variance Decompositions...\n');

%% 1. Ingest Master Dataset and Estimate SVAR(8)
data_path = fullfile('datasets', 'km2007_master_data.csv');
opts = detectImportOptions(data_path);
master_tbl = readtable(data_path, opts);

% Endogenous vector: Delta x_t = [Delta y_t, Delta p_t, Delta u_t]'
Y_diff = [master_tbl.delta_y, master_tbl.delta_p, master_tbl.delta_u];
p   = 8;
N   = size(Y_diff, 2);
hor = 40;

% Reduced-form VAR estimation
[A_ols, Sigma_u] = olsvar(Y_diff, p);

% Blanchard-Quah structural identification
B = LR_restriction(A_ols, Sigma_u, p);

%% 2. Compute Structural Impulse Responses
% IRF_diff dimension: (N^2 x hor+1)
[IRF_diff, ~] = calculate_IRF_FEVD(A_ols, B, hor);

%% 3. Construct Variable Responses in Levels vs Rates
% Variable 1: Output level y (cumulative sum of Delta y)
% Variable 2: Inflation rate pi (non-accumulated Delta p)
% Variable 3: Unemployment level u (cumulative sum of Delta u)
Theta = zeros(N, N, hor + 1);

for s = 1:N
    row_y = 1 + (s - 1) * N;
    row_p = 2 + (s - 1) * N;
    row_u = 3 + (s - 1) * N;
    
    Theta(1, s, :) = cumsum(IRF_diff(row_y, :));
    Theta(2, s, :) = IRF_diff(row_p, :);
    Theta(3, s, :) = cumsum(IRF_diff(row_u, :));
end

%% 4. Compute Forecast Error Variance Decompositions (FEVD)
% FEVD(i, s, h+1): share of variable i's variance due to shock s at horizon h
FEVD_table = zeros(N, N, hor + 1);

for h_idx = 1:(hor + 1)
    for i_var = 1:N
        % Cumulative variance up to horizon h across all 3 shocks
        sq_resp = squeeze(Theta(i_var, :, 1:h_idx)).^2;
        if h_idx == 1
            cum_var_by_shock = sq_resp;
        else
            cum_var_by_shock = sum(sq_resp, 2)';
        end
        total_var = sum(cum_var_by_shock);
        FEVD_table(i_var, :, h_idx) = 100 * (cum_var_by_shock / total_var);
    end
end

%% 5. Compute Infinite Horizon Decomposition (h = infinity)
% Calculate long-run multiplier matrix C(1) = inv(I - sum(A_i)) * B
Companion = [A_ols(2:end, :)'; eye(N*(p-1)), zeros(N*(p-1), N)];
invC = eye(p*N) - Companion;
C_full = inv(invC);
C_LR = C_full(1:N, 1:N);
C1 = C_LR * B;

FEVD_inf = NaN(N, N);
for i_var = [1, 3] % Defined for non-stationary levels: y and u
    sq_C1 = (C1(i_var, :)).^2;
    FEVD_inf(i_var, :) = 100 * (sq_C1 / sum(sq_C1));
end

%% 6. Display Formatted Table Matching Published Layout
selected_horizons = [0, 4, 8, 20, 40];

fprintf('\n========================================================================================================\n');
fprintf('Table 1\n');
fprintf('Variance decompositions\n');
fprintf('========================================================================================================\n');
fprintf('                  Output                         Inflation                     Unemployment rate       \n');
fprintf('         --------------------------     --------------------------     --------------------------\n');
fprintf('Horizon  AS shock  AD shock  NRU shock  AS shock  AD shock  NRU shock  AS shock  AD shock  NRU shock\n');
fprintf('           (%%)       (%%)       (%%)        (%%)       (%%)       (%%)        (%%)       (%%)       (%%)   \n');
fprintf('--------------------------------------------------------------------------------------------------------\n');

for h = selected_horizons
    h_idx = h + 1;
    if h == 0
        h_str = '0 (shock qtr)';
    else
        h_str = sprintf('%2d', h);
    end
    
    fprintf('%-13s %4.0f      %4.0f      %4.0f       %4.0f      %4.0f      %4.0f       %4.0f      %4.0f      %4.0f\n', ...
            h_str, ...
            FEVD_table(1, 1, h_idx), FEVD_table(1, 2, h_idx), FEVD_table(1, 3, h_idx), ...
            FEVD_table(2, 1, h_idx), FEVD_table(2, 2, h_idx), FEVD_table(2, 3, h_idx), ...
            FEVD_table(3, 1, h_idx), FEVD_table(3, 2, h_idx), FEVD_table(3, 3, h_idx));
end

% Infinite horizon row
fprintf('%-13s %4.0f      %4.0f      %4.0f        ---       ---       ---       %4.0f      %4.0f      %4.0f\n', ...
        'Inf', ...
        FEVD_inf(1, 1), FEVD_inf(1, 2), FEVD_inf(1, 3), ...
        FEVD_inf(3, 1), FEVD_inf(3, 2), FEVD_inf(3, 3));
fprintf('========================================================================================================\n\n');

%% 7. Export Table to CSV
row_names = {'h0', 'h4', 'h8', 'h20', 'h40', 'hInf'}';
y_decomp  = [squeeze(FEVD_table(1, :, selected_horizons + 1))'; FEVD_inf(1, :)];
p_decomp  = [squeeze(FEVD_table(2, :, selected_horizons + 1))'; NaN(1, 3)];
u_decomp  = [squeeze(FEVD_table(3, :, selected_horizons + 1))'; FEVD_inf(3, :)];

tbl_out = table(row_names, ...
    round(y_decomp(:,1)), round(y_decomp(:,2)), round(y_decomp(:,3)), ...
    round(p_decomp(:,1)), round(p_decomp(:,2)), round(p_decomp(:,3)), ...
    round(u_decomp(:,1)), round(u_decomp(:,2)), round(u_decomp(:,3)), ...
    'VariableNames', {'Horizon', ...
    'Output_AS', 'Output_AD', 'Output_NRU', ...
    'Inflation_AS', 'Inflation_AD', 'Inflation_NRU', ...
    'Unemployment_AS', 'Unemployment_AD', 'Unemployment_NRU'});

export_path = fullfile('other_scripts', 'Table_1_Results.csv');
writetable(tbl_out, export_path);
fprintf('Table 1 successfully exported to %s.\n', export_path);