%% =========================================================================
%% Figure_1.m
%% King & Morley (2007) Replication: Figure 1
%% Title: Impulse response functions for structural shocks
%% Journal of Monetary Economics 54 (2007) p. 554
%% =========================================================================
fprintf('Generating Figure 1: Structural Impulse Response Functions...\n');

%% 1. Ingest Master Dataset and Estimate SVAR(8)
data_path = fullfile('datasets', 'km2007_master_data.csv');
opts = detectImportOptions(data_path);
master_tbl = readtable(data_path, opts);

% Endogenous vector: \Delta x_t = [\Delta y_t, \Delta p_t, \Delta u_t]'
Y_diff = [master_tbl.delta_y, master_tbl.delta_p, master_tbl.delta_u];
p   = 8;
hor = 16;
N   = size(Y_diff, 2);

% Reduced-form VAR estimation
[A_ols, Sigma_u] = olsvar(Y_diff, p);

% Long-run structural identification
B = LR_restriction(A_ols, Sigma_u, p);

%% 2. Compute Structural Impulse Responses
[IRF_raw, ~] = calculate_IRF_FEVD(A_ols, B, hor);

%% 3. Form Levels and Quarterly Rates
% Variables: 1 = Output (y), 2 = Inflation (p), 3 = Unemployment (u)
% Shocks:    1 = AS Shock,   2 = AD Shock,     3 = NRU Shock
IRF_y = zeros(N, hor + 1);
IRF_p = zeros(N, hor + 1);
IRF_u = zeros(N, hor + 1);

for s = 1:N
    row_y = 1 + (s - 1) * N;
    row_p = 2 + (s - 1) * N;
    row_u = 3 + (s - 1) * N;
    
    % Output level: cumsum of delta_y, scaled to quarterly percent
    IRF_y(s, :) = cumsum(IRF_raw(row_y, :)) / 4;
    % Inflation: quarterly rate (unaccumulated), scaled to quarterly percent
    IRF_p(s, :) = IRF_raw(row_p, :) / 4;
    % Unemployment: level in percentage points
    IRF_u(s, :) = cumsum(IRF_raw(row_u, :));
end

%% 4. Render Figure (1 Column x 3 Rows)
fig1 = figure('Name', 'King & Morley (2007) - Figure 1', ...
              'Color', 'w', ...
              'Position', [200, 50, 680, 800]);

shock_titles = {'AS Shock', 'AD Shock', 'NRU Shock'};
horizon_axis = 0:hor;

for s = 1:N
    subplot(3, 1, s);
    hold on;
    
    % Zero reference line
    plot([0, hor], [0, 0], 'Color', [0.6 0.6 0.6], 'LineWidth', 0.8);
    
    % Output: solid thick black line
    h_y = plot(horizon_axis, IRF_y(s, :), 'k-', 'LineWidth', 2.6);
    
    % Unemployment: dashed thick line
    h_u = plot(horizon_axis, IRF_u(s, :), 'k--', 'LineWidth', 2.2);
    
    % Inflation: solid gray line
    h_p = plot(horizon_axis, IRF_p(s, :), '-', 'Color', [0.55 0.55 0.55], 'LineWidth', 2.0);
    
    % Formatting matching published paper
    xlim([0, hor]);
    ylim([-0.55, 0.55]);
    set(gca, 'YTick', -0.5:0.2:0.5, ...
             'YTickLabel', {'-0.5%', '-0.3%', '-0.1%', '0.1%', '0.3%', '0.5%'}, ...
             'XTick', 0:5:15, ...
             'FontSize', 10, ...
             'TickDir', 'out', ...
             'Box', 'off');
         
    title(shock_titles{s}, 'FontSize', 11, 'FontWeight', 'normal');
    xlabel('quarters after one standard deviation shock', 'FontSize', 10);
end

% Bottom Legend
h_leg = legend([h_y, h_u, h_p], {'Output', 'Unemployment', 'Inflation'}, ...
               'Orientation', 'horizontal', ...
               'Position', [0.18, 0.04, 0.68, 0.035], ...
               'FontSize', 10);
set(h_leg, 'Box', 'on', 'EdgeColor', 'k');

% Save output graphic
export_path = 'Figure_1_Replication.png';
saveas(fig1, export_path);
fprintf('Figure 1 successfully generated and saved to %s.\n', export_path);