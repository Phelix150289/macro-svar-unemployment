%% =========================================================================
%% Figure_3.m
%% King & Morley (2007) Replication: Figure 3
%% Title: Inflation versus cyclical unemployment
%% Journal of Monetary Economics 54 (2007), p. 561
%% =========================================================================
fprintf('Generating Figure 3: Inflation versus cyclical unemployment...\n');

%% 1. Ingest Dataset
data_path = fullfile('datasets', 'km2007_stage2_input.csv');
if ~exist(data_path, 'file')
    error('File %s does not exist. Run Stage 1 extraction first.', data_path);
end
opts = detectImportOptions(data_path);
df = readtable(data_path, opts);

%% 2. Extract and Scale Variables
% Horizontal Axis: Cyclical unemployment gap (u_t - u_t^*)
x_raw = df.u_cyclical;
% Vertical Axis: Annualized CPI inflation rate (4 * delta_p)
y_raw = df.delta_p * 4;

valid_idx = ~isnan(x_raw) & ~isnan(y_raw);
x = x_raw(valid_idx);
y = y_raw(valid_idx);

%% 3. Estimate Linear Phillips Curve Fit
X_mat = [ones(length(x), 1), x];
b = (X_mat' * X_mat) \ (X_mat' * y);
x_line = linspace(-2.8, 2.2, 200)';
y_line = [ones(length(x_line), 1), x_line] * b;

%% 4. Render Canvas Matching Exact Published Style
fig3 = figure('Name', 'KM2007 Figure 3 - Replication', 'Color', 'w', ...
              'Units', 'pixels', 'Position', [150, 150, 780, 520]);
ax = axes('Parent', fig3);
hold(ax, 'on');

% Set coordinate limits with extra padding so edge ticks/labels never clip
xlim(ax, [-4.2, 3.4]);
ylim(ax, [-5.0, 16.8]);
axis(ax, 'off'); % Disable default axes; render exact publishing spines

%% 5. Draw Published Axis Spines
% Horizontal axis along y = 0 from -4 to 3
plot(ax, [-4, 3], [0, 0], 'k-', 'LineWidth', 0.9);
% Vertical axis along x = 0 from -4 to 16
plot(ax, [0, 0], [-4, 16], 'k-', 'LineWidth', 0.9);

%% 6. Render Horizontal Axis Ticks and Labels
x_ticks = -4:1:3;
x_labels = {'-4%', '-3%', '-2%', '-1%', '0%', '1%', '2%', '3%'};
tick_len_y = 0.35;
for k = 1:length(x_ticks)
    xt = x_ticks(k);
    % Downward tick mark
    plot(ax, [xt, xt], [0, -tick_len_y], 'k-', 'LineWidth', 0.8);
    % Tick label
    if xt ~= 0
        text(ax, xt, -0.9, x_labels{k}, 'HorizontalAlignment', 'center', ...
             'VerticalAlignment', 'top', 'FontSize', 10, 'FontName', 'Times New Roman');
    else
        % Label at origin positioned slightly offset to the left
        text(ax, -0.08, -0.9, '0%', 'HorizontalAlignment', 'right', ...
             'VerticalAlignment', 'top', 'FontSize', 10, 'FontName', 'Times New Roman');
    end
end

%% 7. Render Vertical Axis Ticks and Labels
y_ticks = [-4, 4, 8, 12, 16];
y_labels = {'-4%', '4%', '8%', '12%', '16%'};
tick_len_x = 0.07;
for k = 1:length(y_ticks)
    yt = y_ticks(k);
    % Leftward tick mark on the vertical spine
    plot(ax, [0, -tick_len_x], [yt, yt], 'k-', 'LineWidth', 0.8);
    % Label placed strictly to the left of the vertical spine
    text(ax, -0.12, yt, y_labels{k}, 'HorizontalAlignment', 'right', ...
         'VerticalAlignment', 'middle', 'FontSize', 10, 'FontName', 'Times New Roman');
end

%% 8. Plot Empirical Data and Regression Line
% Scatter points
scatter(ax, x, y, 22, 'k', 'filled', 'MarkerEdgeColor', 'k');
% OLS Regression Line
plot(ax, x_line, y_line, 'k-', 'LineWidth', 1.4);

%% 9. Published Title Annotations
text(ax, 0.20, 15.6, 'Inflation (CPI)', 'FontSize', 11, 'FontName', 'Times New Roman');
text(ax, -4.0, 0.9, 'Deviation from natural rate', 'FontSize', 11, 'FontName', 'Times New Roman');
hold(ax, 'off');

%% 10. Export High-Resolution Artifact
export_filename = 'Figure_3_Replication.png';
saveas(fig3, export_filename);
fprintf('Figure 3 successfully rendered and saved to %s.\n', export_filename);