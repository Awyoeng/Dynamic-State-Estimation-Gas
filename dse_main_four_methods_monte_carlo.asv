 function dse_main_four_methods_monte_carlo()
% DSE_MAIN_FOUR_METHODS - Four-method EKF comparison test
% Methods:
%   1. Standard EKF (baseline)
%   2. Chen Robust EKF (innovation covariance adaptation)
%   3. EKF-LE (detector feedback + leak estimation)
%   4. AFEKF (Adaptive Fading Extended Kalman Filter) - YOUR METHOD
%
% Test Cases:
%   Case 1: Clean data (no outliers, no leaks)
%   Case 2: Sparse outliers (6h-12h, 10dB/20dB)
%   Case 3: Outliers (6h-12h) + Leak (12h-18h)
%   Case 4: Pure leak (12h-24h)

clc; clear; close all;
%rng(42)
% System parameters
Sys.c = 340;
Sys.c2 = 340^2;
Sys.dt = 600;
Sys.Hours = 24;
%Monte=100;
% Load network data
[Nodes, Pipes, Compressors, GTU] = dse_1_load_data('gas_data.xlsx');

fprintf('\n========================================================\n');
fprintf('   Four-Method EKF Comparison Test (with AFEKF)\n');
fprintf('========================================================\n');
fprintf('Methods:\n');
fprintf('  1. Standard EKF (baseline)\n');
fprintf('  2. Chen Robust EKF (innovation covariance)\n');
fprintf('  3. EKF-LE (detector feedback)\n');
fprintf('  4. AFEKF (adaptive fading + robust statistics)\n');
fprintf('--------------------------------------------------------\n');
fprintf('Cases:\n');
fprintf('  Case 1: Clean data\n');
fprintf('  Case 2: Sparse outliers (6h-12h)\n');
fprintf('  Case 3: Outliers + Leak\n');
fprintf('  Case 4: Pure leak\n');
fprintf('========================================================\n\n');

% =========================================================================
% CASE 1: Clean data
% =========================================================================
fprintf('CASE 1: Clean data (no outliers, no leaks)\n');
fprintf('--------------------------------------------------------\n');
%c1_normal_pipe5=zeros(Monte,1);
%c1_normal_pipe1=zeros(Monte,1);
%c1_Chen_pipe5=zeros(Monte,1);
%c1_Chen_pipe1=zeros(Monte,1);
%c1_Adaptive_pipe5=zeros(Monte,1);
%c1_Adaptive_pipe1=zeros(Monte,1);
%c1_AKFEF_pipe5=zeros(Monte,1);
%c1_AKFEF_pipe1=zeros(Monte,1);
%for iter=1:Monte
    Leaks_empty = table([],[],[],[],[],...
        'VariableNames',{'PipeID','StartTime_s','EndTime_s','LeakRate_kg_s','Position'});
    
    [H_True_c1, Z_clean, t, ~, P_GTU] = ...
        dse_3_gen_data_leak(Nodes, Pipes, Compressors, Sys, Leaks_empty, GTU);
    
    [H_Normal_c1, H_Chen_c1, H_Adaptive_c1, H_AFEKF_c1, Stats_c1, ~, Diag_c1] = ...
        run_four_methods(Z_clean, H_True_c1, Nodes, Pipes, Compressors, Sys, t, GTU, true, [], []);
    
    %plot_case1_four(H_True_c1, Z_clean, H_Normal_c1, H_Chen_c1, H_Adaptive_c1, H_AFEKF_c1, ...
    %    Nodes, Pipes, Sys, t, GTU);
 %   c1_normal_pipe5(iter)=Stats_c1.Normal.Pipe5_RMSE;
 %   c1_normal_pipe1(iter)=Stats_c1.Normal.Pipe1_RMSE;
 %   c1_Chen_pipe5(iter)=Stats_c1.Chen.Pipe5_RMSE;
 %   c1_Chen_pipe1(iter)=Stats_c1.Chen.Pipe1_RMSE;
 %   c1_Adaptive_pipe5(iter)=Stats_c1.Adaptive.Pipe5_RMSE;
 %   c1_Adaptive_pipe1(iter)=Stats_c1.Adaptive.Pipe1_RMSE;
 %   c1_AKFEF_pipe5(iter)=Stats_c1.Adaptive.Pipe5_RMSE;
 %   c1_AKFEF_pipe1(iter)=Stats_c1.Adaptive.Pipe1_RMSE;
%end
%Stats_c1_all.

save_case_results_four('Case1_Clean', Stats_c1);

% =========================================================================
% CASE 2: Sparse outlier injection
% =========================================================================
fprintf('\nCASE 2: Sparse outliers (sensor faults)\n');
fprintf('Timeline: 0-6h normal | 6h-12h outliers | 12h-24h normal\n');
fprintf('--------------------------------------------------------\n');

N = length(t);
nN = height(Nodes);

outlier_config.start_step = round(N * 0.25);
outlier_config.end_step = round(N * 0.5);
outlier_config.target_nodes = [2, 3, 4, 5, 6, 7, 8, 9, 10];
outlier_config.target_pipes = [1, 2, 3, 4, 6, 7, 8, 9, 10];
outlier_config.outliers_per_hour = 2;
outlier_config.nN = nN;

fprintf('\n--- Test 1: 10dB sparse outliers ---\n');
[Z_outlier_10, outlier_info_10] = inject_outlier_sparse(Z_clean, outlier_config, Sys, 10);
[H_Normal_c2_10, H_Chen_c2_10, H_Adaptive_c2_10, H_AFEKF_c2_10, Stats_c2_10, ~, Diag_c2_10] = ...
    run_four_methods(Z_outlier_10, H_True_c1, Nodes, Pipes, Compressors, Sys, t, GTU, true, [6, 12], outlier_info_10);

fprintf('\n--- Test 2: 20dB sparse outliers ---\n');
[Z_outlier_20, outlier_info_20] = inject_outlier_sparse(Z_clean, outlier_config, Sys, 20);
[H_Normal_c2_20, H_Chen_c2_20, H_Adaptive_c2_20, H_AFEKF_c2_20, Stats_c2_20, ~, Diag_c2_20] = ...
    run_four_methods(Z_outlier_20, H_True_c1, Nodes, Pipes, Compressors, Sys, t, GTU, true, [6, 12], outlier_info_20);

%plot_case2_four(H_True_c1, Z_outlier_10, H_Normal_c2_10, H_Chen_c2_10, H_Adaptive_c2_10, H_AFEKF_c2_10, ...
%    Nodes, Pipes, Sys, t, GTU, outlier_config, outlier_info_10);

save_case2_results_four('Case2_Outlier', Stats_c2_10, Stats_c2_20);

% =========================================================================
% CASE 3: Outliers + Leak
% =========================================================================
fprintf('\nCASE 3: Outliers + Leak\n');
fprintf('Timeline: 0-6h normal | 6h-12h outliers | 12h-18h leak | 18h-24h normal\n');
fprintf('--------------------------------------------------------\n');

Leaks_c3 = dse_load_leak('leak.xlsx');
if height(Leaks_c3) > 0
    Leaks_c3.StartTime_s(1) = 12 * 3600;
    Leaks_c3.EndTime_s(1) = 18 * 3600;
    fprintf('Leak config: 12h-18h, rate %.1f kg/s\n', Leaks_c3.LeakRate_kg_s(1));
end

[H_True_c3, Z_leak_clean_c3, t, Leak_True_c3, P_GTU] = ...
    dse_3_gen_data_leak(Nodes, Pipes, Compressors, Sys, Leaks_c3, GTU);

outlier_config.start_step = round(N * 0.25);
outlier_config.end_step = round(N * 0.5);

[Z_outlier_c3, outlier_info_c3] = inject_outlier_sparse(Z_leak_clean_c3, outlier_config, Sys, 10);

[H_Normal_c3, H_Chen_c3, H_Adaptive_c3, H_AFEKF_c3, Stats_c3, Leak_Est_c3, Diag_c3] = ...
    run_four_methods_with_leak_stats(Z_outlier_c3, H_True_c3, Nodes, Pipes, Compressors, Sys, t, GTU, ...
                                     true, 12, 18, [6, 12], outlier_info_c3);

%plot_case3_four(H_True_c3, Z_outlier_c3, H_Normal_c3, H_Chen_c3, H_Adaptive_c3, H_AFEKF_c3, ...
  %  Nodes, Pipes, Sys, t, GTU, Leaks_c3, outlier_config, outlier_info_c3);

save_case3_results_four('Case3_Out_Leak', Stats_c3, Leak_True_c3, Leak_Est_c3);

% =========================================================================
% CASE 4: Pure leak
% =========================================================================
fprintf('\nCASE 4: Pure leak (no outliers)\n');
fprintf('Timeline: 0-12h normal | 12h-24h leak\n');
fprintf('--------------------------------------------------------\n');

Leaks_c4 = dse_load_leak('leak.xlsx');
if height(Leaks_c4) > 0
    Leaks_c4.StartTime_s(1) = 12 * 3600;
    Leaks_c4.EndTime_s(1) = 24 * 3600;
    fprintf('Leak config: 12h-24h, rate %.1f kg/s\n', Leaks_c4.LeakRate_kg_s(1));
end

[H_True_c4, Z_clean_c4, t, Leak_True_c4, P_GTU] = ...
    dse_3_gen_data_leak(Nodes, Pipes, Compressors, Sys, Leaks_c4, GTU);

[H_Normal_c4, H_Chen_c4, H_Adaptive_c4, H_AFEKF_c4, Stats_c4, Leak_Est_c4, Diag_c4] = ...
    run_four_methods_with_leak_stats(Z_clean_c4, H_True_c4, Nodes, Pipes, Compressors, Sys, t, GTU, ...
                                     true, 12, 24, [], []);

%plot_case4_four(H_True_c4, Z_clean_c4, H_Normal_c4, H_Chen_c4, H_Adaptive_c4, H_AFEKF_c4, ...
%    Nodes, Pipes, Sys, t, GTU, Leaks_c4);

save_case4_results_four('Case4_Pure_Leak', Stats_c4, Leak_True_c4, Leak_Est_c4);

% =========================================================================
% Summary
% =========================================================================
fprintf('\n========================================================\n');
fprintf('   Four-Method RMSE Summary\n');
fprintf('========================================================\n');
print_summary_table_four_methods(Stats_c1, Stats_c2_10, Stats_c2_20, Stats_c3, Stats_c4);

save_comprehensive_results_four_methods(Stats_c1, Stats_c2_10, Stats_c2_20, Stats_c3, Stats_c4, ...
    'Comprehensive_Results_4Methods.xlsx');

if ~exist('csv_results', 'dir')
    mkdir('csv_results');
end

export_results_to_csv(Stats_c1, Stats_c2_10, Stats_c2_20, Stats_c3, Stats_c4, './csv_results/');

fprintf('\n========================================================\n');
fprintf('   All cases complete.\n');
fprintf('========================================================\n');
fprintf('Figures: Case1_*.fig, Case2_*.fig, Case3_*.fig, Case4_*.fig\n');
fprintf('Excel: Comprehensive_Results_4Methods.xlsx\n');
fprintf('CSV: ./csv_results/*.csv\n\n');

end


% =========================================================================
% RUN FOUR METHODS
% =========================================================================
function [H_Normal, H_Chen, H_Adaptive, H_AFEKF, Stats, Leak_Est, Diag] = ...
    run_four_methods(Z, H_True, Nodes, Pipes, Compressors, Sys, t, GTU, enable_detector, exclude_ranges, outlier_info)

nN = height(Nodes);

if nargin < 11
    outlier_info = [];
end

% Method 1: Standard EKF
fprintf('  [1/4] Running Standard EKF...\n');
H_Normal = dse_normal_ekf(Z, Nodes, Pipes, Compressors, Sys, t, GTU);

% Method 2: Chen Robust EKF
fprintf('  [2/4] Running Chen Robust EKF...\n');
H_Chen = dse_chen_ekf(Z, Nodes, Pipes, Compressors, Sys, t, GTU);

% Method 3: EKF-LE (with detector)
if enable_detector
    fprintf('  [3/4] Running 3-layer Detector + EKF-LE...\n');
    [Det, Diag, ~] = dse_leak_detector(H_Normal, Z, Nodes, Pipes, Sys, t);
    [H_Adaptive, Leak_Est_Nodes] = dse_4_estimator_leak(Z, Nodes, Pipes, Compressors, Sys, t, GTU, Det);
    Leak_Est = sum(Leak_Est_Nodes, 2);
else
    fprintf('  [3/4] Running EKF-LE (no detector)...\n');
    Det = false(length(t), 1);
    [H_Adaptive, Leak_Est_Nodes] = dse_4_estimator_leak(Z, Nodes, Pipes, Compressors, Sys, t, GTU, Det);
    Leak_Est = sum(Leak_Est_Nodes, 2);
    Diag = struct();
    Diag.Outlier_mask = false(length(t), nN + height(Pipes));
    Diag.Leak_mask = false(length(t), nN + height(Pipes));
end

% Method 4: AFEKF (your advanced method)
fprintf('  [4/4] Running AFEKF (Adaptive Fading)...\n');
if enable_detector
    [H_AFEKF, ~, ~] = AFUKF(Z, Nodes, Pipes, Compressors, Sys, t, GTU, Det);
else
    [H_AFEKF, ~, ~] = AFUKF(Z, Nodes, Pipes, Compressors, Sys, t, GTU, []);
end

% Calculate statistics
Stats.Normal = calc_stats_simple(H_True, H_Normal, Nodes, Pipes, Sys, t, exclude_ranges, outlier_info);
Stats.Chen = calc_stats_simple(H_True, H_Chen, Nodes, Pipes, Sys, t, exclude_ranges, outlier_info);
Stats.Adaptive = calc_stats_simple(H_True, H_Adaptive, Nodes, Pipes, Sys, t, exclude_ranges, outlier_info);
Stats.AFEKF = calc_stats_simple(H_True, H_AFEKF, Nodes, Pipes, Sys, t, exclude_ranges, outlier_info);

fprintf('  Results (Pipe1_RMSE [kg/s]):\n');
fprintf('    Standard: %.4f | Chen: %.4f | EKF-LE: %.4f | AFEKF: %.4f\n', ...
    Stats.Normal.Pipe1_RMSE, Stats.Chen.Pipe1_RMSE, Stats.Adaptive.Pipe1_RMSE, Stats.AFEKF.Pipe1_RMSE);
fprintf('  Results (Pipe5_RMSE [kg/s]):\n');
fprintf('    Standard: %.4f | Chen: %.4f | EKF-LE: %.4f | AFEKF: %.4f\n', ...
    Stats.Normal.Pipe5_RMSE, Stats.Chen.Pipe5_RMSE, Stats.Adaptive.Pipe5_RMSE, Stats.AFEKF.Pipe5_RMSE);
end


function [H_Normal, H_Chen, H_Adaptive, H_AFEKF, Stats, Leak_Est, Diag] = ...
    run_four_methods_with_leak_stats(Z, H_True, Nodes, Pipes, Compressors, Sys, t, GTU, ...
                                     enable_detector, leak_start_h, leak_end_h, exclude_ranges, outlier_info)

nN = height(Nodes);

% Method 1: Standard EKF
fprintf('  [1/4] Running Standard EKF...\n');
H_Normal = dse_normal_ekf(Z, Nodes, Pipes, Compressors, Sys, t, GTU);

% Method 2: Chen Robust EKF
fprintf('  [2/4] Running Chen Robust EKF...\n');
H_Chen = dse_chen_ekf(Z, Nodes, Pipes, Compressors, Sys, t, GTU);

% Method 3: EKF-LE
if enable_detector
    fprintf('  [3/4] Running 3-layer Detector + EKF-LE...\n');
    [Det, Diag, ~] = dse_leak_detector(H_Normal, Z, Nodes, Pipes, Sys, t);
    [H_Adaptive, Leak_Est_Nodes] = dse_4_estimator_leak(Z, Nodes, Pipes, Compressors, Sys, t, GTU, Det);
    Leak_Est = sum(Leak_Est_Nodes, 2);
else
    fprintf('  [3/4] Running EKF-LE (no detector)...\n');
    Det = false(length(t), 1);
    [H_Adaptive, Leak_Est_Nodes] = dse_4_estimator_leak(Z, Nodes, Pipes, Compressors, Sys, t, GTU, Det);
    Leak_Est = sum(Leak_Est_Nodes, 2);
    Diag = struct();
end

% Method 4: AFEKF
fprintf('  [4/4] Running AFEKF (Adaptive Fading)...\n');
if enable_detector
    [H_AFEKF, ~, ~] = AFUKF(Z, Nodes, Pipes, Compressors, Sys, t, GTU, Det);
else
    [H_AFEKF, ~, ~] = AFUKF(Z, Nodes, Pipes, Compressors, Sys, t, GTU, []);
end

% Calculate statistics with leak separation
if ~isnan(leak_start_h)
    fprintf('  Computing RMSE (separating normal and leak periods)...\n');
    Stats.Normal = calc_stats_with_leak_separation(H_True, H_Normal, Nodes, Pipes, Sys, t, ...
                                                    leak_start_h, leak_end_h, exclude_ranges, outlier_info);
    Stats.Chen = calc_stats_with_leak_separation(H_True, H_Chen, Nodes, Pipes, Sys, t, ...
                                                  leak_start_h, leak_end_h, exclude_ranges, outlier_info);
    Stats.Adaptive = calc_stats_with_leak_separation(H_True, H_Adaptive, Nodes, Pipes, Sys, t, ...
                                                      leak_start_h, leak_end_h, exclude_ranges, outlier_info);
    Stats.AFEKF = calc_stats_with_leak_separation(H_True, H_AFEKF, Nodes, Pipes, Sys, t, ...
                                                   leak_start_h, leak_end_h, exclude_ranges, outlier_info);
    
    fprintf('  Results (Normal Period P_RMSE [Bar]):\n');
    fprintf('    Standard: %.4f | Chen: %.4f | EKF-LE: %.4f | AFEKF: %.4f\n', ...
        Stats.Normal.P_RMSE_Normal, Stats.Chen.P_RMSE_Normal, Stats.Adaptive.P_RMSE_Normal, Stats.AFEKF.P_RMSE_Normal);
    fprintf('  Results (Leak Period P_RMSE [Bar]):\n');
    fprintf('    Standard: %.4f | Chen: %.4f | EKF-LE: %.4f | AFEKF: %.4f\n', ...
        Stats.Normal.P_RMSE_Leak, Stats.Chen.P_RMSE_Leak, Stats.Adaptive.P_RMSE_Leak, Stats.AFEKF.P_RMSE_Leak);
else
    Stats.Normal = calc_stats_simple(H_True, H_Normal, Nodes, Pipes, Sys, t, exclude_ranges, outlier_info);
    Stats.Chen = calc_stats_simple(H_True, H_Chen, Nodes, Pipes, Sys, t, exclude_ranges, outlier_info);
    Stats.Adaptive = calc_stats_simple(H_True, H_Adaptive, Nodes, Pipes, Sys, t, exclude_ranges, outlier_info);
    Stats.AFEKF = calc_stats_simple(H_True, H_AFEKF, Nodes, Pipes, Sys, t, exclude_ranges, outlier_info);
end
end


% =========================================================================
% STATISTICS CALCULATION
% =========================================================================
function S = calc_stats_simple(H_True, H_Est, Nodes, Pipes, Sys, t, exclude_ranges, outlier_info)

nN = height(Nodes);
nP = height(Pipes);
PT = H_True(:,1:nN) * Sys.c2 / 1e5;
PE = H_Est(:,1:nN) * Sys.c2 / 1e5;
MT = H_True(:,nN+1:end);
ME = H_Est(:,nN+1:end);

N = length(t);
mask = true(N, 1);

if nargin >= 7 && ~isempty(exclude_ranges)
    for i = 1:size(exclude_ranges, 1)
        t_start = exclude_ranges(i, 1);
        t_end = exclude_ranges(i, 2);
        exclude_idx = (t >= t_start) & (t <= t_end);
        mask(exclude_idx) = false;
    end
end

if nargin >= 8 && ~isempty(outlier_info) && isstruct(outlier_info)
    outlier_steps = [];
    if isfield(outlier_info, 'node_outliers') && ~isempty(outlier_info.node_outliers)
        outlier_steps = [outlier_steps; outlier_info.node_outliers(:, 1)];
    end
    if isfield(outlier_info, 'pipe_outliers') && ~isempty(outlier_info.pipe_outliers)
        outlier_steps = [outlier_steps; outlier_info.pipe_outliers(:, 1)];
    end
    outlier_steps = unique(outlier_steps);
    for i = 1:length(outlier_steps)
        step_idx = outlier_steps(i);
        if step_idx >= 1 && step_idx <= N
            mask(step_idx) = false;
        end
    end
end

PT_masked = PT(mask, :);
PE_masked = PE(mask, :);
MT_masked = MT(mask, :);
ME_masked = ME(mask, :);

err_p = PE_masked - PT_masked;
err_m = ME_masked - MT_masked;

S.P_RMSE = sqrt(mean(err_p(:).^2));
S.P_MAE = mean(abs(err_p(:)));
S.M_RMSE = sqrt(mean(err_m(:).^2));
S.M_MAE = mean(abs(err_m(:)));

pipe5_idx = 5;
if pipe5_idx <= nP
    err_pipe5 = ME_masked(:, pipe5_idx) - MT_masked(:, pipe5_idx);
    S.Pipe5_RMSE = sqrt(mean(err_pipe5.^2));
    S.Pipe5_MAE = mean(abs(err_pipe5));
else
    S.Pipe5_RMSE = NaN;
    S.Pipe5_MAE = NaN;
end

pipe1_idx = 1;
if pipe1_idx <= nP
    err_pipe1 = ME_masked(:, pipe1_idx) - MT_masked(:, pipe1_idx);
    S.Pipe1_RMSE = sqrt(mean(err_pipe1.^2));
    S.Pipe1_MAE = mean(abs(err_pipe1));
else
    S.Pipe1_RMSE = NaN;
    S.Pipe1_MAE = NaN;
end
end


% =========================================================================
% PLOTTING FUNCTIONS (4 methods)
% =========================================================================
function plot_case1_four(H_True, Z, H_Normal, H_Chen, H_Adaptive, H_AFEKF, Nodes, Pipes, Sys, t, GTU)

nN = height(Nodes);
pipe1_idx = 1;
pipe5_idx = 5;
%size(Z)

figure('Name', 'Case 1: Flow Pipe 1 - 4 Methods', 'Color', 'w', 'Position', [150 150 1200 600]);
hold on; box on;
plot(t, H_True(:,nN+pipe1_idx), 'g-', 'LineWidth', 2.5, 'DisplayName', 'True');
plot(t, Z(:,nN+pipe1_idx), 'k.', 'MarkerSize', 4, 'DisplayName', 'Measurements');
plot(t, H_Normal(:,nN+pipe1_idx), 'b:', 'LineWidth', 2, 'DisplayName', 'Standard EKF');
plot(t, H_Chen(:,nN+pipe1_idx), 'm-.', 'LineWidth', 1.8, 'DisplayName', 'Chen Robust');
plot(t, H_Adaptive(:,nN+pipe1_idx), 'r--', 'LineWidth', 1.8, 'DisplayName', 'EKF-LE');
plot(t, H_AFEKF(:,nN+pipe1_idx), 'c-', 'LineWidth', 2.2, 'DisplayName', 'AFEKF');
title('Case 1: Source Flow (Pipe 1)', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('Time (h)', 'FontSize', 12); ylabel('Flow Rate (kg/s)', 'FontSize', 12);
legend('Location', 'best', 'FontSize', 10); grid on; xlim([0 24]);
savefig('Case1_Flow_Pipe1_4Methods.fig');

% Figure 3: Flow Pipe 5
figure('Name', 'Case 1: Flow Pipe 5 - 4 Methods', 'Color', 'w', 'Position', [200 200 1200 600]);
hold on; box on;
plot(t, H_True(:,nN+pipe5_idx), 'g-', 'LineWidth', 2.5, 'DisplayName', 'True');
plot(t, Z(:,nN+pipe5_idx), 'k.', 'MarkerSize', 4, 'DisplayName', 'Measurements');
plot(t, H_Normal(:,nN+pipe5_idx), 'b:', 'LineWidth', 2, 'DisplayName', 'Standard EKF');
plot(t, H_Chen(:,nN+pipe5_idx), 'm-.', 'LineWidth', 1.8, 'DisplayName', 'Chen Robust');
plot(t, H_Adaptive(:,nN+pipe5_idx), 'r--', 'LineWidth', 1.8, 'DisplayName', 'EKF-LE');
plot(t, H_AFEKF(:,nN+pipe5_idx), 'c-', 'LineWidth', 2.2, 'DisplayName', 'AFEKF');
title('Case 1: Flow at Pipe 5', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('Time (h)', 'FontSize', 12); ylabel('Flow Rate (kg/s)', 'FontSize', 12);
legend('Location', 'best', 'FontSize', 10); grid on; xlim([0 24]);
savefig('Case1_Flow_Pipe5_4Methods.fig');

fprintf('  Saved: Case1_*_4Methods.fig\n');
end


function plot_case2_four(H_True, Z, H_Normal, H_Chen, H_Adaptive, H_AFEKF, Nodes, Pipes, Sys, t, GTU, outlier_config, outlier_info)

nN = height(Nodes);
pipe1_idx = 1;
pipe5_idx = 5;

outlier_start_time = outlier_config.start_step * Sys.dt / 3600;
outlier_end_time = outlier_config.end_step * Sys.dt / 3600;

figure('Name', 'Case 2: Flow Pipe 1 - 4 Methods', 'Color', 'w', 'Position', [100 100 1200 700]);
hold on; box on;

Z_flow1 = Z(:,nN+pipe1_idx);
y_data = [H_True(:,nN+pipe1_idx); H_Normal(:,nN+pipe1_idx); H_Chen(:,nN+pipe1_idx); H_Adaptive(:,nN+pipe1_idx); H_AFEKF(:,nN+pipe1_idx)];
y_min = min(y_data)*0.98; y_max = max(y_data)*1.02;
y_range = y_max - y_min;
y_lim = [y_min - 0.05*y_range, y_max + 0.15*y_range];

fill([outlier_start_time, outlier_end_time, outlier_end_time, outlier_start_time], ...
     [y_lim(1), y_lim(1), y_max, y_max], [1 0.95 0.9], 'EdgeColor', 'none', 'FaceAlpha', 0.3, 'DisplayName', 'Outlier period');

plot(t, H_True(:,nN+pipe1_idx), 'g-', 'LineWidth', 2.5, 'DisplayName', 'True');
Z_normal_mask = (Z_flow1 >= y_lim(1)) & (Z_flow1 <= y_max);
plot(t(Z_normal_mask), Z_flow1(Z_normal_mask), 'k.', 'MarkerSize', 6, 'DisplayName', 'Measurements');
plot(t, H_Normal(:,nN+pipe1_idx), 'b:', 'LineWidth', 2, 'DisplayName', 'Standard EKF');
plot(t, H_Chen(:,nN+pipe1_idx), 'm-.', 'LineWidth', 1.8, 'DisplayName', 'Chen Robust');
plot(t, H_Adaptive(:,nN+pipe1_idx), 'r--', 'LineWidth', 1.8, 'DisplayName', 'EKF-LE');
plot(t, H_AFEKF(:,nN+pipe1_idx), 'c-', 'LineWidth', 2.2, 'DisplayName', 'AFEKF');

if ~isempty(outlier_info) && isfield(outlier_info, 'pipe_outliers') && ~isempty(outlier_info.pipe_outliers)
    pipe_outliers = outlier_info.pipe_outliers(outlier_info.pipe_outliers(:,2) == pipe1_idx, :);
    if ~isempty(pipe_outliers)
        outlier_steps = pipe_outliers(:, 1);
        outlier_times = outlier_steps * Sys.dt / 3600;
        marker_y = y_max + 0.08*y_range;
        for i = 1:length(outlier_times)
            plot(outlier_times(i), marker_y, 'rv', 'MarkerSize', 10, 'MarkerFaceColor', 'r', 'HandleVisibility', 'off');
            plot([outlier_times(i), outlier_times(i)], [marker_y-0.02*y_range, y_max], 'r:', 'LineWidth', 1, 'HandleVisibility', 'off');
        end
        plot(NaN, NaN, 'rv', 'MarkerSize', 10, 'MarkerFaceColor', 'r', 'DisplayName', sprintf('Outliers (n=%d)', length(outlier_times)));
    end
end

xline(outlier_start_time, 'k--', 'LineWidth', 1.5, 'HandleVisibility', 'off');
xline(outlier_end_time, 'k--', 'LineWidth', 1.5, 'HandleVisibility', 'off');

title('Case 2: Source Flow (Pipe 1, Sparse Outliers)', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('Time (h)', 'FontSize', 12); ylabel('Flow Rate (kg/s)', 'FontSize', 12);
legend('Location', 'best', 'FontSize', 9); grid on; xlim([0 24]); ylim(y_lim);
savefig('Case2_Flow_Pipe1_4Methods.fig');

figure('Name', 'Case 2: Flow Pipe 5 - 4 Methods', 'Color', 'w', 'Position', [150 150 1200 700]);
hold on; box on;

y_data = [H_True(:,nN+pipe5_idx); H_AFEKF(:,nN+pipe5_idx)];
y_lim_temp = [min(y_data)*0.98, max(y_data)*1.02];

fill([outlier_start_time, outlier_end_time, outlier_end_time, outlier_start_time], ...
     [y_lim_temp(1), y_lim_temp(1), y_lim_temp(2), y_lim_temp(2)], ...
     [1 0.95 0.9], 'EdgeColor', 'none', 'FaceAlpha', 0.3, 'DisplayName', 'Outlier period');

plot(t, H_True(:,nN+pipe5_idx), 'g-', 'LineWidth', 2.5, 'DisplayName', 'True');
plot(t, H_Normal(:,nN+pipe5_idx), 'b:', 'LineWidth', 2, 'DisplayName', 'Standard EKF');
plot(t, H_Chen(:,nN+pipe5_idx), 'm-.', 'LineWidth', 1.8, 'DisplayName', 'Chen Robust');
plot(t, H_Adaptive(:,nN+pipe5_idx), 'r--', 'LineWidth', 1.8, 'DisplayName', 'EKF-LE');
plot(t, H_AFEKF(:,nN+pipe5_idx), 'c-', 'LineWidth', 2.2, 'DisplayName', 'AFEKF');

xline(outlier_start_time, 'k--', 'LineWidth', 1.5, 'HandleVisibility', 'off');
xline(outlier_end_time, 'k--', 'LineWidth', 1.5, 'HandleVisibility', 'off');

title('Case 2: Flow at Pipe 5 (Sparse Outliers)', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('Time (h)', 'FontSize', 12); ylabel('Flow Rate (kg/s)', 'FontSize', 12);
legend('Location', 'best', 'FontSize', 9); grid on; xlim([0 24]); ylim(y_lim_temp);
savefig('Case2_Flow_Pipe5_4Methods.fig');

fprintf('  Saved: Case2_*_4Methods.fig\n');
end


function plot_case3_four(H_True, Z, H_Normal, H_Chen, H_Adaptive, H_AFEKF, Nodes, Pipes, Sys, t, GTU, Leaks, outlier_config, outlier_info)

nN = height(Nodes);
pipe1_idx = 1;
pipe5_idx = 5;

outlier_start_time = outlier_config.start_step * Sys.dt / 3600;
outlier_end_time = outlier_config.end_step * Sys.dt / 3600;

if height(Leaks) > 0
    leak_start_time = Leaks.StartTime_s(1) / 3600;
    leak_end_time = Leaks.EndTime_s(1) / 3600;
    if isinf(leak_end_time), leak_end_time = 24; end
else
    leak_start_time = NaN; leak_end_time = NaN;
end

figure('Name', 'Case 3: Flow Pipe 1 - 4 Methods', 'Color', 'w', 'Position', [100 100 1200 700]);
hold on; box on;

Z_flow1 = Z(:,nN+pipe1_idx);
y_data = [H_True(:,nN+pipe1_idx); H_Normal(:,nN+pipe1_idx); H_Chen(:,nN+pipe1_idx); H_Adaptive(:,nN+pipe1_idx); H_AFEKF(:,nN+pipe1_idx)];
y_min = min(y_data)*0.98; y_max = max(y_data)*1.02;
y_range = y_max - y_min;
y_lim = [y_min - 0.05*y_range, y_max + 0.20*y_range];

fill([outlier_start_time, outlier_end_time, outlier_end_time, outlier_start_time], ...
     [y_lim(1), y_lim(1), y_max, y_max], [1 0.9 0.9], 'EdgeColor', 'none', 'FaceAlpha', 0.3, 'DisplayName', 'Outlier period');
if ~isnan(leak_start_time)
    fill([leak_start_time, leak_end_time, leak_end_time, leak_start_time], ...
         [y_lim(1), y_lim(1), y_max, y_max], [0.9 0.9 1], 'EdgeColor', 'none', 'FaceAlpha', 0.3, 'DisplayName', 'Leak period');
end

plot(t, H_True(:,nN+pipe1_idx), 'g-', 'LineWidth', 2.5, 'DisplayName', 'True');
Z_normal_mask = (Z_flow1 >= y_lim(1)) & (Z_flow1 <= y_max);
plot(t(Z_normal_mask), Z_flow1(Z_normal_mask), 'k.', 'MarkerSize', 6, 'DisplayName', 'Measurements');
plot(t, H_Normal(:,nN+pipe1_idx), 'b:', 'LineWidth', 2, 'DisplayName', 'Standard EKF');
plot(t, H_Chen(:,nN+pipe1_idx), 'm-.', 'LineWidth', 1.8, 'DisplayName', 'Chen Robust');
plot(t, H_Adaptive(:,nN+pipe1_idx), 'r--', 'LineWidth', 1.8, 'DisplayName', 'EKF-LE');
plot(t, H_AFEKF(:,nN+pipe1_idx), 'c-', 'LineWidth', 2.2, 'DisplayName', 'AFEKF');

xline(outlier_start_time, 'c--', 'LineWidth', 1.5, 'Alpha', 0.6, 'HandleVisibility', 'off');
if ~isnan(leak_start_time)
    xline(leak_start_time, 'k:', 'LineWidth', 2, 'Alpha', 0.5, 'HandleVisibility', 'off');
end

title('Case 3: Source Flow (Pipe 1, Outlier + Leak)', 'FontSize', 13, 'FontWeight', 'bold');
xlabel('Time (h)', 'FontSize', 12); ylabel('Flow Rate (kg/s)', 'FontSize', 12);
legend('Location', 'best', 'FontSize', 9); grid on; xlim([0 24]); ylim(y_lim);
savefig('Case3_Flow_Pipe1_4Methods.fig');

% Figure 2: Flow Pipe 5
figure('Name', 'Case 3: Flow Pipe 5 - 4 Methods', 'Color', 'w', 'Position', [150 150 1200 700]);
hold on; box on;

y_lim_temp = [min(H_True(:,nN+pipe5_idx))*0.98, max(H_True(:,nN+pipe5_idx))*1.02];

fill([outlier_start_time, outlier_end_time, outlier_end_time, outlier_start_time], ...
     [y_lim_temp(1), y_lim_temp(1), y_lim_temp(2), y_lim_temp(2)], ...
     [1 0.9 0.9], 'EdgeColor', 'none', 'FaceAlpha', 0.3, 'DisplayName', 'Outlier period');
if ~isnan(leak_start_time)
    fill([leak_start_time, leak_end_time, leak_end_time, leak_start_time], ...
         [y_lim_temp(1), y_lim_temp(1), y_lim_temp(2), y_lim_temp(2)], ...
         [0.9 0.9 1], 'EdgeColor', 'none', 'FaceAlpha', 0.3, 'DisplayName', 'Leak period');
end

plot(t, H_True(:,nN+pipe5_idx), 'g-', 'LineWidth', 2.5, 'DisplayName', 'True');
plot(t, H_Normal(:,nN+pipe5_idx), 'b:', 'LineWidth', 2, 'DisplayName', 'Standard EKF');
plot(t, H_Chen(:,nN+pipe5_idx), 'm-.', 'LineWidth', 1.8, 'DisplayName', 'Chen Robust');
plot(t, H_Adaptive(:,nN+pipe5_idx), 'r--', 'LineWidth', 1.8, 'DisplayName', 'EKF-LE');
plot(t, H_AFEKF(:,nN+pipe5_idx), 'c-', 'LineWidth', 2.2, 'DisplayName', 'AFEKF');

title('Case 3: Flow at Pipe 5 (Outlier + Leak)', 'FontSize', 13, 'FontWeight', 'bold');
xlabel('Time (h)', 'FontSize', 12); ylabel('Flow Rate (kg/s)', 'FontSize', 12);
legend('Location', 'best', 'FontSize', 9); grid on; xlim([0 24]); ylim(y_lim_temp);
savefig('Case3_Flow_Pipe5_4Methods.fig');

fprintf('  Saved: Case3_*_4Methods.fig\n');
end


function plot_case4_four(H_True, Z, H_Normal, H_Chen, H_Adaptive, H_AFEKF, Nodes, Pipes, Sys, t, GTU, Leaks)

nN = height(Nodes);
pipe1_idx = 1;
pipe5_idx = 5;

if height(Leaks) > 0
    leak_start_time = Leaks.StartTime_s(1) / 3600;
    leak_end_time = Leaks.EndTime_s(1) / 3600;
    if isinf(leak_end_time), leak_end_time = 24; end
else
    leak_start_time = NaN; leak_end_time = NaN;
end

figure('Name', 'Case 4: Flow Pipe 1 - 4 Methods', 'Color', 'w', 'Position', [100 100 1200 600]);
hold on; box on;

y_lim_temp = [min(Z(:,nN+pipe1_idx))*0.98, max(Z(:,nN+pipe1_idx))*1.02];

if ~isnan(leak_start_time)
    fill([leak_start_time, leak_end_time, leak_end_time, leak_start_time], ...
         [y_lim_temp(1), y_lim_temp(1), y_lim_temp(2), y_lim_temp(2)], ...
         [0.9 0.9 1], 'EdgeColor', 'none', 'FaceAlpha', 0.3, 'DisplayName', 'Leak period');
end

plot(t, H_True(:,nN+pipe1_idx), 'g-', 'LineWidth', 2.5, 'DisplayName', 'True');
plot(t, Z(:,nN+pipe1_idx), 'k.', 'MarkerSize', 4, 'DisplayName', 'Measurements');
plot(t, H_Normal(:,nN+pipe1_idx), 'b:', 'LineWidth', 2, 'DisplayName', 'Standard EKF');
plot(t, H_Chen(:,nN+pipe1_idx), 'm-.', 'LineWidth', 1.8, 'DisplayName', 'Chen Robust');
plot(t, H_Adaptive(:,nN+pipe1_idx), 'r--', 'LineWidth', 1.8, 'DisplayName', 'EKF-LE');
plot(t, H_AFEKF(:,nN+pipe1_idx), 'c-', 'LineWidth', 2.2, 'DisplayName', 'AFEKF');

if ~isnan(leak_start_time)
    xline(leak_start_time, 'k:', 'LineWidth', 2, 'HandleVisibility', 'off');
end

title('Case 4: Source Flow (Pipe 1, Pure Leak)', 'FontSize', 13, 'FontWeight', 'bold');
xlabel('Time (h)', 'FontSize', 12); ylabel('Flow Rate (kg/s)', 'FontSize', 12);
legend('Location', 'best', 'FontSize', 9); grid on; xlim([0 24]); ylim(y_lim_temp);
savefig('Case4_Flow_Pipe1_4Methods.fig');

% Figure 2: Flow Pipe 5
figure('Name', 'Case 4: Flow Pipe 5 - 4 Methods', 'Color', 'w', 'Position', [150 150 1200 600]);
hold on; box on;

y_lim_temp = [min(Z(:,nN+pipe5_idx))*0.98, max(Z(:,nN+pipe5_idx))*1.02];

if ~isnan(leak_start_time)
    fill([leak_start_time, leak_end_time, leak_end_time, leak_start_time], ...
         [y_lim_temp(1), y_lim_temp(1), y_lim_temp(2), y_lim_temp(2)], ...
         [0.9 0.9 1], 'EdgeColor', 'none', 'FaceAlpha', 0.3, 'DisplayName', 'Leak period');
end

plot(t, H_True(:,nN+pipe5_idx), 'g-', 'LineWidth', 2.5, 'DisplayName', 'True');
plot(t, Z(:,nN+pipe5_idx), 'k.', 'MarkerSize', 4, 'DisplayName', 'Measurements');
plot(t, H_Normal(:,nN+pipe5_idx), 'b:', 'LineWidth', 2, 'DisplayName', 'Standard EKF');
plot(t, H_Chen(:,nN+pipe5_idx), 'm-.', 'LineWidth', 1.8, 'DisplayName', 'Chen Robust');
plot(t, H_Adaptive(:,nN+pipe5_idx), 'r--', 'LineWidth', 1.8, 'DisplayName', 'EKF-LE');
plot(t, H_AFEKF(:,nN+pipe5_idx), 'c-', 'LineWidth', 2.2, 'DisplayName', 'AFEKF');

if ~isnan(leak_start_time)
    xline(leak_start_time, 'k:', 'LineWidth', 2, 'HandleVisibility', 'off');
end

title('Case 4: Flow at Pipe 5 (Pure Leak)', 'FontSize', 13, 'FontWeight', 'bold');
xlabel('Time (h)', 'FontSize', 12); ylabel('Flow Rate (kg/s)', 'FontSize', 12);
legend('Location', 'best', 'FontSize', 9); grid on; xlim([0 24]); ylim(y_lim_temp);
savefig('Case4_Flow_Pipe5_4Methods.fig');

fprintf('  Saved: Case4_*_4Methods.fig\n');
end


% =========================================================================
% SAVE RESULTS FUNCTIONS
% =========================================================================
function save_case_results_four(case_name, Stats)
fprintf('\n%s Results:\n', case_name);
fprintf('  Pipe1_RMSE [kg/s]: Std=%.4f | Chen=%.4f | EKF-LE=%.4f | AFEKF=%.4f\n', ...
    Stats.Normal.Pipe1_RMSE, Stats.Chen.Pipe1_RMSE, Stats.Adaptive.Pipe1_RMSE, Stats.AFEKF.Pipe1_RMSE);
fprintf('  Pipe5_RMSE [kg/s]: Std=%.4f | Chen=%.4f | EKF-LE=%.4f | AFEKF=%.4f\n', ...
    Stats.Normal.Pipe5_RMSE, Stats.Chen.Pipe5_RMSE, Stats.Adaptive.Pipe5_RMSE, Stats.AFEKF.Pipe5_RMSE);
fprintf('  M_RMSE [kg/s]: Std=%.4f | Chen=%.4f | EKF-LE=%.4f | AFEKF=%.4f\n', ...
    Stats.Normal.M_RMSE, Stats.Chen.M_RMSE, Stats.Adaptive.M_RMSE, Stats.AFEKF.M_RMSE);
end

function save_case2_results_four(case_name, Stats_10, Stats_20)
fprintf('\n%s Results:\n', case_name);
fprintf('  10dB Pipe1_RMSE [kg/s]: Std=%.4f | Chen=%.4f | EKF-LE=%.4f | AFEKF=%.4f\n', ...
    Stats_10.Normal.Pipe1_RMSE, Stats_10.Chen.Pipe1_RMSE, Stats_10.Adaptive.Pipe1_RMSE, Stats_10.AFEKF.Pipe1_RMSE);
fprintf('  20dB Pipe1_RMSE [kg/s]: Std=%.4f | Chen=%.4f | EKF-LE=%.4f | AFEKF=%.4f\n', ...
    Stats_20.Normal.Pipe1_RMSE, Stats_20.Chen.Pipe1_RMSE, Stats_20.Adaptive.Pipe1_RMSE, Stats_20.AFEKF.Pipe1_RMSE);
end

function save_case3_results_four(case_name, Stats, Leak_True, Leak_Est)
fprintf('\n%s Results:\n', case_name);
fprintf('  Full Pipe1_RMSE [kg/s]: Std=%.4f | Chen=%.4f | EKF-LE=%.4f | AFEKF=%.4f\n', ...
    Stats.Normal.Pipe1_RMSE, Stats.Chen.Pipe1_RMSE, Stats.Adaptive.Pipe1_RMSE, Stats.AFEKF.Pipe1_RMSE);
if isfield(Stats.Normal, 'P_RMSE_Normal')
    fprintf('  Normal Pipe1_RMSE: Std=%.4f | Chen=%.4f | EKF-LE=%.4f | AFEKF=%.4f\n', ...
        Stats.Normal.Pipe1_RMSE_Normal, Stats.Chen.Pipe1_RMSE_Normal, Stats.Adaptive.Pipe1_RMSE_Normal, Stats.AFEKF.Pipe1_RMSE_Normal);
    fprintf('  Leak Pipe1_RMSE: Std=%.4f | Chen=%.4f | EKF-LE=%.4f | AFEKF=%.4f\n', ...
        Stats.Normal.Pipe1_RMSE_Leak, Stats.Chen.Pipe1_RMSE_Leak, Stats.Adaptive.Pipe1_RMSE_Leak, Stats.AFEKF.Pipe1_RMSE_Leak);
end
end

function save_case4_results_four(case_name, Stats, Leak_True, Leak_Est)
fprintf('\n%s Results:\n', case_name);
fprintf('  Full Pipe1_RMSE [kg/s]: Std=%.4f | Chen=%.4f | EKF-LE=%.4f | AFEKF=%.4f\n', ...
    Stats.Normal.Pipe1_RMSE, Stats.Chen.Pipe1_RMSE, Stats.Adaptive.Pipe1_RMSE, Stats.AFEKF.Pipe1_RMSE);
if isfield(Stats.Normal, 'P_RMSE_Normal')
    fprintf('  Normal Pipe1_RMSE: Std=%.4f | Chen=%.4f | EKF-LE=%.4f | AFEKF=%.4f\n', ...
        Stats.Normal.Pipe1_RMSE_Normal, Stats.Chen.Pipe1_RMSE_Normal, Stats.Adaptive.Pipe1_RMSE_Normal, Stats.AFEKF.Pipe1_RMSE_Normal);
    fprintf('  Leak Pipe1_RMSE: Std=%.4f | Chen=%.4f | EKF-LE=%.4f | AFEKF=%.4f\n', ...
        Stats.Normal.Pipe1_RMSE_Leak, Stats.Chen.Pipe1_RMSE_Leak, Stats.Adaptive.Pipe1_RMSE_Leak, Stats.AFEKF.Pipe1_RMSE_Leak);
end
end


% =========================================================================
% PRINT SUMMARY TABLE
% =========================================================================
function print_summary_table_four_methods(Stats_c1, Stats_c2_10, Stats_c2_20, Stats_c3, Stats_c4)

% -------------------------------
% Pipe 1 RMSE Summary
% -------------------------------
fprintf('\nPipe 1 RMSE Summary [kg/s]:\n');
fprintf('%-25s | %-10s | %-10s | %-10s | %-10s\n', 'Case', 'Standard', 'Chen', 'EKF-LE', 'AFEKF');
fprintf('%s\n', repmat('-', 1, 85));
fprintf('%-25s | %.4f     | %.4f     | %.4f     | %.4f\n', ...
    'Case 1 (Clean)', Stats_c1.Normal.Pipe1_RMSE, Stats_c1.Chen.Pipe1_RMSE, Stats_c1.Adaptive.Pipe1_RMSE, Stats_c1.AFEKF.Pipe1_RMSE);
fprintf('%-25s | %.4f     | %.4f     | %.4f     | %.4f\n', ...
    'Case 2 (10dB outlier)', Stats_c2_10.Normal.Pipe1_RMSE, Stats_c2_10.Chen.Pipe1_RMSE, Stats_c2_10.Adaptive.Pipe1_RMSE, Stats_c2_10.AFEKF.Pipe1_RMSE);
fprintf('%-25s | %.4f     | %.4f     | %.4f     | %.4f\n', ...
    'Case 3 (Outlier+Leak)', Stats_c3.Normal.Pipe1_RMSE, Stats_c3.Chen.Pipe1_RMSE, Stats_c3.Adaptive.Pipe1_RMSE, Stats_c3.AFEKF.Pipe1_RMSE);
fprintf('%-25s | %.4f     | %.4f     | %.4f     | %.4f\n', ...
    'Case 4 (Pure Leak)', Stats_c4.Normal.Pipe1_RMSE, Stats_c4.Chen.Pipe1_RMSE, Stats_c4.Adaptive.Pipe1_RMSE, Stats_c4.AFEKF.Pipe1_RMSE);
fprintf('%s\n', repmat('-', 1, 85));

% -------------------------------
% Pipe 5 RMSE Summary
% -------------------------------
fprintf('\nPipe 5 RMSE Summary [kg/s]:\n');
fprintf('%-25s | %-10s | %-10s | %-10s | %-10s\n', 'Case', 'Standard', 'Chen', 'EKF-LE', 'AFEKF');
fprintf('%s\n', repmat('-', 1, 85));
fprintf('%-25s | %.4f     | %.4f     | %.4f     | %.4f\n', ...
    'Case 1 (Clean)', Stats_c1.Normal.Pipe5_RMSE, Stats_c1.Chen.Pipe5_RMSE, Stats_c1.Adaptive.Pipe5_RMSE, Stats_c1.AFEKF.Pipe5_RMSE);
fprintf('%-25s | %.4f     | %.4f     | %.4f     | %.4f\n', ...
    'Case 2 (10dB outlier)', Stats_c2_10.Normal.Pipe5_RMSE, Stats_c2_10.Chen.Pipe5_RMSE, Stats_c2_10.Adaptive.Pipe5_RMSE, Stats_c2_10.AFEKF.Pipe5_RMSE);
fprintf('%-25s | %.4f     | %.4f     | %.4f     | %.4f\n', ...
    'Case 3 (Outlier+Leak)', Stats_c3.Normal.Pipe5_RMSE, Stats_c3.Chen.Pipe5_RMSE, Stats_c3.Adaptive.Pipe5_RMSE, Stats_c3.AFEKF.Pipe5_RMSE);
fprintf('%-25s | %.4f     | %.4f     | %.4f     | %.4f\n', ...
    'Case 4 (Pure Leak)', Stats_c4.Normal.Pipe5_RMSE, Stats_c4.Chen.Pipe5_RMSE, Stats_c4.Adaptive.Pipe5_RMSE, Stats_c4.AFEKF.Pipe5_RMSE);
fprintf('%s\n', repmat('-', 1, 85));

% -------------------------------
% (Pipe1 + Pipe5)/2 Average RMSE Summary
% -------------------------------
fprintf('\nAverage RMSE [kg/s]:\n');
fprintf('%-25s | %-10s | %-10s | %-10s | %-10s\n', 'Case', 'Standard', 'Chen', 'EKF-LE', 'AFEKF');
fprintf('%s\n', repmat('-', 1, 85));

% helper inline (avoid repetition)
avg = @(a,b) 0.5*(a+b);

fprintf('%-25s | %.4f     | %.4f     | %.4f     | %.4f\n', ...
    'Case 1 (Clean)', ...
    avg(Stats_c1.Normal.Pipe1_RMSE,    Stats_c1.Normal.Pipe5_RMSE), ...
    avg(Stats_c1.Chen.Pipe1_RMSE,      Stats_c1.Chen.Pipe5_RMSE), ...
    avg(Stats_c1.Adaptive.Pipe1_RMSE,  Stats_c1.Adaptive.Pipe5_RMSE), ...
    avg(Stats_c1.AFEKF.Pipe1_RMSE,     Stats_c1.AFEKF.Pipe5_RMSE));

fprintf('%-25s | %.4f     | %.4f     | %.4f     | %.4f\n', ...
    'Case 2 (10dB outlier)', ...
    avg(Stats_c2_10.Normal.Pipe1_RMSE,    Stats_c2_10.Normal.Pipe5_RMSE), ...
    avg(Stats_c2_10.Chen.Pipe1_RMSE,      Stats_c2_10.Chen.Pipe5_RMSE), ...
    avg(Stats_c2_10.Adaptive.Pipe1_RMSE,  Stats_c2_10.Adaptive.Pipe5_RMSE), ...
    avg(Stats_c2_10.AFEKF.Pipe1_RMSE,     Stats_c2_10.AFEKF.Pipe5_RMSE));

fprintf('%-25s | %.4f     | %.4f     | %.4f     | %.4f\n', ...
    'Case 3 (Outlier+Leak)', ...
    avg(Stats_c3.Normal.Pipe1_RMSE,    Stats_c3.Normal.Pipe5_RMSE), ...
    avg(Stats_c3.Chen.Pipe1_RMSE,      Stats_c3.Chen.Pipe5_RMSE), ...
    avg(Stats_c3.Adaptive.Pipe1_RMSE,  Stats_c3.Adaptive.Pipe5_RMSE), ...
    avg(Stats_c3.AFEKF.Pipe1_RMSE,     Stats_c3.AFEKF.Pipe5_RMSE));

fprintf('%-25s | %.4f     | %.4f     | %.4f     | %.4f\n', ...
    'Case 4 (Pure Leak)', ...
    avg(Stats_c4.Normal.Pipe1_RMSE,    Stats_c4.Normal.Pipe5_RMSE), ...
    avg(Stats_c4.Chen.Pipe1_RMSE,      Stats_c4.Chen.Pipe5_RMSE), ...
    avg(Stats_c4.Adaptive.Pipe1_RMSE,  Stats_c4.Adaptive.Pipe5_RMSE), ...
    avg(Stats_c4.AFEKF.Pipe1_RMSE,     Stats_c4.AFEKF.Pipe5_RMSE));

fprintf('%s\n', repmat('-', 1, 85));

% 你原本的整体平均提升那段可以继续保留（如果你想）
avg_std  = mean([Stats_c1.Normal.Pipe1_RMSE, Stats_c2_10.Normal.Pipe1_RMSE, Stats_c2_20.Normal.Pipe1_RMSE, Stats_c3.Normal.Pipe1_RMSE, Stats_c4.Normal.Pipe1_RMSE]);
avg_chen = mean([Stats_c1.Chen.Pipe1_RMSE,   Stats_c2_10.Chen.Pipe1_RMSE,   Stats_c2_20.Chen.Pipe1_RMSE,   Stats_c3.Chen.Pipe1_RMSE,   Stats_c4.Chen.Pipe1_RMSE]);
avg_ekfle= mean([Stats_c1.Adaptive.Pipe1_RMSE,Stats_c2_10.Adaptive.Pipe1_RMSE,Stats_c2_20.Adaptive.Pipe1_RMSE,Stats_c3.Adaptive.Pipe1_RMSE,Stats_c4.Adaptive.Pipe1_RMSE]);
avg_afukf= mean([Stats_c1.AFEKF.Pipe1_RMSE,  Stats_c2_10.AFEKF.Pipe1_RMSE,  Stats_c2_20.AFEKF.Pipe1_RMSE,  Stats_c3.AFEKF.Pipe1_RMSE,  Stats_c4.AFEKF.Pipe1_RMSE]);

fprintf('\nAFEKF Improvement (Avg Pipe1_RMSE):\n');
fprintf('  vs Standard EKF: %.1f%%\n', (avg_std - avg_afukf) / avg_std * 100);
fprintf('  vs Chen Robust:  %.1f%%\n', (avg_chen - avg_afukf) / avg_chen * 100);
fprintf('  vs EKF-LE:       %.1f%%\n', (avg_ekfle - avg_afukf) / avg_ekfle * 100);

end



% =========================================================================
% SAVE TO EXCEL
% =========================================================================
function save_comprehensive_results_four_methods(Stats_c1, Stats_c2_10, Stats_c2_20, Stats_c3, Stats_c4, filename)

T1 = table();
T1.Case = {'Case1_Clean'; 'Case2_10dB'; 'Case3_Out_Leak'; 'Case4_Pure_Leak'};
T1.Standard_EKF = [Stats_c1.Normal.Pipe1_RMSE; Stats_c2_10.Normal.Pipe1_RMSE; Stats_c3.Normal.Pipe1_RMSE; Stats_c4.Normal.Pipe1_RMSE];
T1.Chen_Robust = [Stats_c1.Chen.Pipe1_RMSE; Stats_c2_10.Chen.Pipe1_RMSE; Stats_c3.Chen.Pipe1_RMSE; Stats_c4.Chen.Pipe1_RMSE];
T1.EKF_LE = [Stats_c1.Adaptive.Pipe1_RMSE; Stats_c2_10.Adaptive.Pipe1_RMSE; Stats_c3.Adaptive.Pipe1_RMSE; Stats_c4.Adaptive.Pipe1_RMSE];
T1.AFEKF = [Stats_c1.AFEKF.Pipe1_RMSE; Stats_c2_10.AFEKF.Pipe1_RMSE; Stats_c3.AFEKF.Pipe1_RMSE; Stats_c4.AFEKF.Pipe1_RMSE];
T1.AFEKF_vs_Std_pct = (T1.Standard_EKF - T1.AFEKF) ./ T1.Standard_EKF * 100;
%T1.Case = {'Case1_Clean'; 'Case2_10dB'; 'Case2_20dB'; 'Case3_Out_Leak'; 'Case4_Pure_Leak'};
%T1.Standard_EKF = [Stats_c1.Normal.Pipe1_RMSE; Stats_c2_10.Normal.Pipe1_RMSE; Stats_c2_20.Normal.Pipe1_RMSE; Stats_c3.Normal.Pipe1_RMSE; Stats_c4.Normal.Pipe1_RMSE];
%T1.Chen_Robust = [Stats_c1.Chen.Pipe1_RMSE; Stats_c2_10.Chen.Pipe1_RMSE; Stats_c2_20.Chen.Pipe1_RMSE; Stats_c3.Chen.Pipe1_RMSE; Stats_c4.Chen.Pipe1_RMSE];
%T1.EKF_LE = [Stats_c1.Adaptive.Pipe1_RMSE; Stats_c2_10.Adaptive.Pipe1_RMSE; Stats_c2_20.Adaptive.Pipe1_RMSE; Stats_c3.Adaptive.Pipe1_RMSE; Stats_c4.Adaptive.Pipe1_RMSE];
%T1.AFEKF = [Stats_c1.AFEKF.Pipe1_RMSE; Stats_c2_10.AFEKF.Pipe1_RMSE; Stats_c2_20.AFEKF.Pipe1_RMSE; Stats_c3.AFEKF.Pipe1_RMSE; Stats_c4.AFEKF.Pipe1_RMSE];
%T1.AFEKF_vs_Std_pct = (T1.Standard_EKF - T1.AFEKF) ./ T1.Standard_EKF * 100;
writetable(T1, filename, 'Sheet', 'Pipe1_RMSE');

T2 = table();
T2.Case = T1.Case;
T2.Standard_EKF = [Stats_c1.Normal.Pipe5_RMSE; Stats_c2_10.Normal.Pipe5_RMSE; Stats_c3.Normal.Pipe5_RMSE; Stats_c4.Normal.Pipe5_RMSE];
T2.Chen_Robust = [Stats_c1.Chen.Pipe5_RMSE; Stats_c2_10.Chen.Pipe5_RMSE; Stats_c3.Chen.Pipe5_RMSE; Stats_c4.Chen.Pipe5_RMSE];
T2.EKF_LE = [Stats_c1.Adaptive.Pipe5_RMSE; Stats_c2_10.Adaptive.Pipe5_RMSE; Stats_c3.Adaptive.Pipe5_RMSE; Stats_c4.Adaptive.Pipe5_RMSE];
T2.AFEKF = [Stats_c1.AFEKF.Pipe5_RMSE; Stats_c2_10.AFEKF.Pipe5_RMSE; Stats_c3.AFEKF.Pipe5_RMSE; Stats_c4.AFEKF.Pipe5_RMSE];
T2.AFEKF_vs_Std_pct = (T2.Standard_EKF - T2.AFEKF) ./ T2.Standard_EKF * 100;
%T2.Standard_EKF = [Stats_c1.Normal.Pipe5_RMSE; Stats_c2_10.Normal.Pipe5_RMSE; Stats_c2_20.Normal.Pipe5_RMSE; Stats_c3.Normal.Pipe5_RMSE; Stats_c4.Normal.Pipe5_RMSE];
%T2.Chen_Robust = [Stats_c1.Chen.Pipe5_RMSE; Stats_c2_10.Chen.Pipe5_RMSE; Stats_c2_20.Chen.Pipe5_RMSE; Stats_c3.Chen.Pipe5_RMSE; Stats_c4.Chen.Pipe5_RMSE];
%T2.EKF_LE = [Stats_c1.Adaptive.Pipe5_RMSE; Stats_c2_10.Adaptive.Pipe5_RMSE; Stats_c2_20.Adaptive.Pipe5_RMSE; Stats_c3.Adaptive.Pipe5_RMSE; Stats_c4.Adaptive.Pipe5_RMSE];
%T2.AFEKF = [Stats_c1.AFEKF.Pipe5_RMSE; Stats_c2_10.AFEKF.Pipe5_RMSE; Stats_c2_20.AFEKF.Pipe5_RMSE; Stats_c3.AFEKF.Pipe5_RMSE; Stats_c4.AFEKF.Pipe5_RMSE];
%T2.AFEKF_vs_Std_pct = (T2.Standard_EKF - T2.AFEKF) ./ T2.Standard_EKF * 100;
writetable(T2, filename, 'Sheet', 'Pipe5_RMSE');

T3 = table();
T3.Case = T1.Case;
T3.Standard_EKF = [Stats_c1.Normal.M_RMSE; Stats_c2_10.Normal.M_RMSE; Stats_c3.Normal.M_RMSE; Stats_c4.Normal.M_RMSE];
T3.Chen_Robust = [Stats_c1.Chen.M_RMSE; Stats_c2_10.Chen.M_RMSE; Stats_c3.Chen.M_RMSE; Stats_c4.Chen.M_RMSE];
T3.EKF_LE = [Stats_c1.Adaptive.M_RMSE; Stats_c2_10.Adaptive.M_RMSE; Stats_c3.Adaptive.M_RMSE; Stats_c4.Adaptive.M_RMSE];
T3.AFEKF = [Stats_c1.AFEKF.M_RMSE; Stats_c2_10.AFEKF.M_RMSE; Stats_c3.AFEKF.M_RMSE; Stats_c4.AFEKF.M_RMSE];

%T3.Standard_EKF = [Stats_c1.Normal.M_RMSE; Stats_c2_10.Normal.M_RMSE; Stats_c2_20.Normal.M_RMSE; Stats_c3.Normal.M_RMSE; Stats_c4.Normal.M_RMSE];
%T3.Chen_Robust = [Stats_c1.Chen.M_RMSE; Stats_c2_10.Chen.M_RMSE; Stats_c2_20.Chen.M_RMSE; Stats_c3.Chen.M_RMSE; Stats_c4.Chen.M_RMSE];
%T3.EKF_LE = [Stats_c1.Adaptive.M_RMSE; Stats_c2_10.Adaptive.M_RMSE; Stats_c2_20.Adaptive.M_RMSE; Stats_c3.Adaptive.M_RMSE; Stats_c4.Adaptive.M_RMSE];
%T3.AFEKF = [Stats_c1.AFEKF.M_RMSE; Stats_c2_10.AFEKF.M_RMSE; Stats_c2_20.AFEKF.M_RMSE; Stats_c3.AFEKF.M_RMSE; Stats_c4.AFEKF.M_RMSE];
writetable(T3, filename, 'Sheet', 'Flow_RMSE');

if isfield(Stats_c3.Normal, 'P_RMSE_Normal')
    T_c3 = table();
    T_c3.Metric = {'P_RMSE_Normal'; 'P_RMSE_Leak'; 'M_RMSE_Normal'; 'M_RMSE_Leak'; 'Pipe1_RMSE_Normal'; 'Pipe1_RMSE_Leak'; 'Pipe5_RMSE_Normal'; 'Pipe5_RMSE_Leak'};
    T_c3.Standard_EKF = [Stats_c3.Normal.P_RMSE_Normal; Stats_c3.Normal.P_RMSE_Leak; Stats_c3.Normal.M_RMSE_Normal; Stats_c3.Normal.M_RMSE_Leak; Stats_c3.Normal.Pipe1_RMSE_Normal; Stats_c3.Normal.Pipe1_RMSE_Leak; Stats_c3.Normal.Pipe5_RMSE_Normal; Stats_c3.Normal.Pipe5_RMSE_Leak];
    T_c3.Chen_Robust = [Stats_c3.Chen.P_RMSE_Normal; Stats_c3.Chen.P_RMSE_Leak; Stats_c3.Chen.M_RMSE_Normal; Stats_c3.Chen.M_RMSE_Leak; Stats_c3.Chen.Pipe1_RMSE_Normal; Stats_c3.Chen.Pipe1_RMSE_Leak; Stats_c3.Chen.Pipe5_RMSE_Normal; Stats_c3.Chen.Pipe5_RMSE_Leak];
    T_c3.EKF_LE = [Stats_c3.Adaptive.P_RMSE_Normal; Stats_c3.Adaptive.P_RMSE_Leak; Stats_c3.Adaptive.M_RMSE_Normal; Stats_c3.Adaptive.M_RMSE_Leak; Stats_c3.Adaptive.Pipe1_RMSE_Normal; Stats_c3.Adaptive.Pipe1_RMSE_Leak; Stats_c3.Adaptive.Pipe5_RMSE_Normal; Stats_c3.Adaptive.Pipe5_RMSE_Leak];
    T_c3.AFEKF = [Stats_c3.AFEKF.P_RMSE_Normal; Stats_c3.AFEKF.P_RMSE_Leak; Stats_c3.AFEKF.M_RMSE_Normal; Stats_c3.AFEKF.M_RMSE_Leak; Stats_c3.AFEKF.Pipe1_RMSE_Normal; Stats_c3.AFEKF.Pipe1_RMSE_Leak; Stats_c3.AFEKF.Pipe5_RMSE_Normal; Stats_c3.AFEKF.Pipe5_RMSE_Leak];
    writetable(T_c3, filename, 'Sheet', 'Case3_Normal_vs_Leak');
end

if isfield(Stats_c4.Normal, 'P_RMSE_Normal')
    T_c4 = table();
    T_c4.Metric = {'P_RMSE_Normal'; 'P_RMSE_Leak'; 'M_RMSE_Normal'; 'M_RMSE_Leak'; 'Pipe1_RMSE_Normal'; 'Pipe1_RMSE_Leak'; 'Pipe5_RMSE_Normal'; 'Pipe5_RMSE_Leak'};
    T_c4.Standard_EKF = [Stats_c4.Normal.P_RMSE_Normal; Stats_c4.Normal.P_RMSE_Leak; Stats_c4.Normal.M_RMSE_Normal; Stats_c4.Normal.M_RMSE_Leak; Stats_c4.Normal.Pipe1_RMSE_Normal; Stats_c4.Normal.Pipe1_RMSE_Leak; Stats_c4.Normal.Pipe5_RMSE_Normal; Stats_c4.Normal.Pipe5_RMSE_Leak];
    T_c4.Chen_Robust = [Stats_c4.Chen.P_RMSE_Normal; Stats_c4.Chen.P_RMSE_Leak; Stats_c4.Chen.M_RMSE_Normal; Stats_c4.Chen.M_RMSE_Leak; Stats_c4.Chen.Pipe1_RMSE_Normal; Stats_c4.Chen.Pipe1_RMSE_Leak; Stats_c4.Chen.Pipe5_RMSE_Normal; Stats_c4.Chen.Pipe5_RMSE_Leak];
    T_c4.EKF_LE = [Stats_c4.Adaptive.P_RMSE_Normal; Stats_c4.Adaptive.P_RMSE_Leak; Stats_c4.Adaptive.M_RMSE_Normal; Stats_c4.Adaptive.M_RMSE_Leak; Stats_c4.Adaptive.Pipe1_RMSE_Normal; Stats_c4.Adaptive.Pipe1_RMSE_Leak; Stats_c4.Adaptive.Pipe5_RMSE_Normal; Stats_c4.Adaptive.Pipe5_RMSE_Leak];
    T_c4.AFEKF = [Stats_c4.AFEKF.P_RMSE_Normal; Stats_c4.AFEKF.P_RMSE_Leak; Stats_c4.AFEKF.M_RMSE_Normal; Stats_c4.AFEKF.M_RMSE_Leak; Stats_c4.AFEKF.Pipe1_RMSE_Normal; Stats_c4.AFEKF.Pipe1_RMSE_Leak; Stats_c4.AFEKF.Pipe5_RMSE_Normal; Stats_c4.AFEKF.Pipe5_RMSE_Leak];
    writetable(T_c4, filename, 'Sheet', 'Case4_Normal_vs_Leak');
end

T_sum = table();
T_sum.Metric = {'Avg_Pipe1_RMSE'; 'Avg_Pipe5_RMSE'; 'Avg_Flow_RMSE'};
T_sum.Standard_EKF = [
    mean([Stats_c1.Normal.Pipe1_RMSE, Stats_c2_10.Normal.Pipe1_RMSE, Stats_c3.Normal.Pipe1_RMSE, Stats_c4.Normal.Pipe1_RMSE]);
    mean([Stats_c1.Normal.Pipe5_RMSE, Stats_c2_10.Normal.Pipe5_RMSE, Stats_c3.Normal.Pipe5_RMSE, Stats_c4.Normal.Pipe5_RMSE]);
    mean([Stats_c1.Normal.M_RMSE, Stats_c2_10.Normal.M_RMSE, Stats_c3.Normal.M_RMSE, Stats_c4.Normal.M_RMSE])
%    mean([Stats_c1.Normal.Pipe1_RMSE, Stats_c2_10.Normal.Pipe1_RMSE, Stats_c2_20.Normal.Pipe1_RMSE, Stats_c3.Normal.Pipe1_RMSE, Stats_c4.Normal.Pipe1_RMSE]);
%    mean([Stats_c1.Normal.Pipe5_RMSE, Stats_c2_10.Normal.Pipe5_RMSE, Stats_c2_20.Normal.Pipe5_RMSE, Stats_c3.Normal.Pipe5_RMSE, Stats_c4.Normal.Pipe5_RMSE]);
%    mean([Stats_c1.Normal.M_RMSE, Stats_c2_10.Normal.M_RMSE, Stats_c2_20.Normal.M_RMSE, Stats_c3.Normal.M_RMSE, Stats_c4.Normal.M_RMSE])
];
T_sum.Chen_Robust = [
    mean([Stats_c1.Chen.Pipe1_RMSE, Stats_c2_10.Chen.Pipe1_RMSE, Stats_c3.Chen.Pipe1_RMSE, Stats_c4.Chen.Pipe1_RMSE]);
    mean([Stats_c1.Chen.Pipe5_RMSE, Stats_c2_10.Chen.Pipe5_RMSE, Stats_c3.Chen.Pipe5_RMSE, Stats_c4.Chen.Pipe5_RMSE]);
    mean([Stats_c1.Chen.M_RMSE, Stats_c2_10.Chen.M_RMSE, Stats_c3.Chen.M_RMSE, Stats_c4.Chen.M_RMSE])

%    mean([Stats_c1.Chen.Pipe1_RMSE, Stats_c2_10.Chen.Pipe1_RMSE, Stats_c2_20.Chen.Pipe1_RMSE, Stats_c3.Chen.Pipe1_RMSE, Stats_c4.Chen.Pipe1_RMSE]);
%    mean([Stats_c1.Chen.Pipe5_RMSE, Stats_c2_10.Chen.Pipe5_RMSE, Stats_c2_20.Chen.Pipe5_RMSE, Stats_c3.Chen.Pipe5_RMSE, Stats_c4.Chen.Pipe5_RMSE]);
%    mean([Stats_c1.Chen.M_RMSE, Stats_c2_10.Chen.M_RMSE, Stats_c2_20.Chen.M_RMSE, Stats_c3.Chen.M_RMSE, Stats_c4.Chen.M_RMSE])
];
T_sum.EKF_LE = [
    mean([Stats_c1.Adaptive.Pipe1_RMSE, Stats_c2_10.Adaptive.Pipe1_RMSE, Stats_c3.Adaptive.Pipe1_RMSE, Stats_c4.Adaptive.Pipe1_RMSE]);
    mean([Stats_c1.Adaptive.Pipe5_RMSE, Stats_c2_10.Adaptive.Pipe5_RMSE, Stats_c3.Adaptive.Pipe5_RMSE, Stats_c4.Adaptive.Pipe5_RMSE]);
    mean([Stats_c1.Adaptive.M_RMSE, Stats_c2_10.Adaptive.M_RMSE, Stats_c3.Adaptive.M_RMSE, Stats_c4.Adaptive.M_RMSE])

%    mean([Stats_c1.Adaptive.Pipe1_RMSE, Stats_c2_10.Adaptive.Pipe1_RMSE, Stats_c2_20.Adaptive.Pipe1_RMSE, Stats_c3.Adaptive.Pipe1_RMSE, Stats_c4.Adaptive.Pipe1_RMSE]);
%    mean([Stats_c1.Adaptive.Pipe5_RMSE, Stats_c2_10.Adaptive.Pipe5_RMSE, Stats_c2_20.Adaptive.Pipe5_RMSE, Stats_c3.Adaptive.Pipe5_RMSE, Stats_c4.Adaptive.Pipe5_RMSE]);
%    mean([Stats_c1.Adaptive.M_RMSE, Stats_c2_10.Adaptive.M_RMSE, Stats_c2_20.Adaptive.M_RMSE, Stats_c3.Adaptive.M_RMSE, Stats_c4.Adaptive.M_RMSE])
];
T_sum.AFEKF = [
    mean([Stats_c1.AFEKF.Pipe1_RMSE, Stats_c2_10.AFEKF.Pipe1_RMSE,  Stats_c3.AFEKF.Pipe1_RMSE, Stats_c4.AFEKF.Pipe1_RMSE]);
    mean([Stats_c1.AFEKF.Pipe5_RMSE, Stats_c2_10.AFEKF.Pipe5_RMSE,  Stats_c3.AFEKF.Pipe5_RMSE, Stats_c4.AFEKF.Pipe5_RMSE]);
    mean([Stats_c1.AFEKF.M_RMSE, Stats_c2_10.AFEKF.M_RMSE, Stats_c3.AFEKF.M_RMSE, Stats_c4.AFEKF.M_RMSE])

%    mean([Stats_c1.AFEKF.Pipe1_RMSE, Stats_c2_10.AFEKF.Pipe1_RMSE, Stats_c2_20.AFEKF.Pipe1_RMSE, Stats_c3.AFEKF.Pipe1_RMSE, Stats_c4.AFEKF.Pipe1_RMSE]);
%    mean([Stats_c1.AFEKF.Pipe5_RMSE, Stats_c2_10.AFEKF.Pipe5_RMSE, Stats_c2_20.AFEKF.Pipe5_RMSE, Stats_c3.AFEKF.Pipe5_RMSE, Stats_c4.AFEKF.Pipe5_RMSE]);
%    mean([Stats_c1.AFEKF.M_RMSE, Stats_c2_10.AFEKF.M_RMSE, Stats_c2_20.AFEKF.M_RMSE, Stats_c3.AFEKF.M_RMSE, Stats_c4.AFEKF.M_RMSE])
];
T_sum.AFEKF_Improvement_vs_Std_pct = (T_sum.Standard_EKF - T_sum.AFEKF) ./ T_sum.Standard_EKF * 100;
writetable(T_sum, filename, 'Sheet', 'Summary');

fprintf('Excel results saved: %s\n', filename);
end


% =========================================================================
% EXPORT TO CSV
% =========================================================================
function export_results_to_csv_four(Stats_c1, Stats_c2_10, Stats_c2_20, Stats_c3, Stats_c4, output_dir)

if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

T1 = table();
T1.Case = {'Case1_Clean'; 'Case2_10dB'; 'Case2_20dB'; 'Case3_Outlier_Leak'; 'Case4_Pure_Leak'};
T1.Standard_EKF = [Stats_c1.Normal.Pipe1_RMSE; Stats_c2_10.Normal.Pipe1_RMSE; Stats_c2_20.Normal.Pipe1_RMSE; Stats_c3.Normal.Pipe1_RMSE; Stats_c4.Normal.Pipe1_RMSE];
T1.Chen_Robust = [Stats_c1.Chen.Pipe1_RMSE; Stats_c2_10.Chen.Pipe1_RMSE; Stats_c2_20.Chen.Pipe1_RMSE; Stats_c3.Chen.Pipe1_RMSE; Stats_c4.Chen.Pipe1_RMSE];
T1.EKF_LE = [Stats_c1.Adaptive.Pipe1_RMSE; Stats_c2_10.Adaptive.Pipe1_RMSE; Stats_c2_20.Adaptive.Pipe1_RMSE; Stats_c3.Adaptive.Pipe1_RMSE; Stats_c4.Adaptive.Pipe1_RMSE];
T1.AFEKF = [Stats_c1.AFEKF.Pipe1_RMSE; Stats_c2_10.AFEKF.Pipe1_RMSE; Stats_c2_20.AFEKF.Pipe1_RMSE; Stats_c3.AFEKF.Pipe1_RMSE; Stats_c4.AFEKF.Pipe1_RMSE];
writetable(T1, fullfile(output_dir, 'Pipe1_RMSE_4Methods.csv'));

T2 = table();
T2.Case = T1.Case;
T2.Standard_EKF = [Stats_c1.Normal.Pipe5_RMSE; Stats_c2_10.Normal.Pipe5_RMSE; Stats_c2_20.Normal.Pipe5_RMSE; Stats_c3.Normal.Pipe5_RMSE; Stats_c4.Normal.Pipe5_RMSE];
T2.Chen_Robust = [Stats_c1.Chen.Pipe5_RMSE; Stats_c2_10.Chen.Pipe5_RMSE; Stats_c2_20.Chen.Pipe5_RMSE; Stats_c3.Chen.Pipe5_RMSE; Stats_c4.Chen.Pipe5_RMSE];
T2.EKF_LE = [Stats_c1.Adaptive.Pipe5_RMSE; Stats_c2_10.Adaptive.Pipe5_RMSE; Stats_c2_20.Adaptive.Pipe5_RMSE; Stats_c3.Adaptive.Pipe5_RMSE; Stats_c4.Adaptive.Pipe5_RMSE];
T2.AFEKF = [Stats_c1.AFEKF.Pipe5_RMSE; Stats_c2_10.AFEKF.Pipe5_RMSE; Stats_c2_20.AFEKF.Pipe5_RMSE; Stats_c3.AFEKF.Pipe5_RMSE; Stats_c4.AFEKF.Pipe5_RMSE];
writetable(T2, fullfile(output_dir, 'Pipe5_RMSE_4Methods.csv'));

T3 = table();
T3.Case = T1.Case;
T3.Standard_EKF = [Stats_c1.Normal.M_RMSE; Stats_c2_10.Normal.M_RMSE; Stats_c2_20.Normal.M_RMSE; Stats_c3.Normal.M_RMSE; Stats_c4.Normal.M_RMSE];
T3.Chen_Robust = [Stats_c1.Chen.M_RMSE; Stats_c2_10.Chen.M_RMSE; Stats_c2_20.Chen.M_RMSE; Stats_c3.Chen.M_RMSE; Stats_c4.Chen.M_RMSE];
T3.EKF_LE = [Stats_c1.Adaptive.M_RMSE; Stats_c2_10.Adaptive.M_RMSE; Stats_c2_20.Adaptive.M_RMSE; Stats_c3.Adaptive.M_RMSE; Stats_c4.Adaptive.M_RMSE];
T3.AFEKF = [Stats_c1.AFEKF.M_RMSE; Stats_c2_10.AFEKF.M_RMSE; Stats_c2_20.AFEKF.M_RMSE; Stats_c3.AFEKF.M_RMSE; Stats_c4.AFEKF.M_RMSE];
writetable(T3, fullfile(output_dir, 'Flow_RMSE_4Methods.csv'));

fprintf('CSV files exported to: %s\n', output_dir);
end