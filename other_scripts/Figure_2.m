%% =========================================================================
%% Figure_2.m
%% King and Morley (2007) Replication: Figure 2
%% Title: The Natural Rate of Unemployment and the Actual Unemployment Rate
%% Sample: 1948:Q2 to 2001:Q1 (T = 212 quarters)
%% =========================================================================
fprintf('Generating Figure 2: Natural Rate vs. Actual Unemployment...\n');

%% 1. Ingest Stage 2 Master Input Data
data_path = fullfile('datasets', 'km2007_stage2_input.csv');
if ~exist(data_path, 'file')
    error('File not found: %s. Run setup_dataset.m first.', data_path);
end

opts = detectImportOptions(data_path);
stage2_tbl = readtable(data_path, opts);

unrate_actual = stage2_tbl.unrate;
unrate_star   = stage2_tbl.u_star;
T_sample      = height(stage2_tbl);

assert(T_sample == 212, 'Expected 212 observations (1948:Q2 - 2001:Q1).');

%% 2. Define Time Axis and Series Matrix
% Quarterly grid: 1948:Q2 = 1948.25 to 2001:Q1 = 2001.00
time_axis = (1948.25 : 0.25 : 2001.0)';
y_data    = [unrate_actual, unrate_star];

%% 3. Plot Configuration
% Line 1 (Actual): Dashed black line ('--'), width 1.2, color 'k'
% Line 2 (Natural Rate): Solid blue line ('-'), width 2.0, color 'b'
LS = {'--', '-'};
LW = [1.2, 2.0];
LC = {'k', 'b'};

fig2 = figure('Name', 'King and Morley (2007) - Figure 2', ...
              'Color', 'w', ...
              'Position', [100, 100, 1000, 480]);

%% 4. Execute NBERbc
fh = NBERbc(time_axis, y_data, LS, LW, LC);

%% 5. Formatting & Annotations
title('Figure 2: The Natural Rate of Unemployment and the Actual Unemployment Rate', ...
      'FontSize', 12, 'FontWeight', 'bold');
xlabel('Quarter', 'FontSize', 11);
ylabel('Percent', 'FontSize', 11);

legend(fh, ...
       {'Actual Unemployment Rate (u_t)', ...
        'Natural Rate of Unemployment (u_t^*)'}, ...
       'Location', 'northwest', ...
       'FontSize', 10);

xlim([1948.25, 2001.0]);
ylim([1.0, 11.5]);

set(gca, 'Box', 'on', ...
         'FontSize', 10, ...
         'TickDir', 'out', ...
         'XMinorTick', 'on', ...
         'YMinorTick', 'on', ...
         'Layer', 'top');
grid on;

%% 6. Save Figure to Disk
export_filename = 'Figure_2_Replication.png';
saveas(fig2, export_filename);
fprintf('Figure 2 successfully rendered and saved to %s.\n', export_filename);