%% =========================================================================
%% Figure_4_Extended.m
%% King & Morley (2007) Replication & Extension: Figure 4
%% Title: Impulse response functions for structural shocks (1950-2001 vs 1950-2010)
%% =========================================================================
fprintf('Generating Figure 4 Comparison: Narrow (to 2001) vs Extended (to 2010)...\n');
%% 1. Ingest Both Master Datasets
p = 8;
hor = 16;
% Baseline (to 2001)
path_base = fullfile('datasets', 'km2007_master_data.csv');
tbl_base  = readtable(path_base);
Y_base    = [tbl_base.delta_y, tbl_base.delta_p, tbl_base.delta_u];
% Extended (to 2010)
path_ext  = fullfile('datasets', 'km2007_master_data_extended.csv');
tbl_ext   = readtable(path_ext);
Y_ext     = [tbl_ext.delta_y, tbl_ext.delta_p, tbl_ext.delta_u];
%% 2. Estimate and Compute IRFs for Both Horizons
[IRF_y_base, IRF_p_base, IRF_u_base] = compute_structural_irfs(Y_base, p, hor);
[IRF_y_ext,  IRF_p_ext,  IRF_u_ext]  = compute_structural_irfs(Y_ext,  p, hor);
%% 3. Render 3x2 Comparative Canvas
fig4_comp = figure('Name', 'King & Morley (2007) - Figure 4 (Sample Comparison)', ...
                   'Color', 'w', ...
                   'Position', [150, 50, 1100, 850]);
shock_titles = {'AS Shock', 'AD Shock', 'NRU Shock'};
horizon_axis = 0:hor;
for s = 1:3
    % ----------------------------------------------------
    % Left Column: Baseline Subsample (1948Q2 - 2001Q1)
    % ----------------------------------------------------
    subplot(3, 2, (s - 1) * 2 + 1);
    hold on;
    plot([0, hor], [0, 0], 'Color', [0.6 0.6 0.6], 'LineWidth', 0.8);
    h_y = plot(horizon_axis, IRF_y_base(s, :), 'k-', 'LineWidth', 2.4);
    h_u = plot(horizon_axis, IRF_u_base(s, :), 'k--', 'LineWidth', 2.0);
    h_p = plot(horizon_axis, IRF_p_base(s, :), '-', 'Color', [0.55 0.55 0.55], 'LineWidth', 2.0);
    xlim([0, hor]);
    ylim([-0.55, 0.55]);
    set(gca, 'YTick', -0.5:0.2:0.5, ...
             'YTickLabel', {'-0.5%', '-0.3%', '-0.1%', '0.1%', '0.3%', '0.5%'}, ...
             'XTick', 0:5:15, 'FontSize', 9, 'TickDir', 'out', 'Box', 'off');
    title(sprintf('%s (Sample to 2001)', shock_titles{s}), 'FontSize', 10, 'FontWeight', 'bold');
    if s == 3
        xlabel('quarters after shock', 'FontSize', 10);
    end
    
    % ----------------------------------------------------
    % Right Column: Extended Subsample (1948Q2 - 2010Q1)
    % ----------------------------------------------------
    subplot(3, 2, (s - 1) * 2 + 2);
    hold on;
    plot([0, hor], [0, 0], 'Color', [0.6 0.6 0.6], 'LineWidth', 0.8);
    plot(horizon_axis, IRF_y_ext(s, :), 'k-', 'LineWidth', 2.4);
    plot(horizon_axis, IRF_u_ext(s, :), 'k--', 'LineWidth', 2.0);
    plot(horizon_axis, IRF_p_ext(s, :), '-', 'Color', [0.55 0.55 0.55], 'LineWidth', 2.0);
    xlim([0, hor]);
    ylim([-0.55, 0.55]);
    set(gca, 'YTick', -0.5:0.2:0.5, ...
             'YTickLabel', {'-0.5%', '-0.3%', '-0.1%', '0.1%', '0.3%', '0.5%'}, ...
             'XTick', 0:5:15, 'FontSize', 9, 'TickDir', 'out', 'Box', 'off');
    title(sprintf('%s (Sample to 2010)', shock_titles{s}), 'FontSize', 10, 'FontWeight', 'bold');
    if s == 3
        xlabel('quarters after shock', 'FontSize', 10);
    end
end
% Shared Bottom Legend
h_leg = legend([h_y, h_u, h_p], {'Output', 'Unemployment', 'Inflation'}, ...
               'Orientation', 'horizontal', ...
               'Position', [0.32, 0.02, 0.40, 0.03], ...
               'FontSize', 10);
set(h_leg, 'Box', 'on', 'EdgeColor', 'k');
saveas(fig4_comp, 'Figure_4_Comparison_2001_vs_2010.png');
fprintf('Figure 4 comparative evaluation saved.\n');
%% Helper Function: SVAR Identification and IRF Mapping
function [IRF_y, IRF_p, IRF_u] = compute_structural_irfs(Y_diff, p, hor)
    N = size(Y_diff, 2);
    [A_ols, Sigma_u] = olsvar(Y_diff, p);
    B = LR_restriction(A_ols, Sigma_u, p);
    [IRF_raw, ~] = calculate_IRF_FEVD(A_ols, B, hor);
    
    IRF_y = zeros(N, hor + 1);
    IRF_p = zeros(N, hor + 1);
    IRF_u = zeros(N, hor + 1);
    
    for s = 1:N
        row_y = 1 + (s - 1) * N;
        row_p = 2 + (s - 1) * N;
        row_u = 3 + (s - 1) * N;
        
        IRF_y(s, :) = cumsum(IRF_raw(row_y, :)) / 4;
        IRF_p(s, :) = IRF_raw(row_p, :) / 4;
        IRF_u(s, :) = cumsum(IRF_raw(row_u, :));
    end
end