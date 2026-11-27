%% =========================================================================
%% setup_dataset_extended.m
%% King & Morley (2007) Replication & Extension - Stage 1 Estimation Engine
%% Processes both Baseline (to 2001) and Extended (to 2010) Datasets
%% =========================================================================
clear; clc;
fprintf('------------------------------------------------------------------\n');
fprintf('Executing setup_dataset_extended.m: Stage 1 SVAR & Natural Rate\n');
fprintf('------------------------------------------------------------------\n');

%% Select Mode: 'narrow' (1948Q2-2001Q1) or 'extended' (1948Q2-2010Q1)
run_modes = {'narrow', 'extended'};

for m = 1:length(run_modes)
    mode = run_modes{m};
    
    if strcmp(mode, 'narrow')
        in_filename  = 'km2007_master_data.csv';
        out_filename = 'km2007_stage2_input.csv';
    else
        in_filename  = 'km2007_master_data_extended.csv';
        out_filename = 'km2007_stage2_input_extended.csv';
    end
    
    data_path = fullfile('datasets', in_filename);
    if ~exist(data_path, 'file')
        % Fallback if files are stored in current root directory
        data_path = in_filename;
        if ~exist(data_path, 'file')
            warning('Dataset %s not found. Skipping mode: %s.', in_filename, mode);
            continue;
        end
    end
    
    opts = detectImportOptions(data_path);
    master_tbl = readtable(data_path, opts);
    T_total = height(master_tbl);
    fprintf('\n>>> Running Mode: [%s] | Loaded %d observations from %s\n', upper(mode), T_total, in_filename);
    
    % Endogenous Difference System: \Delta x_t = [\Delta y_t, \Delta p_t, \Delta u_t]'
    Y_diff = [master_tbl.delta_y, master_tbl.delta_p, master_tbl.delta_u];
    unrate_level = master_tbl.unrate;
    p = 8; % 8 quarterly lags
    [T_obs, N] = size(Y_diff);
    
    %% 1. Beveridge-Nelson Decomposition
    BN_cycle = multivariate_BN_ols(Y_diff, p);
    u_cyclical = BN_cycle(:, 3);
    u_star     = unrate_level - u_cyclical;
    
    %% 2. Reduced-Form SVAR(8) Estimation
    [A_ols, Sigma_u, U_resid] = olsvar(Y_diff, p);
    T_eff = size(U_resid, 1);
    
    %% 3. Blanchard-Quah Identification
    C0 = LR_restriction(A_ols, Sigma_u, p);
    inv_C0 = inv(C0);
    structural_shocks = (inv_C0 * U_resid')';
    
    % Long-run multiplier matrix C(1)
    A_companion = A_ols(2:end, :)';
    sum_A = zeros(N, N);
    for i = 1:p
        sum_A = sum_A + A_companion(:, (i-1)*N+1 : i*N);
    end
    A1_sum = eye(N) - sum_A;
    C1 = inv(A1_sum) * C0;
    
    %% 4. Save Enriched Output Table
    master_tbl.u_star     = u_star;
    master_tbl.u_cyclical = u_cyclical;
    master_tbl.shock_supply = [nan(p, 1); structural_shocks(:, 1)];
    master_tbl.shock_demand = [nan(p, 1); structural_shocks(:, 2)];
    master_tbl.shock_labor  = [nan(p, 1); structural_shocks(:, 3)];
    
    if ~exist('datasets', 'dir')
        mkdir('datasets');
    end
    stage2_output_path = fullfile('datasets', out_filename);
    writetable(master_tbl, stage2_output_path);
    fprintf('Saved Stage 2 dataset to: %s\n', stage2_output_path);
    
    %% 5. Display Diagnostics
    fprintf('Natural Rate Summary (%s):\n', mode);
    disp(table(mean(u_star), std(u_star), min(u_star), max(u_star), ...
        'VariableNames', {'Mean', 'StdDev', 'Min', 'Max'}));
end
fprintf('------------------------------------------------------------------\n');