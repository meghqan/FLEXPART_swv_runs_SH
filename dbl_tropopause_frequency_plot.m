% February 2026

% from the final state of the particle trajectories (final state when
% crossing a defined border), figure out which ones pass between the
% primary and secondary tropopause, and what percent are coming from the
% tropics

c = ["#1171BE"; "#DD5400"; "#EDB120"; ...
    "#8516D1"; "#3BAA32"; "#2FBEEF"; ...
    "#D1048B"; "#FFD60A"; "#6582FD"; "#FF453A"; "#00A3A3"; "#CB845D"];

filenames = ["partoutput_20161201075959.nc", "partoutput_20161229075959.nc", ...
    "partoutput_20170126050000.nc", "partoutput_20170223050000.nc", ...
    "partoutput_20170323050000.nc", "partoutput_20170420050000.nc", ...
    "partoutput_20170518050000.nc", "partoutput_20170615050000.nc", ...
    "partoutput_20170713050000.nc", "partoutput_20170810050000.nc", ...
    "partoutput_20170907050000.nc", "partoutput_20171005050000.nc", ...
    "partoutput_20171102050000.nc", "partoutput_20171130050000.nc"];

tropopause_altitude_secondary = ncread("F:/_PhD/flexpart_swv_runs/" + ...
    "ERA5_primary_secondary_trop_height_v3.nc", "tropopause_altitude_secondary");
tropopause_altitude_primary = ncread("F:/_PhD/flexpart_swv_runs/" + ...
    "ERA5_primary_secondary_trop_height_v3.nc", "tropopause_altitude_primary");
latitude = ncread("F:/_PhD/flexpart_swv_runs/" + ...
    "ERA5_primary_secondary_trop_height_v3.nc", "lat");
longitude = ncread("F:/_PhD/flexpart_swv_runs/" + ...
    "ERA5_primary_secondary_trop_height_v3.nc", "lon");
trop_time = days(ncread("F:/_PhD/flexpart_swv_runs/" + ...
    "ERA5_primary_secondary_trop_height_v3.nc", "time")) + datetime(2016, 10, 1);
SH_breaklat = ncread("F:\_PhD\flexpart_swv_runs\ERA5_NH_SH_break_lat_v3.nc", ...
    "SH_break_lat");
SH_breaklat = medfilt1(SH_breaklat, 12);

% convert from geopotential height to geometric height
Re = 6371.229; % according to https://confluence.ecmwf.int/display/CKB/ERA5%3A+data+documentation#ERA5:datadocumentation-Spatialreferencesystems, ERA5 assumes the Earth is a perfect sphere with radius 6371.229 km.
tropopause_altitude_secondary = (tropopause_altitude_secondary .* Re) ./ ...
    (Re - tropopause_altitude_secondary);
tropopause_altitude_primary = (tropopause_altitude_primary .* Re) ./ ...
    (Re - tropopause_altitude_primary);

final_state_all = zeros(100, 11);
time_final_state_all = NaT(100, 1);

index = 2:15;
idx_all = 1;
idx = 1;
t_index = 1;
for i = 1:length(index)
    if i < 14
        load(strcat('F:\_PhD\flexpart_swv_runs\SH_d_WK1\SH_d_WK', ...
            num2str(index(i)), '_final_state'), 'final_state');
        load(strcat('F:\_PhD\flexpart_swv_runs\SH_d_WK1\SH_d_WK', ...
            num2str(index(i)), '_final_state'), 'start_idx');
        load(strcat('F:\_PhD\flexpart_swv_runs\SH_d_WK1\SH_d_WK', ...
            num2str(index(i)), '_final_state'), 'time');
    else
        load(strcat('F:\_PhD\flexpart_swv_runs\SH_d_WK1\SH_d_WK', ...
            num2str(index(i)), '_final_state_v2'), 'final_state');
        load(strcat('F:\_PhD\flexpart_swv_runs\SH_d_WK1\SH_d_WK', ...
            num2str(index(i)), '_final_state_v2'), 'start_idx');
        load(strcat('F:\_PhD\flexpart_swv_runs\SH_d_WK1\SH_d_WK', ...
            num2str(index(i)), '_final_state_v2'), 'time');
    end
    start_date(idx_all:idx_all+height(final_state)-1,1) = time(start_idx);
    final_state(:,11) = table([1:height(final_state)]'); % adding an index column to index time

    % get the offset from the file (time = seconds since ...)
    disp("Z:/Shared/FLEXPART_wv_2017_output/SH_d_WK" + ...
        index(i) + "/" + filenames(i))
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
    
    start_idx_all(idx_all:idx_all+height(final_state)-1) = start_idx;

    time_all(t_index:t_index+length(time)-1) = time;
    t_index = t_index + + length(time);

    final_state_all(idx_all:idx_all+height(final_state)-1,:) = table2array(final_state);
    time_final_state_all(idx_all:idx_all+height(final_state)-1) = hours(start_idx' + final_state.TimeIndex - 1) + first_day; 

    idx_all = idx_all + height(final_state);
    clear final_state start_idx d first_day
end

%
% round the latitude and longitude to bin into 0.5 deg x 0.5 deg bins:

nan_index = find(isnan(final_state_all(:,1)));
final_state_all(nan_index, :) = [];
time_final_state_all(nan_index) = [];
extratropics_index = find(final_state_all(:,1) == 0);
final_state_all(extratropics_index, :) = [];
time_final_state_all(extratropics_index) = [];

final_state_all(:,7) = floor(final_state_all(:,7) * 2) / 2;
final_state_all(:,6) = floor(final_state_all(:,6) * 2) / 2;

%%
% crop the tropopause arrays to only cover the dates that I have output
% from FLEXPART:
first_day = min(time_final_state_all);
last_day = max(time_final_state_all);
d1 = find(year(trop_time) == year(first_day) & month(trop_time) == ...
    month(first_day) & day(trop_time) == day(first_day));
d2 = find(year(trop_time) == year(last_day) & month(trop_time) == ...
    month(last_day) & day(trop_time) == day(last_day));

tropopause_altitude_primary = tropopause_altitude_primary(:,:,d1:d2);
tropopause_altitude_secondary = tropopause_altitude_secondary(:,:,d1:d2);
SH_breaklat = SH_breaklat(:,d1:d2);
trop_time = trop_time(d1:d2);

%%
between_pt_st_idx = zeros(height(final_state_all), 1);
sum_dbl_trop_crossing = zeros(720, 361);

for i = 1:height(final_state_all)
    [~,lon_index] = min(abs(longitude-final_state_all(i,7)));
    [~,lat_index] = min(abs(latitude-final_state_all(i,6)));
    time_index = find(year(trop_time) == year(time_final_state_all(i)) & ...
        month(trop_time) == month(time_final_state_all(i)) & ...
        day(trop_time) == day(time_final_state_all(i)));
    if final_state_all(i,3) < tropopause_altitude_secondary(lon_index, lat_index, time_index) && ...
            final_state_all(i,3) > tropopause_altitude_primary(lon_index, lat_index, time_index)
        between_pt_st_idx(i) = 1;
        sum_dbl_trop_crossing(lon_index, lat_index) = ...
            sum_dbl_trop_crossing(lon_index, lat_index) + 1;
    end
end

sum_dbl_trop_crossing(sum_dbl_trop_crossing == 0) = NaN;
%%
addpath("F:/_PhD/common_functions/")

% !!!!!!!!!!!!!!!!!!!!!!!!!!!!! BY MONTH !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

between_pt_st_idx_bm = zeros(height(final_state_all), 12);
sum_dbl_trop_crossing_bm = zeros(720, 361, 12);
sum_trop_crossing_bm = zeros(720, 361, 12);

dbl_tropopause_frequency_bm = zeros(720, 361, 12);

months = 1:12;
years = 2017*ones(1,12);

for j = 1:12
       month_idx = find(month(time_final_state_all) == months(j) & ...
           year(time_final_state_all) == years(j));
       final_state_subset_j = final_state_all(month_idx,:);
       time_final_state_subset_j = time_final_state_all(month_idx);

       tidx = find(month(trop_time) == months(j) & ...
           year(trop_time) == years(j));
       length_month(j) = length(tidx);
       dbl_tropopause_frequency_bm(:,:,j) = sum(~isnan(tropopause_altitude_secondary(:,:,tidx)), 3) / length_month(j) * 100;
       
    for i = 1:height(final_state_subset_j)
        [~,lon_index] = min(abs(longitude-final_state_subset_j(i,7)));
        [~,lat_index] = min(abs(latitude-final_state_subset_j(i,6)));
        time_index = find(year(trop_time) == year(time_final_state_subset_j(i)) & ...
            month(trop_time) == month(time_final_state_subset_j(i)) & ...
            day(trop_time) == day(time_final_state_subset_j(i)));
        sum_trop_crossing_bm(lon_index, lat_index, j) = sum_trop_crossing_bm(lon_index, lat_index, j) + 1;
        if final_state_subset_j(i,3) < tropopause_altitude_secondary(lon_index, lat_index, time_index) && ...
                final_state_subset_j(i,3) > tropopause_altitude_primary(lon_index, lat_index, time_index)
            between_pt_st_idx_bm(i,j) = 1;
            sum_dbl_trop_crossing_bm(lon_index, lat_index, j) = ...
                sum_dbl_trop_crossing_bm(lon_index, lat_index, j) + 1;
        end
    end
    pcnt_through_dbl_trop(j) = sum(sum(sum_dbl_trop_crossing_bm(:,:,j))) / length(month_idx) * 100;
end

sum_dbl_trop_crossing_bm(sum_dbl_trop_crossing_bm == 0) = NaN;
sum_trop_crossing_bm(sum_trop_crossing_bm == 0) = NaN;

addpath("F:/_PhD/common_functions/")

title_string = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", ...
    "Aug", "Sep", "Oct", "Nov", "Dec"];

%%
figure()
t = tiledlayout(4,3, 'tilespacing', 'compact');
title(t, ['Frequency of double tropopause occurrence'], 'fontsize', 16, ...
    'fontweight', 'bold')

for i = 1:12
    to_plot = NaN(361, 721);
    to_plot(1:361, 1:720) = dbl_tropopause_frequency_bm(:,:,i)'; %/length_month(i) * 100)';
    disp(max(max(to_plot)))
    nexttile
    hold on
    grid on
    box on
    h = pcolor(-180:0.5:180, latitude, to_plot);
    set(h, 'edgecolor', 'none')
    borders('countries', 'k')
    ylim([-90 90])
    xlim([-180 180])
    set(gca, 'fontsize', 16, 'layer', 'top')
    text(-170, 15, title_string(i), 'color', 'y', 'FontSize', 16)
    if ~ismember(i, [1, 4, 7, 10])
        set(gca, 'yticklabels', [])
    end
    if i < 9
        set(gca, 'xticklabels', [])
    end
    clim([0 100])
end

cbar = colorbar;
ylabel(cbar, '%')
cbar.Layout.Tile = 'south';

%%
figure()
t = tiledlayout(4,3, 'tilespacing', 'compact');
title(t, ['Frequency of particle entry from the tropics (2017)'], ...
        'fontsize', 16, 'fontweight', 'bold')

for i = 1:12
    to_plot = NaN(361, 721);
    to_plot(1:361, 1:720) = (sum_trop_crossing_bm(:,:,i)/sum(sum(sum_trop_crossing_bm(:,:,i), 'omitnan'), 'omitnan') * 100)';
    % to_plot(1:361, 1:720) = sum_trop_crossing_bm(:,:,i)';
    nexttile
    hold on
    grid on
    box on
    h = pcolor(-180:0.5:180, latitude, to_plot);
    % disp(sum(sum(sum_dbl_trop_crossing_bm(:,:,i)/sum(sum(sum_dbl_trop_crossing_bm(:,:,i), 'omitnan'), 'omitnan') * 100, 'omitnan'), 'omitnan'))
    set(h, 'edgecolor', 'none')
    borders('countries', 'k')
    ylim([-90 0])
    xlim([-180 180])
    set(gca, 'fontsize', 16)
    text(-170, -80, title_string(i), 'color', 'r', 'FontSize', 16)
    text(125, -15, num2str(sum(sum(sum_trop_crossing_bm(:,:,i), 'omitnan'), 'omitnan')), 'color', 'r', 'FontSize', 16)
    if ~ismember(i, [1, 4, 7, 10])
        set(gca, 'yticklabels', [])
    end
    if i < 9
        set(gca, 'xticklabels', [])
    end
    clim([0 0.06])
end

cbar = colorbar;
ylabel(cbar, '[%]')
cbar.Layout.Tile = 'south';

save('SH_count_of_trajectory_crossings','sum_trop_crossing_bm','latitude')