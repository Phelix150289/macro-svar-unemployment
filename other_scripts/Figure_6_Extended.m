%% =========================================================================
%% Figure_6_extended.m
%% King & Morley (2007) Wider Replication: Figure 6 Extended
%% Title: Inflation versus cyclical unemployment (Sample through 2010)
%% =========================================================================
fprintf('Generating Figure 6 Extended: Inflation versus cyclical unemployment...\n');
%% 1. Ingest Extended Dataset
data_path = fullfile('datasets', 'km2007_stage2_input_extended.csv');
if ~exist(data_path, 'file')
    data_path = 'km2007_stage2_input_extended.csv';
    if ~exist(data_path, 'file')
        error('File %s does not exist. Run setup_dataset_extended.m first.', data_path);
    end
end
opts = detectImportOptions(data_path);
df = readtable(data_path, opts);
%% 2. Extract Variables
x_raw = df.u_cyclical;
y_raw = df.delta_p * 4;
valid_idx = ~isnan(x_raw) & ~isnan(y_raw);
x = x_raw(valid_idx);
y = y_raw(valid_idx);
x = x(:);
y = y(:);
%% 3. Estimate Linear Phillips Curve Fit
X_mat = [ones(length(x), 1), x];
b = X_mat \ y;
x_line = linspace(min(x) - 0.2, max(x) + 0.2, 200)';
y_line = [ones(length(x_line), 1), x_line] * b;
%% 4. Render Canvas Matching Exact Published Style
fig = figure('Name', 'KM2007 Figure 6 Extended - Replication', 'Color', 'w', ...
    'Units', 'pixels', 'Position', [150, 150, 780, 520]);
ax = axes('Parent', fig);
hold(ax, 'on');
xlim(ax, [-4.2, 4.2]);
ylim(ax, [-5.0, 16.8]);
axis(ax, 'off');
%% 5. Draw Published Axis Spines
plot(ax, [-4, 4], [0, 0], 'k-', 'LineWidth', 0.9);
plot(ax, [0, 0], [-4, 16], 'k-', 'LineWidth', 0.9);
%% 6. Horizontal Axis Ticks and Labels
x_ticks = -4:1:4;
x_labels = {'-4%', '-3%', '-2%', '-1%', '0%', '1%', '2%', '3%', '4%'};
tick_len_y = 0.35;
for k = 1:length(x_ticks)
    xt = x_ticks(k);
    plot(ax, [xt, xt], [0, -tick_len_y], 'k-', 'LineWidth', 0.8);
    if xt ~= 0
        text(ax, xt, -0.9, x_labels{k}, 'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'top', 'FontSize', 10, 'FontName', 'Times New Roman');
    else
        text(ax, -0.08, -0.9, '0%', 'HorizontalAlignment', 'right', ...
            'VerticalAlignment', 'top', 'FontSize', 10, 'FontName', 'Times New Roman');
    end
end
%% 7. Vertical Axis Ticks and Labels
y_ticks = [-4, 4, 8, 12, 16];
y_labels = {'-4%', '4%', '8%', '12%', '16%'};
tick_len_x = 0.07;
for k = 1:length(y_ticks)
    yt = y_ticks(k);
    plot(ax, [0, -tick_len_x], [yt, yt], 'k-', 'LineWidth', 0.8);
    text(ax, -0.12, yt, y_labels{k}, 'HorizontalAlignment', 'right', ...
        'VerticalAlignment', 'middle', 'FontSize', 10, 'FontName', 'Times New Roman');
end
%% 8. Plot Empirical Data and Regression Line
scatter(ax, x, y, 22, 'k', 'filled', 'MarkerEdgeColor', 'k');
plot(ax, x_line, y_line, 'k-', 'LineWidth', 1.4);
%% 9. Published Title Annotations
text(ax, 0.20, 15.6, 'Inflation (CPI)', 'FontSize', 11, 'FontName', 'Times New Roman');
text(ax, -4.0, 0.9, 'Deviation from natural rate', 'FontSize', 11, 'FontName', 'Times New Roman');
hold(ax, 'off');
export_path = 'Figure_6_Extended.png';
saveas(fig, export_path);
fprintf('Figure 6 Extended successfully rendered and saved to %s.\n', export_path);