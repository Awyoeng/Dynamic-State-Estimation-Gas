function dse_main_leak()
% DSE_MAIN_LEAK - Leak Detection with Iterative Detector-EKF Feedback
% Architecture: EKF → Detector → Feedback → EKF (with compensation)
clc; clear; close all;

% System Parameters
Sys.c = 340;
Sys.c2 = 340^2;
Sys.dt = 600;
Sys.Hours = 24;

% Load Data
[Nodes, Pipes, Compressors, GTU] = dse_1_load_data('gas_data.xlsx');
Leaks = dse_load_leak('leak.xlsx');

% Visualize
draw_topo(Nodes, Pipes, Compressors, GTU, Leaks);

% Generate Truth
[H_True, Z, t, Leak_True, P_GTU] = ...
    dse_3_gen_data_leak(Nodes, Pipes, Compressors, Sys, Leaks, GTU);

% ===========================================================================
% THREE-WAY COMPARISON:
% 1. Standard EKF (no compensation) - baseline
% 2. Chen's Robust EKF (innovation covariance adaptation)
% 3. Adaptive EKF with detector feedback (our method)
% ===========================================================================

% Method 1: Standard EKF (baseline)
fprintf('\n========================================\n');
fprintf('Method 1: Standard EKF (no compensation)\n');
fprintf('========================================\n');
H_Est_Normal = dse_normal_ekf(Z, Nodes, Pipes, Compressors, Sys, t, GTU);

% Method 2: Chen's Robust EKF
fprintf('\n========================================\n');
fprintf('Method 2: Chen Robust EKF (innovation covariance)\n');
fprintf('========================================\n');
H_Est_Chen = dse_chen_ekf(Z, Nodes, Pipes, Compressors, Sys, t, GTU);

% Method 3: Detector + Adaptive EKF (our method)
fprintf('\n========================================\n');
fprintf('Method 3: Detector + Adaptive EKF (innovation feedback)\n');
fprintf('========================================\n');

% Step 3a: Run Leak Detector
fprintf('  Running Leak Detector...\n');
[Det, Diag] = dse_leak_detector(H_Est_Normal, Z, Nodes, Pipes, Sys, t);

% Step 3b: Run Adaptive EKF with detector signal
fprintf('  Running Adaptive EKF with detector signal...\n');
[H_Est_Adaptive, Leak_Est_Nodes] = dse_4_estimator_leak(Z, Nodes, Pipes, Compressors, Sys, t, GTU, Det);
Leak_Est = sum(Leak_Est_Nodes, 2);  % Total leak

fprintf('\n========================================\n');
fprintf('All methods complete\n');
fprintf('========================================\n\n');

% ===========================================================================
% Performance Statistics for All Three Methods
% ===========================================================================
Stats_Normal = calc_stats(H_True, H_Est_Normal, Z, Nodes, Pipes, Sys, 'Standard EKF');
Stats_Chen = calc_stats(H_True, H_Est_Chen, Z, Nodes, Pipes, Sys, 'Chen Robust EKF');
Stats_Adaptive = calc_stats(H_True, H_Est_Adaptive, Z, Nodes, Pipes, Sys, 'Detector-Feedback EKF');

% Leak Detection Performance
if height(Leaks) > 0
    True_Exists = any(Leak_True > 0, 2);
    TP = sum(Det & True_Exists);
    TN = sum(~Det & ~True_Exists);
    FP = sum(Det & ~True_Exists);
    FN = sum(~Det & True_Exists);
    
    fprintf('\nLeak Detection Performance:\n');
    fprintf('  True Positives: %d\n', TP);
    fprintf('  True Negatives: %d\n', TN);
    fprintf('  False Positives: %d\n', FP);
    fprintf('  False Negatives: %d\n', FN);
    fprintf('  Accuracy: %.1f%%\n', (TP+TN)/length(t)*100);
    fprintf('  Precision: %.1f%%\n', TP/max(TP+FP,1)*100);
    fprintf('  Recall: %.1f%%\n', TP/max(TP+FN,1)*100);
end

% Save and Plot
save_results(H_True, H_Est_Normal, H_Est_Chen, H_Est_Adaptive, Z, Stats_Normal, Stats_Chen, Stats_Adaptive, ...
    Nodes, Pipes, Sys, t, GTU, P_GTU, Leak_Est);

plot_comparison(H_True, H_Est_Normal, H_Est_Chen, H_Est_Adaptive, Z, Leak_True, Leak_Est, ...
    Det, Nodes, Pipes, Sys, t, Leaks, GTU, P_GTU);

end


function Stats = calc_stats(HT, HE, ZM, Nodes, Pipes, Sys, method_name)
nN = height(Nodes);
nP = height(Pipes);

PT = HT(:,1:nN) * Sys.c2 / 1e5;
PE = HE(:,1:nN) * Sys.c2 / 1e5;
PM = ZM(:,1:nN) * Sys.c2 / 1e5;
MT = HT(:,nN+1:end);
ME = HE(:,nN+1:end);
MM = ZM(:,nN+1:end);

Stats.P_RMSE_Est = zeros(nN,1);
Stats.P_RMSE_Meas = zeros(nN,1);
Stats.P_MAE_Est = zeros(nN,1);
Stats.P_Var_Est = zeros(nN,1);
for n = 1:nN
    err_e = PE(:,n) - PT(:,n);
    err_m = PM(:,n) - PT(:,n);
    Stats.P_RMSE_Est(n) = sqrt(mean(err_e.^2));
    Stats.P_RMSE_Meas(n) = sqrt(mean(err_m.^2));
    Stats.P_MAE_Est(n) = mean(abs(err_e));
    Stats.P_Var_Est(n) = var(err_e);
end

Stats.M_RMSE_Est = zeros(nP,1);
Stats.M_RMSE_Meas = zeros(nP,1);
Stats.M_MAE_Est = zeros(nP,1);
Stats.M_Var_Est = zeros(nP,1);
for p = 1:nP
    err_e = ME(:,p) - MT(:,p);
    err_m = MM(:,p) - MT(:,p);
    Stats.M_RMSE_Est(p) = sqrt(mean(err_e.^2));
    Stats.M_RMSE_Meas(p) = sqrt(mean(err_m.^2));
    Stats.M_MAE_Est(p) = mean(abs(err_e));
    Stats.M_Var_Est(p) = var(err_e);
end

Stats.P_RMSE_Total = sqrt(mean(Stats.P_RMSE_Est.^2));
Stats.M_RMSE_Total = sqrt(mean(Stats.M_RMSE_Est.^2));

fprintf('\n%s Performance:\n', method_name);
fprintf('  Pressure RMSE: %.4f Bar\n', Stats.P_RMSE_Total);
fprintf('  Flow RMSE: %.4f kg/s\n', Stats.M_RMSE_Total);
end


function save_results(HT, HE_Normal, HE_Chen, HE_Adaptive, ZM, Stats_Normal, Stats_Chen, Stats_Adaptive, ...
    Nodes, Pipes, Sys, t, GTU, P_GTU, Leak_Est)

nN = height(Nodes);

T1 = table();
T1.Time_h = t';
for n = [1 7 10 18]
    if n > nN, continue; end
    T1.(sprintf('P%d_True_Bar',n)) = HT(:,n)*Sys.c2/1e5;
    T1.(sprintf('P%d_Meas_Bar',n)) = ZM(:,n)*Sys.c2/1e5;
    T1.(sprintf('P%d_Normal_Bar',n)) = HE_Normal(:,n)*Sys.c2/1e5;
    T1.(sprintf('P%d_Chen_Bar',n)) = HE_Chen(:,n)*Sys.c2/1e5;
    T1.(sprintf('P%d_Adaptive_Bar',n)) = HE_Adaptive(:,n)*Sys.c2/1e5;
end
T1.M1_True_kgs = HT(:,nN+1);
T1.M1_Meas_kgs = ZM(:,nN+1);
T1.M1_Normal_kgs = HE_Normal(:,nN+1);
T1.M1_Chen_kgs = HE_Chen(:,nN+1);
T1.M1_Adaptive_kgs = HE_Adaptive(:,nN+1);
T1.Leak_Est_kgs = Leak_Est;
for g = 1:height(GTU)
    T1.(sprintf('GTU%d_Power_MW',g)) = P_GTU(:,g);
end

T4 = table();
T4.Metric = {'Pressure_RMSE_Bar';'Pressure_MAE_Bar';'Flow_RMSE_kgs';'Flow_MAE_kgs'};
T4.Standard_EKF = [Stats_Normal.P_RMSE_Total; mean(Stats_Normal.P_MAE_Est); ...
    Stats_Normal.M_RMSE_Total; mean(Stats_Normal.M_MAE_Est)];
T4.Chen_Robust_EKF = [Stats_Chen.P_RMSE_Total; mean(Stats_Chen.P_MAE_Est); ...
    Stats_Chen.M_RMSE_Total; mean(Stats_Chen.M_MAE_Est)];
T4.Adaptive_EKF = [Stats_Adaptive.P_RMSE_Total; mean(Stats_Adaptive.P_MAE_Est); ...
    Stats_Adaptive.M_RMSE_Total; mean(Stats_Adaptive.M_MAE_Est)];
T4.Improvement_Chen_vs_Standard = (T4.Standard_EKF - T4.Chen_Robust_EKF) ./ T4.Standard_EKF * 100;
T4.Improvement_Adaptive_vs_Standard = (T4.Standard_EKF - T4.Adaptive_EKF) ./ T4.Standard_EKF * 100;

writetable(T1, 'dse_results.xlsx', 'Sheet', 'TimeSeries');
writetable(T4, 'dse_results.xlsx', 'Sheet', 'Summary');
fprintf('\nResults saved to dse_results.xlsx\n');
end


function draw_topo(Nodes, Pipes, Compressors, GTU, Leaks)
figure('Name','Network Topology','Color','w','Position',[50 50 950 700]);
G = digraph(Pipes.From, Pipes.To);
G = simplify(G);
h = plot(G,'Layout','force','NodeLabel',{},'EdgeColor',[.6 .6 .6],'LineWidth',2,'MarkerSize',1);
hold on; axis off;
title('Gas Network Topology','FontSize',14);
x = h.XData; y = h.YData;

src = find(Nodes.Type==1);
plot(x(src),y(src),'rs','MarkerSize',16,'MarkerFaceColor','r');

gtu_n = find(Nodes.Type==4);
if ~isempty(gtu_n)
    plot(x(gtu_n),y(gtu_n),'h','MarkerSize',18,'MarkerFaceColor',[.3 .8 .3],'MarkerEdgeColor','k');
end

load_n = find(Nodes.Type==2);
plot(x(load_n),y(load_n),'o','MarkerSize',10,'MarkerFaceColor',[.3 .5 .9],'MarkerEdgeColor','k');

comp_n = find(Nodes.Type==3);
if ~isempty(comp_n)
    plot(x(comp_n),y(comp_n),'d','MarkerSize',12,'MarkerFaceColor',[1 .8 0],'MarkerEdgeColor','k');
end

for i = 1:height(Nodes)
    text(x(i),y(i)+0.08,sprintf('%d',Nodes.ID(i)),'HorizontalAlignment','center','FontSize',8);
end

for g = 1:height(GTU)
    n = GTU.NodeID(g);
    text(x(n),y(n)-0.12,sprintf('GTU-%d\n%dMW',g,GTU.Capacity_MW(g)),...
        'HorizontalAlignment','center','FontSize',8,'Color',[0 .5 0],'FontWeight','bold');
end

for i = 1:height(Leaks)
    pid = Leaks.PipeID(i);
    pos = Leaks.Position(i);
    idx = find(Pipes.ID==pid,1);
    if isempty(idx), continue; end
    u = Pipes.From(idx); v = Pipes.To(idx);
    lx = x(u)+pos*(x(v)-x(u));
    ly = y(u)+pos*(y(v)-y(u));
    plot(lx,ly,'mp','MarkerSize',18,'MarkerFaceColor','m','LineWidth',2);
end

leg = []; lab = {};
h1 = plot(nan,nan,'rs','MarkerFaceColor','r','MarkerSize',10);
h2 = plot(nan,nan,'o','MarkerFaceColor',[.3 .5 .9],'MarkerSize',8);
leg = [h1 h2]; lab = {'Source','Load'};
if height(GTU)>0
    h3 = plot(nan,nan,'h','MarkerFaceColor',[.3 .8 .3],'MarkerSize',12);
    leg(end+1) = h3; lab{end+1} = 'GTU';
end
if ~isempty(comp_n)
    h4 = plot(nan,nan,'d','MarkerFaceColor',[1 .8 0],'MarkerSize',10);
    leg(end+1) = h4; lab{end+1} = 'Compressor';
end
if height(Leaks)>0
    h5 = plot(nan,nan,'mp','MarkerFaceColor','m','MarkerSize',12);
    leg(end+1) = h5; lab{end+1} = 'Leak';
end
legend(leg,lab,'Location','best');
end


function plot_comparison(HT, HE_Normal, HE_Chen, HE_Adaptive, ZM, Leak_True, Leak_Est, ...
    Det, Nodes, Pipes, Sys, t, Leaks, GTU, P_GTU)

nN = height(Nodes);
figure('Name','Three-Way EKF Comparison','Color','w','Position',[100 100 1400 800]);

if height(GTU)>0
    tgt = GTU.NodeID(1);
else
    tgt = min(7,nN);
end

subplot(2,2,1); hold on; box on;
plot(t, HT(:,tgt)*Sys.c2/1e5, 'g-', 'LineWidth', 2.5);
plot(t, ZM(:,tgt)*Sys.c2/1e5, 'k.', 'MarkerSize', 5);
plot(t, HE_Normal(:,tgt)*Sys.c2/1e5, 'b:', 'LineWidth', 2);
plot(t, HE_Chen(:,tgt)*Sys.c2/1e5, 'm-.', 'LineWidth', 1.5);
plot(t, HE_Adaptive(:,tgt)*Sys.c2/1e5, 'r--', 'LineWidth', 1.5);
if height(Leaks)>0
    xline(Leaks.StartTime_s(1)/3600, 'c--', 'LineWidth', 1, 'Alpha', 0.5);
end
title(sprintf('Pressure at Node %d', tgt));
ylabel('Bar');
legend('True', 'Meas', 'Standard EKF', 'Chen Robust EKF', 'Detector-Feedback EKF', 'Location', 'best');
grid on; xlim([0 24]);

subplot(2,2,2); hold on; box on;
plot(t, HT(:,nN+1), 'g-', 'LineWidth', 2.5);
plot(t, ZM(:,nN+1), 'k.', 'MarkerSize', 5);
plot(t, HE_Normal(:,nN+1), 'b:', 'LineWidth', 2);
plot(t, HE_Chen(:,nN+1), 'm-.', 'LineWidth', 1.5);
plot(t, HE_Adaptive(:,nN+1), 'r--', 'LineWidth', 1.5);
if height(Leaks)>0
    xline(Leaks.StartTime_s(1)/3600, 'c--', 'LineWidth', 1, 'Alpha', 0.5);
end
title('Source Flow (Pipe 1)');
ylabel('kg/s');
legend('True', 'Meas', 'Standard EKF', 'Chen Robust EKF', 'Detector-Feedback EKF', 'Location', 'best');
grid on; xlim([0 24]);

subplot(2,2,3); hold on; box on;
if height(GTU)>0
    clrs = lines(height(GTU));
    for g = 1:height(GTU)
        plot(t, P_GTU(:,g), '-', 'LineWidth', 2, 'Color', clrs(g,:), ...
            'DisplayName', sprintf('GTU-%d (%dMW)', g, GTU.Capacity_MW(g)));
    end
    legend('Location', 'best');
else
    text(0.5, 0.5, 'No GTU', 'HorizontalAlignment', 'center', 'FontSize', 14, 'Units', 'normalized');
end
title('GTU Power');
ylabel('MW');
xlabel('Time (h)');
grid on; xlim([0 24]);

subplot(2,2,4); hold on; box on;
total_leak = sum(Leak_True, 2);
if height(Leaks)>0
    plot(t, total_leak, 'r-', 'LineWidth', 2.5, 'DisplayName', 'True Leak');
    % Estimated leak line removed per user request
    legend('Location', 'best');
    ylim([0 max(total_leak)*1.3+1]);
else
    text(0.5, 0.5, 'No Leak', 'HorizontalAlignment', 'center', 'FontSize', 14, 'Units', 'normalized');
end
title('Leak Rate');
ylabel('kg/s');
xlabel('Time (h)');
grid on; xlim([0 24]);
end