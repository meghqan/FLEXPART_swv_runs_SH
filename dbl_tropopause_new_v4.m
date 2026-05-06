% January 2026

% from the final state of the particle trajectories (final state when
% crossing a defined border), figure out which ones pass between the
% primary and secondary tropopause, and what percent are coming from the
% tropics

c = ["#1171BE"; "#DD5400"; "#EDB120"; ...
    "#8516D1"; "#3BAA32"; "#2FBEEF"; ...
    "#D1048B"; "#FFD60A"; "#6582FD"; "#FF453A"; "#00A3A3"; "#CB845D"];

filenames = ["partoutput_20161103075959.nc", ...
    "partoutput_20161201075959.nc", "partoutput_20161229075959.nc", ...
    "partoutput_20170126050000.nc", "partoutput_20170223050000.nc", ...
    "partoutput_20170323050000.nc", "partoutput_20170420050000.nc", ...
    "partoutput_20170518050000.nc", "partoutput_20170615050000.nc", ...
    "partoutput_20170713050000.nc", "partoutput_20170810050000.nc", ...
    "partoutput_20170907050000.nc", "partoutput_20171005050000.nc", ...
    "partoutput_20171102050000.nc"];

tropopause_altitude_secondary = ncread("F:/_PhD/flexpart_swv_runs/" + ...
    "ERA5_primary_secondary_trop_height_v3.nc", "tropopause_altitude_secondary");
tropopause_altitude_primary = ncread("F:/_PhD/flexpart_swv_runs/" + ...
    "ERA5_primary_secondary_trop_height_v3.nc", "tropopause_altitude_primary");
latitude = ncread("F:/_PhD/flexpart_swv_runs/" + ...
    "ERA5_primary_secondary_trop_height_v3.nc", "lat");
longitude = ncread("F:/_PhD/flexpart_swv_runs/" + ...
    "ERA5_primary_secondary_trop_height_v3.nc", "lon");
trop_time = ncread("F:/_PhD/flexpart_swv_runs/" + ...
    "ERA5_primary_secondary_trop_height_v3.nc", "time");

% convert from geopotential height to geometric height
Re = 6371.229; % according to https://confluence.ecmwf.int/display/CKB/ERA5%3A+data+documentation#ERA5:datadocumentation-Spatialreferencesystems, ERA5 assumes the Earth is a perfect sphere with radius 6371.229 km.
tropopause_altitude_secondary = (tropopause_altitude_secondary .* Re) ./ ...
    (Re - tropopause_altitude_secondary);
tropopause_altitude_primary = (tropopause_altitude_primary .* Re) ./ ...
    (Re - tropopause_altitude_primary);

% final_state_dbl_trp = zeros(1355657, 12);
% final_state_all = zeros(1355657, 11);
% time_final_state = NaT(1355657, 1);
% % start_idx_dbl_trp = zeros(1355657, 1);
% time_final_state_dbl_trp = NaT(1355657, 1);

final_state_dbl_trp = zeros(100, 12);
final_state_all = zeros(100, 11);
time_final_state = NaT(100, 1);
% start_idx_dbl_trp = zeros(100, 1);
time_final_state_dbl_trp = NaT(100, 1);

index = [1:8,10:13];
idx_all = 1;
idx = 1;
t_index = 1;
for i = 1:length(index)
% for i = 13:13
    if i < 14
        load(strcat('F:\_PhD\flexpart_swv_runs\SH_d_WK1\SH_d_WK', ...
            num2str(index(i)), '_final_state'), 'final_state');
        load(strcat('F:\_PhD\flexpart_swv_runs\SH_d_WK1\SH_d_WK', ...
            num2str(index(i)), '_final_state'), 'start_idx');
        load(strcat('F:\_PhD\flexpart_swv_runs\SH_d_WK1\SH_d_WK', ...
            num2str(index(i)), '_final_state'), 'SH_breaklat_time_index');
        load(strcat('F:\_PhD\flexpart_swv_runs\SH_d_WK1\SH_d_WK', ...
            num2str(index(i)), '_final_state'), 'time');
        load(strcat('F:\_PhD\flexpart_swv_runs\SH_d_WK1\SH_d_WK', ...
            num2str(index(i)), '_final_state'), 'location_around_final_lon');
        load(strcat('F:\_PhD\flexpart_swv_runs\SH_d_WK1\SH_d_WK', ...
            num2str(index(i)), '_final_state'), 'location_around_final_lat');
        load(strcat('F:\_PhD\flexpart_swv_runs\SH_d_WK1\SH_d_WK', ...
            num2str(index(i)), '_final_state'), 'location_around_final_z');
        load(strcat('F:\_PhD\flexpart_swv_runs\SH_d_WK1\SH_d_WK', ...
            num2str(index(i)), '_final_state'), 'location_around_final_prs');
    else
        load(strcat('F:\_PhD\flexpart_swv_runs\SH_d_WK1\SH_d_WK', ...
            num2str(index(i)), '_final_state_v2'), 'final_state');
        load(strcat('F:\_PhD\flexpart_swv_runs\SH_d_WK1\SH_d_WK', ...
            num2str(index(i)), '_final_state_v2'), 'start_idx');
        load(strcat('F:\_PhD\flexpart_swv_runs\SH_d_WK1\SH_d_WK', ...
            num2str(index(i)), '_final_state_v2'), 'SH_breaklat_time_index');
        load(strcat('F:\_PhD\flexpart_swv_runs\SH_d_WK1\SH_d_WK', ...
            num2str(index(i)), '_final_state_v2'), 'time');
        load(strcat('F:\_PhD\flexpart_swv_runs\SH_d_WK1\SH_d_WK', ...
            num2str(index(i)), '_final_state_v2'), 'location_around_final_lon');
        load(strcat('F:\_PhD\flexpart_swv_runs\SH_d_WK1\SH_d_WK', ...
            num2str(index(i)), '_final_state_v2'), 'location_around_final_lat');
        load(strcat('F:\_PhD\flexpart_swv_runs\SH_d_WK1\SH_d_WK', ...
            num2str(index(i)), '_final_state_v2'), 'location_around_final_z');
        load(strcat('F:\_PhD\flexpart_swv_runs\SH_d_WK1\SH_d_WK', ...
            num2str(index(i)), '_final_state_v2'), 'location_around_final_prs');
    end
    start_date(idx_all:idx_all+height(final_state)-1,1) = time(start_idx);
    final_state(:,11) = table([1:height(final_state)]'); % adding an index column to index time
    [f, s] = SortFinalStateForDblTrp(...
        tropopause_altitude_secondary, tropopause_altitude_primary, ...
        latitude, longitude, final_state, start_idx, SH_breaklat_time_index);

    % get the offset from the file (time = seconds since ...)
    time_units= ncreadatt("Z:/Shared/FLEXPART_wv_2017_output/SH_d_WK" + ...
        index(i) + "/" + filenames(index(i)), "time", "units");
    time_units = split(time_units, ' ');
    time_unit_day = split(time_units{3}, '-');
    time_unit_hour = split(time_units{4}, ':');

    time_offset = datetime(str2double(time_unit_day{1}), ...
        str2double(time_unit_day{2}), str2double(time_unit_day{3}), ...
        str2double(time_unit_hour{1}), str2double(time_unit_hour{2}), 0);
    d = seconds(ncread("Z:/Shared/FLEXPART_wv_2017_output/SH_d_WK" + ...
        index(i) + "/" + filenames(index(i)), 'time')) + time_offset;

    first_day = d(end);
    
    start_idx_all(idx_all:idx_all+height(final_state)-1) = start_idx;

    location_around_final_lon_all(idx_all:idx_all+height(final_state)-1, :) = location_around_final_lon;
    location_around_final_lat_all(idx_all:idx_all+height(final_state)-1, :) = location_around_final_lat;
    location_around_final_z_all(idx_all:idx_all+height(final_state)-1, :) = location_around_final_z;
    location_around_final_prs_all(idx_all:idx_all+height(final_state)-1, :) = location_around_final_prs;

    time_all(t_index:t_index+length(time)-1) = time;
    t_index = t_index + + length(time);

    final_state_all(idx_all:idx_all+height(final_state)-1,:) = table2array(final_state);
    time_final_state_all(idx_all:idx_all+height(final_state)-1) = hours(start_idx' + final_state.TimeIndex - 1) + first_day; 

    final_state_dbl_trp(idx:idx+length(f)-1,:) = f;
    time_final_state_dbl_trp(idx:idx+length(f)-1) = hours(s + f(:,8) - 1) + first_day; 
    start_idx_dbl_trp(idx:idx+length(f)-1) = s;

    idx = idx + length(f);
    idx_all = idx_all + height(final_state);
    clear final_state start_idx SH_breaklat_time_index f s d first_day
end

%%
addpath('F:\_PhD\common_functions\')
months = [11, 12, 1:10, 11];
years = [2016, 2016, ones(1,11)*2017];

title_string = ["11/16", "12/16", ...
    "01/17", "02/17", "03/17", "04/17", "05/17", "06/17", "07/17", ...
    "08/17", "09/17", "10/17", "11/17"];

% !!!!!! figure of particle position when it is entrained in the box !!!!!!
% figure()
% t = tiledlayout(3,4, 'TileSpacing', 'compact');
% title(t, 'Position when particle is tagged as having left the box', ...
%     'fontsize', 16, 'fontweight', 'bold')
% 
% for i = 1:12
%     nexttile
%     hold on
%     grid on
%     box on
%     t_idx = find(month(time_final_state_all) == months(i) & ...
%         year(time_final_state_all) == years(i));
%     scatter(final_state_all(t_idx, 7), final_state_all(t_idx, 6), ...
%         'filled')
%     borders('countries', 'k')
%     ylim([0 90])
%     xlim([-180 180])
%     if i < 9
%         set(gca, 'xticklabels', [])
%     end
%     if ~ismember(i, [1, 5, 9])
%         set(gca, 'yticklabels', [])
%     end
%     set(gca, 'fontsize', 16)
%     title(title_string(i))
% end

% !!!! figure of particle position when it is entrained in the tropics !!!!
% figure()
% t = tiledlayout(3,4, 'TileSpacing', 'compact');
% title(t, 'Position when particle is tagged as having entered the tropics', ...
%     'fontsize', 16, 'fontweight', 'bold')
% 
% for i = 1:12
%     nexttile
%     hold on
%     grid on
%     box on
%     t_idx = find(month(time_final_state_all) == months(i) & ...
%         year(time_final_state_all) == years(i));
%     tropical_nans = final_state_all(t_idx, 1);
%     tropical_nans(tropical_nans == 0) = NaN;
%     lon_to_plot = final_state_all(t_idx, 7).*tropical_nans;
%     lat_to_plot = final_state_all(t_idx, 6).*tropical_nans;
%     height_to_plot = final_state_all(t_idx, 5).*tropical_nans;
%     tropospheric_heights = height_to_plot < 500;
%     scatter(lon_to_plot(~tropospheric_heights), lat_to_plot(~tropospheric_heights), ...
%         10, height_to_plot(~tropospheric_heights), 'filled')
%     scatter(lon_to_plot(tropospheric_heights), lat_to_plot(tropospheric_heights), ...
%         10, height_to_plot(tropospheric_heights), 'filled')
%     clim([60 900])
%     borders('countries', 'k')
%     ylim([0 90])
%     xlim([-180 180])
%     if i < 9
%         set(gca, 'xticklabels', [])
%     end
%     if ~ismember(i, [1, 5, 9])
%         set(gca, 'yticklabels', [])
%     end
%     set(gca, 'fontsize', 16)
%     title(title_string(i))
% end
% cbar = colorbar;
% cbar.Layout.Tile = 'south';
% ylabel(cbar, 'Pressure [hPa]')

% % of the particles crossing through a column with a double tropopause,
% % calculate the percent coming from the tropics:
% disp("***************************************************************************************" + ...
%     "***************************************************************************************")
% disp("The percentage of trajectories passing through a column with a " + ...
%     "double tropopause that originate in the tropics is: " + ...
%     sum(final_state_dbl_trp(:,1))/length(final_state_dbl_trp) * 100 + "%")
% disp("The percentage of trajectories passing through a column with a " + ...
%     "double tropopause that pass between the primary and secondary is: " + ...
%     sum(final_state_dbl_trp(:,12))/length(final_state_dbl_trp) * 100 + "%")
% disp("The percentage of trajectories passing through a column with a " + ...
%     "double tropopause that pass between the primary and secondary and " + ...
%     "originate in the tropics is: " + sum(final_state_dbl_trp(:,12)...
%     .*final_state_dbl_trp(:,1))/length(final_state_dbl_trp) * 100 + "%")
% disp("***************************************************************************************" + ...
%     "***************************************************************************************")

%%
final_days = sort(unique(dateshift(time_final_state_dbl_trp, 'start', 'day')));
months = [11, 12, 1:11]';
years = [2016, 2016, ones(1,11)*2017]';
for i = 1:13
    current{i} = find(month(time_final_state_dbl_trp) == months(i) & ...
        year(time_final_state_dbl_trp) == years(i));
    current_all{i} = find(month(time_final_state_all) == months(i) & ...
        year(time_final_state_all) == years(i));

    dbl_count(i) = length(current{i});
    all_count(i) = length(current_all{i});
    tropical_dbl_count(i) = length(find(final_state_dbl_trp(current{i},1) == 1));
    tropical_count(i) = length(find(final_state_all(current_all{i},1) == 1));

end

%%
% profiles:
figure()
t = tiledlayout(1,13,'TileSpacing','tight');
xlabel(t, 'Percent of trajectories entrained from the tropics by height [%]', ...
    'fontsize', 16)
ylabel(t, 'Height [km]', ...
    'fontsize', 16)
title(t, ['Height of trajectories at transition from tropics to ' ...
    'extratropics'], 'fontsize', 16, 'fontweight', 'bold')

plot_heights = 0.25:0.5:21.75;
for i = 1:13
    % get counts of heights for the month:
    final_state_height_i = final_state_all(current_all{i}, :);
    final_state_height_i(final_state_height_i(:,1) == 0, :) = []; % get rid of the ones that aren't entrained from the tropics

    [counts, ~] = histcounts(final_state_height_i(:,3), [0:0.5:22]);
    [max_count, max_count_index] = max(counts);

    nexttile
    hold on
    grid on
    box on
    p(1) = plot(counts / height(final_state_height_i) * 100, plot_heights, 'LineWidth', 2, ...
        'color', c(9));
    scatter(counts / height(final_state_height_i) * 100, plot_heights, 'filled', ...
        'MarkerEdgeColor', c(9), 'MarkerFaceColor', c(9))
    scatter(max_count / height(final_state_height_i) * 100, plot_heights(max_count_index), 'filled', ...
        'MarkerEdgeColor', c(7), 'MarkerFaceColor', c(7))

    final_state_height_i = final_state_dbl_trp(current{i}, :);
    final_state_height_i(final_state_height_i(:,1) == 0, :) = []; % get rid of the ones that aren't entrained from the tropics

    % [counts, ~] = histcounts(final_state_height_i(:,3), [0:0.5:22]);
    % [max_count, max_count_index] = max(counts);
    % 
    % p(2) = plot(counts / height(final_state_height_i) * 100, plot_heights, 'LineWidth', 2, ...
    %     'color', c(10));
    % scatter(counts / height(final_state_height_i) * 100, plot_heights, 'filled', ...
    %     'MarkerEdgeColor', c(10), 'MarkerFaceColor', c(10))
    % scatter(max_count / height(final_state_height_i) * 100, plot_heights(max_count_index), 'filled', ...
    %     'MarkerEdgeColor', c(7), 'MarkerFaceColor', c(7))

    % check!
    if sum(counts / height(final_state_height_i) * 100) < 99.8
        error('Percent not adding up to 100%')
    end

    ylim([4 21])
    xlim([0 16])
    xtickangle(45)
    set(gca, 'fontsize', 16)
    if i > 2
        set(gca, 'yticklabels', [])
        % legend([p(1) p(2)], 'All tropics', 'Tropics crossing through double tropopause')
    end
    title(title_string(i))
end

%%

% profiles by longitude:
longitude_lower = [-180, -90, 0, 90];
longitude_upper = [-89.9999, -0.00001, 89.9999, 180];

figure()
t = tiledlayout(1,13,'TileSpacing','tight');
xlabel(t, 'Percent of trajectories entrained from the tropics by height [%]', ...
    'fontsize', 16)
ylabel(t, 'Height [km]', ...
    'fontsize', 16)
title(t, ['Height of trajectories at transition from tropics to ' ...
    'extratropics'], 'fontsize', 16, 'fontweight', 'bold')

plot_heights = 4.25:0.5:20.75;
for i = 1:13
    check = 0;
    nexttile
    hold on
    grid on
    box on
    % get counts of heights for the month:
    final_state_height_i = final_state_all(current_all{i}, :);
    final_state_height_i(final_state_height_i(:,1) == 0, :) = []; % get rid of the ones that aren't entrained from the tropics
    check_pcnt_tropical(i) = height(final_state_height_i) / height(final_state_all(current_all{i}, :));
    for j = 1:4
        longitude_index = find(final_state_height_i(:,7) ...
            > longitude_lower(j) & final_state_height_i(:,7) < longitude_upper(j));
        final_state_height_j = final_state_height_i(longitude_index, :);
        [counts, ~] = histcounts(final_state_height_j(:,3), [4:0.5:21]);
        [max_count, max_count_index] = max(counts);
    
        % counts by height (for specific longitude bin) divided by total 
        % number of trajectoriesentrained from the tropics for the whole 
        % globe
        p(j) = plot(counts / height(final_state_height_i) * 100, plot_heights, 'LineWidth', 2, ...
            'color', c(j));
        scatter(counts / height(final_state_height_i) * 100, plot_heights, 'filled', ...
            'MarkerEdgeColor', c(j), 'MarkerFaceColor', c(j))
        scatter(max_count / height(final_state_height_i) * 100, plot_heights(max_count_index), 'filled', ...
            'MarkerEdgeColor', c(5), 'MarkerFaceColor', c(5))
    
        check = check + sum((counts / height(final_state_height_i) * 100));
        monthly_percent_by_longitude(i,j) = height(final_state_height_j) ...
            / length(current_all{i}) * 100;

        ylim([4 21])
        xlim([0 7])
        xtickangle(45)
        set(gca, 'fontsize', 16, 'xtick', [0:7])
        if i > 2
            set(gca, 'yticklabels', [])
        end
    end
    % check!
    if check < 99.7
        error('Percent not adding up to 100%')
    end
    if i == 2
        legend([p(1) p(2) p(3) p(4)], '-180\circE to -90\circE', '-90\circE to 0\circE', ...
            '0\circE to 90\circE', '90\circE to 180\circE', 'numcolumns', 4)
    end
    title(title_string(i))
end
%%
figure()
hold on
grid on
box on
for i = 1:4
    p(i) = plot(1:13, monthly_percent_by_longitude(:,i), 'linewidth', 2, ...
        'color', c(i));
    scatter(1:13, monthly_percent_by_longitude(:,i), 'filled', ...
        'markerfacecolor', c(i), 'MarkerEdgeColor', c(i));
end
p(5) = plot(1:13, sum(monthly_percent_by_longitude, 2), 'linewidth', 2, ...
    'color', c(5));
scatter(1:13, sum(monthly_percent_by_longitude, 2), 'filled', ...
    'markerfacecolor', c(5), 'MarkerEdgeColor', c(5));

legend([p(1) p(2) p(3) p(4) p(5)], '-180\circE to -90\circE', '-90\circE to 0\circE', ...
            '0\circE to 90\circE', '90\circE to 180\circE', 'sum', 'numcolumns', 4)
xlim([1 13])
xticks([1:13])
xticklabels(title_string)
set(gca, 'fontsize', 16)
title('Percent of trajectories entrained from the tropics by longitude bin')
ylabel('Percent of trajectories entrained from the tropics [%]')
xlabel('Month')


%%
max_number_of_trajectories = max(all_count);
max_number_of_trajectories_dbl = max(dbl_count);
figure()
hold on
box on 
grid on
p(1) = plot(1:13, dbl_count/max_number_of_trajectories_dbl * 100, 'LineWidth',2, 'Color', c(5));
scatter(1:13, dbl_count/max_number_of_trajectories_dbl * 100, 100, 'filled', 'MarkerEdgeColor', c(5), ...
    'MarkerFaceColor', c(5))
p(2) = plot(1:13, all_count/max_number_of_trajectories * 100, 'LineWidth', 2, 'Color', c(6));
scatter(1:13, all_count/max_number_of_trajectories * 100, 100, 'filled', 'MarkerEdgeColor', c(6), ...
    'MarkerFaceColor', c(6))
legend([p(2) p(1)],  'all trajectories', 'trajectories crossing through cell with double tropopause')
title('Percent of trajectories counted by month (wrt the max number)')
set(gca, 'fontsize', 16, 'xtick', [1:13], 'xticklabels', ["11/16", "12/16", ...
    "01/17", "02/17", "03/17", "04/17", "05/17", "06/17", "07/17", ...
    "08/17", "09/17", "10/17", "11/17"])
ylabel('Percent of max (134,039, 98,749)')
xlabel('Month')

% !!!!!!!!!!!!!! same as above, but now for the tropics only !!!!!!!!!!!!!! 
max_number_of_trajectories_tropics = max(tropical_count);
max_number_of_trajectories_tropics_dbl = max(tropical_dbl_count);
figure()
hold on
box on 
grid on
p(1) = plot(1:13, tropical_dbl_count/max_number_of_trajectories_tropics_dbl * 100, 'LineWidth',2, 'Color', c(5));
scatter(1:13, tropical_dbl_count/max_number_of_trajectories_tropics_dbl * 100, 100, 'filled', 'MarkerEdgeColor', c(5), ...
    'MarkerFaceColor', c(5))
p(2) = plot(1:13, tropical_count/max_number_of_trajectories_tropics * 100, 'LineWidth', 2, 'Color', c(6));
scatter(1:13, tropical_count/max_number_of_trajectories_tropics * 100, 100, 'filled', 'MarkerEdgeColor', c(6), ...
    'MarkerFaceColor', c(6))
legend([p(2) p(1)],  'tropical trajectories', 'tropical trajectories crossing through cell with double tropopause')
title('Percent of trajectories counted by month (wrt the max number)')
set(gca, 'fontsize', 16, 'xtick', [1:13], 'xticklabels', ["11/16", "12/16", ...
    "01/17", "02/17", "03/17", "04/17", "05/17", "06/17", "07/17", ...
    "08/17", "09/17", "10/17", "11/17"])
ylabel('Percent of max (49,805, 31,487)')
xlabel('Month')

figure()
hold on
box on 
grid on
p(1) = plot(1:13, tropical_dbl_count, 'LineWidth',2, 'Color', c(5));
scatter(1:13, tropical_dbl_count, 100, 'filled', 'MarkerEdgeColor', c(5), ...
    'MarkerFaceColor', c(5))
p(2) = plot(1:13, tropical_count, 'LineWidth', 2, 'Color', c(6));
scatter(1:13, tropical_count, 100, 'filled', 'MarkerEdgeColor', c(6), ...
    'MarkerFaceColor', c(6))
legend([p(2) p(1)],  'tropical trajectories', 'tropical trajectories crossing through cell with double tropopause')
title('Count of trajectories counted by month')
set(gca, 'fontsize', 16, 'xtick', [1:13], 'xticklabels', ["11/16", "12/16", ...
    "01/17", "02/17", "03/17", "04/17", "05/17", "06/17", "07/17", ...
    "08/17", "09/17", "10/17", "11/17"])
ylabel('Count')
xlabel('Month')

%% wrt to all trajectories:
tropics_dbl = find(final_state_dbl_trp(:,1) == 1);
tropics_all = find(final_state_all(:,1) == 1);
final_state_dbl_trop_tropics = final_state_dbl_trp(tropics_dbl,:);
final_state_all_tropics = final_state_all(tropics_all,:);
for i = 1:13
    current = find(month(time_final_state_dbl_trp) == months(i) & ...
        year(time_final_state_dbl_trp) == years(i));
    current_all = find(month(time_final_state_all) == months(i) & ...
        year(time_final_state_all) == years(i));

    pcnt_tropical(i) = sum(final_state_dbl_trp(current,1)) / length(current_all) * 100;
    pcnt_tropical_btwn(i) = sum(final_state_dbl_trp(current,1).*final_state_dbl_trp(current,12)) / length(current_all) * 100;

    % current_all = find(month(time_final_state_all) == months(i) & ...
    %     year(time_final_state_all) == years(i));
    pcnt_tropical_all(i) = sum(final_state_all(current_all,1)) / length(current_all) * 100;

    current_tropics = find(month(time_final_state_dbl_trp(tropics_dbl)) == months(i) & ...
        year(time_final_state_dbl_trp(tropics_dbl)) == years(i));
    current_all_tropics = find(month(time_final_state_all(tropics_all)) == months(i) & ...
        year(time_final_state_all(tropics_all)) == years(i));

    [counts_tropics{i}, ~] = histcounts(final_state_dbl_trop_tropics(current_tropics,3), [4:21]);
    % check!
        % disp(sum(counts_tropics{i}) - length(current_tropics))
    count(i) = length(current_tropics);

    [counts_all{i}, ~] = histcounts(final_state_all_tropics(current_all_tropics,3), [4:21]);
    % check!
        % disp(sum(counts_all{i}) - length(current_all_tropics))
        % disp(length(isnan(final_state_all(current_all_tropics,3))))
    count_all(i) = length(current_all);
end

%%
figure()
hold on
grid on
box on
% yyaxis left
scatter(1:13, pcnt_tropical, 100, 'filled', 'MarkerFaceColor', c(9), ...
    'MarkerEdgeColor', c(9))
p(1) = plot(1:13, pcnt_tropical, '-', 'linewidth', 2, 'Color', c(9));

scatter(1:13, pcnt_tropical_btwn, 100, 'filled', 'MarkerFaceColor', c(10), ...
    'MarkerEdgeColor', c(10))
p(2) = plot(1:13, pcnt_tropical_btwn, '-', 'linewidth', 2, 'Color', c(10));

% set(gca, 'fontsize', 16, 'XTick', 1:13, 'XTickLabels', ["N", "D", ...
%     "J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N"])
% ylabel("Percent originating from the tropics (double trop only) [%]")
% xlabel("Months (2016-2017)")
% xlim([1 13])
% yyaxis right
scatter(1:13, pcnt_tropical_all, 100, 'filled', 'MarkerFaceColor', c(12), ...
    'MarkerEdgeColor', c(12))
p(3) = plot(1:13, pcnt_tropical_all, '-', 'linewidth', 2, 'Color', c(12));
set(gca, 'fontsize', 16, 'XTick', 1:13, 'XTickLabels', ["11/16", "12/16", ...
    "01/17", "02/17", "03/17", "04/17", "05/17", "06/17", "07/17", ...
    "08/17", "09/17", "10/17", "11/17"])
ylabel("Percent originating from the tropics [%]")
xlim([1 13])
legend([p(1), p(2), p(3)], 'Column with double tropopause', ['Between primary and secondary ' ...
    'tropopause'], 'All trajectories', 'numcolumns', 1)
title('Percentage of trajectories originating in the tropics (wrt to total)')

% ax = gca;
% ax.YAxis(1).Color = 'k';
% ax.YAxis(2).Color = 'k';

%

% [counts_tropics, ~] = histcounts(final_state_dbl_trp(:,3), [4:21]);
% [counts_dbltrop, ~] = histcounts(particle_entry_dbl_trop_all.Height, [4:21]);
% [counts_dbl_btwn, ~] = histcounts(particle_entry_dbl_trop.Height, [4:21]);
% [counts_sth, ~] = histcounts(sth, [4:21]);
% [counts_pth, ~] = histcounts(pth, [4:21]);
% [counts_sth_dbl, ~] = histcounts(sth_dbl, [4:21]);
% [counts_pth_dbl, ~] = histcounts(pth_dbl, [4:21]);
% [counts_dbl_below, ~] = histcounts(particle_entry_dbl_below.Height, [4:21]);
% [counts_dbl_above, ~] = histcounts(particle_entry_dbl_above.Height, [4:21]);

%%
titles = ["11/16", "12/16", ...
    "01/17", "02/17", "03/17", "04/17", "05/17", "06/17", "07/17", ...
    "08/17", "09/17", "10/17", "11/17"];

figure()
t = tiledlayout(1,13, 'TileSpacing', 'tight');

for i = 1:13
    nexttile
    hold on
    grid on
    box on
    plot(counts_tropics{i}, 4.5:20.5, 'linewidth', 2, 'Color', c(9))
    plot(counts_all{i}, 4.5:20.5, 'linewidth', 2, 'color', c(7))
    if i == 1
        legend('double tropopause', 'all', 'numcolumns', 2)
    end
    title(titles(i))
    set(gca, 'fontsize', 16)
end

%%
longitude_lower = [-180, -90, 0, 90];
longitude_upper = [-89.9999, -0.00001, 89.9999, 180];

for j = 1:4
    lon_index{j} = find(final_state_all(:,7) > longitude_lower(j) & ...
        final_state_all(:,7) < longitude_upper(j));
end

k = 1;
for i = 1:13
    for j = 1:4
        current = find(month(time_final_state_dbl_trp) == months(i) & ...
            year(time_final_state_dbl_trp) == years(i));
        current_all = find(month(time_final_state_all) == months(i) & ...
            year(time_final_state_all) == years(i));



        pcnt_tropical(i) = sum(final_state_dbl_trp(intersect(current, lon_index{j}),1)) / length(current_all) * 100;
        pcnt_tropical_btwn(i) = sum(final_state_dbl_trp(intersect(current, lon_index{j}),1).*final_state_dbl_trp(intersect(current, lon_index{j}),12)) / length(current_all) * 100;

        % current_all = find(month(time_final_state_all) == months(i) & ...
        %     year(time_final_state_all) == years(i));
        pcnt_tropical_all(i) = sum(final_state_all(intersect(current_all, lon_index{j}),1)) / length(current_all) * 100;

        current_tropics = find(month(time_final_state_dbl_trp(tropics_dbl)) == months(i) & ...
            year(time_final_state_dbl_trp(tropics_dbl)) == years(i));
        current_all_tropics = find(month(time_final_state_all(tropics_all)) == months(i) & ...
            year(time_final_state_all(tropics_all)) == years(i));

        [counts_tropics{k}, ~] = histcounts(final_state_dbl_trop_tropics(intersect(current_tropics, lon_index{j}),3), [4:0.5:21]);
        % check!
            % disp(sum(counts_tropics{i}) - length(current_tropics))
        count(i) = length(current_tropics);

        [counts_all{k}, ~] = histcounts(final_state_all_tropics(intersect(current_all_tropics, lon_index{j}),3), [4:0.5:21]);
        % check!
            % disp(sum(counts_all{i}) - length(current_all_tropics))
            % disp(length(isnan(final_state_all(current_all_tropics,3))))
        count_all(k) = length(intersect(current_all, lon_index{j}));
        k = k + 1;
    end
end

%%

figure()
t = tiledlayout(1,13, 'TileSpacing', 'tight');
ylabel(t, 'Altitude [km]', 'fontsize', 16)
xlabel(t, '% of all trajectories', 'fontsize', 16)
k = 1;
for i = 1:13
    nexttile
    hold on
    grid on
    box on
    for j = 1:4
        plot(counts_tropics{k}/count_all(k) * 100, 4.25:0.5:20.75, 'linewidth', 2, 'Color', c(j))
        % plot(counts_all{k}, 4.5:20.5, 'linewidth', 2, 'color', c(7))
        title(titles(i))
        set(gca, 'fontsize', 16)
        k = k + 1;
    end
    if i == 1
        legend('-180\circE to -90\circE', '-90\circE to 0\circE', ...
            '0\circE to 90\circE', '90\circE to 180\circE', 'numcolumns', 4)
        set(gca, 'ytick', [5:20], 'XMinorTick', 'on') % 'xtick', [0:4:8]
    else
        set(gca, 'yticklabels', [], 'ytick', [5:20], 'XMinorTick', 'on') % 'xtick', [0:4:8]
    end
    xtickangle(45)
    title(titles(i))
    set(gca, 'fontsize', 16)
    % xlim([0 5])
    ylim([4.5 20.5])
end

% %%
% % !!!!!!!!!!!!!!!!!!!!!!!!! WATER VAPOUR THINGS !!!!!!!!!!!!!!!!!!!!!!!!!!!
% 
% d1 = -2;
% d2 = 5;
% 
% [tropics_sorted_by_longitude, i] = sortrows(final_state_all,7);
% location_around_final_lon_all = location_around_final_lon_all(i,:);
% location_around_final_lat_all = location_around_final_lat_all(i,:);
% location_around_final_z_all = location_around_final_z_all(i,:);
% location_around_final_prs_all = location_around_final_prs_all(i,:);
% time_final_state_all = time_final_state_all(i);
% 
% index_remove = find(tropics_sorted_by_longitude(:,1) == 0 | ...
%     isnan(tropics_sorted_by_longitude(:,1)));
% 
% tropics_sorted_by_longitude(index_remove,:) = [];
% location_around_final_lon_all(index_remove,:) = [];
% location_around_final_lat_all(index_remove,:) = [];
% location_around_final_z_all(index_remove,:) = [];
% location_around_final_prs_all(index_remove,:) = [];
% time_final_state_all(index_remove) = [];
% %%
% wv = ncread("F:/_PhD/MLS_H2O/MLS_v5_H2O.nc", "h2o");
% time_wv = caldays(ncread("F:/_PhD/MLS_H2O/MLS_v5_H2O.nc", "time")) + datetime(1950,1,1);
% wv_lev = ncread("F:/_PhD/MLS_H2O/MLS_v5_H2O.nc", "lev");
% wv_lat = ncread("F:/_PhD/MLS_H2O/MLS_v5_H2O.nc", "lat");
% wv_lon = ncread("F:/_PhD/MLS_H2O/MLS_v5_H2O.nc", "lon");
% 
% idx_147 = find(tropics_sorted_by_longitude(:,5) > 129.99999 & ...
%     tropics_sorted_by_longitude(:,5) < 160.00001);
% 
% time_final_state_all_147 = time_final_state_all(idx_147);
% tropics_sorted_by_longitude_147 = tropics_sorted_by_longitude(idx_147,:);
% location_around_final_lon_147 = location_around_final_lon_all(idx_147,:);
% location_around_final_lat_147 = location_around_final_lat_all(idx_147,:);
% location_around_final_z_147 = location_around_final_z_all(idx_147,:);
% location_around_final_prs_147 = location_around_final_prs_all(idx_147,:);
% %%
% % interpolate the column in latitude and longitude to the particle
% % location, then interpolate to the height of the trajectory
% [wv_lon_mesh, wv_lat_mesh] = meshgrid(wv_lon, wv_lat);
% good = 0;
% for i = 1:height(tropics_sorted_by_longitude_147)
%     % disp(i)
%     final_date = time_final_state_all_147(i);
%     tidx = find(year(time_wv) == year(final_date) & month(time_wv) == ...
%         month(final_date) & day(time_wv) == day(final_date));
%     % if tidx > 25
%     %     tidx = 25;
%     %     check = check + 1;
%     % elseif tidx < 2
%     %     tidx = 2;
%     %     check = check + 1;
%     % end
%     % if ismember(i, check)
%     %     stop = 1;
%     % end
%     for d = d1:d2
%         tidx_day = tidx + d;
%         % if i == 1 && d == d1
%         %     wv_tidx(1) = tidx_day;
%         % elseif i == 1 && d == d2
%         %     wv_tidx(2) = tidx_day;
%         % end
%         for lev = 9:12
%             wv_latlon_interp(lev-8) = interp2(wv_lon_mesh, wv_lat_mesh, ...
%                 squeeze(mean(wv(:,:, lev, tidx_day-2:tidx_day+2), 4, 'omitnan')),  ...
%                 location_around_final_lon_147(i, d+1-d1), ...
%                 location_around_final_lat_147(i, d+1-d1));
%             if lev == 12 && ~isnan(wv_latlon_interp(lev-8)) 
%                 % now I interpolate in height
%                 wv_alt_interp(i,d+1-d1) = interp1(log(wv_lev(9:12)), wv_latlon_interp, ...
%                     log(location_around_final_prs_147(i, d+1-d1)));
%                 alt_check(i,d+1-d1) = location_around_final_prs_147(i, d+1-d1);
%             else
%                  wv_alt_interp(i,d+1-d1) = NaN;
%                  alt_check(i,d+1-d1) = NaN;
%             end
%         end
%     end
%     if sum(isnan(wv_alt_interp(i,:))) > 0 && sum(isnan(wv_alt_interp(i,:))) < length(d1:d2)
%         wv_alt_interp(i,:) = NaN(1,length(d1:d2));
%     end
% end
% 
% good_interp = find(~isnan(wv_alt_interp(:,1)));
% 
% [~,y] = size(wv_alt_interp);
% hist_data = wv_alt_interp(good_interp, y) - wv_alt_interp(good_interp, 1);
% 
% 
% longitude = ncread("F:/ERA5_for_tropopause_calculation/EN17042300.nc", "lon");
% SH_breaklat = ncread("F:\_PhD\flexpart_swv_runs\ERA5_SH_SH_break_lat_v2.nc", ...
%     "SH_break_lat");time_trop_height = days(0:89) + datetime(2017,4,23);
% time_trop_height = time_trop_height(54:end);
% 
% SH_breaklat = medfilt1(SH_breaklat, 13);
% 
% SH_breaklat_mean = mean(SH_breaklat, 2);
% SH_breaklat_max = max(SH_breaklat,[],2);
% SH_breaklat_min = min(SH_breaklat,[],2);
% 
% %%
% addpath('F:\_PhD\common_functions\')
% title_string = ["11/16", "12/16", ...
%     "01/17", "02/17", "03/17", "04/17", "05/17", "06/17", "07/17", ...
%     "08/17", "09/17", "10/17", "11/17"];
% % indexes = tropics_sorted_by_longitude_147(:,end);
% % indexes_filtered = indexes(good_interp);
% time_good_trajectories = time_final_state_all_147(good_interp);
% good_trajectories_lon = location_around_final_lon_147(good_interp,:); 
% good_trajectories_lat = location_around_final_lat_147(good_interp,:); 
% wv_to_plot = NaN(46, 73);
% 
% figure()
% t = tiledlayout(3, 4, 'tilespacing', 'compact');
% months = [11, 12, 1:10, 11];
% years = [2016, 2016, ones(1,11)*2017];
% 
% for i = 1:12
% % for i = 13:13
%     wv_tidx(1) = find(month(time_wv) == months(i) & year(time_wv) == years(i), 1, 'first');
%     wv_tidx(2) = find(month(time_wv) == months(i) & year(time_wv) == years(i), 1, 'last');
%     wv_to_plot(1:45, 1:72) = mean(wv(:,:,11,wv_tidx(1):wv_tidx(2)), 4, 'omitnan');
% 
%     trajectories_to_plot_index = find(month(time_good_trajectories) == months(i) & year(time_good_trajectories) == years(i));
%     nexttile
%     counter = 0;
%     hold on
%     grid on
%     box on
%     h = pcolor(-180:5:180, -90:4:90, wv_to_plot);
%     set(h, 'edgecolor', 'none')
%     borders('countries', 'k')
%     plot(longitude, SH_breaklat_min, 'w', 'linewidth', 1.5)
%     plot(longitude, SH_breaklat_mean, 'w', 'linewidth', 1.5)
%     plot(longitude, SH_breaklat_max, 'w', 'linewidth', 1.5)
%     ylim([0 80])
%     xlim([-180 180])
%     % cbar = colorbar;
%     clim([1 25])
%     % ylabel(cbar, 'ppmv')
%     set(gca, 'fontsize', 16, 'layer', 'top')
%     for j = 1:40:length(trajectories_to_plot_index)
%         if max(diff(good_trajectories_lon(trajectories_to_plot_index(j),1:d2+1-d1))) < 230
%             counter = counter + 1;
%             p(2) = plot(good_trajectories_lon(trajectories_to_plot_index(j),1:d2+1-d1), ...
%                     good_trajectories_lat(trajectories_to_plot_index(j),1:d2+1-d1), 'color', ...
%                     'm', 'linewidth', 2);
%             scatter(good_trajectories_lon(trajectories_to_plot_index(j),1), ...
%                 good_trajectories_lat(trajectories_to_plot_index(j),1), ...
%                 10, 'MarkerEdgeColor', 'w', 'MarkerFaceColor', 'w') 
%             if counter > 30
%                 break;
%             end
%         end
%         % title(i)
%         % drawnow
%         % pause(1)
%     end
%     title(title_string(i), 'fontsize', 16)
%     if i < 9
%         set(gca, 'xticklabels', [])
%     end
%     if ~ismember(i, [1, 5, 9])
%         set(gca, 'yticklabels', [])
%     end
% end
% 
% cbar = colorbar;
% cbar.Layout.Tile = 'south';
% ylabel(cbar, 'ppmv')
% %%
% 
% figure()
% t = tiledlayout(3,4, 'TileSpacing', 'compact');
% title(t, 'Position at transition to the tropics (between 130 and 160 hPa)', ...
%     'fontsize', 16, 'fontweight', 'bold')
% 
% for i = 1:12
% % for i = 13:13
%     nexttile
%     hold on
%     grid on
%     box on
%     trajectories_to_plot_index = find(month(time_final_state_all_147) == months(i) & year(time_final_state_all_147) == years(i));
%     scatter(location_around_final_lon_147(trajectories_to_plot_index, abs(d1)+1), ...
%         location_around_final_lat_147(trajectories_to_plot_index, abs(d1)+1), 'filled')
%     borders('countries', 'k')
%     ylim([0 90])
%     xlim([-180 180])
%     if i < 9
%         set(gca, 'xticklabels', [])
%     end
%     if ~ismember(i, [1, 5, 9])
%         set(gca, 'yticklabels', [])
%     end
%     set(gca, 'fontsize', 16)
%     title(title_string(i))
% end
% 
% %%
% 
% figure()
% t = tiledlayout(3,4, 'TileSpacing', 'tight');
% title(t, 'Water vapour amount around entry to the tropics', ...
%     'fontsize', 16, 'fontweight', 'bold')
% ylabel(t, 'ppmv', 'fontsize', 16)
% xlabel(t, 'Days since entering the tropics', 'fontsize', 16)
% 
% for i = 1:12
% % for i = 13:13
%     nexttile
%     hold on
%     grid on
%     box on
%     trajectories_to_plot_index = find(month(time_final_state_all_147) ...
%         == months(i) & year(time_final_state_all_147) == years(i));
%     wv_mean = mean(wv_alt_interp(trajectories_to_plot_index,:), 'omitnan');
%     % % % for j = 1:8
%     wv_std = std(wv_alt_interp(trajectories_to_plot_index,:), 'omitnan');
%     errorbar(d1:d2, wv_mean, wv_std, wv_std, [], [], 'o-', 'LineWidth', 2)
%     set(gca, 'fontsize', 16)
%     xticks([d1:d2])
%     title(title_string(i))
%     % % % end
%     % % % plot(1:8, wv_mean, 'linewidth', 2, 'Color', c(9))
%     % % % scatter(1:8, wv_mean, 'filled', 'markerfacecolor', c(9), 'markeredgecolor', c(9))
%     % errorbar(d1:d2, wv_mean, wv_std, wv_std, [], [], 'o-', 'LineWidth', 2)
%     if i > 8
%         set(gca, 'fontsize', 16, 'xtick', [d1:d2], 'xticklabels', [d1:d2])
%     else
%         set(gca, 'fontsize', 16, 'xtick', [d1:d2], 'xticklabels', [])
%     end
%     if ~ismember(i, [1, 5, 9])
%         set(gca, 'yticklabels', [])
%     end
%     ylim([-2 20])
%     xlim([d1 d2])
%     title(title_string(i))
% end
% 
