% DIFFERENCE FROM v5:
    % changed so that I am interpolating the MLS water vapour to the lat,
    % lon, and altitude of the trajectory (rather than just taking the
    % value for the bin that the trajectory falls into)

% trying to calculate the mass of water vapour in the starting region

figure_number = 1;
% MLS water vapour:
wv = ncread("F:/_PhD/MLS_H2O/MLS_v5_H2O.nc", "h2o");
wv_time = caldays(ncread("F:/_PhD/MLS_H2O/MLS_v5_H2O.nc", "time")) + datetime(1950,1,1);
wv_lev = ncread("F:/_PhD/MLS_H2O/MLS_v5_H2O.nc", "lev");
wv_lat = ncread("F:/_PhD/MLS_H2O/MLS_v5_H2O.nc", "lat");
wv_lon = ncread("F:/_PhD/MLS_H2O/MLS_v5_H2O.nc", "lon");

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

% "partoutput_20161103050000.nc", ...
% "partoutput_20161103075959.nc",
filenames = ["partoutput_20161201075959.nc", "partoutput_20161229075959.nc", ...
    "partoutput_20170126050000.nc", "partoutput_20170223050000.nc", ...
    "partoutput_20170323050000.nc", "partoutput_20170420050000.nc", ...
    "partoutput_20170518050000.nc", "partoutput_20170615050000.nc", ...
    "partoutput_20170713050000.nc", "partoutput_20170810050000.nc", ...
    "partoutput_20170907050000.nc", "partoutput_20171005050000.nc", ...
    "partoutput_20171102050000.nc", "partoutput_20171130050000.nc"];

index = 2:15;

filenames_nc = "SH_d_WK" + index + "_traj.nc";
filenames_nc(1) = "SH_d_WK" + index(1) + "_v2_traj.nc";
filenames_nc(2) = "SH_d_WK" + index(2) + "_v2_traj.nc";
filenames_nc(8) = "SH_d_WK" + index(8) + "_v2_traj.nc";
filenames_nc(13) = "SH_d_WK" + index(13) + "_v2_traj.nc";
filenames_nc(14) = "SH_d_WK" + index(14) + "_v2_traj.nc";

idx_all = 1;
idx = 1;
t_index = 1;
k = 1;
bad_idx = [];
for i = 1:length(index)
    if i < 13
        load(strcat('F:\_PhD\flexpart_swv_runs\SH_d_WK1\SH_d_WK', ...
            num2str(index(i)), '_final_state'), 'final_state', 'start_idx', ...
            'time', 'starting_lat', 'starting_lon', 'starting_z', ...
            'starting_prs', 'location_around_final_lon', ...
            'location_around_final_lat', 'location_around_final_z', ...
            'location_around_final_prs');
    else
        load(strcat('F:\_PhD\flexpart_swv_runs\SH_d_WK1\SH_d_WK', ...
            num2str(index(i)), '_final_state_v2'), 'final_state', 'start_idx', ...
            'time', 'starting_lat', 'starting_lon', 'starting_z', ...
            'starting_prs', 'location_around_final_lon', ...
            'location_around_final_lat', 'location_around_final_z', ...
            'location_around_final_prs');
    end
   
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
    start_time_all(idx_all:idx_all+height(final_state)-1,1) = time(start_idx+719) + hours(1);
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

    sh_i = ncread(filenames_nc(i), "sh");
    lat_i = ncread(filenames_nc(i), "lat");
    lon_i = ncread(filenames_nc(i), "lon");
    prs_i = ncread(filenames_nc(i), "prs");
    % GET RID OF THIS IF NOTHING IS PRINTED
    if length(sh_i) ~= height(final_state)
        disp(index(i))
    end
    %
    for j = 1:length(sh_i)
        % if idx_all+j-1 == 199555
        %     stop = 1;
        % end
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
    
    idx_all = idx_all + height(final_state);

    clear final_state start_idx SH_breaklat_time_index f s 
end
sh(sh == 0) = NaN;

sh = sh ./ (1 - sh); % CONVERT FROM KG/MOIST AIR to KG/DRY AIR
if ~isempty(bad_idx)
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
end
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
            % lev_i = wv_lev(7);
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
                % lev_i = wv_lev(7);
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
figure(figure_number)
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