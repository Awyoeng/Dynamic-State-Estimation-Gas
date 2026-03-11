function dse_main_three_cases()
% DSE_MAIN_THREE_CASES - Four-case EKF comparison test
% Case 1: Clean data (no outliers, no leaks)
% Case 2: Sparse outliers (6h-12h, 2 per hour, 10dB/20dB)
% Case 3: Outliers (6h-12h) + Leak (12h-18h)
% Case 4: Pure leak (12h-24h)

clc; clear; close all;

% System parameters
Sys.c = 340;
Sys.c2 = 340^2;
Sys.dt = 600;
Sys.Hours = 24;

% Load network data
[Nodes, Pipes, Compressors, GTU] = dse_1_load_data('gas_data.xlsx');

fprintf('\nFour-Case EKF Comparison Test\n');
fprintf('Case 1: Clean data\n');
fprintf('Case 2: Sparse outliers (6h-12h)\n');
fprintf('Case 3: Outliers + Leak\n');
fprintf('Case 4: Pure leak\n\n');

% CASE 1: Clean data
fprintf('CASE 1: Clean data (no outliers, no leaks)\n');

Leaks_empty = table([],[],[],[],[],...
    'VariableNames',{'PipeID','StartTime_s','EndTime_s','LeakRate_kg_s','Position'});

[H_True_c1, Z_clean, t, ~, P_GTU] = ...
    dse_3_gen_data_leak(Nodes, Pipes, Compressors, Sys, Leaks_empty, GTU);

[H_Normal_c1, H_Chen_c1, H_Adaptive_c1, Stats_c1, ~, Diag_c1] = ...
    run_three_methods(Z_clean, H_True_c1, Nodes, Pipes, Compressors, Sys, t, GTU, true, [], []);

plot_case1(H_True_c1, Z_clean, H_Normal_c1, H_Chen_c1, H_Adaptive_c1, ...
    Nodes, Pipes, Sys, t, GTU);

save_case_results('Case1_Clean', Stats_c1);

% CASE 2: Sparse outlier injection
fprintf('\nCASE 2: Sparse outliers (sensor faults)\n');
fprintf('Timeline: 0-6h normal | 6h-12h outliers | 12h-24h normal\n');

N = length(t);
nN = height(Nodes);

outlier_config.start_step = round(N * 0.25);
outlier_config.end_step = round(N * 0.5);
outlier_config.target_nodes = [2, 3, 4, 5, 6, 7, 8, 9, 10];
outlier_config.target_pipes = [1, 2, 3, 4, 6, 7, 8, 9, 10];
outlier_config.outliers_per_hour = 2;
outlier_config.nN = nN;

fprintf('\n--- Test 1: 10dB sparse outliers ---\n');
[Z_outlier_300, outlier_info_300] = inject_outlier_sparse(Z_clean, outlier_config, Sys, 10);
[H_Normal_c2_300, H_Chen_c2_300, H_Adaptive_c2_300, Stats_c2_300, ~, Diag_c2_300] = ...
    run_three_methods(Z_outlier_300, H_True_c1, Nodes, Pipes, Compressors, Sys, t, GTU, true, [6, 12], outlier_info_300);

fprintf('\n--- Test 2: 20dB sparse outliers ---\n');
[Z_outlier_500, outlier_info_500] = inject_outlier_sparse(Z_clean, outlier_config, Sys, 20);
[H_Normal_c2_500, H_Chen_c2_500, H_Adaptive_c2_500, Stats_c2_500, ~, Diag_c2_500] = ...
    run_three_methods(Z_outlier_500, H_True_c1, Nodes, Pipes, Compressors, Sys, t, GTU, true, [6, 12], outlier_info_500);

plot_case2(H_True_c1, Z_outlier_300, H_Normal_c2_300, H_Chen_c2_300, H_Adaptive_c2_300, ...
    Nodes, Pipes, Sys, t, GTU, outlier_config, outlier_info_300);

save_case2_results('Case2_Outlier_Burst', Stats_c2_300, Stats_c2_500);

% CASE 3: Outliers + Leak
fprintf('\nCASE 3: Outliers + Leak\n');
fprintf('Timeline: 0-6h normal | 6h-12h outliers | 12h-18h leak | 18h-24h normal\n');

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

[Z_outlier_300_c3, outlier_info_300] = inject_outlier_sparse(Z_leak_clean_c3, outlier_config, Sys, 10);

[H_Normal_c3, H_Chen_c3, H_Adaptive_c3, Stats_c3, Leak_Est_c3, Diag_c3] = ...
    run_three_methods_with_leak_stats(Z_outlier_300_c3, H_True_c3, Nodes, Pipes, Compressors, Sys, t, GTU, ...
                                       true, 12, 18, [6, 12], outlier_info_300);

plot_case3_simplified(H_True_c3, Z_outlier_300_c3, H_Normal_c3, H_Chen_c3, H_Adaptive_c3, ...
    Nodes, Pipes, Sys, t, GTU, Leaks_c3, outlier_config, outlier_info_300);

save_case3_results('Case3_Out_Leak', Stats_c3, Leak_True_c3, Leak_Est_c3);

% CASE 4: Pure leak
fprintf('\nCASE 4: Pure leak (no outliers)\n');
fprintf('Timeline: 0-12h normal | 12h-24h leak\n');

Leaks_c4 = dse_load_leak('leak.xlsx');
if height(Leaks_c4) > 0
    Leaks_c4.StartTime_s(1) = 12 * 3600;
    Leaks_c4.EndTime_s(1) = 24 * 3600;
    fprintf('Leak config: 12h-24h, rate %.1f kg/s\n', Leaks_c4.LeakRate_kg_s(1));
end

[H_True_c4, Z_clean_c4, t, Leak_True_c4, P_GTU] = ...
    dse_3_gen_data_leak(Nodes, Pipes, Compressors, Sys, Leaks_c4, GTU);

[H_Normal_c4, H_Chen_c4, H_Adaptive_c4, Stats_c4, Leak_Est_c4, Diag_c4] = ...
    run_three_methods_with_leak_stats(Z_clean_c4, H_True_c4, Nodes, Pipes, Compressors, Sys, t, GTU, ...
                                       true, 12, 24, [], []);

plot_case4_simplified(H_True_c4, Z_clean_c4, H_Normal_c4, H_Chen_c4, H_Adaptive_c4, ...
    Nodes, Pipes, Sys, t, GTU, Leaks_c4);

save_case4_results('Case4_Pure_Leak', Stats_c4, Leak_True_c4, Leak_Est_c4);

% Summary
fprintf('\nFour-Case RMSE Summary\n');
print_summary_table_four_cases(Stats_c1, Stats_c2_300, Stats_c2_500, Stats_c3, Stats_c4);

save_comprehensive_results_four_cases(Stats_c1, Stats_c2_300, Stats_c2_500, Stats_c3, Stats_c4, ...
    'Comprehensive_Results_4Cases.xlsx');

fprintf('\nExporting CSV results\n');

if ~exist('csv_results', 'dir')
    mkdir('csv_results');
end

export_results_to_csv(Stats_c1, Stats_c2_300, Stats_c2_500, Stats_c3, Stats_c4, './csv_results/');

fprintf('\nAll cases complete.\n');
fprintf('Figures: Case1_*.fig, Case2_*.fig, Case3_*.fig, Case4_*.fig\n');
fprintf('Excel: Comprehensive_Results_4Cases.xlsx\n');
fprintf('CSV: ./csv_results/*.csv\n\n');

end


function [H_Normal, H_Chen, H_Adaptive, Stats, Leak_Est, Diag] = ...
    run_three_methods(Z, H_True, Nodes, Pipes, Compressors, Sys, t, GTU, enable_detector, exclude_ranges, outlier_info)
% Run all three EKF methods and compute statistics

nN = height(Nodes);

if nargin < 11
    outlier_info = [];
end

fprintf('  Running Standard EKF...\n');
H_Normal = dse_normal_ekf(Z, Nodes, Pipes, Compressors, Sys, t, GTU);

fprintf('  Running Chen Robust EKF...\n');
H_Chen = dse_chen_ekf(Z, Nodes, Pipes, Compressors, Sys, t, GTU);

if enable_detector
    fprintf('  Running 3-layer Detector...\n');
    [Det, Diag, Leak_Est_Nodes_from_Det] = dse_leak_detector(H_Normal, Z, Nodes, Pipes, Sys, t);
    
    fprintf('  Running EKF-LE...\n');
    [H_Adaptive, Leak_Est_Nodes_from_EKF] = dse_4_estimator_leak(Z, Nodes, Pipes, Compressors, Sys, t, GTU, Det);
    
    Leak_Est_Nodes = Leak_Est_Nodes_from_EKF;
    Leak_Est = sum(Leak_Est_Nodes, 2);
else
    fprintf('  Running EKF-LE (no detector)...\n');
    Det = false(length(t), 1);
    [H_Adaptive, Leak_Est_Nodes] = dse_4_estimator_leak(Z, Nodes, Pipes, Compressors, Sys, t, GTU, Det);
    Leak_Est = sum(Leak_Est_Nodes, 2);
    
    Diag = struct();
    Diag.Outlier_mask = false(length(t), nN + height(Pipes));
    Diag.Leak_mask = false(length(t), nN + height(Pipes));
    Diag.sigma_copy = zeros(length(t), nN + height(Pipes));
    Diag.d_k = zeros(length(t), nN + height(Pipes));
end

Stats.Normal = calc_stats_simple(H_True, H_Normal, Nodes, Pipes, Sys, t, exclude_ranges, outlier_info);
Stats.Chen = calc_stats_simple(H_True, H_Chen, Nodes, Pipes, Sys, t, exclude_ranges, outlier_info);
Stats.Adaptive = calc_stats_simple(H_True, H_Adaptive, Nodes, Pipes, Sys, t, exclude_ranges, outlier_info);

fprintf('  Result: P_RMSE - Std:%.4f | Chen:%.4f | EKF-LE:%.4f Bar\n', ...
    Stats.Normal.P_RMSE, Stats.Chen.P_RMSE, Stats.Adaptive.P_RMSE);
fprintf('  Result: Pipe5_RMSE - Std:%.4f | Chen:%.4f | EKF-LE:%.4f kg/s\n', ...
    Stats.Normal.Pipe5_RMSE, Stats.Chen.Pipe5_RMSE, Stats.Adaptive.Pipe5_RMSE);
end


function [H_Normal, H_Chen, H_Adaptive, Stats, Leak_Est, Diag] = ...
    run_three_methods_with_leak_stats(Z, H_True, Nodes, Pipes, Compressors, Sys, t, GTU, ...
                                      enable_detector, leak_start_h, leak_end_h, exclude_ranges, outlier_info)
% Run three methods with separate leak period statistics

nN = height(Nodes);

fprintf('  Running Standard EKF...\n');
H_Normal = dse_normal_ekf(Z, Nodes, Pipes, Compressors, Sys, t, GTU);

fprintf('  Running Chen Robust EKF...\n');
H_Chen = dse_chen_ekf(Z, Nodes, Pipes, Compressors, Sys, t, GTU);

if enable_detector
    fprintf('  Running 3-layer Detector...\n');
    [Det, Diag, Leak_Est_Nodes_from_Det] = dse_leak_detector(H_Normal, Z, Nodes, Pipes, Sys, t);
    
    fprintf('  Running EKF-LE...\n');
    [H_Adaptive, Leak_Est_Nodes_from_EKF] = dse_4_estimator_leak(Z, Nodes, Pipes, Compressors, Sys, t, GTU, Det);
    
    Leak_Est_Nodes = Leak_Est_Nodes_from_EKF;
    Leak_Est = sum(Leak_Est_Nodes, 2);
else
    fprintf('  Running EKF-LE (no detector)...\n');
    Det = false(length(t), 1);
    [H_Adaptive, Leak_Est_Nodes] = dse_4_estimator_leak(Z, Nodes, Pipes, Compressors, Sys, t, GTU, Det);
    Leak_Est = sum(Leak_Est_Nodes, 2);
    
    Diag = struct();
    Diag.Outlier_mask = false(length(t), nN + height(Pipes));
    Diag.Leak_mask = false(length(t), nN + height(Pipes));
    Diag.sigma_copy = zeros(length(t), nN + height(Pipes));
    Diag.d_k = zeros(length(t), nN + height(Pipes));
end

if nargin >= 10 && ~isnan(leak_start_h)
    fprintf('  Computing RMSE (separating normal and leak periods)...\n');
    Stats.Normal = calc_stats_with_leak_separation(H_True, H_Normal, Nodes, Pipes, Sys, t, ...
                                                    leak_start_h, leak_end_h, exclude_ranges, outlier_info);
    Stats.Chen = calc_stats_with_leak_separation(H_True, H_Chen, Nodes, Pipes, Sys, t, ...
                                                  leak_start_h, leak_end_h, exclude_ranges, outlier_info);
    Stats.Adaptive = calc_stats_with_leak_separation(H_True, H_Adaptive, Nodes, Pipes, Sys, t, ...
                                                      leak_start_h, leak_end_h, exclude_ranges, outlier_info);
    
    fprintf('  Result (normal): P_RMSE - Std:%.4f | Chen:%.4f | EKF-LE:%.4f Bar\n', ...
        Stats.Normal.P_RMSE_Normal, Stats.Chen.P_RMSE_Normal, Stats.Adaptive.P_RMSE_Normal);
    fprintf('  Result (leak): P_RMSE - Std:%.4f | Chen:%.4f | EKF-LE:%.4f Bar\n', ...
        Stats.Normal.P_RMSE_Leak, Stats.Chen.P_RMSE_Leak, Stats.Adaptive.P_RMSE_Leak);
else
    Stats.Normal = calc_stats_simple(H_True, H_Normal, Nodes, Pipes, Sys, t, exclude_ranges, outlier_info);
    Stats.Chen = calc_stats_simple(H_True, H_Chen, Nodes, Pipes, Sys, t, exclude_ranges, outlier_info);
    Stats.Adaptive = calc_stats_simple(H_True, H_Adaptive, Nodes, Pipes, Sys, t, exclude_ranges, outlier_info);
    
    fprintf('  Result: P_RMSE - Std:%.4f | Chen:%.4f | EKF-LE:%.4f Bar\n', ...
        Stats.Normal.P_RMSE, Stats.Chen.P_RMSE, Stats.Adaptive.P_RMSE);
end

end


function S = calc_stats_simple(H_True, H_Est, Nodes, Pipes, Sys, t, exclude_ranges, outlier_info)
% Calculate simple RMSE statistics

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


function save_case_results(case_name, Stats)
% Save case results to console
fprintf('\nSaving %s results...\n', case_name);
fprintf('  P_RMSE: Std=%.4f | Chen=%.4f | EKF-LE=%.4f Bar\n', ...
    Stats.Normal.P_RMSE, Stats.Chen.P_RMSE, Stats.Adaptive.P_RMSE);
fprintf('  M_RMSE: Std=%.4f | Chen=%.4f | EKF-LE=%.4f kg/s\n', ...
    Stats.Normal.M_RMSE, Stats.Chen.M_RMSE, Stats.Adaptive.M_RMSE);
fprintf('  Pipe5_RMSE: Std=%.4f | Chen=%.4f | EKF-LE=%.4f kg/s\n', ...
    Stats.Normal.Pipe5_RMSE, Stats.Chen.Pipe5_RMSE, Stats.Adaptive.Pipe5_RMSE);
end


function save_case2_results(case_name, Stats_10, Stats_20)
% Save Case 2 results
fprintf('\nSaving %s results...\n', case_name);
fprintf('  10dB - P_RMSE: Std=%.4f | Chen=%.4f | EKF-LE=%.4f Bar\n', ...
    Stats_10.Normal.P_RMSE, Stats_10.Chen.P_RMSE, Stats_10.Adaptive.P_RMSE);
fprintf('  20dB - P_RMSE: Std=%.4f | Chen=%.4f | EKF-LE=%.4f Bar\n', ...
    Stats_20.Normal.P_RMSE, Stats_20.Chen.P_RMSE, Stats_20.Adaptive.P_RMSE);
end


function save_case3_results(case_name, Stats, Leak_True, Leak_Est)
% Save Case 3 results
fprintf('\nSaving %s results...\n', case_name);
fprintf('  Full period P_RMSE: Std=%.4f | Chen=%.4f | EKF-LE=%.4f Bar\n', ...
    Stats.Normal.P_RMSE, Stats.Chen.P_RMSE, Stats.Adaptive.P_RMSE);
if isfield(Stats.Normal, 'P_RMSE_Normal')
    fprintf('  Normal period P_RMSE: Std=%.4f | Chen=%.4f | EKF-LE=%.4f Bar\n', ...
        Stats.Normal.P_RMSE_Normal, Stats.Chen.P_RMSE_Normal, Stats.Adaptive.P_RMSE_Normal);
    fprintf('  Leak period P_RMSE: Std=%.4f | Chen=%.4f | EKF-LE=%.4f Bar\n', ...
        Stats.Normal.P_RMSE_Leak, Stats.Chen.P_RMSE_Leak, Stats.Adaptive.P_RMSE_Leak);
end
end


function save_case4_results(case_name, Stats, Leak_True, Leak_Est)
% Save Case 4 results
fprintf('\nSaving %s results...\n', case_name);
fprintf('  Full period P_RMSE: Std=%.4f | Chen=%.4f | EKF-LE=%.4f Bar\n', ...
    Stats.Normal.P_RMSE, Stats.Chen.P_RMSE, Stats.Adaptive.P_RMSE);
if isfield(Stats.Normal, 'P_RMSE_Normal')
    fprintf('  Normal period P_RMSE: Std=%.4f | Chen=%.4f | EKF-LE=%.4f Bar\n', ...
        Stats.Normal.P_RMSE_Normal, Stats.Chen.P_RMSE_Normal, Stats.Adaptive.P_RMSE_Normal);
    fprintf('  Leak period P_RMSE: Std=%.4f | Chen=%.4f | EKF-LE=%.4f Bar\n', ...
        Stats.Normal.P_RMSE_Leak, Stats.Chen.P_RMSE_Leak, Stats.Adaptive.P_RMSE_Leak);
end
end


function print_summary_table_four_cases(Stats_c1, Stats_c2_10, Stats_c2_20, Stats_c3, Stats_c4)
% Print summary table for all cases
fprintf('\nPressure RMSE Summary (Bar):\n');
fprintf('%-25s | %-15s | %-15s | %-15s\n', 'Case', 'Standard', 'Chen', 'EKF-LE');
fprintf('%s\n', repmat('-', 1, 80));
fprintf('%-25s | %.4f         | %.4f         | %.4f\n', ...
    'Case 1 (Clean)', Stats_c1.Normal.P_RMSE, Stats_c1.Chen.P_RMSE, Stats_c1.Adaptive.P_RMSE);
fprintf('%-25s | %.4f         | %.4f         | %.4f\n', ...
    'Case 2 (10dB outlier)', Stats_c2_10.Normal.P_RMSE, Stats_c2_10.Chen.P_RMSE, Stats_c2_10.Adaptive.P_RMSE);
fprintf('%-25s | %.4f         | %.4f         | %.4f\n', ...
    'Case 2 (20dB outlier)', Stats_c2_20.Normal.P_RMSE, Stats_c2_20.Chen.P_RMSE, Stats_c2_20.Adaptive.P_RMSE);
fprintf('%-25s | %.4f         | %.4f         | %.4f\n', ...
    'Case 3 (Outlier+Leak)', Stats_c3.Normal.P_RMSE, Stats_c3.Chen.P_RMSE, Stats_c3.Adaptive.P_RMSE);
fprintf('%-25s | %.4f         | %.4f         | %.4f\n', ...
    'Case 4 (Pure Leak)', Stats_c4.Normal.P_RMSE, Stats_c4.Chen.P_RMSE, Stats_c4.Adaptive.P_RMSE);
fprintf('%s\n', repmat('-', 1, 80));

fprintf('\nPipe 5 RMSE Comparison (kg/s):\n');
fprintf('%-25s | %-15s | %-15s | %-15s\n', 'Case', 'Standard', 'Chen', 'EKF-LE');
fprintf('%s\n', repmat('-', 1, 80));
fprintf('%-25s | %.4f         | %.4f         | %.4f\n', ...
    'Case 1 (Clean)', Stats_c1.Normal.Pipe5_RMSE, Stats_c1.Chen.Pipe5_RMSE, Stats_c1.Adaptive.Pipe5_RMSE);
fprintf('%-25s | %.4f         | %.4f         | %.4f\n', ...
    'Case 2 (10dB outlier)', Stats_c2_10.Normal.Pipe5_RMSE, Stats_c2_10.Chen.Pipe5_RMSE, Stats_c2_10.Adaptive.Pipe5_RMSE);
fprintf('%-25s | %.4f         | %.4f         | %.4f\n', ...
    'Case 2 (20dB outlier)', Stats_c2_20.Normal.Pipe5_RMSE, Stats_c2_20.Chen.Pipe5_RMSE, Stats_c2_20.Adaptive.Pipe5_RMSE);
fprintf('%-25s | %.4f         | %.4f         | %.4f\n', ...
    'Case 3 (Outlier+Leak)', Stats_c3.Normal.Pipe5_RMSE, Stats_c3.Chen.Pipe5_RMSE, Stats_c3.Adaptive.Pipe5_RMSE);
fprintf('%-25s | %.4f         | %.4f         | %.4f\n', ...
    'Case 4 (Pure Leak)', Stats_c4.Normal.Pipe5_RMSE, Stats_c4.Chen.Pipe5_RMSE, Stats_c4.Adaptive.Pipe5_RMSE);
fprintf('%s\n', repmat('-', 1, 80));
end


function save_comprehensive_results_four_cases(Stats_c1, Stats_c2_300, Stats_c2_500, Stats_c3, Stats_c4, filename)
% Save comprehensive results to Excel

T1 = table();
T1.Case = {'Case1_Clean'; 'Case2_10dB'; 'Case2_20dB'; 'Case3_Out_Leak'; 'Case4_Pure_Leak'};
T1.Standard_EKF = [Stats_c1.Normal.P_RMSE; Stats_c2_300.Normal.P_RMSE; Stats_c2_500.Normal.P_RMSE; 
                   Stats_c3.Normal.P_RMSE; Stats_c4.Normal.P_RMSE];
T1.Chen_Robust_EKF = [Stats_c1.Chen.P_RMSE; Stats_c2_300.Chen.P_RMSE; Stats_c2_500.Chen.P_RMSE;
                      Stats_c3.Chen.P_RMSE; Stats_c4.Chen.P_RMSE];
T1.EKF_LE = [Stats_c1.Adaptive.P_RMSE; Stats_c2_300.Adaptive.P_RMSE; Stats_c2_500.Adaptive.P_RMSE;
             Stats_c3.Adaptive.P_RMSE; Stats_c4.Adaptive.P_RMSE];
T1.Chen_vs_Std_pct = (T1.Standard_EKF - T1.Chen_Robust_EKF) ./ T1.Standard_EKF * 100;
T1.EKF_LE_vs_Std_pct = (T1.Standard_EKF - T1.EKF_LE) ./ T1.Standard_EKF * 100;
T1.EKF_LE_vs_Chen_pct = (T1.Chen_Robust_EKF - T1.EKF_LE) ./ T1.Chen_Robust_EKF * 100;

writetable(T1, filename, 'Sheet', 'Pressure_RMSE');

T2 = table();
T2.Case = T1.Case;
T2.Standard_EKF = [Stats_c1.Normal.M_RMSE; Stats_c2_300.Normal.M_RMSE; Stats_c2_500.Normal.M_RMSE;
                   Stats_c3.Normal.M_RMSE; Stats_c4.Normal.M_RMSE];
T2.Chen_Robust_EKF = [Stats_c1.Chen.M_RMSE; Stats_c2_300.Chen.M_RMSE; Stats_c2_500.Chen.M_RMSE;
                      Stats_c3.Chen.M_RMSE; Stats_c4.Chen.M_RMSE];
T2.EKF_LE = [Stats_c1.Adaptive.M_RMSE; Stats_c2_300.Adaptive.M_RMSE; Stats_c2_500.Adaptive.M_RMSE;
             Stats_c3.Adaptive.M_RMSE; Stats_c4.Adaptive.M_RMSE];
T2.Chen_vs_Std_pct = (T2.Standard_EKF - T2.Chen_Robust_EKF) ./ T2.Standard_EKF * 100;
T2.EKF_LE_vs_Std_pct = (T2.Standard_EKF - T2.EKF_LE) ./ T2.Standard_EKF * 100;
T2.EKF_LE_vs_Chen_pct = (T2.Chen_Robust_EKF - T2.EKF_LE) ./ T2.Chen_Robust_EKF * 100;

writetable(T2, filename, 'Sheet', 'Flow_RMSE');

T3 = table();
T3.Case = T1.Case;
T3.Standard_EKF = [Stats_c1.Normal.Pipe5_RMSE; Stats_c2_300.Normal.Pipe5_RMSE; Stats_c2_500.Normal.Pipe5_RMSE;
                   Stats_c3.Normal.Pipe5_RMSE; Stats_c4.Normal.Pipe5_RMSE];
T3.Chen_Robust_EKF = [Stats_c1.Chen.Pipe5_RMSE; Stats_c2_300.Chen.Pipe5_RMSE; Stats_c2_500.Chen.Pipe5_RMSE;
                      Stats_c3.Chen.Pipe5_RMSE; Stats_c4.Chen.Pipe5_RMSE];
T3.EKF_LE = [Stats_c1.Adaptive.Pipe5_RMSE; Stats_c2_300.Adaptive.Pipe5_RMSE; Stats_c2_500.Adaptive.Pipe5_RMSE;
             Stats_c3.Adaptive.Pipe5_RMSE; Stats_c4.Adaptive.Pipe5_RMSE];
T3.Chen_vs_Std_pct = (T3.Standard_EKF - T3.Chen_Robust_EKF) ./ T3.Standard_EKF * 100;
T3.EKF_LE_vs_Std_pct = (T3.Standard_EKF - T3.EKF_LE) ./ T3.Standard_EKF * 100;
T3.EKF_LE_vs_Chen_pct = (T3.Chen_Robust_EKF - T3.EKF_LE) ./ T3.Chen_Robust_EKF * 100;

writetable(T3, filename, 'Sheet', 'Pipe5_RMSE');

T4 = table();
T4.Case = T1.Case;
T4.Standard_EKF = [Stats_c1.Normal.Pipe1_RMSE; Stats_c2_300.Normal.Pipe1_RMSE; Stats_c2_500.Normal.Pipe1_RMSE;
                   Stats_c3.Normal.Pipe1_RMSE; Stats_c4.Normal.Pipe1_RMSE];
T4.Chen_Robust_EKF = [Stats_c1.Chen.Pipe1_RMSE; Stats_c2_300.Chen.Pipe1_RMSE; Stats_c2_500.Chen.Pipe1_RMSE;
                      Stats_c3.Chen.Pipe1_RMSE; Stats_c4.Chen.Pipe1_RMSE];
T4.EKF_LE = [Stats_c1.Adaptive.Pipe1_RMSE; Stats_c2_300.Adaptive.Pipe1_RMSE; Stats_c2_500.Adaptive.Pipe1_RMSE;
             Stats_c3.Adaptive.Pipe1_RMSE; Stats_c4.Adaptive.Pipe1_RMSE];
T4.Chen_vs_Std_pct = (T4.Standard_EKF - T4.Chen_Robust_EKF) ./ T4.Standard_EKF * 100;
T4.EKF_LE_vs_Std_pct = (T4.Standard_EKF - T4.EKF_LE) ./ T4.Standard_EKF * 100;
T4.EKF_LE_vs_Chen_pct = (T4.Chen_Robust_EKF - T4.EKF_LE) ./ T4.Chen_Robust_EKF * 100;

writetable(T4, filename, 'Sheet', 'Pipe1_RMSE');

T5 = table();
T5.Metric = {'Avg_Pressure_RMSE'; 'Avg_Flow_RMSE'; 'Avg_Pipe5_RMSE'; 'Avg_Pipe1_RMSE'; ...
             'Max_Pressure_RMSE'; 'Max_Flow_RMSE'; 'Max_Pipe5_RMSE'; 'Max_Pipe1_RMSE'};
T5.Standard_EKF = [
    mean([Stats_c1.Normal.P_RMSE, Stats_c2_300.Normal.P_RMSE, Stats_c2_500.Normal.P_RMSE, Stats_c3.Normal.P_RMSE, Stats_c4.Normal.P_RMSE]);
    mean([Stats_c1.Normal.M_RMSE, Stats_c2_300.Normal.M_RMSE, Stats_c2_500.Normal.M_RMSE, Stats_c3.Normal.M_RMSE, Stats_c4.Normal.M_RMSE]);
    mean([Stats_c1.Normal.Pipe5_RMSE, Stats_c2_300.Normal.Pipe5_RMSE, Stats_c2_500.Normal.Pipe5_RMSE, Stats_c3.Normal.Pipe5_RMSE, Stats_c4.Normal.Pipe5_RMSE]);
    mean([Stats_c1.Normal.Pipe1_RMSE, Stats_c2_300.Normal.Pipe1_RMSE, Stats_c2_500.Normal.Pipe1_RMSE, Stats_c3.Normal.Pipe1_RMSE, Stats_c4.Normal.Pipe1_RMSE]);
    max([Stats_c1.Normal.P_RMSE, Stats_c2_300.Normal.P_RMSE, Stats_c2_500.Normal.P_RMSE, Stats_c3.Normal.P_RMSE, Stats_c4.Normal.P_RMSE]);
    max([Stats_c1.Normal.M_RMSE, Stats_c2_300.Normal.M_RMSE, Stats_c2_500.Normal.M_RMSE, Stats_c3.Normal.M_RMSE, Stats_c4.Normal.M_RMSE]);
    max([Stats_c1.Normal.Pipe5_RMSE, Stats_c2_300.Normal.Pipe5_RMSE, Stats_c2_500.Normal.Pipe5_RMSE, Stats_c3.Normal.Pipe5_RMSE, Stats_c4.Normal.Pipe5_RMSE]);
    max([Stats_c1.Normal.Pipe1_RMSE, Stats_c2_300.Normal.Pipe1_RMSE, Stats_c2_500.Normal.Pipe1_RMSE, Stats_c3.Normal.Pipe1_RMSE, Stats_c4.Normal.Pipe1_RMSE])
];
T5.Chen_Robust_EKF = [
    mean([Stats_c1.Chen.P_RMSE, Stats_c2_300.Chen.P_RMSE, Stats_c2_500.Chen.P_RMSE, Stats_c3.Chen.P_RMSE, Stats_c4.Chen.P_RMSE]);
    mean([Stats_c1.Chen.M_RMSE, Stats_c2_300.Chen.M_RMSE, Stats_c2_500.Chen.M_RMSE, Stats_c3.Chen.M_RMSE, Stats_c4.Chen.M_RMSE]);
    mean([Stats_c1.Chen.Pipe5_RMSE, Stats_c2_300.Chen.Pipe5_RMSE, Stats_c2_500.Chen.Pipe5_RMSE, Stats_c3.Chen.Pipe5_RMSE, Stats_c4.Chen.Pipe5_RMSE]);
    mean([Stats_c1.Chen.Pipe1_RMSE, Stats_c2_300.Chen.Pipe1_RMSE, Stats_c2_500.Chen.Pipe1_RMSE, Stats_c3.Chen.Pipe1_RMSE, Stats_c4.Chen.Pipe1_RMSE]);
    max([Stats_c1.Chen.P_RMSE, Stats_c2_300.Chen.P_RMSE, Stats_c2_500.Chen.P_RMSE, Stats_c3.Chen.P_RMSE, Stats_c4.Chen.P_RMSE]);
    max([Stats_c1.Chen.M_RMSE, Stats_c2_300.Chen.M_RMSE, Stats_c2_500.Chen.M_RMSE, Stats_c3.Chen.M_RMSE, Stats_c4.Chen.M_RMSE]);
    max([Stats_c1.Chen.Pipe5_RMSE, Stats_c2_300.Chen.Pipe5_RMSE, Stats_c2_500.Chen.Pipe5_RMSE, Stats_c3.Chen.Pipe5_RMSE, Stats_c4.Chen.Pipe5_RMSE]);
    max([Stats_c1.Chen.Pipe1_RMSE, Stats_c2_300.Chen.Pipe1_RMSE, Stats_c2_500.Chen.Pipe1_RMSE, Stats_c3.Chen.Pipe1_RMSE, Stats_c4.Chen.Pipe1_RMSE])
];
T5.EKF_LE = [
    mean([Stats_c1.Adaptive.P_RMSE, Stats_c2_300.Adaptive.P_RMSE, Stats_c2_500.Adaptive.P_RMSE, Stats_c3.Adaptive.P_RMSE, Stats_c4.Adaptive.P_RMSE]);
    mean([Stats_c1.Adaptive.M_RMSE, Stats_c2_300.Adaptive.M_RMSE, Stats_c2_500.Adaptive.M_RMSE, Stats_c3.Adaptive.M_RMSE, Stats_c4.Adaptive.M_RMSE]);
    mean([Stats_c1.Adaptive.Pipe5_RMSE, Stats_c2_300.Adaptive.Pipe5_RMSE, Stats_c2_500.Adaptive.Pipe5_RMSE, Stats_c3.Adaptive.Pipe5_RMSE, Stats_c4.Adaptive.Pipe5_RMSE]);
    mean([Stats_c1.Adaptive.Pipe1_RMSE, Stats_c2_300.Adaptive.Pipe1_RMSE, Stats_c2_500.Adaptive.Pipe1_RMSE, Stats_c3.Adaptive.Pipe1_RMSE, Stats_c4.Adaptive.Pipe1_RMSE]);
    max([Stats_c1.Adaptive.P_RMSE, Stats_c2_300.Adaptive.P_RMSE, Stats_c2_500.Adaptive.P_RMSE, Stats_c3.Adaptive.P_RMSE, Stats_c4.Adaptive.P_RMSE]);
    max([Stats_c1.Adaptive.M_RMSE, Stats_c2_300.Adaptive.M_RMSE, Stats_c2_500.Adaptive.M_RMSE, Stats_c3.Adaptive.M_RMSE, Stats_c4.Adaptive.M_RMSE]);
    max([Stats_c1.Adaptive.Pipe5_RMSE, Stats_c2_300.Adaptive.Pipe5_RMSE, Stats_c2_500.Adaptive.Pipe5_RMSE, Stats_c3.Adaptive.Pipe5_RMSE, Stats_c4.Adaptive.Pipe5_RMSE]);
    max([Stats_c1.Adaptive.Pipe1_RMSE, Stats_c2_300.Adaptive.Pipe1_RMSE, Stats_c2_500.Adaptive.Pipe1_RMSE, Stats_c3.Adaptive.Pipe1_RMSE, Stats_c4.Adaptive.Pipe1_RMSE])
];

writetable(T5, filename, 'Sheet', 'Summary');

fprintf('Excel results saved: %s\n', filename);
end