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
    "partoutput_20171102050000.nc", "partoutput_20171130050000.nc"];

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

index = 1:15;
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

    start_time_all(idx_all:idx_all+height(final_state)-1) = time(start_idx+719) + hours(1);

    location_around_final_lon_all(idx_all:idx_all+height(final_state)-1, :) = location_around_final_lon(:,1:8);
    location_around_final_lat_all(idx_all:idx_all+height(final_state)-1, :) = location_around_final_lat(:,1:8);
    location_around_final_z_all(idx_all:idx_all+height(final_state)-1, :) = location_around_final_z(:,1:8);
    location_around_final_prs_all(idx_all:idx_all+height(final_state)-1, :) = location_around_final_prs(:,1:8);

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

idx_121 = find(tropics_sorted_by_longitude(:,5) > 109.9999 & ...
    tropics_sorted_by_longitude(:,5) < 130.00001);

% upper_height_lim = [194.9999, 159.9999, 129.9999, 109.9999, 90.9999]; %, 74.9999, 60];
% lower_height_lim = [235, 195, 160, 130, 110]; %, 91, 75];

time_final_state_all_121 = time_final_state_all(idx_121);
start_time_all_121 = start_time_all(idx_121);
tropics_sorted_by_longitude_121 = tropics_sorted_by_longitude(idx_121,:);
location_around_final_lon_121 = location_around_final_lon_all(idx_121,:);
location_around_final_lat_121 = location_around_final_lat_all(idx_121,:);
location_around_final_z_121 = location_around_final_z_all(idx_121,:);
location_around_final_prs_121 = location_around_final_prs_all(idx_121,:);
starting_lat_121 = starting_lat_all(idx_121);
starting_lon_121 = starting_lon_all(idx_121);
%%
% interpolate the column in latitude and longitude to the particle
% location, then interpolate to the height of the trajectory
[wv_lon_mesh, wv_lat_mesh] = meshgrid(wv_lon, wv_lat);
wv_alt_interp = nan(height(location_around_final_prs_121), length(d1:d2));
good = 0;
non_nans_idx = find(~isnan(location_around_final_prs_121(:,1)));
for i = 1:length(non_nans_idx)
    final_date = time_final_state_all_121(non_nans_idx(i));
    tidx = find(year(time_wv) == year(final_date) & month(time_wv) == ...
        month(final_date) & day(time_wv) == day(final_date));
    for d = d1:d2
        tidx_day = tidx + d;
        for lev = 9:12
            wv_latlon_interp(lev-8) = interp2(wv_lon_mesh, wv_lat_mesh, ...
                squeeze(mean(wv(:,:, lev, tidx_day-2:tidx_day+2), 4, 'omitnan')),  ...
                location_around_final_lon_121(non_nans_idx(i), d+1-d1), ...
                location_around_final_lat_121(non_nans_idx(i), d+1-d1));
        end
        if ~isnan(wv_latlon_interp(lev-8)) 
            % now I interpolate in height
            wv_alt_interp(non_nans_idx(i),d+1-d1) = interp1(log(wv_lev(9:12)), wv_latlon_interp, ...
                log(location_around_final_prs_121(non_nans_idx(i), d+1-d1)));
            alt_check(non_nans_idx(i),d+1-d1) = location_around_final_prs_121(non_nans_idx(i), d+1-d1);
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

%% doing the average over the area where the particles are released
months = [11, 12, 1:12];
years = [2016, 2016, ones(1,12)*2017];

lon_left_edge = [-180:5:175];
k = 1;
for i = 1:length(years)
    time_idx = find(year(start_time_all_121) == years(i) & ...
        month(start_time_all_121) == months(i));
    for j = 1:72
        starting_lon_i = starting_lon_121(time_idx);
        starting_lat_i = starting_lat_121(time_idx);

        lon_idx = find(starting_lon_i > lon_left_edge(j) & ...
            starting_lon_i < lon_left_edge(j)+ 4.99999);

        min_lat = floor(min(min(starting_lat_i(lon_idx))));
        min_lat = min_lat - mod(min_lat, 4);
        max_lat = ceil(max(max(starting_lat_i(lon_idx))));
        max_lat = max_lat + (4-mod(max_lat, 4));
        
        if ~isempty(lon_idx)
            wv_idx = find(year(time_wv) == years(i) & month(time_wv) == months(i));
            cweight = cos(wv_lat(find(wv_lat==min_lat): find(wv_lat==max_lat)) * pi / 180);
            weight = cweight / mean(cweight);
            weighted_wv = squeeze(wv(find(wv_lat==min_lat):find(wv_lat==max_lat),j,11,wv_idx)) .* weight;
            wv_mean_by_longitude(i,j) = mean(mean(weighted_wv, 'omitnan'), 'omitnan');
        else
            wv_mean_by_longitude(i,j) = NaN;
        end
    end
end

wv_mean_total_by_starting_region = mean(wv_mean_by_longitude, 2);
std_mean_total_by_starting_region = std(wv_mean_by_longitude, [], 2);

for i = 1:length(years)
    
    trajectories_to_plot_index = find(month(start_time_all_121) ...
        == months(i) & year(start_time_all_121) == years(i));
    cweight = cos(tropics_sorted_by_longitude_121(trajectories_to_plot_index,6) * pi / 180);
    weight = cweight / mean(cweight);
    weighted_wv = wv_alt_interp(trajectories_to_plot_index,end) .* weight;
    wv_mean(i) = mean(weighted_wv, 'omitnan');
    % % % for j = 1:8
    wv_std(i) = std(weighted_wv, 'omitnan');
    
end
%%
title_string = ["11/16", "12/16", ...
    "01/17", "02/17", "03/17", "04/17", "05/17", "06/17", "07/17", ...
    "08/17", "09/17", "10/17", "11/17"];

figure(6)
title('Water vapour amount around entry to the tropics', ...
    'fontsize', 16, 'fontweight', 'bold')
subtitle('Trajectory time taken at particle initialization')
ylabel('ppmv', 'fontsize', 16)
xlabel('Month', 'fontsize', 16)
hold on
grid on
box on

p(1) = errorbar(1:length(years), wv_mean, wv_std, wv_std, [], [], 'o-', 'LineWidth', ...
    2, "MarkerEdgeColor",c(1),"MarkerFaceColor",c(1));
p(2) = errorbar(1:length(years), wv_mean_total_by_starting_region, std_mean_total_by_starting_region, std_mean_total_by_starting_region, [], ...
    [], 'o-', 'LineWidth', 2, "MarkerEdgeColor",c(10),"MarkerFaceColor",c(10));

% ylim([0 20])
xticks([1:length(years)])
xlim([1 13])
xticklabels(title_string)

set(gca, 'fontsize', 16)

legend([p(1) p(2)], 'MLS interpolated to trajectories (t5)', 'MLS averaged over initialization region (ExT LS)')
%

save('plotting_entrainment_ss_at_121hPa', 'wv_mean', 'wv_std', 'wv_mean_total_by_starting_region', 'std_mean_total_by_starting_region')

clear

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
    "partoutput_20171102050000.nc", "partoutput_20171130050000.nc"];

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

index = 1:15;
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

    start_time_all(idx_all:idx_all+height(final_state)-1) = time(start_idx+719) + hours(1);

    location_around_final_lon_all(idx_all:idx_all+height(final_state)-1, :) = location_around_final_lon(:,1:8);
    location_around_final_lat_all(idx_all:idx_all+height(final_state)-1, :) = location_around_final_lat(:,1:8);
    location_around_final_z_all(idx_all:idx_all+height(final_state)-1, :) = location_around_final_z(:,1:8);
    location_around_final_prs_all(idx_all:idx_all+height(final_state)-1, :) = location_around_final_prs(:,1:8);

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

idx_147 = find(tropics_sorted_by_longitude(:,5) > 129.9999 & ...
    tropics_sorted_by_longitude(:,5) < 160.00001);

% upper_height_lim = [194.9999, 159.9999, 129.9999, 109.9999, 90.9999]; %, 74.9999, 60];
% lower_height_lim = [235, 195, 160, 130, 110]; %, 91, 75];

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

%% doing the average over the area where the particles are released
months = [11, 12, 1:12];
years = [2016, 2016, ones(1,12)*2017];

lon_left_edge = [-180:5:175];
k = 1;
for i = 1:length(years)
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
        
        if ~isempty(lon_idx)
            wv_idx = find(year(time_wv) == years(i) & month(time_wv) == months(i));
            cweight = cos(wv_lat(find(wv_lat==min_lat): find(wv_lat==max_lat)) * pi / 180);
            weight = cweight / mean(cweight);
            weighted_wv = squeeze(wv(find(wv_lat==min_lat):find(wv_lat==max_lat),j,11,wv_idx)) .* weight;
            wv_mean_by_longitude(i,j) = mean(mean(weighted_wv, 'omitnan'), 'omitnan');
        else
            wv_mean_by_longitude(i,j) = NaN;
        end
    end
end

wv_mean_total_by_starting_region = mean(wv_mean_by_longitude, 2);
std_mean_total_by_starting_region = std(wv_mean_by_longitude, [], 2);

for i = 1:length(years)
    
    trajectories_to_plot_index = find(month(start_time_all_147) ...
        == months(i) & year(start_time_all_147) == years(i));
    cweight = cos(tropics_sorted_by_longitude_147(trajectories_to_plot_index,6) * pi / 180);
    weight = cweight / mean(cweight);
    weighted_wv = wv_alt_interp(trajectories_to_plot_index,end) .* weight;
    wv_mean(i) = mean(weighted_wv, 'omitnan');
    % % % for j = 1:8
    wv_std(i) = std(weighted_wv, 'omitnan');
    
end
%%
title_string = ["11/16", "12/16", ...
    "01/17", "02/17", "03/17", "04/17", "05/17", "06/17", "07/17", ...
    "08/17", "09/17", "10/17", "11/17"];

figure(6)
title('Water vapour amount around entry to the tropics', ...
    'fontsize', 16, 'fontweight', 'bold')
subtitle('Trajectory time taken at particle initialization')
ylabel('ppmv', 'fontsize', 16)
xlabel('Month', 'fontsize', 16)
hold on
grid on
box on

p(1) = errorbar(1:length(years), wv_mean, wv_std, wv_std, [], [], 'o-', 'LineWidth', ...
    2, "MarkerEdgeColor",c(1),"MarkerFaceColor",c(1));
p(2) = errorbar(1:length(years), wv_mean_total_by_starting_region, std_mean_total_by_starting_region, std_mean_total_by_starting_region, [], ...
    [], 'o-', 'LineWidth', 2, "MarkerEdgeColor",c(10),"MarkerFaceColor",c(10));

% ylim([0 20])
xticks([1:length(years)])
xlim([1 13])
xticklabels(title_string)

set(gca, 'fontsize', 16)

legend([p(1) p(2)], 'MLS interpolated to trajectories (t5)', 'MLS averaged over initialization region (ExT LS)')
%

save('plotting_entrainment_ss_at_147hPa', 'wv_mean', 'wv_std', 'wv_mean_total_by_starting_region', 'std_mean_total_by_starting_region')

clear

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
    "partoutput_20171102050000.nc", "partoutput_20171130050000.nc"];

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

index = 1:15;
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

    start_time_all(idx_all:idx_all+height(final_state)-1) = time(start_idx+719) + hours(1);

    location_around_final_lon_all(idx_all:idx_all+height(final_state)-1, :) = location_around_final_lon(:,1:8);
    location_around_final_lat_all(idx_all:idx_all+height(final_state)-1, :) = location_around_final_lat(:,1:8);
    location_around_final_z_all(idx_all:idx_all+height(final_state)-1, :) = location_around_final_z(:,1:8);
    location_around_final_prs_all(idx_all:idx_all+height(final_state)-1, :) = location_around_final_prs(:,1:8);

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

idx_178 = find(tropics_sorted_by_longitude(:,5) > 159.9999 & ...
    tropics_sorted_by_longitude(:,5) < 195.00001);

% upper_height_lim = [194.9999, 159.9999, 129.9999, 109.9999, 90.9999]; %, 74.9999, 60];
% lower_height_lim = [235, 195, 160, 130, 110]; %, 91, 75];

time_final_state_all_178 = time_final_state_all(idx_178);
start_time_all_178 = start_time_all(idx_178);
tropics_sorted_by_longitude_178 = tropics_sorted_by_longitude(idx_178,:);
location_around_final_lon_178 = location_around_final_lon_all(idx_178,:);
location_around_final_lat_178 = location_around_final_lat_all(idx_178,:);
location_around_final_z_178 = location_around_final_z_all(idx_178,:);
location_around_final_prs_178 = location_around_final_prs_all(idx_178,:);
starting_lat_178 = starting_lat_all(idx_178);
starting_lon_178 = starting_lon_all(idx_178);
%%
% interpolate the column in latitude and longitude to the particle
% location, then interpolate to the height of the trajectory
[wv_lon_mesh, wv_lat_mesh] = meshgrid(wv_lon, wv_lat);
wv_alt_interp = nan(height(location_around_final_prs_178), length(d1:d2));
good = 0;
non_nans_idx = find(~isnan(location_around_final_prs_178(:,1)));
for i = 1:length(non_nans_idx)
    final_date = time_final_state_all_178(non_nans_idx(i));
    tidx = find(year(time_wv) == year(final_date) & month(time_wv) == ...
        month(final_date) & day(time_wv) == day(final_date));
    for d = d1:d2
        tidx_day = tidx + d;
        for lev = 9:12
            wv_latlon_interp(lev-8) = interp2(wv_lon_mesh, wv_lat_mesh, ...
                squeeze(mean(wv(:,:, lev, tidx_day-2:tidx_day+2), 4, 'omitnan')),  ...
                location_around_final_lon_178(non_nans_idx(i), d+1-d1), ...
                location_around_final_lat_178(non_nans_idx(i), d+1-d1));
        end
        if ~isnan(wv_latlon_interp(lev-8)) 
            % now I interpolate in height
            wv_alt_interp(non_nans_idx(i),d+1-d1) = interp1(log(wv_lev(9:12)), wv_latlon_interp, ...
                log(location_around_final_prs_178(non_nans_idx(i), d+1-d1)));
            alt_check(non_nans_idx(i),d+1-d1) = location_around_final_prs_178(non_nans_idx(i), d+1-d1);
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

%% doing the average over the area where the particles are released
months = [11, 12, 1:12];
years = [2016, 2016, ones(1,12)*2017];

lon_left_edge = [-180:5:175];
k = 1;
for i = 1:length(years)
    time_idx = find(year(start_time_all_178) == years(i) & ...
        month(start_time_all_178) == months(i));
    for j = 1:72
        starting_lon_i = starting_lon_178(time_idx);
        starting_lat_i = starting_lat_178(time_idx);

        lon_idx = find(starting_lon_i > lon_left_edge(j) & ...
            starting_lon_i < lon_left_edge(j)+ 4.99999);
        
        if ~isempty(lon_idx)
            min_lat = floor(min(min(starting_lat_i(lon_idx))));
            min_lat = min_lat - mod(min_lat, 4);
            max_lat = ceil(max(max(starting_lat_i(lon_idx))));
            max_lat = max_lat + (4-mod(max_lat, 4));
            
            wv_idx = find(year(time_wv) == years(i) & month(time_wv) == months(i));
            cweight = cos(wv_lat(find(wv_lat==min_lat): find(wv_lat==max_lat)) * pi / 180);
            weight = cweight / mean(cweight);
            weighted_wv = squeeze(wv(find(wv_lat==min_lat):find(wv_lat==max_lat),j,11,wv_idx)) .* weight;
            wv_mean_by_longitude(i,j) = mean(mean(weighted_wv, 'omitnan'), 'omitnan');
        else
            wv_mean_by_longitude(i,j) = NaN;
        end
    end
end

wv_mean_total_by_starting_region = mean(wv_mean_by_longitude, 2, 'omitnan');
std_mean_total_by_starting_region = std(wv_mean_by_longitude, [], 2, 'omitnan');

for i = 1:length(years)
    
    trajectories_to_plot_index = find(month(start_time_all_178) ...
        == months(i) & year(start_time_all_178) == years(i));
    cweight = cos(tropics_sorted_by_longitude_178(trajectories_to_plot_index,6) * pi / 180);
    weight = cweight / mean(cweight);
    weighted_wv = wv_alt_interp(trajectories_to_plot_index,end) .* weight;
    wv_mean(i) = mean(weighted_wv, 'omitnan');
    % % % for j = 1:8
    wv_std(i) = std(weighted_wv, 'omitnan');
    
end
%%
title_string = ["11/16", "12/16", ...
    "01/17", "02/17", "03/17", "04/17", "05/17", "06/17", "07/17", ...
    "08/17", "09/17", "10/17", "11/17"];

figure(6)
title('Water vapour amount around entry to the tropics', ...
    'fontsize', 16, 'fontweight', 'bold')
subtitle('Trajectory time taken at particle initialization')
ylabel('ppmv', 'fontsize', 16)
xlabel('Month', 'fontsize', 16)
hold on
grid on
box on

p(1) = errorbar(1:length(years), wv_mean, wv_std, wv_std, [], [], 'o-', 'LineWidth', ...
    2, "MarkerEdgeColor",c(1),"MarkerFaceColor",c(1));
p(2) = errorbar(1:length(years), wv_mean_total_by_starting_region, std_mean_total_by_starting_region, std_mean_total_by_starting_region, [], ...
    [], 'o-', 'LineWidth', 2, "MarkerEdgeColor",c(10),"MarkerFaceColor",c(10));

% ylim([0 20])
xticks([1:length(years)])
xlim([1 13])
xticklabels(title_string)

set(gca, 'fontsize', 16)

legend([p(1) p(2)], 'MLS interpolated to trajectories (t5)', 'MLS averaged over initialization region (ExT LS)')
%

save('plotting_entrainment_ss_at_178hPa', 'wv_mean', 'wv_std', 'wv_mean_total_by_starting_region', 'std_mean_total_by_starting_region')

clear

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
    "partoutput_20171102050000.nc", "partoutput_20171130050000.nc"];

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

index = 1:15;
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

    start_time_all(idx_all:idx_all+height(final_state)-1) = time(start_idx+719) + hours(1);

    location_around_final_lon_all(idx_all:idx_all+height(final_state)-1, :) = location_around_final_lon(:,1:8);
    location_around_final_lat_all(idx_all:idx_all+height(final_state)-1, :) = location_around_final_lat(:,1:8);
    location_around_final_z_all(idx_all:idx_all+height(final_state)-1, :) = location_around_final_z(:,1:8);
    location_around_final_prs_all(idx_all:idx_all+height(final_state)-1, :) = location_around_final_prs(:,1:8);

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

idx_215 = find(tropics_sorted_by_longitude(:,5) > 194.9999 & ...
    tropics_sorted_by_longitude(:,5) < 235.00001);

% upper_height_lim = [194.9999, 159.9999, 129.9999, 109.9999, 90.9999]; %, 74.9999, 60];
% lower_height_lim = [235, 195, 160, 130, 110]; %, 91, 75];

time_final_state_all_215 = time_final_state_all(idx_215);
start_time_all_215 = start_time_all(idx_215);
tropics_sorted_by_longitude_215 = tropics_sorted_by_longitude(idx_215,:);
location_around_final_lon_215 = location_around_final_lon_all(idx_215,:);
location_around_final_lat_215 = location_around_final_lat_all(idx_215,:);
location_around_final_z_215 = location_around_final_z_all(idx_215,:);
location_around_final_prs_215 = location_around_final_prs_all(idx_215,:);
starting_lat_215 = starting_lat_all(idx_215);
starting_lon_215 = starting_lon_all(idx_215);
%%
% interpolate the column in latitude and longitude to the particle
% location, then interpolate to the height of the trajectory
[wv_lon_mesh, wv_lat_mesh] = meshgrid(wv_lon, wv_lat);
wv_alt_interp = nan(height(location_around_final_prs_215), length(d1:d2));
good = 0;
non_nans_idx = find(~isnan(location_around_final_prs_215(:,1)));
for i = 1:length(non_nans_idx)
    final_date = time_final_state_all_215(non_nans_idx(i));
    tidx = find(year(time_wv) == year(final_date) & month(time_wv) == ...
        month(final_date) & day(time_wv) == day(final_date));
    for d = d1:d2
        tidx_day = tidx + d;
        for lev = 9:12
            wv_latlon_interp(lev-8) = interp2(wv_lon_mesh, wv_lat_mesh, ...
                squeeze(mean(wv(:,:, lev, tidx_day-2:tidx_day+2), 4, 'omitnan')),  ...
                location_around_final_lon_215(non_nans_idx(i), d+1-d1), ...
                location_around_final_lat_215(non_nans_idx(i), d+1-d1));
        end
        if ~isnan(wv_latlon_interp(lev-8)) 
            % now I interpolate in height
            wv_alt_interp(non_nans_idx(i),d+1-d1) = interp1(log(wv_lev(9:12)), wv_latlon_interp, ...
                log(location_around_final_prs_215(non_nans_idx(i), d+1-d1)));
            alt_check(non_nans_idx(i),d+1-d1) = location_around_final_prs_215(non_nans_idx(i), d+1-d1);
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

%% doing the average over the area where the particles are released
months = [11, 12, 1:12];
years = [2016, 2016, ones(1,12)*2017];

lon_left_edge = [-180:5:175];
k = 1;
for i = 1:length(years)
    time_idx = find(year(start_time_all_215) == years(i) & ...
        month(start_time_all_215) == months(i));
    for j = 1:72
        starting_lon_i = starting_lon_215(time_idx);
        starting_lat_i = starting_lat_215(time_idx);

        lon_idx = find(starting_lon_i > lon_left_edge(j) & ...
            starting_lon_i < lon_left_edge(j)+ 4.99999);

        if ~isempty(lon_idx)
            min_lat = floor(min(min(starting_lat_i(lon_idx))));
            min_lat = min_lat - mod(min_lat, 4);
            max_lat = ceil(max(max(starting_lat_i(lon_idx))));
            max_lat = max_lat + (4-mod(max_lat, 4));
            
            wv_idx = find(year(time_wv) == years(i) & month(time_wv) == months(i));
            cweight = cos(wv_lat(find(wv_lat==min_lat): find(wv_lat==max_lat)) * pi / 180);
            weight = cweight / mean(cweight);
            weighted_wv = squeeze(wv(find(wv_lat==min_lat):find(wv_lat==max_lat),j,11,wv_idx)) .* weight;
            wv_mean_by_longitude(i,j) = mean(mean(weighted_wv, 'omitnan'), 'omitnan');
        else
            wv_mean_by_longitude(i,j) = NaN;
        end
    end
end

wv_mean_total_by_starting_region = mean(wv_mean_by_longitude, 2);
std_mean_total_by_starting_region = std(wv_mean_by_longitude, [], 2);

for i = 1:length(years)
    
    trajectories_to_plot_index = find(month(start_time_all_215) ...
        == months(i) & year(start_time_all_215) == years(i));
    cweight = cos(tropics_sorted_by_longitude_215(trajectories_to_plot_index,6) * pi / 180);
    weight = cweight / mean(cweight);
    weighted_wv = wv_alt_interp(trajectories_to_plot_index,end) .* weight;
    wv_mean(i) = mean(weighted_wv, 'omitnan');
    % % % for j = 1:8
    wv_std(i) = std(weighted_wv, 'omitnan');
    
end
%%
title_string = ["11/16", "12/16", ...
    "01/17", "02/17", "03/17", "04/17", "05/17", "06/17", "07/17", ...
    "08/17", "09/17", "10/17", "11/17"];

figure(6)
title('Water vapour amount around entry to the tropics', ...
    'fontsize', 16, 'fontweight', 'bold')
subtitle('Trajectory time taken at particle initialization')
ylabel('ppmv', 'fontsize', 16)
xlabel('Month', 'fontsize', 16)
hold on
grid on
box on

p(1) = errorbar(1:length(years), wv_mean, wv_std, wv_std, [], [], 'o-', 'LineWidth', ...
    2, "MarkerEdgeColor",c(1),"MarkerFaceColor",c(1));
p(2) = errorbar(1:length(years), wv_mean_total_by_starting_region, std_mean_total_by_starting_region, std_mean_total_by_starting_region, [], ...
    [], 'o-', 'LineWidth', 2, "MarkerEdgeColor",c(10),"MarkerFaceColor",c(10));

% ylim([0 20])
xticks([1:length(years)])
xlim([1 13])
xticklabels(title_string)

set(gca, 'fontsize', 16)

legend([p(1) p(2)], 'MLS interpolated to trajectories (t5)', 'MLS averaged over initialization region (ExT LS)')
%

save('plotting_entrainment_ss_at_215hPa', 'wv_mean', 'wv_std', 'wv_mean_total_by_starting_region', 'std_mean_total_by_starting_region')

clear

% DIFFERENCE FROM v5:
    % changed so that I am interpolating the MLS water vapour to the lat,
    % lon, and altitude of the trajectory (rather than just taking the
    % value for the bin that the trajectory falls into)

% trying to calculate the mass of water vapour in the starting region


function t0 = read_flexpart_time(ncfile)
    u = split(ncreadatt(ncfile,'time','units'));
    d = split(u{3},'-');
    h = split(u{4},':');
    t0 = datetime(str2double(d{1}),str2double(d{2}),str2double(d{3}), ...
                  str2double(h{1}),str2double(h{2}),0);
end


figure_number = 1;
% MLS water vapour:
wv_file = "F:/_PhD/MLS_H2O/MLS_v5_H2O.nc";
wv = ncread(wv_file, "h2o");
wv_time = caldays(ncread(wv_file, "time")) + datetime(1950,1,1);
wv_lev = ncread(wv_file, "lev");
wv_lat = ncread(wv_file, "lat");
wv_lon = ncread(wv_file, "lon");
clear wv_file

% only want 2017:
t1 = find(year(wv_time) == 2017, 1, 'first')-60;
t2 = find(year(wv_time) == 2018 & month(wv_time) == 1, 1, 'last')+10;

wv = wv(:,:,:,t1:t2) * 18.015/28.97 * 10^-6; % go from VMR to MMR
wv_time = wv_time(t1:t2);

grid_area = ncread("area.nc", "cell_area"); % square metres

%

c = ["#1171BE"; "#DD5400"; "#EDB120"; ...
    "#8516D1"; "#3BAA32"; "#2FBEEF"; ...
    "#D1048B"; "#FFD60A"; "#6582FD"; "#FF453A"; "#00A3A3"; "#CB845D"];

% "partoutput_20161103075959.nc", ...
filenames = ["partoutput_20161201075959.nc", "partoutput_20161229075959.nc", ...
    "partoutput_20170126050000.nc", "partoutput_20170223050000.nc", ...
    "partoutput_20170323050000.nc", "partoutput_20170420050000.nc", ...
    "partoutput_20170518050000.nc", "partoutput_20170615050000.nc", ...
    "partoutput_20170713050000.nc", "partoutput_20170810050000.nc", ...
    "partoutput_20170907050000.nc", "partoutput_20171005050000.nc", ...
    "partoutput_20171102050000.nc", "partoutput_20171130050000.nc"];

index = 2:15;

% preallocate array sizes:
nfiles = numel(index);
nPart = 0;

for i = 1:nfiles
    S = load(sprintf('F:/_PhD/flexpart_swv_runs/SH_d_WK1/SH_d_WK%d_final_state',index(i)), ...
        'final_state');
    nPart = nPart + height(S.final_state);
end
final_state_all = NaN(nPart, width(S.final_state));
sh = NaN(nPart, 1);
lat = NaN(nPart, 1);
lon = NaN(nPart, 1);
prs = NaN(nPart, 1);

final_idx = NaN(nPart,1);
start_time_all = NaT(nPart,1);
time_final_state_all = NaT(nPart,1);

starting_lat_all = NaN(nPart,1);
starting_lon_all = NaN(nPart,1);
starting_z_all   = NaN(nPart,1);
starting_prs_all = NaN(nPart,1);

bad_idx = false(nPart,1);
% preallocate array sizes ^

filenames_nc = "SH_d_WK" + index + "_traj.nc";

idx_all = 1;
idx = 1;
t_index = 1;
k = 1;

figure()
hold on
grid on

for i = 1:length(index)
    load(strcat('F:\_PhD\flexpart_swv_runs\SH_d_WK1\SH_d_WK', ...
        num2str(index(i)), '_final_state'), 'final_state', 'start_idx', ...
        'time', 'starting_lat', 'starting_lon', 'starting_z', ...
        'starting_prs', 'location_around_final_lon', ...
        'location_around_final_lat', 'location_around_final_z', ...
        'location_around_final_prs');
   
    ncfile = "Z:/Shared/FLEXPART_wv_2017_output/SH_d_WK" + ...
        index(i) + "/" + filenames(i);
    
    t0 = read_flexpart_time(ncfile);
    d  = seconds(ncread(ncfile,'time')) + t0;
    time_final_state_all(idx_all:idx_all+height(final_state)-1) = ...
        hours(start_idx' + final_state.TimeIndex - 1) + d(end);


    final_state_all(idx_all:idx_all+height(final_state)-1,:) = table2array(final_state);
    start_time_all(idx_all:idx_all+height(final_state)-1,1) = time(start_idx+719) + hours(1);
    final_idx(idx_all:idx_all+height(final_state)-1) = final_state.TimeIndex;

    location_around_final_lon_all(idx_all:idx_all+height(final_state)-1, :) = location_around_final_lon(:,1:8);
    location_around_final_lat_all(idx_all:idx_all+height(final_state)-1, :) = location_around_final_lat(:,1:8);
    location_around_final_z_all(idx_all:idx_all+height(final_state)-1, :) = location_around_final_z(:,1:8);
    location_around_final_prs_all(idx_all:idx_all+height(final_state)-1, :) = location_around_final_prs(:,1:8);

    starting_lat_all(idx_all:idx_all+height(final_state)-1, :) = starting_lat;
    starting_lon_all(idx_all:idx_all+height(final_state)-1, :) = starting_lon;
    starting_z_all(idx_all:idx_all+height(final_state)-1, :) = starting_z;
    starting_prs_all(idx_all:idx_all+height(final_state)-1, :) = starting_prs;

    sh_i = ncread(filenames_nc(i), "sh");
    lat_i = ncread(filenames_nc(i), "lat");
    lon_i = ncread(filenames_nc(i), "lon");
    prs_i = ncread(filenames_nc(i), "prs");

    for j = 1:length(sh_i)
        if ~isnan(final_state.TimeIndex(j)) && final_state.TimeIndex(j)-120 > 0
            % save @ 5 days before entrainment
            sh(idx_all+j-1, 1) = sh_i(final_state.TimeIndex(j)-120, j);
            lat(idx_all+j-1, 1) = lat_i(final_state.TimeIndex(j)-120, j);
            lon(idx_all+j-1, 1) = lon_i(final_state.TimeIndex(j)-120, j);
            prs(idx_all+j-1, 1) = prs_i(final_state.TimeIndex(j)-120, j);
        elseif ~isnan(final_state.TimeIndex(j)) && final_state.TimeIndex(j)-120 < 0
            if final_state.TropicalState(j)
                final_state_all(idx_all+j-1,:) = NaN;
                bad_idx(k) = idx_all+j-1;
                k = k + 1;
            end
            sh(idx_all+j-1, 1) = NaN;
            lat(idx_all+j-1, 1) = NaN;
            lon(idx_all+j-1, 1) = NaN;
            prs(idx_all+j-1, 1) = NaN;
        else
            sh(idx_all+j-1, 1) = NaN;
            lat(idx_all+j-1, 1) = NaN;
            lon(idx_all+j-1, 1) = NaN;
            prs(idx_all+j-1, 1) = NaN;
        end
    end

    scatter(ones(length(idx_all:idx_all+height(final_state)-1), 1) * i, time_final_state_all(idx_all:idx_all+height(final_state)-1))
    drawnow

    idx_all = idx_all + height(final_state);

    clear final_state start_idx SH_breaklat_time_index f s sh_i lat_i lon_i prs_i
end
yline(datetime(2016, 11, 1):calmonths(1):datetime(2018,2,1))

sh(sh == 0) = NaN;

sh = sh ./ (1 - sh); % CONVERT FROM KG/MOIST AIR to KG/DRY AIR
%%

final_state_all(bad_idx,:) = [];
sh(bad_idx) = [];
lat(bad_idx) = [];
lon(bad_idx) = [];
prs(bad_idx) = [];
starting_lat_all(bad_idx) = [];
starting_lon_all(bad_idx) = [];
starting_prs_all(bad_idx) = [];
starting_z_all(bad_idx) = [];
final_idx(bad_idx) = [];
start_time_all(bad_idx) = [];
time_final_state_all(bad_idx) = [];

% sh = sh * 10^6 * 28.97 / 18.015; % convert from kg/kg to ppmv
%%
g = 9.81;

lon_left = [-180:5:175];
lat_bottom = [-90:4:86];

starting_prs_mls = interp1(wv_lev, wv_lev, starting_prs_all, 'next', 'extrap');
starting_lat_4 = interp1(lat_bottom, lat_bottom, starting_lat_all, 'previous', 'extrap');
starting_lon_5 = interp1(lon_left, lon_left, starting_lon_all, 'previous', 'extrap');

non_nan = find(final_state_all(:,1) == 1);
ending_prs_mls = NaN(length(prs), 1);
for i = 1:length(non_nan)
    if prs(non_nan(i)) > 1000
        ending_prs_mls(non_nan(i)) = 1000;
    else
        ending_prs_mls(non_nan(i)) = interp1(wv_lev, wv_lev, ...
            prs(non_nan(i)), 'next', 'extrap');
    end
end

not_tropics = find(final_state_all(:,1) == 0);

ending_lat_4 = interp1(lat_bottom, lat_bottom, lat, 'previous', 'extrap');
ending_lon_5 = interp1(lon_left, lon_left, lon, 'previous', 'extrap');

ending_lat_4(not_tropics) = NaN;
ending_lon_5(not_tropics) = NaN;
time_final_state_all(not_tropics) = NaT;

months = [12, 12, 12, ones(1,31), 2*ones(1,28), 3*ones(1,31), 4*ones(1,30), 5*ones(1,31), ...
    6*ones(1,30), 7*ones(1,31), 8*ones(1,31), 9*ones(1,30), 10*ones(1,31), ...
    11*ones(1,30), 12*ones(1,31)];
days = [29, 30, 31, 1:31, 1:28, 1:31, 1:30, 1:31, 1:30, 1:31, 1:31, 1:30, 1:31, 1:30, 1:31];

%%
% months = 1:12;
years = [2016, 2016, 2016, 2017*ones(1, 365)];

release_windows = datetime(years(1), months(1), days(1)):caldays(7):...
    datetime(years(end), months(end), days(end));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
release_windows = release_windows(1:52); % *** put these last ones back once I have the output from the last FLEXPART run! ***
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% for each day, get the # of particles per MLS grid:
count = NaN(length(lon_left), length(lat_bottom), length(release_windows));
air_kg = zeros(length(lat_bottom), length(lon_left), length(wv_lev), length(release_windows));
air_kg_per_traj_flat_i = zeros(length(release_windows), 1);
air_kg_flat = zeros(length(release_windows));

% p_test = cell(48,1);
l = 0;
% figure()
for i = 1:length(release_windows)
    disp("pt 1 i=" + i)
    % p_test{i} = NaN(72, 45);
    start_day_idx{i} = (start_time_all >= release_windows(i)) & (start_time_all <= release_windows(i)+caldays(6)+hours(21));
    start_wv_idx{i} = (wv_time >= release_windows(i)) & (wv_time <= release_windows(i)+caldays(6));

    idx = find(start_day_idx{i});
    for j = 1:length(idx)
        if ~isnat(time_final_state_all(idx(j)))
            % going 5 days back since we are taking the value at 5 days in
            % the tropics, pre-entrainment
            end_wv_idx{i}(j) = find(day(wv_time) == day(time_final_state_all(idx(j))-caldays(5)) & ...
                month(wv_time) == month(time_final_state_all(idx(j))-caldays(5)) ...
                & year(wv_time) == year(time_final_state_all(idx(j))-caldays(5)));
        else
            end_wv_idx{i}(j) = NaN;
        end
    end


    starting_lat_i{i} = starting_lat_all(start_day_idx{i});
    starting_lon_i{i} = starting_lon_all(start_day_idx{i});
    starting_prs_i{i} = starting_prs_all(start_day_idx{i});

    starting_lat_i_4{i} = starting_lat_4(start_day_idx{i});
    starting_lon_i_5{i} = starting_lon_5(start_day_idx{i});
    starting_prs_i_mls{i} = starting_prs_mls(start_day_idx{i});

    ending_lat{i} = lat(start_day_idx{i});
    ending_lon{i} = lon(start_day_idx{i});
    ending_prs{i} = prs(start_day_idx{i});
    traj_idx{i} = find(start_day_idx{i});

    for j = 1:length(lon_left)
        lon_idx = find(starting_lon_i_5{i} == lon_left(j));
        for k = 4:18
            lat_idx = find(starting_lat_i_4{i} == lat_bottom(k));
            count(j,k,i) = length(intersect(lon_idx, lat_idx));
            for lev = 7:13
                prs_idx = find(starting_prs_i_mls{i} == wv_lev(lev));
                if ~isempty(prs_idx) % if there are actually starting pressures at the current MLS level
                    depth = (wv_lev(lev) - wv_lev(lev+1)) * 100; % get depth *AND CONVERT TO PA
                    air_kg(k, j, lev, i) = depth / g * grid_area(j,k);
                end
            end
        end
    end

    [non_zeros_count_cells_x, non_zeros_count_cells_y] = find(count(:,:,i) > 10);
    for k = 1:length(non_zeros_count_cells_y)
        air_kg_flat(i) = air_kg_flat(i) + sum(air_kg(non_zeros_count_cells_y(k),non_zeros_count_cells_x(k),:,i), 3, 'omitnan');
    end
    air_kg_per_traj_flat_i(i) = air_kg_flat(i) / sum(sum(count(:,:,i), 'omitnan'), 'omitnan');
    z0 = 9; % reference altitude == 9 km
    H = 7; % scale height == 7 km
    for j = 1:length(traj_idx{i})
        weight(j) = exp(-(starting_z_all(traj_idx{i}(j))-z0)/H);
    end
    air_kg_per_traj_flat{i} = air_kg_flat(i) .* (weight / sum(weight));
    clear weight
    % for k = 1:length(non_zeros_count_cells_x)
    %     p_test{i}(non_zeros_count_cells_x(k), non_zeros_count_cells_y(k)) = 1;
    % end

    % figure()
    % hold on
    % grid on
    % box on
    % h = pcolor(lon_left, lat_bottom, p_test{i}');
    % scatter(starting_lon_all(start_day_idx{i}), starting_lat_all(start_day_idx{i}))
    % yline(lat_bottom)
    % xline(lon_left)
    % set(h, 'edgecolor', 'none')
    % xlim([-180 180])
    % ylim([0 90])
    % drawnow
end

%%
[wv_lon_mesh, wv_lat_mesh] = meshgrid(lon_left, lat_bottom);
how_often_is_there_nan_start = 0;
% AT THE START:
k = 1;
for i = 1:length(release_windows)
    disp("pt 2 i=" + i)
    % LOOPING OVER ALL TRAJECTORIES
    for j = 1:length(starting_lat_i{i})
       

        lon_idx = find(lon_left == starting_lon_i_5{i}(j));
        lat_idx = find(lat_bottom == starting_lat_i_4{i}(j));
        prs_idx = find(wv_lev == starting_prs_i_mls{i}(j));
    

        lev_i = starting_prs_i{i}(j);
        if lev_i > 315
            lev_idx = 7;
            bad_idx_start(k) = i;
            k = k + 1;
        else
            lev_idx = find(wv_lev > lev_i, 1, 'last');
        end
        m = 1;
        for lev = lev_idx:lev_idx+1
            if starting_lon_i{i}(j) > 175
                start_lon_i = double(175);
            else
                start_lon_i = double(starting_lon_i{i}(j));
            end
            if starting_lat_i{i}(j) > 86
                start_lat_i = double(86);
            else
                start_lat_i = double(starting_lat_i{i}(j));
            end

            wv_latlon_interp(m) = interp2(wv_lon_mesh, wv_lat_mesh, ...
                squeeze(mean(wv(:,:, lev, start_wv_idx{i}), 4, 'omitnan')),  ...
                start_lon_i, ...
                start_lat_i);
            m = m + 1;
        end

        if ~isnan(wv_latlon_interp(2)) 
            % now I interpolate in height
            wv_height_interp = double(interp1(log(wv_lev(lev_idx:lev_idx+1)), wv_latlon_interp, ...
                log(lev_i)));
            % MASS OF TRAJECTORY FOR THIS RELEASE WINDOW TIMES THE MLS
            % WATER VAPOUR HERE
            wv_kg_trajectories_initial{i}(j) = double(air_kg_per_traj_flat{i}(j) * ...
                wv_height_interp);

            wv_other_method{i}(j) = mean(wv(lat_idx, lon_idx,  prs_idx, start_wv_idx{i}), 4, 'omitnan');
            wv_this_method{i}(j) = wv_height_interp;
        
        else
            how_often_is_there_nan_start = how_often_is_there_nan_start + 1;
        end
    end
    % DO A SUM OVER ALL TRAJECTORIES AT EACH TIME STEP
    wv_kg_trajectories_initial_plot(i) = sum(wv_kg_trajectories_initial{i}, 'omitnan');
end

%
% inital trajectories, taking only the ones that are entrained from
% somewhere during the simulation:
wv_kg_trajectories_initial_plot_entrain_only = zeros(length(release_windows), 1);
for i = 1:length(release_windows)
    for j = 1:length(wv_kg_trajectories_initial{i})
        if ~isnan(final_state_all(traj_idx{i}(j), 1))
            if ~isnan(wv_kg_trajectories_initial{i}(j)) && starting_prs_i{i}(j) < wv_lev(7)
                wv_kg_trajectories_initial_plot_entrain_only(i) = wv_kg_trajectories_initial_plot_entrain_only(i) + wv_kg_trajectories_initial{i}(j);
            end
        end
    end
end

%%
how_often_is_there_nan = 0;
% AT THE END:
for i = 1:length(release_windows)
    disp("pt 3 i=" + i)
    % LOOPING OVER ALL TRAJECTORIES
    for j = 1:length(ending_lon{i})
        % ENDING: IF THE TRAJECTORY WAS ENTRAINED FROM THE TROPICS
        if ~isnan(ending_lon{i}(j)) && ~isnan(end_wv_idx{i}(j))
            % GET INDICES FOR LAT, LON, HEIGHT AT THE ENDING TIME STEP (5
            % DAYS IN THE TROPICS)
            % lon_idx = find(lon_left == ending_lon{i}(j));
            % lat_idx = find(lat_bottom == ending_lat{i}(j));
            % prs_idx = find(wv_lev == ending_prs{i}(j));
            %
            lev_i = ending_prs{i}(j);
            if lev_i > 315
                lev_idx = 7;
                bad_idx_start(k) = i;
                k = k + 1;
            else
                lev_idx = find(wv_lev > lev_i, 1, 'last');
            end

            if ending_lon{i}(j) > 175
                end_lon_i = double(175);
            else
                end_lon_i = double(ending_lon{i}(j));
            end
            if ending_lat{i}(j) > 86
                end_lat_i = double(86);
            else
                end_lat_i = double(ending_lat{i}(j));
            end

            m = 1;
            for lev = lev_idx:lev_idx+1

                wv_latlon_interp(m) = interp2(wv_lon_mesh, wv_lat_mesh, ...
                    squeeze(mean(wv(:,:, lev, end_wv_idx{i}(j)-3:end_wv_idx{i}(j)+3), 4, 'omitnan')),  ...
                    end_lon_i, ...
                    end_lat_i);
                m = m + 1;
            end
    
            if ~isnan(wv_latlon_interp(2)) 
                % now I interpolate in height
                wv_height_interp = interp1(log(wv_lev(lev_idx:lev_idx+1)), wv_latlon_interp, ...
                    log(lev_i));
                % MASS OF TRAJECTORY FOR THIS RELEASE WINDOW TIMES THE MLS
                % WATER VAPOUR HERE
                wv_kg_trajectories{i}(j) = air_kg_per_traj_flat{i}(j) * ...
                    wv_height_interp;
            
            else
                how_often_is_there_nan = how_often_is_there_nan + 1;
            end

            % % IF BELOW THE USABLE MLS DATA
            % if prs_idx < 7 
            %     % OPTION 1: USE THE ERA5 WV
            %     % wv_kg_trajectories{i}(j) = ...
            %     %     air_kg_per_traj_flat(i) * sh(traj_idx{i}(j));
            %     % ---------------------------------------------------------
            %     % OPTION 2: USE THE MLS VALUE AT 316 HPA
            %     wv_kg_trajectories{i}(j) = ...
            %         air_kg_per_traj_flat(i) * mean(wv(lat_idx, lon_idx,  ...
            %         7, end_wv_idx{i}(j)-3:end_wv_idx{i}(j)+3), 4, 'omitnan');
            %     % ---------------------------------------------------------
            %     % OPTION 3: ASSIGN NAN
            %     % wv_kg_trajectories{i}(j) = NaN;
            %     % ---------------------------------------------------------
            % else
            %     % MASS OF TRAJECTORY FOR THIS RELEASE WINDOW TIMES THE MLS
            %     % WATER VAPOUR HERE
            %     wv_kg_trajectories{i}(j) = air_kg_per_traj_flat(i) * ...
            %         mean(wv(lat_idx, lon_idx,  prs_idx, end_wv_idx{i}(j)-3:end_wv_idx{i}(j)+3), 4, 'omitnan');
            % end
        % IF THE TRAJECTORY WASN'T ENTRAINED FROM THE TROPICS JUST ASSIGN
        % NAN
        else
            wv_kg_trajectories{i}(j) = NaN;
        end
    end
    % DO A SUM OVER ALL TRAJECTORIES AT EACH TIME STEP
    wv_kg_trajectories_plot(i) = sum(wv_kg_trajectories{i}, 'omitnan');
end
%%
figure()
figure_number = figure_number + 1;
hold on
grid on
box on
plot(release_windows, wv_kg_trajectories_initial_plot/10^9, 'linewidth', 2)
plot(release_windows, wv_kg_trajectories_initial_plot_entrain_only/10^9, 'linewidth', 2)
% ylabel('Water vapour in the initialization region [Tg]')

plot(release_windows, wv_kg_trajectories_plot/10^9, 'linewidth', 2)
% ylabel('Water vapour from the tropics [Tg]')

xlim([release_windows(1) release_windows(end)])
set(gca, 'fontsize', 16)
ylabel('Water vapour [Tg]')

legend('Total', 'Tropics')

release_windows_SH = release_windows;
wv_kg_trajectories_plot_SH = wv_kg_trajectories_plot;
wv_kg_trajectories_plot_entrain_only_SH = wv_kg_trajectories_initial_plot_entrain_only;
wv_kg_initial_SH = wv_kg_trajectories_initial_plot;
save('Tg_water_SH_v6.mat', 'release_windows_SH', ...
    'wv_kg_trajectories_plot_SH', 'wv_kg_initial_SH', ...
    'wv_kg_trajectories_plot_entrain_only_SH')

%%

figure(figure_number)
figure_number = figure_number + 1;
hold on
grid on
box on
plot(release_windows, wv_kg_trajectories_plot./wv_kg_trajectories_initial_plot * 100, 'linewidth', 2)
% ylabel('Water vapour in the initialization region [Tg]')

xlim([release_windows(1) release_windows(end)])
set(gca, 'fontsize', 16)
ylabel('Water vapour [Tg]')

%% ! CHECKING THE SEASONAL CYCLE !

for m = 1:12
    tidx = find(month(wv_time) == m & year(wv_time) == 2017);

    ss(m) = mean(mean(mean(mean(wv(29:39,:,11:13,tidx), 'omitnan'), 'omitnan'), 'omitnan'));

end

figure(figure_number)
% figure_number = figure_number + 1;
hold on
grid on
box on
plot(1:12, ss, 'linewidth', 2)
ylabel('MLS water vapour [kg/kg]')
xlabel('Months in 2017')
set(gca, 'fontsize', 16)
