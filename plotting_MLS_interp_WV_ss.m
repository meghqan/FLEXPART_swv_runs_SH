c = ["#1171BE"; "#DD5400"; "#EDB120"; ...
    "#8516D1"; "#3BAA32"; "#2FBEEF"; ...
    "#D1048B"; "#FFD60A"; "#6582FD"; "#FF453A"; "#00A3A3"; "#CB845D"];
% 

title_string = ["Jan", "Feb", ...
    "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", ...
    "Oct", "Nov", "Dec"];
%

figure(1)
t = tiledlayout(4,1,'TileSpacing', 'tight');
ylabel(t, 'Water vapour [ppmv]', 'FontSize', 16)
xlabel(t, 'Month in 2017', 'FontSize', 16)


load('plotting_entrainment_ss_at_121hPa', 'wv_mean', 'wv_std', 'wv_mean_total_by_starting_region', 'std_mean_total_by_starting_region')
%
nexttile
hold on
grid on
box on

p(1) = errorbar(1:12, wv_mean(3:14), wv_std(3:14), wv_std(3:14), [], [], 'o-', 'LineWidth', ...
    2, "MarkerEdgeColor",c(1),"MarkerFaceColor",c(1));
p(2) = errorbar(1:12, wv_mean_total_by_starting_region(3:14), std_mean_total_by_starting_region(3:14), std_mean_total_by_starting_region(3:14), [], ...
    [], 'o-', 'LineWidth', 2, "MarkerEdgeColor",c(10),"MarkerFaceColor",c(10));

% ylim([0 20])
xticks([1:12])
xlim([1 12])
xticklabels([])
text(1.1, 10, '121 hPa', 'fontsize', 16)

set(gca, 'fontsize', 16)

legend([p(1) p(2)], 'WV at 5 days before entrainment into the ExLS', ...
    'WV at initialization in the ExLS', 'numcolumns', 2)
clear wv_mean wv_std wv_mean_total_by_starting_region std_mean_total_by_starting_region

load('plotting_entrainment_ss_at_147hPa', 'wv_mean', 'wv_std', 'wv_mean_total_by_starting_region', 'std_mean_total_by_starting_region')
%
nexttile
hold on
grid on
box on

p(1) = errorbar(1:12, wv_mean(3:14), wv_std(3:14), wv_std(3:14), [], [], 'o-', 'LineWidth', ...
    2, "MarkerEdgeColor",c(1),"MarkerFaceColor",c(1));
p(2) = errorbar(1:12, wv_mean_total_by_starting_region(3:14), std_mean_total_by_starting_region(3:14), std_mean_total_by_starting_region(3:14), [], ...
    [], 'o-', 'LineWidth', 2, "MarkerEdgeColor",c(10),"MarkerFaceColor",c(10));

% ylim([0 20])
xticks([1:12])
xlim([1 12])
xticklabels([])
text(1.1, 14, '147 hPa', 'fontsize', 16)

set(gca, 'fontsize', 16)

% legend([p(1) p(2)], 'WV at 5 days before entrainment into the ExLS', 'WV at initialization in the ExLS')
clear wv_mean wv_std wv_mean_total_by_starting_region std_mean_total_by_starting_region

load('plotting_entrainment_ss_at_178hPa', 'wv_mean', 'wv_std', 'wv_mean_total_by_starting_region', 'std_mean_total_by_starting_region')
%
nexttile
hold on
grid on
box on

p(1) = errorbar(1:12, wv_mean(3:14), wv_std(3:14), wv_std(3:14), [], [], 'o-', 'LineWidth', ...
    2, "MarkerEdgeColor",c(1),"MarkerFaceColor",c(1));
p(2) = errorbar(1:12, wv_mean_total_by_starting_region(3:14), std_mean_total_by_starting_region(3:14), std_mean_total_by_starting_region(3:14), [], ...
    [], 'o-', 'LineWidth', 2, "MarkerEdgeColor",c(10),"MarkerFaceColor",c(10));

% ylim([0 20])
xticks([1:12])
xlim([1 12])
xticklabels([])
text(1.1, 26, '178 hPa', 'fontsize', 16)

set(gca, 'fontsize', 16)
clear wv_mean wv_std wv_mean_total_by_starting_region std_mean_total_by_starting_region

load('plotting_entrainment_ss_at_215hPa', 'wv_mean', 'wv_std', 'wv_mean_total_by_starting_region', 'std_mean_total_by_starting_region')
%
nexttile
hold on
grid on
box on

p(1) = errorbar(1:12, wv_mean(3:14), wv_std(3:14), wv_std(3:14), [], [], 'o-', 'LineWidth', ...
    2, "MarkerEdgeColor",c(1),"MarkerFaceColor",c(1));
p(2) = errorbar(1:12, wv_mean_total_by_starting_region(3:14), std_mean_total_by_starting_region(3:14), std_mean_total_by_starting_region(3:14), [], ...
    [], 'o-', 'LineWidth', 2, "MarkerEdgeColor",c(10),"MarkerFaceColor",c(10));

% ylim([0 20])
xticks([1:12])
xlim([1 12])
xticklabels(title_string)
text(1.1, 36, '215 hPa', 'fontsize', 16)

set(gca, 'fontsize', 16)