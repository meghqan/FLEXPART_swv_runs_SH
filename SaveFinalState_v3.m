function length_bt = SaveFinalState_v3(filenames, save_file, time_offset)

%read in the flexpart data:
z = NaN(1389, 432000);
prs = NaN(1389, 432000);
tro = NaN(1389, 432000);
lat = NaN(1389, 432000);
lon = NaN(1389, 432000);
time = NaN(1389,1);

idx = 1;
for i = 1:length(filenames)
    z_i = single(ncread(filenames(i), "z") / 1000);
    prs_i = single(ncread(filenames(i), "prs") / 100);
    tro_i = single(ncread(filenames(i), "tro") / 1000);
    lat_i = single(ncread(filenames(i), "lat"));
    lon_i = single(rem((ncread(filenames(i), "lon")+180),360)-180);
    sh_i = single(ncread(filenames(i), "sh"));
    z(idx:idx+height(z_i)-1,:) = single(z_i);
    prs(idx:idx+height(prs_i)-1,:) = single(prs_i);
    tro(idx:idx+height(tro_i)-1,:) = single(tro_i);
    lat(idx:idx+height(lat_i)-1,:) = single(lat_i);
    lon(idx:idx+height(lon_i)-1,:) = single(lon_i);
    sh(idx:idx+height(lon_i)-1,:) = single(sh_i);
    time(idx:idx+height(z_i)-1,1) = ncread(filenames(i), "time");
    idx = idx + height(z_i);

    clear z_i prs_i tro_i lat_i lon_i sh_i
end

clear i idx filenames

time = time_offset + seconds(time);
time = flipud(time);
z = single(flipud(z));
tro = single(flipud(tro));
prs = single(flipud(prs));
lon = single(flipud(lon));
lat = single(flipud(lat));
sh = single(flipud(sh));

% where does each trajectory start (from the bottom, what is the first
% non-NaN value?)
start_idx = zeros(length(z),1);
bad_t = 0;
b = 1;
for i = 1:length(z)
    if ~isempty(find(~isnan(z(:,i)), 1, 'first'))
        start_idx(i) = find(~isnan(z(:,i)), 1, 'first');
    else
        bad_t(b) = i;
        b = b + 1;
    end
end

if sum(bad_t) > 0
    start_idx(bad_t) = [];
    lat(:, bad_t) = [];
    lon(:, bad_t) = [];
    prs(:, bad_t) = [];
    z(:, bad_t) = [];
    sh(:, bad_t) = [];
    tro(:, bad_t) = [];
end

clear i bad_t
%
% ** 4.75 minutes for this section **

for i = 1:length(z)
    z_no_nan(:,i) = single(z(start_idx(i):start_idx(i)+719,i));
    trop_no_nan(:,i) = single(tro(start_idx(i):start_idx(i)+719,i));
    lat_no_nan(:,i) = single(lat(start_idx(i):start_idx(i)+719,i));
    lon_no_nan(:,i) = single(lon(start_idx(i):start_idx(i)+719,i));
    prs_no_nan(:,i) = single(prs(start_idx(i):start_idx(i)+719,i));
    sh_no_nan(:,i) = single(sh(start_idx(i):start_idx(i)+719,i));
end
clear z tro lat lon prs sh

lon_no_nan = single(rem((lon_no_nan+180),360)-180);

%
% read in tropopause break data, sort so that the time actually lines up
% properly with the flexpart data (or maybe create a new array for the
% particles that contains an index corresponding to the time index in the
% tropopause break array?)

SH_breaklat = ncread("F:\_PhD\flexpart_swv_runs\ERA5_NH_SH_break_lat_v3.nc", ...
    "SH_break_lat");
SH_breaklat = medfilt1(SH_breaklat, 13);
CPT_height = ncread("F:\_PhD\flexpart_swv_runs\CPT_height_temp_all_v3.nc", ...
    "CPT_height");
CPT_lat = ncread("F:\_PhD\flexpart_swv_runs\CPT_height_temp_all_v3.nc", ...
    "lat");
pheight_380K = ncread("F:/_PhD/flexpart_swv_runs/height_380K_v2.nc", "height_380K");
SH_breaklat_lon = ncread("F:\_PhD\flexpart_swv_runs\ERA5_NH_SH_break_lat_v3.nc", ...
    "lon");
SH_breaklat_time = caldays(ncread("F:\_PhD\flexpart_swv_runs\ERA5_NH_SH_break_lat_v3.nc", ...
    "time")) + datetime(2016, 10, 1);

SH_breaklat_time_index = zeros(length(time),1);
for i = 1:length(time)
    SH_breaklat_time_index(i) = find(year(SH_breaklat_time) == year(time(i)) & ...
        month(SH_breaklat_time) == month(time(i)) & day(SH_breaklat_time) == day(time(i)));
end
clear i
%

% ** 1.25 minutes for this section **

% loop over all trajectories, get rid of the ones that aren't where they're
% supposed to be at the start of the simulation

z = zeros(720, 100);
tro = zeros(720, 100);
lat = zeros(720, 100);
lon = zeros(720, 100);
prs = zeros(720, 100);
sh = zeros(720, 100);

% loop over the trajectories, check if above the tropopause, and if north
% of the tropopause break for that day
c = 1;
particle_below_tropopause = 0;
particle_in_tropics = 0;
for i = 1:length(z_no_nan)

    [~,lon_index] = min(abs(SH_breaklat_lon-lon_no_nan(end,i)));
    [~,lat_index] = min(abs(CPT_lat-lat_no_nan(end,i)));
  
    if (z_no_nan(end,i) > trop_no_nan(end,i)) && (lat_no_nan(end,i) < SH_breaklat(lon_index, SH_breaklat_time_index(start_idx(i)+719))) ...
            && z_no_nan(end,i) < pheight_380K(lon_index, lat_index, SH_breaklat_time_index(start_idx(i)+719))
        
        starting_z(c,1) = single(z_no_nan(end,i));
        starting_lat(c,1) = single(lat_no_nan(end,i));
        starting_lon(c,1) = single(lon_no_nan(end,i));
        starting_prs(c,1) = single(prs_no_nan(end,i));
        starting_trop(c,1) = single(trop_no_nan(end,i));
        z(:,c) = single(z_no_nan(:,i));
        sh(:,c) = single(sh_no_nan(:,i));
        tro(:,c) = single(trop_no_nan(:,i));
        lat(:,c) = single(lat_no_nan(:,i));
        lon(:,c) = single(lon_no_nan(:,i));
        prs(:,c) = single(prs_no_nan(:,i));
        start_idx_edited(c) = start_idx(i);
        c = c + 1;

    end
end
clear i c z_no_nan trop_no_nan lat_no_nan lon_no_nan prs_no_nan sh_no_nan

start_idx = start_idx_edited;

%

% ** 0.33 minutes for this section **

% figure out which trajectories go below the tropopause
below_the_tropopause = zeros(height(lon),length(lon));

smooth_z = smoothdata(z, 'movmean', 24);
smooth_trop = smoothdata(tro, 'movmean', 24);
x = smooth_z - smooth_trop;
below_the_tropopause(x<0) = 1;
clear x
num_days = 5; % number of days to require particles stay in troposphere/tropics

%

% ** 1.5 minutes for this section **

% filter so to meet the set requirement for number of days below the
% tropopause
[below_the_tropopause_edited, ~, ~] = ...
    FixWobblesV6(below_the_tropopause, smooth_trop, smooth_z, num_days);
% if there are cases where the particle is in the stratosphere the whole
% time but switches to the tropopsphere just at the end, catch and set to 0
for i = 1:length(below_the_tropopause_edited)
    check_case = below_the_tropopause_edited(24:end,i);
    if sum(check_case == 0) > 696
        below_the_tropopause_edited(1:23,i) = 0;
    end
end

% % CHECK:
% % [x,y] = find(below_the_tropopause_edited == 1);
% % index = unique(y);
% below_the_tropopause_edited(below_the_tropopause_edited == 0) = NaN;
% figure()
% % for i = 1:length(index)
% for i = 137832
%     hold on
%     grid on
%     box on
%     plot(1:720, smooth_z(:,i), 'LineWidth', 2)
%     plot(1:720, smooth_z(:,i) .* below_the_tropopause_edited(:,i), 'LineWidth', 2)
%     plot(1:720, smooth_trop(:,i), 'LineWidth', 2)
%     legend('Stratopshere', 'Troposphere', 'Tropopause')
%     title(index(i))
%     clf
% end

%
% ** 7.5 minutes for this section **

% the same thing, but now checking for when the trajectories cross into the
% tropics
in_the_tropics = zeros(height(lon),length(lon));
trop_location = zeros(height(lon),length(lon));

for i = 1:length(lon)
    for j = 1:height(lon)
        [~,lon_index] = min(abs(SH_breaklat_lon-lon(j,i)));
        trop_location(j,i) =  SH_breaklat(lon_index, SH_breaklat_time_index(start_idx(i) + j - 1));
        if j > 1 && j < 720
            if in_the_tropics(j-1,i) == 1
                % want a condition so that once a particle is in the
                % tropics it has to cross the break by more than a degree
                % to be classified as in the extratropics again
                if lat(j,i) > (trop_location(j,i)+1.9999)
                    in_the_tropics(j,i) = 1;
                end
            else
                if lat(j,i) > trop_location(j,i)
                    in_the_tropics(j,i) = 1;
                end
            end
        else
            if lat(j,i) > trop_location(j,i)
                in_the_tropics(j,i) = 1;
                if j == 720
                    warning("particle started in the tropics (i=" + i)
                end
            end
        end
    end
end

%
[in_the_tropics_edited, bt] = FixWobblesTropBreakV2(in_the_tropics, ...
    lat, trop_location, num_days);

% % CHECK:
% [x,y] = find(in_the_tropics_edited == 1);
% index = unique(y);
% in_the_tropics_edited(in_the_tropics_edited == 0) = NaN;
% %
% % index = [42, 47];
% figure()
% for i = 1:length(in_the_tropics_edited)
% % for i = 1:length(bt)
%     hold on
%     grid on
%     box on
%     % plot(1:720, lat_no_nan(:,bt(i)), 'LineWidth', 2)
%     % plot(1:720, lat_no_nan(:,bt(i)) .* in_the_tropics_edited(:,bt(i)), 'LineWidth', 2)
%     % plot(1:720, trop_location(:,bt(i)), 'LineWidth', 2)
%     plot(1:720, lat_no_nan(:,i), 'LineWidth', 2)
%     plot(1:720, lat_no_nan(:,i) .* in_the_tropics_edited(:,i), 'LineWidth', 2)
%     plot(1:720, trop_location(:,i), 'LineWidth', 2)
%     legend('Extratropics', 'Tropics', 'Break')
%     % title(bt(i))
%     title(i)
%     drawnow
%     % pause(0.8)
%     clf  
% end

%

% ** xx minutes for this section **

% track particle backward, identify where it enters a new "box"

length_bt = length(bt);

TropicalState = zeros(length(lon),1);
Height = zeros(length(lon), 1);
Height_rounded = zeros(length(lon), 1);
Height_hPa = zeros(length(lon), 1);
Latitude = zeros(length(lon),1);
Longitude = zeros(length(lon),1);
StratosphericState = zeros(length(lon),1);
TimeIndex = zeros(length(lon),1);
TT_to_ExS = zeros(length(lon),1);
aboveCPT = NaN(length(lon),1);
location_around_final_z = NaN(length(lon), 8);
location_around_final_lat = NaN(length(lon), 8);
location_around_final_lon = NaN(length(lon), 8);
location_around_final_prs = NaN(length(lon), 8);

final_state = table(TropicalState, StratosphericState, Height, ...
    Height_rounded, Height_hPa, Latitude, Longitude, TimeIndex, TT_to_ExS, aboveCPT);

entered_the_tropics = 0;
entered_the_extratropics = 0;
went_above_380K = 0;
went_below_the_trop = 0;


% loop over all trajectories (backwards), identify where they leave the
% stratosphere or enter the tropics based on the indexes I figured out
% earlier
for i = 1:length(lat)
    if ismember(i, bt)
        final_state(i,:) = {NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN};
    else
        j = 720-1;    
        while j > 0
            [~,lon_index] = min(abs(SH_breaklat_lon-lon(j,i)));
            [~,lat_index] = min(abs(CPT_lat-lat(j,i)));
            % if the trajectory is in the tropics, or has gone northward of
            % 80N, or above 18 km, or below the tropopause go into this loop
            % and save the details of the trajectory around the final position
            if in_the_tropics_edited(j,i) || lat(j,i) > 80 ...
                   || z(j,i) > 18 || below_the_tropopause_edited(j,i)
                if in_the_tropics_edited(j,i)
                    entered_the_tropics = entered_the_tropics + 1;
                    if z(j,i) > CPT_height(lon_index, lat_index, SH_breaklat_time_index(start_idx(i) + j - 1))
                        final_state.aboveCPT(i) = 1;
                    else
                        final_state.aboveCPT(i) = 0;
                    end
                end

                final_state.Height(i) = z(j,i);
                final_state.Height_hPa(i) = prs(j,i);
                final_state.Latitude(i) = lat(j,i);
                final_state.Longitude(i) = lon(j,i);

                % here I'm just saving the position 2 and 5 days on either side
                % of the transition to the tropics because we were looking at
                % how the water vapour changes around this boundary
                if j + 48 < 720 && j - 120 > 0 && (in_the_tropics_edited(j,i) && ~in_the_tropics_edited(j+1,i))
                    location_around_final_z(i,:) = z([j+48, j+24, j, j-24, j-48, j-72, j-96, j-120], i); 
                    location_around_final_lat(i,:) = lat([j+48, j+24, j, j-24, j-48, j-72, j-96, j-120], i); 
                    location_around_final_lon(i,:) = lon([j+48, j+24, j, j-24, j-48, j-72, j-96, j-120], i); 
                    location_around_final_prs(i,:) = prs([j+48, j+24, j, j-24, j-48, j-72, j-96, j-120], i); 
                end

                if ~below_the_tropopause_edited(j,i)
                    final_state.StratosphericState(i) = 1;
                end
                if in_the_tropics_edited(j,i)
                    final_state.TropicalState(i) = 1;
                end
                final_state.TimeIndex(i) = j;
                j = 0;
                break;
            end
            if j == 1 % if it never left the box, set everything to NaN
                final_state(i,:) = {NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN};
            end
            j = j - 1;
        end
    end
end

final_state.Height_rounded = floor(final_state.Height);
save(save_file, 'final_state', 'start_idx', 'time', 'SH_breaklat_time_index', ...
    'location_around_final_prs', 'location_around_final_z', ...
    'location_around_final_lat', 'location_around_final_lon', 'starting_z', ...
    'starting_lat', 'starting_lon', 'starting_trop', 'starting_prs')

proportions = zeros(3,1);
labels = ["S", "TT", "ExT"]';

% printing some statistics
total_traj = height(final_state)-sum(isnan(final_state.TropicalState));
disp("###################################################################")
disp("# of total trajectories = " + total_traj)
tropical_index = find(final_state.TropicalState == 1);
disp("# of trajectories coming from the tropics = " + length(tropical_index) + " (" + length(tropical_index)/total_traj*100 + "%)");
% TROPICAL TRAJECTORIES COMING FROM BELOW THE COLD POINT (calc from ERA5):
tropical_index_lt_cpt = find(final_state.aboveCPT == 0);
disp("     # of trajectories coming from the below the CP in the " + ...
    "tropics = " + length(tropical_index_lt_cpt)+ " (" + ...
    length(tropical_index_lt_cpt)/total_traj*100 + "%)");
disp("          # of trajectories below the CPT but above the thermal " + ...
    "tropopause in the tropics = " + sum(final_state.StratosphericState(tropical_index_lt_cpt))+ ...
    " (" + sum(final_state.StratosphericState(tropical_index_lt_cpt))/total_traj*100 + "%)");
disp("          # of trajectories below the CPT and the thermal tropopause " + ...
    "in the tropics = " + sum(~final_state.StratosphericState(tropical_index_lt_cpt))+ ...
    " (" + sum(~final_state.StratosphericState(tropical_index_lt_cpt))/total_traj*100 + "%)");
% TROPICAL TRAJECTORIES COMING FROM ABOVE THE COLD POINT (17km):
tropical_index_gt_cpt = find(final_state.aboveCPT == 1);
disp("     # of trajectories coming from the above the CP in the tropics = " ...
    + length(tropical_index_gt_cpt) + " (" + length(tropical_index_gt_cpt)/total_traj*100 + "%)");

extropical_index = find(final_state.TropicalState == 0);
disp("# of trajectories coming from the extratropics = " + ...
    length(extropical_index)+ " (" + length(extropical_index)/total_traj*100 + "%)");
if length(tropical_index) + length(extropical_index) ~= total_traj
    warning("Problem: tropical index + extratropical index does not equal total trajectories")
end
% EXTRATROPICAL TRAJECTORIES COMING FROM THE TROPOSPHERE:
extropical_trop_index = find(final_state.StratosphericState == 0 & ...
    final_state.TropicalState == 0);

disp("     # of trajectories coming from the below the tropopause in the " + ...
    "extratropics = " + length(extropical_trop_index) + " (" + ...
    length(extropical_trop_index)/total_traj*100 + "%)");
% EXTRATROPICAL TRAJECTORIES COMING FROM THE STRATOSPHERE:
extropical_strat_index = find(final_state.StratosphericState == 1 & ...
    final_state.TropicalState == 0);

disp("     # of trajectories coming from the above the tropopause in the extratropics = " + length(extropical_strat_index)+ " (" + ...
    length(extropical_strat_index)/total_traj*100 + "%)");


end