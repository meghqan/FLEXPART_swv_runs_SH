
% % WK 2
% filenamesWK2 = ["partoutput_20170125235959_init.nc", "partoutput_20170107095959.nc", ...
%     "partoutput_20161219205959.nc", "partoutput_20161201075959.nc"];
% file_prefix = "Z:/Shared/FLEXPART_wv_2017_output/SH_d_WK2/";
% filenamesWK2 = file_prefix + filenamesWK2;
% 
% filenames = filenamesWK2;
% save_file = '2_v2';
% time_offset = datetime(2017,1,25,23,59,0);

% % WK3:
% filenamesWK3 = ["partoutput_20170222235959_init.nc", "partoutput_20170204095959.nc", ...
%     "partoutput_20170116205959.nc", "partoutput_20161229075959.nc"];
% file_prefix = "Z:/Shared/FLEXPART_wv_2017_output/SH_d_WK3/";
% filenamesWK3 = file_prefix + filenamesWK3;
% 
% filenames = filenamesWK3;
% save_file = '3_v2';
% time_offset = datetime(2017,2,22,23,59,0);

% WK9:
filenamesWK9 = ["partoutput_20170809210000_init.nc", "partoutput_20170722070000.nc", ...
    "partoutput_20170703180000.nc", "partoutput_20170615050000.nc"];
file_prefix = "Z:/Shared/FLEXPART_wv_2017_output/SH_d_WK9/";
filenamesWK9 = file_prefix + filenamesWK9;

filenames = filenamesWK9;
save_file = '9_v2';
time_offset = datetime(2017,8,9,21,0,0);

%read in the flexpart data:
z = NaN(1389, 432000);
prs = NaN(1389, 432000);
tro = NaN(1389, 432000);
lat = NaN(1389, 432000);
lon = NaN(1389, 432000);
sh = NaN(1389, 432000);
pv = NaN(1389, 432000);
time = NaN(1389,1);

idx = 1;
for i = 1:length(filenames)

    z_i = single(ncread(filenames(i), "z") / 1000);
    z(idx:idx+height(z_i)-1,:) = single(z_i);
    clear z_i

    prs_i = single(ncread(filenames(i), "prs") / 100);
    prs(idx:idx+height(prs_i)-1,:) = single(prs_i);
    clear prs_i

    tro_i = single(ncread(filenames(i), "tro") / 1000);
    tro(idx:idx+height(tro_i)-1,:) = single(tro_i);
    clear tro_i

    lat_i = single(ncread(filenames(i), "lat"));
    lat(idx:idx+height(lat_i)-1,:) = single(lat_i);
    clear lat_i

    lon_i = single(rem((ncread(filenames(i), "lon")+180),360)-180);
    lon(idx:idx+height(lon_i)-1,:) = single(lon_i);
    clear lon_i

    sh_i = single(ncread(filenames(i), "sh"));
    sh(idx:idx+height(sh_i)-1,:) = single(sh_i);
    clear sh_i

    pv_i = single(ncread(filenames(i), "pv"));
    pv(idx:idx+height(pv_i)-1,:) = single(pv_i);
    
    time(idx:idx+height(pv_i)-1,1) = single(ncread(filenames(i), "time"));
    idx = idx + height(pv_i);

    clear pv_i
end

clear i idx filenames

time_dbl = single(time);
time = time_offset + seconds(time);
time = flipud(time);
z = single(flipud(z));
tro = single(flipud(tro));
prs = single(flipud(prs));
lon = single(flipud(lon));
lat = single(flipud(lat));
sh = single(flipud(sh));
pv = single(flipud(pv));

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
    pv_no_nan(:,i) = single(pv(start_idx(i):start_idx(i)+719,i));
end
clear z tro lat lon prs sh pv

lon_no_nan = rem((lon_no_nan+180),360)-180;

%
% read in tropopause break data, sort so that the time actually lines up
% properly with the flexpart data (or maybe create a new array for the
% particles that contains an index corresponding to the time index in the
% tropopause break array?)

SH_breaklat = ncread("F:\_PhD\flexpart_swv_runs\ERA5_NH_SH_break_lat_v3.nc", ...
    "SH_break_lat");
SH_breaklat = medfilt1(SH_breaklat, 13);
% CPT_height = ncread("F:\_PhD\flexpart_swv_runs\CPT_height_temp_all_v2.nc", ...
%     "CPT_height");
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
pv = zeros(720, 100);

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
        
        z(:,c) = single(z_no_nan(:,i));
        tro(:,c) = single(trop_no_nan(:,i));
        lat(:,c) = single(lat_no_nan(:,i));
        lon(:,c) = single(lon_no_nan(:,i));
        prs(:,c) = single(prs_no_nan(:,i));
        sh(:,c) = single(sh_no_nan(:,i));
        pv(:,c) = single(pv_no_nan(:,i));
        start_idx_edited(c) = single(start_idx(i));
        c = c + 1;

    end
end
clear i c z_no_nan trop_no_nan lat_no_nan lon_no_nan prs_no_nan sh_no_nan pv_no_nan

[time_dim, traj_dim] = size(z);

start_idx = start_idx_edited;

nccreate("SH_d_WK"+save_file+"_traj.nc", 'z', "Dimensions", {"tdim", time_dim, "num_trajectories", traj_dim,});
nccreate("SH_d_WK"+save_file+"_traj.nc", 'tro', "Dimensions", {"tdim", time_dim, "num_trajectories", traj_dim,});
nccreate("SH_d_WK"+save_file+"_traj.nc", 'lat', "Dimensions", {"tdim", time_dim, "num_trajectories", traj_dim,});
nccreate("SH_d_WK"+save_file+"_traj.nc", 'lon', "Dimensions", {"tdim", time_dim, "num_trajectories", traj_dim,});
nccreate("SH_d_WK"+save_file+"_traj.nc", 'prs', "Dimensions", {"tdim", time_dim, "num_trajectories", traj_dim,});
nccreate("SH_d_WK"+save_file+"_traj.nc", 'sh', "Dimensions", {"tdim", time_dim, "num_trajectories", traj_dim,});
nccreate("SH_d_WK"+save_file+"_traj.nc", 'pv', "Dimensions", {"tdim", time_dim, "num_trajectories", traj_dim,});
nccreate("SH_d_WK"+save_file+"_traj.nc", 'time', 'Dimensions', {"tdim_full", length(time_dbl)});
nccreate("SH_d_WK"+save_file+"_traj.nc", 'start_idx', 'Dimensions', {'num_trajectories', traj_dim});

ncwrite("SH_d_WK"+save_file+"_traj.nc", 'z', z);
ncwrite("SH_d_WK"+save_file+"_traj.nc", 'tro', tro);
ncwrite("SH_d_WK"+save_file+"_traj.nc", 'lat', lat);
ncwrite("SH_d_WK"+save_file+"_traj.nc", 'lon', lon);
ncwrite("SH_d_WK"+save_file+"_traj.nc", 'prs', prs);
ncwrite("SH_d_WK"+save_file+"_traj.nc", 'sh', sh);
ncwrite("SH_d_WK"+save_file+"_traj.nc", 'pv', pv);
ncwrite("SH_d_WK"+save_file+"_traj.nc", 'time', time_dbl);
ncwrite("SH_d_WK"+save_file+"_traj.nc", 'start_idx', start_idx)

ncwriteatt("SH_d_WK"+save_file+"_traj.nc", "/", "creation_date", datestr(datetime("now")))
ncwriteatt("SH_d_WK"+save_file+"_traj.nc", "z", "Description", "Height above ground of FLEXPART trajectories")
ncwriteatt("SH_d_WK"+save_file+"_traj.nc", "z", "Units", "km")
ncwriteatt("SH_d_WK"+save_file+"_traj.nc", "tro", "Description", "Height of primary (thermal) tropopause (from FLEXPART output)")
ncwriteatt("SH_d_WK"+save_file+"_traj.nc", "tro", "Units", "km")
ncwriteatt("SH_d_WK"+save_file+"_traj.nc", "prs", "Description", "Pressure height of FLEXPART trajectories")
ncwriteatt("SH_d_WK"+save_file+"_traj.nc", "prs", "Units", "hPa")
ncwriteatt("SH_d_WK"+save_file+"_traj.nc", "lat", "units", "degrees north")
ncwriteatt("SH_d_WK"+save_file+"_traj.nc", "lon", "units", "degrees east")
ncwriteatt("SH_d_WK"+save_file+"_traj.nc", "sh", "units", "kg/kg")
ncwriteatt("SH_d_WK"+save_file+"_traj.nc", "sh", "Description", "Specific humidity (interpolated to trajectory location from ERA5)")
ncwriteatt("SH_d_WK"+save_file+"_traj.nc", "pv", "units", "pvu")
ncwriteatt("SH_d_WK"+save_file+"_traj.nc", "pv", "Description", "Potential vorticity along trajectories")
ncwriteatt("SH_d_WK"+save_file+"_traj.nc", "time", "units", "seconds since " + string(time_offset))
ncwriteatt("SH_d_WK"+save_file+"_traj.nc", "start_idx", "Description", "Time index where the particle starts")
