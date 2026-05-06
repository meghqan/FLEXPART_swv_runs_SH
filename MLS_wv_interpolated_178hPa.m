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
        load(strcat('F:\_PhD\flexpart_swv_runs\SH_d_WK1\SH_d_WK', ...
            num2str(index(i)), '_final_state'), 'starting_lat');
        load(strcat('F:\_PhD\flexpart_swv_runs\SH_d_WK1\SH_d_WK', ...
            num2str(index(i)), '_final_state'), 'starting_lon');
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
        load(strcat('F:\_PhD\flexpart_swv_runs\SH_d_WK1\SH_d_WK', ...
            num2str(index(i)), '_final_state_v2'), 'starting_lat');
        load(strcat('F:\_PhD\flexpart_swv_runs\SH_d_WK1\SH_d_WK', ...
            num2str(index(i)), '_final_state_v2'), 'starting_lon');
    end
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