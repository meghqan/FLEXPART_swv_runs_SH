c = ["#1171BE"; "#DD5400"; "#EDB120"; ...
    "#8516D1"; "#3BAA32"; "#2FBEEF"; ...
    "#D1048B"; "#FFD60A"; "#6582FD"; "#FF453A"; "#00A3A3"; "#CB845D"];
% 
filenames = ["partoutput_20161103075959.nc", ...
    "partoutput_20161201075959.nc", "partoutput_20161229075959.nc", ...
    "partoutput_20170126050000.nc", "partoutput_20170223050000.nc", ...
    "partoutput_20170323050000.nc", "partoutput_20170420050000.nc", ...
    "partoutput_20170518050000.nc", "partoutput_20170615050000.nc", ...
    "partoutput_20170713050000.nc", "partoutput_20170810050000.nc", ...
    "partoutput_20170907050000.nc", "partoutput_20171005050000.nc", ...
    "partoutput_20171102050000.nc"];

tropopause_altitude_secondary = ncread("F:/_PhD/flexpart_swv_runs/" + ...
    "ERA5_primary_secondary_trop_height_v2.nc", "tropopause_altitude_secondary");
tropopause_altitude_primary = ncread("F:/_PhD/flexpart_swv_runs/" + ...
    "ERA5_primary_secondary_trop_height_v2.nc", "tropopause_altitude_primary");
latitude = ncread("F:/_PhD/flexpart_swv_runs/" + ...
    "ERA5_primary_secondary_trop_height_v2.nc", "lat");
longitude = ncread("F:/_PhD/flexpart_swv_runs/" + ...
    "ERA5_primary_secondary_trop_height_v2.nc", "lon");
trop_time = datetime(2016, 10, 1) + caldays(ncread("F:/_PhD/flexpart_swv_runs/" + ...
    "ERA5_primary_secondary_trop_height_v2.nc", "time"));

% convert from geopotential height to geometric height
Re = 6371.229; % according to https://confluence.ecmwf.int/display/CKB/
% ERA5%3A+data+documentation#ERA5:datadocumentation-Spatialreferencesystems, 
% ERA5 assumes the Earth is a perfect sphere with radius 6371.229 km.
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

index = [1:14];
idx_all = 1;
idx = 1;
t_index = 1;
for i = 1:length(index)
% for i = 13:13
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
    load(strcat('F:\_PhD\flexpart_swv_runs\SH_d_WK1\SH_d_WK', ...
        num2str(index(i)), '_final_state'), 'starting_lat');
    load(strcat('F:\_PhD\flexpart_swv_runs\SH_d_WK1\SH_d_WK', ...
        num2str(index(i)), '_final_state'), 'starting_lon');
    start_date(idx_all:idx_all+height(final_state)-1,1) = time(start_idx);
    final_state(:,11) = table([1:height(final_state)]'); % adding an index column to index time
    [f, s] = SortFinalStateForDblTrp(...
        tropopause_altitude_secondary, tropopause_altitude_primary, ...
        latitude, longitude, final_state, start_idx, SH_breaklat_time_index);

    % get the offset from the file (time = seconds since ...)
    time_units= ncreadatt("Z:/Shared/FLEXPART_wv_2017_output/SH_d_WK" + ...
        index(i) + "/" + filenames(i), "time", "units");
    time_units = split(time_units, ' ');
    time_unit_day = split(time_units{3}, '-');
    time_unit_hour = split(time_units{4}, ':');

    time_offset = datetime(str2double(time_unit_day{1}), ...
        str2double(time_unit_day{2}), str2double(time_unit_day{3}), ...
        str2double(time_unit_hour{1}), str2double(time_unit_hour{2}), 0);
    d = seconds(ncread("Z:/Shared/FLEXPART_wv_2017_output/SH_d_WK" + ...
        index(i) + "/" + filenames(i), 'time')) + time_offset;

    first_day = d(end);

    start_time_all(idx_all:idx_all+height(final_state)-1) = time(start_idx);

    location_around_final_lon_all(idx_all:idx_all+height(final_state)-1, :) = location_around_final_lon;
    location_around_final_lat_all(idx_all:idx_all+height(final_state)-1, :) = location_around_final_lat;
    location_around_final_z_all(idx_all:idx_all+height(final_state)-1, :) = location_around_final_z;
    location_around_final_prs_all(idx_all:idx_all+height(final_state)-1, :) = location_around_final_prs;

    starting_lat_all(idx_all:idx_all+height(final_state)-1, :) = starting_lat;
    starting_lon_all(idx_all:idx_all+height(final_state)-1, :) = starting_lon;

    time_all(t_index:t_index+length(time)-1) = time;
    t_index = t_index + + length(time);

    final_state_all(idx_all:idx_all+height(final_state)-1,:) = table2array(final_state);
    time_final_state_all(idx_all:idx_all+height(final_state)-1) = hours(start_idx' + final_state.TimeIndex - 1) + first_day; 

    final_state_dbl_trp(idx:idx+length(f)-1,:) = f;
    time_final_state_dbl_trp(idx:idx+length(f)-1) = hours(s + f(:,8) - 1) + first_day; 
    % start_idx_dbl_trp(idx:idx+length(f)-1) = s;

    idx = idx + length(f);
    idx_all = idx_all + height(final_state);
    clear final_state start_idx SH_breaklat_time_index f s d first_day
end

%% 
%%
% !!!!!!!!!!!!!!!!!!!!!!!!! WATER VAPOUR THINGS !!!!!!!!!!!!!!!!!!!!!!!!!!!
%
d1 = -2;
d2 = 5;

[tropics_sorted_by_longitude, i] = sortrows(final_state_all,7);
location_around_final_lon_all = location_around_final_lon_all(i,:);
location_around_final_lat_all = location_around_final_lat_all(i,:);
location_around_final_z_all = location_around_final_z_all(i,:);
location_around_final_prs_all = location_around_final_prs_all(i,:);
time_final_state_all = time_final_state_all(i);
start_time_all = start_time_all(i);
starting_lon_all = starting_lon_all(i);
starting_lat_all = starting_lat_all(i);

index_remove = find(tropics_sorted_by_longitude(:,1) == 0 | ...
    isnan(tropics_sorted_by_longitude(:,1)));

tropics_sorted_by_longitude(index_remove,:) = [];
location_around_final_lon_all(index_remove,:) = [];
location_around_final_lat_all(index_remove,:) = [];
location_around_final_z_all(index_remove,:) = [];
location_around_final_prs_all(index_remove,:) = [];
time_final_state_all(index_remove) = [];
start_time_all(index_remove) = [];
starting_lon_all(index_remove) = [];
starting_lat_all(index_remove) = [];

%%
wv = ncread("F:/_PhD/MLS_H2O/MLS_v5_H2O.nc", "h2o");
time_wv = caldays(ncread("F:/_PhD/MLS_H2O/MLS_v5_H2O.nc", "time")) + datetime(1950,1,1);
wv_lev = ncread("F:/_PhD/MLS_H2O/MLS_v5_H2O.nc", "lev");
wv_lat = ncread("F:/_PhD/MLS_H2O/MLS_v5_H2O.nc", "lat");
wv_lon = ncread("F:/_PhD/MLS_H2O/MLS_v5_H2O.nc", "lon");

% !!!!! GET ABOUT 10,000 OR 11,000 MORE "GOOD" TRAJECTORIES FROM THE
% INTERPOLATION IF I USE THIS FILE OF WV INTERPOLATED IN TIME RATHER THAN
% THE RAW FILE. DOESN'T SEEM TO HAVE A NOTICEABLE IMPACT ON THE PLOTS !!!!!
% load("MLS_wv_interpolated_in_time.mat")

idx_147 = find(tropics_sorted_by_longitude(:,5) > 129.99999 & ...
    tropics_sorted_by_longitude(:,5) < 160.00001);

time_final_state_all_147 = time_final_state_all(idx_147);
start_time_all_147 = start_time_all(idx_147);
tropics_sorted_by_longitude_147 = tropics_sorted_by_longitude(idx_147,:);
location_around_final_lon_147 = location_around_final_lon_all(idx_147,:);
location_around_final_lat_147 = location_around_final_lat_all(idx_147,:);
location_around_final_z_147 = location_around_final_z_all(idx_147,:);
location_around_final_prs_147 = location_around_final_prs_all(idx_147,:);
starting_lat_147 = starting_lat_all(idx_147);
starting_lon_147 = starting_lon_all(idx_147);
%%
% interpolate the column in latitude and longitude to the particle
% location, then interpolate to the height of the trajectory
[wv_lon_mesh, wv_lat_mesh] = meshgrid(wv_lon, wv_lat);
wv_alt_interp = nan(height(location_around_final_prs_147), length(d1:d2));
good = 0;
non_nans_idx = find(~isnan(location_around_final_prs_147(:,1)));
for i = 1:length(non_nans_idx)
    final_date = time_final_state_all_147(non_nans_idx(i));
    tidx = find(year(time_wv) == year(final_date) & month(time_wv) == ...
        month(final_date) & day(time_wv) == day(final_date));
    for d = d1:d2
        tidx_day = tidx + d;
        for lev = 9:12
            wv_latlon_interp(lev-8) = interp2(wv_lon_mesh, wv_lat_mesh, ...
                squeeze(mean(wv(:,:, lev, tidx_day-2:tidx_day+2), 4, 'omitnan')),  ...
                location_around_final_lon_147(non_nans_idx(i), d+1-d1), ...
                location_around_final_lat_147(non_nans_idx(i), d+1-d1));
        end
        if ~isnan(wv_latlon_interp(lev-8)) 
            % now I interpolate in height
            wv_alt_interp(non_nans_idx(i),d+1-d1) = interp1(log(wv_lev(9:12)), wv_latlon_interp, ...
                log(location_around_final_prs_147(non_nans_idx(i), d+1-d1)));
            alt_check(non_nans_idx(i),d+1-d1) = location_around_final_prs_147(non_nans_idx(i), d+1-d1);
        % else
        %      wv_alt_interp(i,d+1-d1) = NaN;
        %      alt_check(i,d+1-d1) = NaN;
        end
    end
end

good_interp = find(~isnan(wv_alt_interp(:,1)));

[~,y] = size(wv_alt_interp);
hist_data = wv_alt_interp(good_interp, y) - wv_alt_interp(good_interp, 1);


longitude = ncread("F:/ERA5_for_tropopause_calculation/EN17042300.nc", "lon");
SH_breaklat = ncread("F:\_PhD\flexpart_swv_runs\ERA5_NH_SH_break_lat_v2.nc", ...
    "SH_break_lat");time_trop_height = days(0:89) + datetime(2017,4,23);
time_trop_height = time_trop_height(54:end);

SH_breaklat = medfilt1(SH_breaklat, 13);

SH_breaklat_mean = mean(SH_breaklat, 2);
SH_breaklat_max = max(SH_breaklat,[],2);
SH_breaklat_min = min(SH_breaklat,[],2);

%%
addpath('F:\_PhD\common_functions\')
title_string = ["11/16", "12/16", ...
    "01/17", "02/17", "03/17", "04/17", "05/17", "06/17", "07/17", ...
    "08/17", "09/17", "10/17", "11/17"];
% indexes = tropics_sorted_by_longitude_147(:,end);
% indexes_filtered = indexes(good_interp);
time_good_trajectories = time_final_state_all_147(good_interp);
good_trajectories_lon = location_around_final_lon_147(good_interp,:); 
good_trajectories_lat = location_around_final_lat_147(good_interp,:); 
wv_to_plot = NaN(46, 73);

figure()
t = tiledlayout(4, 4, 'tilespacing', 'compact');
months = [11, 12, 1:11];
years = [2016, 2016, ones(1,11)*2017];

for i = 1:13
% for i = 13:13
    wv_tidx(1) = find(month(time_wv) == months(i) & year(time_wv) == years(i), 1, 'first');
    wv_tidx(2) = find(month(time_wv) == months(i) & year(time_wv) == years(i), 1, 'last');
    wv_to_plot(1:45, 1:72) = mean(wv(:,:,11,wv_tidx(1):wv_tidx(2)), 4, 'omitnan');

    trajectories_to_plot_index = find(month(time_good_trajectories) == months(i) & year(time_good_trajectories) == years(i));
    nexttile
    counter = 0;
    hold on
    grid on
    box on
    h = pcolor(-180:5:180, -90:4:90, wv_to_plot);
    set(h, 'edgecolor', 'none')
    borders('countries', 'k')
    plot(longitude, SH_breaklat_min, 'w', 'linewidth', 1.5)
    plot(longitude, SH_breaklat_mean, 'w', 'linewidth', 1.5)
    plot(longitude, SH_breaklat_max, 'w', 'linewidth', 1.5)
    ylim([0 80])
    xlim([-180 180])
    % cbar = colorbar;
    clim([1 25])
    % ylabel(cbar, 'ppmv')
    set(gca, 'fontsize', 16, 'layer', 'top')
    for j = 1:40:length(trajectories_to_plot_index)
        if max(diff(good_trajectories_lon(trajectories_to_plot_index(j),1:d2+1-d1))) < 230
            counter = counter + 1;
            p(2) = plot(good_trajectories_lon(trajectories_to_plot_index(j),1:d2+1-d1), ...
                    good_trajectories_lat(trajectories_to_plot_index(j),1:d2+1-d1), 'color', ...
                    'm', 'linewidth', 2);
            scatter(good_trajectories_lon(trajectories_to_plot_index(j),1), ...
                good_trajectories_lat(trajectories_to_plot_index(j),1), ...
                10, 'MarkerEdgeColor', 'w', 'MarkerFaceColor', 'w') 
            if counter > 30
                break;
            end
        end
        % title(i)
        % drawnow
        % pause(1)
    end
    title(title_string(i), 'fontsize', 16)
    if i < 9
        set(gca, 'xticklabels', [])
    end
    if ~ismember(i, [1, 5, 9])
        set(gca, 'yticklabels', [])
    end
end

cbar = colorbar;
cbar.Layout.Tile = 'south';
ylabel(cbar, 'ppmv')
%

figure()
t = tiledlayout(3,4, 'TileSpacing', 'compact');
title(t, 'Position at transition to the tropics (between 130 and 160 hPa)', ...
    'fontsize', 16, 'fontweight', 'bold')

for i = 1:12
% for i = 13:13
    nexttile
    hold on
    grid on
    box on
    trajectories_to_plot_index = find(month(time_final_state_all_147) == months(i) & year(time_final_state_all_147) == years(i));
    scatter(location_around_final_lon_147(trajectories_to_plot_index, abs(d1)+1), ...
        location_around_final_lat_147(trajectories_to_plot_index, abs(d1)+1), 'filled')
    borders('countries', 'k')
    ylim([0 90])
    xlim([-180 180])
    if i < 9
        set(gca, 'xticklabels', [])
    end
    if ~ismember(i, [1, 5, 9])
        set(gca, 'yticklabels', [])
    end
    set(gca, 'fontsize', 16)
    title(title_string(i))
end

%

figure()
t = tiledlayout(3,4, 'TileSpacing', 'tight');
title(t, 'Water vapour amount around entry to the tropics', ...
    'fontsize', 16, 'fontweight', 'bold')
ylabel(t, 'ppmv', 'fontsize', 16)
xlabel(t, 'Days since entering the tropics', 'fontsize', 16)

for i = 1:12
% for i = 13:13
    nexttile
    hold on
    grid on
    box on
    trajectories_to_plot_index = find(month(time_final_state_all_147) ...
        == months(i) & year(time_final_state_all_147) == years(i));
    wv_mean = mean(wv_alt_interp(trajectories_to_plot_index,:), 'omitnan');
    % % % for j = 1:8
    wv_std = std(wv_alt_interp(trajectories_to_plot_index,:), 'omitnan');
    errorbar(d1:d2, wv_mean, wv_std, wv_std, [], [], 'o-', 'LineWidth', 2)
    set(gca, 'fontsize', 16)
    xticks([d1:d2])
    title(title_string(i))
    % % % end
    % % % plot(1:8, wv_mean, 'linewidth', 2, 'Color', c(9))
    % % % scatter(1:8, wv_mean, 'filled', 'markerfacecolor', c(9), 'markeredgecolor', c(9))
    % errorbar(d1:d2, wv_mean, wv_std, wv_std, [], [], 'o-', 'LineWidth', 2)
    if i > 8
        set(gca, 'fontsize', 16, 'xtick', [d1:d2], 'xticklabels', [d1:d2])
    else
        set(gca, 'fontsize', 16, 'xtick', [d1:d2], 'xticklabels', [])
    end
    if ~ismember(i, [1, 5, 9])
        set(gca, 'yticklabels', [])
    end
    ylim([-2 20])
    xlim([d1 d2])
    title(title_string(i))
end

%
k = 1;
for i = 1:13
    for j = 1:72
        break_idx = find(year(trop_time) == years(i) & month(trop_time) == months(i));
        min_lat = floor(min(min(SH_breaklat(k:k+9, break_idx))));
        min_lat = min_lat - mod(min_lat, 4);
        max_lat = ceil(max(max(SH_breaklat(k:k+9, break_idx))));
        max_lat = max_lat + (4-mod(max_lat, 4));
        
        wv_idx = find(year(time_wv) == years(i) & month(time_wv) == months(i));
        cweight = cos(wv_lat(find(wv_lat==min_lat): find(wv_lat==max_lat)) * pi / 180);
        weight = cweight / mean(cweight);
        weighted_wv = squeeze(wv(find(wv_lat==min_lat):find(wv_lat==max_lat),j,11,wv_idx)) .* weight;
        wv_mean_by_longitude(i,j) = mean(mean(weighted_wv, 'omitnan'), 'omitnan');
    end
end

wv_mean_total = mean(wv_mean_by_longitude, 2);
%%
time_t5 = time_final_state_all_147 - caldays(5);

for i = 1:13
    
    trajectories_to_plot_index = find(month(time_t5) ...
        == months(i) & year(time_t5) == years(i));
    cweight = cos(tropics_sorted_by_longitude_147(trajectories_to_plot_index,6) * pi / 180);
    weight = cweight / mean(cweight);
    weighted_wv = wv_alt_interp(trajectories_to_plot_index,end) .* weight;
    wv_mean(i) = mean(weighted_wv, 'omitnan');
    % % % for j = 1:8
    wv_std(i) = std(weighted_wv, 'omitnan');
    
end
%%
figure()
title('Water vapour amount around entry to the tropics', ...
    'fontsize', 16, 'fontweight', 'bold')
subtitle('Trajectory time taken at 5 days in the tropics')
ylabel('ppmv', 'fontsize', 16)
xlabel('Month', 'fontsize', 16)
hold on
grid on
box on

p(1) = errorbar(1:13, wv_mean, wv_std, wv_std, [], [], 'o-', 'LineWidth', 2, "MarkerEdgeColor",c(1),"MarkerFaceColor",c(1));
p(2) = errorbar(1:13, wv_mean_total, [], [], [], [], 'o-', 'LineWidth', 2, "MarkerEdgeColor",c(10),"MarkerFaceColor",c(10));

ylim([0 20])
xticks([1:13])
xlim([1 13])
xticklabels(title_string)

set(gca, 'fontsize', 16)

legend([p(1) p(2)], 'MLS interpolated to trajectories (t5)', 'MLS averaged over region of double tropopause')


%%

for i = 1:13
    
    trajectories_to_plot_index = find(month(start_time_all_147) ...
        == months(i) & year(start_time_all_147) == years(i));
    cweight = cos(tropics_sorted_by_longitude_147(trajectories_to_plot_index,6) * pi / 180);
    weight = cweight / mean(cweight);
    weighted_wv = wv_alt_interp(trajectories_to_plot_index,end) .* weight;
    wv_mean(i) = mean(weighted_wv, 'omitnan');
    % % % for j = 1:8
    wv_std(i) = std(weighted_wv, 'omitnan');
    
end
%
figure()
title('Water vapour amount around entry to the tropics', ...
    'fontsize', 16, 'fontweight', 'bold')
subtitle('Trajectory time taken at particle initialization')
ylabel('ppmv', 'fontsize', 16)
xlabel('Month', 'fontsize', 16)
hold on
grid on
box on

p(1) = errorbar(1:13, wv_mean, wv_std, wv_std, [], [], 'o-', 'LineWidth', 2, "MarkerEdgeColor",c(1),"MarkerFaceColor",c(1));
p(2) = errorbar(1:13, wv_mean_total, [], [], [], [], 'o-', 'LineWidth', 2, "MarkerEdgeColor",c(10),"MarkerFaceColor",c(10));

ylim([0 20])
xticks([1:13])
xlim([1 13])
xticklabels(title_string)

set(gca, 'fontsize', 16)

legend([p(1) p(2)], 'MLS interpolated to trajectories (t5)', 'MLS averaged over region of double tropopause')


%% doing the average over the area where the particles are released

lon_left_edge = [-180:5:175];
k = 1;
for i = 1:13
    time_idx = find(year(start_time_all_147) == years(i) & ...
        month(start_time_all_147) == months(i));
    for j = 1:72
        starting_lon_i = starting_lon_147(time_idx);
        starting_lat_i = starting_lat_147(time_idx);

        lon_idx = find(starting_lon_i > lon_left_edge(j) & ...
            starting_lon_i < lon_left_edge(j)+ 4.99999);

        min_lat = floor(min(min(starting_lat_i(lon_idx))));
        min_lat = min_lat - mod(min_lat, 4);
        max_lat = ceil(max(max(starting_lat_i(lon_idx))));
        max_lat = max_lat + (4-mod(max_lat, 4));
        
        wv_idx = find(year(time_wv) == years(i) & month(time_wv) == months(i));
        cweight = cos(wv_lat(find(wv_lat==min_lat): find(wv_lat==max_lat)) * pi / 180);
        weight = cweight / mean(cweight);
        weighted_wv = squeeze(wv(find(wv_lat==min_lat):find(wv_lat==max_lat),j,11,wv_idx)) .* weight;
        wv_mean_by_longitude(i,j) = mean(mean(weighted_wv, 'omitnan'), 'omitnan');
    end
end

wv_mean_total_by_starting_region = mean(wv_mean_by_longitude, 2);

for i = 1:13
    
    trajectories_to_plot_index = find(month(start_time_all_147) ...
        == months(i) & year(start_time_all_147) == years(i));
    cweight = cos(tropics_sorted_by_longitude_147(trajectories_to_plot_index,6) * pi / 180);
    weight = cweight / mean(cweight);
    weighted_wv = wv_alt_interp(trajectories_to_plot_index,end) .* weight;
    wv_mean(i) = mean(weighted_wv, 'omitnan');
    % % % for j = 1:8
    wv_std(i) = std(weighted_wv, 'omitnan');
    
end
%
figure()
title('Water vapour amount around entry to the tropics', ...
    'fontsize', 16, 'fontweight', 'bold')
subtitle('Trajectory time taken at particle initialization')
ylabel('ppmv', 'fontsize', 16)
xlabel('Month', 'fontsize', 16)
hold on
grid on
box on

p(1) = errorbar(1:13, wv_mean, wv_std, wv_std, [], [], 'o-', 'LineWidth', ...
    2, "MarkerEdgeColor",c(1),"MarkerFaceColor",c(1));
p(2) = errorbar(1:13, wv_mean_total_by_starting_region, [], [], [], ...
    [], 'o-', 'LineWidth', 2, "MarkerEdgeColor",c(10),"MarkerFaceColor",c(10));

ylim([0 20])
xticks([1:13])
xlim([1 13])
xticklabels(title_string)

set(gca, 'fontsize', 16)

legend([p(1) p(2)], 'MLS interpolated to trajectories (t5)', 'MLS averaged over initialization region (ExT LS)')

for i = 1:13
    
    trajectories_to_plot_index = find(month(time_t5) ...
        == months(i) & year(time_t5) == years(i));
    cweight = cos(tropics_sorted_by_longitude_147(trajectories_to_plot_index,6) * pi / 180);
    weight = cweight / mean(cweight);
    weighted_wv = wv_alt_interp(trajectories_to_plot_index,end) .* weight;
    wv_mean(i) = mean(weighted_wv, 'omitnan');
    % % % for j = 1:8
    wv_std(i) = std(weighted_wv, 'omitnan');
    
end
%
figure()
title('Water vapour amount around entry to the tropics', ...
    'fontsize', 16, 'fontweight', 'bold')
subtitle('Trajectory time taken at 5 days in the tropics')
ylabel('ppmv', 'fontsize', 16)
xlabel('Month', 'fontsize', 16)
hold on
grid on
box on

p(1) = errorbar(1:13, wv_mean, wv_std, wv_std, [], [], 'o-', 'LineWidth', 2, "MarkerEdgeColor",c(1),"MarkerFaceColor",c(1));
p(2) = errorbar(1:13, wv_mean_total_by_starting_region, [], [], [], [], 'o-', 'LineWidth', 2, "MarkerEdgeColor",c(10),"MarkerFaceColor",c(10));

ylim([0 20])
xticks([1:13])
xlim([1 13])
xticklabels(title_string)

set(gca, 'fontsize', 16)

legend([p(1) p(2)], 'MLS interpolated to trajectories (t5)', 'MLS averaged over initialization region (ExT LS)')

%%

% scale to a larger grid, count the number of particles passing through
% each grid box and scale the size of the dot by the number of particles?

figure()
t = tiledlayout(5,3);
pointsize = 10;

% INDEX NUMBER 3 IS THE TRANSITION, 1 AND 2 ARE IN THE EXTRATROPICS, THE
% REST ARE IN THE TROPICS

k = 1;
for i = 1:4
    nexttile
    hold on
    grid on
    box on
    for j = 1:8
        scatter(location_around_final_lon_147(wv_idx, j), ...
            location_around_final_lat_147(wv_idx, j), pointsize, ...
            wv_alt_interp(wv_idx, j), 'filled');
    end
    cbar = colorbar;
    clim([0 30])
    xlim([-180 180])
    ylim([0 90])
    borders('countries', 'k')
end

%%
% ** do it by season rather than by month to make the plot more readable **

season_months = [12 1 2; 3 4 5; 6 7 8; 9 10 11];
season_years = [2016 2017 2017; 2017 2017 2017; 2017 2017 2017; 2017 2017 2017];
seasons = ["DJF", "MAM", "JJA", "SON"];

figure()
t = tiledlayout(4,8, 'tilespacing', 'compact');
pointsize = 10;

% INDEX NUMBER 3 IS THE TRANSITION, 1 AND 2 ARE IN THE EXTRATROPICS, THE
% REST ARE IN THE TROPICS

% STEP 1: SORT BY SEASON, only take data for rows that are completely non-nan:
c = 1;
for i = 1:length(wv_alt_interp)
    if sum(isnan(wv_alt_interp(i, :))) < 8
        wv_no_nan(c,:) = wv_alt_interp(i, :);
        lat_no_nan(c,:) = location_around_final_lat_147(i,:);
        lon_no_nan(c,:) = location_around_final_lon_147(i,:);
        time_no_nan(c,1) = time_final_state_all_147(i);
        c = c + 1;
    end
end

%%
for i = 1:4
    if i == 1
        wv_idx = find((year(time_no_nan) == season_years(i,1) & ...
            month(time_no_nan) == season_months(i,1)) | ...
            (year(time_no_nan) == season_years(i,2) & ...
            month(time_no_nan) >= season_months(i,2) & ...
            month(time_no_nan) <= season_months(i,3)));
    else
        wv_idx = find(year(time_no_nan) == season_years(i,1) & ...
            month(time_no_nan) >= season_months(i,1) & ...
            month(time_no_nan) <= season_months(i,3));
    end

    wv_seasonal{i} = wv_no_nan(wv_idx,:);
    lat_seasonal{i} = lat_no_nan(wv_idx,:);
    lon_seasonal{i} = lon_no_nan(wv_idx,:);
    time_seasonal{i} = time_no_nan(wv_idx);
end

%%
lat_seasonal = cellfun(@floor,lat_seasonal,'UniformOutput',...
    false);
lat_seasonal = cellfun(@minus, lat_seasonal, cellfun(@(x) mod(x, 3), ...
    lat_seasonal,'UniformOutput',false),'UniformOutput',false);

lon_seasonal = cellfun(@floor,lon_seasonal,'UniformOutput',...
    false);
lon_seasonal = cellfun(@minus, lon_seasonal, cellfun(@(x) mod(x, 4), ...
    lon_seasonal,'UniformOutput',false),'UniformOutput',false);

%%
% num_trajectories = NaN(100, 4);
% mean_wv = NaN(100, 8, 4);

lat_3 = -90:3:12;
lon_4 = -180:4:176;

for i = 1:4
    k = 1;
    disp(i)
    for lat = 1:length(lat_3)
        lat_idx = find(lat_seasonal{i}(:,3) == lat_3(lat));
        for lon = 1:length(lon_4)
            lon_idx = find(lon_seasonal{i}(:,3) == lon_4(lon));

            idx = intersect(lat_idx, lon_idx);
            if length(idx) > 1
                num_trajectories{i}(k) = length(idx);
                mean_wv{i}(k, :) = mean(wv_seasonal{i}(idx,:), ...
                    'omitnan');
                lon_plot{i}(k) = lon_4(lon);
                lat_plot{i}(k) = lat_3(lat);
                k = k + 1;
            elseif isscalar(idx)
                num_trajectories{i}(k) = length(idx);
                mean_wv{i}(k, :) = wv_seasonal{i}(idx,:);
                lon_plot{i}(k) = lon_4(lon);
                lat_plot{i}(k) = lat_3(lat);
                k = k + 1;
            end
        end
    end
end

%%

figure()
t = tiledlayout(4, 8, 'TileSpacing', 'compact');
title(t, ['Water vapour concentration x days from crossing the tropopause' ...
    ' break (in backwards time)'], 'fontsize', 16, 'fontweight', 'bold')

for i = 1:4
    num_trajectories_weighted = num_trajectories{i} / max(cellfun(@max, num_trajectories));
    dot_size = num_trajectories_weighted * 300;
    
    for j = 1:8    
        nexttile
        hold on
        grid on
        scatter(lon_plot{i}, lat_plot{i}, dot_size, mean_wv{i}(:,j), 'filled')
        borders('countries', 'k')
    
        if i < 4
            set(gca, 'xticklabels', [])
        end
        if ~ismember(j, [1,9,17,25])
            set(gca, 'yticklabels', [])
        end
        if i == 1
            title(j-3 + " days")
        end
    
        xlim([-180 180])
        ylim([10 70])
        clim([2 10])

        set(gca, 'fontsize', 16)
    end
end

cbar = colorbar;
cbar.Layout.Tile = 'south';
ylabel(cbar, 'ppmv')
%%

%     for j = 1:8
%         nexttile
%         hold on
%         grid on
%         box on
% 
%         la = 1;
%         lo = 1;
%         counts = zeros(length(-90:4:86), length(-180:4:176));
%         average_wv = zeros(length(-90:4:86), length(-180:4:176));
%         % lat_4x4 = floor(location_around_final_lat_147);
%         % lon_4x4 = floor(location_around_final_lon_147);
%         % for k = 1:length(lat_4x4)
%         %     lat_4x4(k) = lat_4x4(k) - mod(lat_4x4(k));
%         %     lon_4x4(k) = lon_4x4(k) - mod(lon_4x4(k));
%         % end
%         for lat = -90:4:86
%             for lon = -180:4:176
%                 wv_i = wv_alt_interp(wv_idx, j);
%                 lat_idx = find(location_around_final_lat_147(wv_idx, j) ...
%                     > lat & location_around_final_lat_147(wv_idx, j) < lat + 4);
%                 lon_idx = find(location_around_final_lon_147(wv_idx, j) ...
%                     > lon & location_around_final_lon_147(wv_idx, j) < lon + 4);
%                 idx = intersect(lat_idx, lon_idx);
%                 counts(la, lo) = length(idx);
%                 average_wv(la, lo) = mean(wv_i, 'omitnan');
% 
%                 scatter(lon, lat, pointsize, average_wv(la, lo), 'filled');
% 
%                 lo = lo + 1;
% 
%             end
%             la = la + 1;
%         end
%         clim([0 30])
%         xlim([-180 180])
%         ylim([-20 90])
%         borders('countries', 'k')
%         if j ~= 1
%             set(gca, 'yticklabels', [])
%         end
%         if i ~= 4
%             set(gca, 'xticklabels', [])
%         end
%         set(gca, 'fontsize', 16)
%     end
% end
% 
% cbar = colorbar;
% cbar.Layout.Tile = 'south';
% ylabel(cbar, 'ppmv')


%{
what I want: 
    - sort data by season
    - move onto a 4x4 degree grid
    - for each grid cell, count the number of trajectories, scale the
    scatterpoint by this number
    - colour grid the points by the average of the water vapour in that
    grid cell
    - always place the scatter points on the same grid point (based on the
    time when the trajectory crosses into the tropics (alternatively, where
    the particle is initialized), but change the water vapour amount based
    on the mean for the trajectories as they move in space.
%}