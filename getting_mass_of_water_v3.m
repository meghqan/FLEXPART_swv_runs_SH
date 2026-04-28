% trying to calculate the mass of water vapour in the starting region

% % MLS altitude at pressure levels:
% MLS_altitude = ncread("MLS-GPH_GEO_200408-202507_MZM.nc", "altitude");
% MLS_altitude_lat = ncread("MLS-GPH_GEO_200408-202507_MZM.nc", "latitude");
% MLS_levs = ncread("MLS-GPH_GEO_200408-202507_MZM.nc", "pressure");
% MLS_altitude_time = caldays(ncread("MLS-GPH_GEO_200408-202507_MZM.nc", "time")) + datetime(2004, 8, 1);
% 
% % only want 2017:
% t1 = find(year(MLS_altitude_time) == 2017, 1, 'first');
% t2 = find(year(MLS_altitude_time) == 2017, 1, 'last');
% 
% MLS_altitude_time = MLS_altitude_time(t1:t2);
% MLS_altitude = MLS_altitude(:,t1:t2,:);

% MLS water vapour:
wv = ncread("F:/_PhD/MLS_H2O/MLS_v5_H2O.nc", "h2o");
wv_time = caldays(ncread("F:/_PhD/MLS_H2O/MLS_v5_H2O.nc", "time")) + datetime(1950,1,1);
wv_lev = ncread("F:/_PhD/MLS_H2O/MLS_v5_H2O.nc", "lev");
wv_lat = ncread("F:/_PhD/MLS_H2O/MLS_v5_H2O.nc", "lat");
wv_lon = ncread("F:/_PhD/MLS_H2O/MLS_v5_H2O.nc", "lon");

% only want 2017:
t1 = find(year(wv_time) == 2017, 1, 'first')-10;
t2 = find(year(wv_time) == 2017, 1, 'last')+10;

wv = wv(:,:,:,t1:t2) * 18.015/28.97 * 10^-6; % go from VMR to MMR
wv_time = wv_time(t1:t2);

grid_area = ncread("area.nc", "cell_area"); % square metres

%%

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

index = [1:14];

% filenames_nc = "SH_d_WK" + index + "_traj.nc";

idx_all = 1;
idx = 1;
t_index = 1;
for i = 1:length(index)
    load(strcat('F:\_PhD\flexpart_swv_runs\SH_d_WK1\SH_d_WK', ...
        num2str(index(i)), '_final_state'), 'final_state');
    load(strcat('F:\_PhD\flexpart_swv_runs\SH_d_WK1\SH_d_WK', ...
        num2str(index(i)), '_final_state'), 'start_idx');
    load(strcat('F:\_PhD\flexpart_swv_runs\SH_d_WK1\SH_d_WK', ...
        num2str(index(i)), '_final_state'), 'time');
    load(strcat('F:\_PhD\flexpart_swv_runs\SH_d_WK1\SH_d_WK', ...
        num2str(index(i)), '_final_state'), 'starting_lat');
    load(strcat('F:\_PhD\flexpart_swv_runs\SH_d_WK1\SH_d_WK', ...
        num2str(index(i)), '_final_state'), 'starting_lon');
    load(strcat('F:\_PhD\flexpart_swv_runs\SH_d_WK1\SH_d_WK', ...
        num2str(index(i)), '_final_state'), 'starting_z');
    load(strcat('F:\_PhD\flexpart_swv_runs\SH_d_WK1\SH_d_WK', ...
        num2str(index(i)), '_final_state'), 'starting_prs');
    load(strcat('F:\_PhD\flexpart_swv_runs\SH_d_WK1\SH_d_WK', ...
        num2str(index(i)), '_final_state'), 'location_around_final_lon');
    load(strcat('F:\_PhD\flexpart_swv_runs\SH_d_WK1\SH_d_WK', ...
        num2str(index(i)), '_final_state'), 'location_around_final_lat');
    load(strcat('F:\_PhD\flexpart_swv_runs\SH_d_WK1\SH_d_WK', ...
        num2str(index(i)), '_final_state'), 'location_around_final_z');
    load(strcat('F:\_PhD\flexpart_swv_runs\SH_d_WK1\SH_d_WK', ...
        num2str(index(i)), '_final_state'), 'location_around_final_prs');
    % start_date(idx_all:idx_all+height(final_state)-1,1) = time(start_idx);
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

    final_state_all(idx_all:idx_all+height(final_state)-1,:) = table2array(final_state);
    start_time_all(idx_all:idx_all+height(final_state)-1,1) = time(start_idx);
    time_final_state_all(idx_all:idx_all+height(final_state)-1) = ...
        hours(start_idx' + final_state.TimeIndex - 1) + first_day; 
    final_idx(idx_all:idx_all+height(final_state)-1) = final_state.TimeIndex;

    location_around_final_lon_all(idx_all:idx_all+height(final_state)-1, :) = location_around_final_lon;
    location_around_final_lat_all(idx_all:idx_all+height(final_state)-1, :) = location_around_final_lat;
    location_around_final_z_all(idx_all:idx_all+height(final_state)-1, :) = location_around_final_z;
    location_around_final_prs_all(idx_all:idx_all+height(final_state)-1, :) = location_around_final_prs;

    starting_lat_all(idx_all:idx_all+height(final_state)-1, :) = starting_lat;
    starting_lon_all(idx_all:idx_all+height(final_state)-1, :) = starting_lon;
    starting_z_all(idx_all:idx_all+height(final_state)-1, :) = starting_z;
    starting_prs_all(idx_all:idx_all+height(final_state)-1, :) = starting_prs;

    % sh_i = ncread(filenames_nc(i), "sh");
    % for j = 1:length(sh_i)
    %     if ~isnan(final_state.TimeIndex(j))
    %         sh(idx_all+j-1, 1) = sh_i(final_state.TimeIndex(j), j);
    %     end
    % end
    
    idx_all = idx_all + height(final_state);

    clear final_state start_idx SH_breaklat_time_index f s 
end
% sh(sh == 0) = NaN;

% sh = sh * 10^6 * 28.97 / 18.015; % convert from kg/kg to ppmv
%%
g = 9.81;

lon_left = [-180:5:175];
lat_bottom = [-90:4:86];

starting_prs_mls = interp1(wv_lev, wv_lev, starting_prs_all, 'next', 'extrap');
starting_lat_4 = interp1(lat_bottom, lat_bottom, starting_lat_all, 'previous', 'extrap');
starting_lon_5 = floor(starting_lon_all / 5) * 5;

non_nan = find(~isnan(location_around_final_prs_all(:,1)));
ending_prs_mls = NaN(length(location_around_final_prs_all), 8);
for i = 1:length(non_nan)
    if any(location_around_final_prs_all(non_nan(i),:) > 1000)
        ending_prs_mls(non_nan(i),:) = 1000;
    else
        ending_prs_mls(non_nan(i),:) = interp1(wv_lev, wv_lev, ...
            location_around_final_prs_all(non_nan(i),:), 'next', 'extrap');
    % if isnan(ending_prs_mls(non_nan(i),1))
    %     stop = 1;
    % end
    end
end
% ending_prs_mls = interp1(wv_lev, wv_lev, location_around_final_prs_all, 'next', 'extrap');
ending_lat_4 = interp1(lat_bottom, lat_bottom, location_around_final_lat_all, 'previous', 'extrap');
ending_lon_5 = floor(location_around_final_lon_all / 5) * 5;

months = [12, 12, 12, ones(1,31), 2*ones(1,28), 3*ones(1,31), 4*ones(1,30), 5*ones(1,31), ...
    6*ones(1,30), 7*ones(1,31), 8*ones(1,31), 9*ones(1,30), 10*ones(1,31), ...
    11*ones(1,30), 12*ones(1,31)];
days = [29, 30, 31, 1:31, 1:28, 1:31, 1:30, 1:31, 1:30, 1:31, 1:31, 1:30, 1:31, 1:30, 1:31];


% months = 1:12;
years = [2016, 2016, 2016, 2017*ones(1, 365)];

release_windows = datetime(years(1), months(1), days(1)):caldays(7):...
    datetime(years(end), months(end), days(end));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
release_windows = release_windows(1:48); % *** put these last ones back once I have the output from the last FLEXPART run! ***
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% for each day, get the # of particles per MLS grid:
count = NaN(length(lon_left), length(lat_bottom), length(release_windows));
wv_kg = zeros(length(lat_bottom), length(lon_left), length(wv_lev), length(release_windows));
air_kg = zeros(length(lat_bottom), length(lon_left), length(wv_lev), length(release_windows));
air_kg_per_traj = zeros(length(lat_bottom), length(lon_left), length(wv_lev), length(release_windows));
air_kg_per_traj_flat = zeros(length(lat_bottom), length(lon_left), length(release_windows));
air_kg_flat = zeros(length(lat_bottom), length(lon_left), length(release_windows));

addpath("F:/_PhD/common_functions/")
figure()
hold on
grid on
box on
borders('countries', 'k')
xline(lon_left)
yline(lat_bottom)
xlim([-180 180])
yline([-80 0])
for i = 1:length(release_windows)
    disp(i)

    start_day_idx = (start_time_all >= release_windows(i)) & (start_time_all <= release_windows(i)+caldays(6)+hours(21));
    start_wv_idx = (wv_time >= release_windows(i)) & (wv_time <= release_windows(i)+caldays(6));

    idx = find(start_day_idx);
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

    starting_lat_i = starting_lat_4(start_day_idx);
    starting_lon_i = starting_lon_5(start_day_idx);
    starting_prs_i = starting_prs_mls(start_day_idx);

    scatter(starting_lon_all(start_day_idx), starting_lat_all(start_day_idx), 'filled', 'MarkerEdgeColor', c(1), 'MarkerFaceColor', c(1))
    drawnow

    starting_lat_air{i} = starting_lat_i;
    starting_lon_air{i} = starting_lon_i;

    ending_lat{i} = ending_lat_4(start_day_idx, 8);
    ending_lon{i} = ending_lon_5(start_day_idx, 8);
    ending_prs{i} = ending_prs_mls(start_day_idx, 8);
    traj_idx{i} = find(start_day_idx);

    for j = 1:length(lon_left)
        lon_idx = find(starting_lon_i == lon_left(j));
        for k = 4:18
            lat_idx = find(starting_lat_i == lat_bottom(k));
            count(j,k,i) = length(intersect(lon_idx, lat_idx));
            for z = 7:13
                prs_idx = find(starting_prs_i == wv_lev(z));
                if ~isempty(prs_idx) % if there are actually starting pressures at the current MLS level
                    depth = (wv_lev(z) - wv_lev(z+1)) * 100; % get depth *AND CONVERT TO PA
                    wv_i = mean(wv(k,j,z,start_wv_idx), 4, 'omitnan');
                    wv_kg(k, j, z, i) = wv_i * depth / g * grid_area(j,k);
                    air_kg(k, j, z, i) = depth / g * grid_area(j,k);
                    air_kg_per_traj(k,j,z,i) = air_kg(k,j,z,i) / count(j,k,i);
                    % if ~isnan(wv(k, j, z, wv_idx))
                    %     wv_kg(k, j, z, i) = wv(k,j,z,wv_idx) * depth / g * grid_area(j,k);
                    %     good_data = good_data + 1;
                    % elseif ~isnan(wv(k, j, z, wv_idx+1))
                    %     wv_kg(k, j, z, i) = wv(k,j,z,wv_idx+1) * depth / g * grid_area(j,k);
                    %     good_data = good_data + 1;
                    % elseif ~isnan(wv(k, j, z, wv_idx-1))
                    %     wv_kg(k, j, z, i) = wv(k,j,z,wv_idx-1) * depth / g * grid_area(j,k);
                    %     good_data = good_data + 1;
                    % elseif ~isnan(wv(k, j, z, wv_idx+2))
                    %     wv_kg(k, j, z, i) = wv(k,j,z,wv_idx+2) * depth / g * grid_area(j,k);
                    %     good_data = good_data + 1;
                    % elseif ~isnan(wv(k, j, z, wv_idx-2))
                    %     wv_kg(k, j, z, i) = wv(k,j,z,wv_idx-2) * depth / g * grid_area(j,k);
                    %     good_data = good_data + 1;
                    % elseif ~isnan(wv(k, j, z, wv_idx+3))
                    %     wv_kg(k, j, z, i) = wv(k,j,z,wv_idx+3) * depth / g * grid_area(j,k);
                    %     good_data = good_data + 1;
                    % elseif ~isnan(wv(k, j, z, wv_idx-3))
                    %     wv_kg(k, j, z, i) = wv(k,j,z,wv_idx-3) * depth / g * grid_area(j,k);
                    %     good_data = good_data + 1;
                    % else
                    %     wv_kg(k, j, z, i) = NaN;
                    %     missing_data = missing_data + 1;
                    %     warning("day " + i + " has no h2o value")
                    % end
                end
            end
            air_kg_flat(k,j,i) = squeeze(sum(air_kg(k,j,:,i), 3, 'omitnan'));
            if count(j,k,i) > 0
                air_kg_per_traj_flat(k,j,i) = air_kg_flat(k,j,i) / count(j,k,i);
            end
        end
    end
    wv_kg_flat(:,:,i) = squeeze(sum(wv_kg(:,:,:,i), 3, 'omitnan'));
    % air_kg_flat(:,:,i) = squeeze(sum(air_kg(:,:,:,i), 3, 'omitnan'));
    % air_kg_per_traj_flat(:,:,i) = squeeze(sum(air_kg_per_traj(:,:,:,i), 3, 'omitnan'));
    mass_per_trajectory(i) = sum(sum(air_kg_flat(:,:,i))) / sum(sum(count(:,:,i)));
end


%%
count_per_cell = zeros(length(lon_left), length(lat_bottom), length(release_windows));
below_316_count = 0;
nan_count = 0;
for i = 1:length(release_windows)
    for j = 1:length(ending_lon{i})
        if ~isnan(ending_lon{i}(j)) && ~isnan(end_wv_idx{i}(j))
            lon_idx = find(lon_left == ending_lon{i}(j));
            lat_idx = find(lat_bottom == ending_lat{i}(j));
            prs_idx = find(wv_lev == ending_prs{i}(j));

            start_lon_idx = find(lon_left == starting_lon_air{i}(j));
            start_lat_idx = find(lat_bottom == starting_lat_air{i}(j));

    
            if prs_idx < 7 % below the usable MLS values
                % wv_kg_trajectories{i}(j) = air_kg_per_traj_flat(start_lat_idx, start_lon_idx, i) * sh(traj_idx{i}(j));
                % count_per_cell(start_lon_idx, start_lat_idx, i) = count_per_cell(start_lon_idx, start_lat_idx, i) + 1;
                wv_kg_trajectories{i}(j) = NaN;
                below_316_count = below_316_count + 1;
            else
                wv_kg_trajectories{i}(j) = air_kg_per_traj_flat(start_lat_idx, start_lon_idx, i) * ...
                    mean(wv(lat_idx, lon_idx, prs_idx, end_wv_idx{i}(j)-3:end_wv_idx{i}(j)+3), 4, 'omitnan');
                count_per_cell(start_lon_idx, start_lat_idx, i) = count_per_cell(start_lon_idx, start_lat_idx, i) + 1;
            end
        else
            wv_kg_trajectories{i}(j) = NaN;
            nan_count = nan_count + 1;
        end
    end
    wv_kg_trajectories_plot(i) = sum(wv_kg_trajectories{i}, 'omitnan');
    % end
end
%
figure()
hold on
grid on
box on
yyaxis left
plot(release_windows, squeeze(sum(sum(wv_kg_flat(:,:,1:48))))/10^9, 'linewidth', 2)
ylabel('Water vapour in the initialization region [Tg]')

yyaxis right
plot(release_windows, wv_kg_trajectories_plot/10^9, 'linewidth', 2)
ylabel('Water vapour from the tropics [Tg]')

xlim([release_windows(1) release_windows(end)])
set(gca, 'fontsize', 16)

ax = gca;
ax.YAxis(1).Color = 'k'; % Left Axis
ax.YAxis(2).Color = 'k';
legend('Total', 'Tropics')

release_windows_SH = release_windows;
wv_kg_trajectories_plot_SH = wv_kg_trajectories_plot;
wv_kg_flat_SH = wv_kg_flat;
save('Tg_water_SH.mat', 'release_windows_SH', 'wv_kg_trajectories_plot_SH', 'wv_kg_flat_SH')

% NEED TO:
    % make the values on the x-axis the midpoint of the release windows (or
    % the first value of the release windows?)
% %%
% 
% 
% figure(1)
% t = tiledlayout(4,3, 'TileSpacing', 'compact');
% 
% for i = 1:12
%     count_plot = NaN(46, 73);
%     count_plot(1:45, 1:72) = count(:,:,i)';
% 
%     wv_plot = NaN(46, 73);
%     wv_plot(1:45, 1:72) = sum(wv_kg_flat(:,:,i), 3);
% 
%     wv_plot(count_plot == 0) = NaN;
%     count_plot(count_plot == 0) = NaN;
% 
%     nexttile
%     hold on
%     grid on
%     box on
%     h = pcolor(-180:5:180, -90:4:90, count_plot);
%     set(h, 'edgecolor', 'none')
%     borders('countries', 'k')
%     ylim([0 80])
%     xlim([-180 180])
%     c = colorbar;
%     title(i)
% end
% 
% figure(2)
% t = tiledlayout(4,3, 'TileSpacing', 'compact');
% 
% for i = 1:12
%     count_plot = NaN(46, 73);
%     count_plot(1:45, 1:72) = count(:,:,i)';
% 
%     wv_plot = NaN(46, 73);
%     wv_plot(1:45, 1:72) = sum(wv_kg_flat(:,:,i), 3);
% 
%     wv_plot(count_plot == 0) = NaN;
%     count_plot(count_plot == 0) = NaN;
% 
%     nexttile
%     hold on
%     grid on
%     box on
%     h = pcolor(-180:5:180, -90:4:90, wv_plot/10^9);
%     set(h, 'edgecolor', 'none')
%     borders('countries', 'k')
%     ylim([0 80])
%     xlim([-180 180])
%     c = colorbar;
%     ylabel(c, 'Tg')
%     clim([0 60])
%     title(i + ", " + sum(sum(wv_plot, 'omitnan'), 'omitnan') / 10^9 + " Tg")
% end