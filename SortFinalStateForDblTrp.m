function [final_state_dbl_trp, start_idx_dbl_trp] = SortFinalStateForDblTrp(...
    tropopause_altitude_secondary, tropopause_altitude_primary, ...
    latitude, longitude, final_state, start_idx, NH_breaklat_time_index)

longitude_rounded = round(final_state.Longitude/0.5)*0.5;
latitude_rounded = round(final_state.Latitude/0.5)*0.5;

% loop over all trajectories, get the primary and secondary tropopause
% height and put trajectories that come between in new table
final_state_array = table2array(final_state);
final_state_dbl_trp = zeros(10000,12);
start_idx_dbl_trp = zeros(10000, 1);
c = 1;
for i = 1:length(longitude_rounded)
    if isnan(final_state_array(i,8)) % index 8 is the time index. just checking if there is actually data here or not
        sth(i) = NaN;
        pth(i) = NaN;
        continue;
    end
    if longitude_rounded(i) == -180
        lon_index = 720;
    else
        lon_index = find(longitude == longitude_rounded(i));
    end
    lat_index = find(latitude == latitude_rounded(i));

    time_index = NH_breaklat_time_index(final_state_array(i,8)+...
        start_idx(final_state_array(i,8)) - 1);

    sth(i) = tropopause_altitude_secondary(lon_index,lat_index,time_index);
    pth(i) = tropopause_altitude_primary(lon_index,lat_index,time_index);

    if ~isnan(sth(i))
        final_state_dbl_trp(c,:) = [final_state_array(i,:),0];
        start_idx_dbl_trp(c) = start_idx(i);
        if final_state_array(i,3) > pth(i) && final_state_array(i,3) < sth(i) % 3 is the Height index
            final_state_dbl_trp(c,12) = 1; % adding an index column to index time
        else
            final_state_dbl_trp(c,12) = 0; % adding an index column to index time
        end
        c = c + 1;
    end
end

end