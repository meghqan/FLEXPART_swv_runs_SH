function [binary, bad_trajectory] = FixWobblesTropBreakV2(binary, part_lat, break_lat, num_days)

% figure()
a = 1;
s = 1;
limit = num_days * 24;
for i = 1:length(binary)
    % finding the indexes where the particle is in the tropics and where it
    % is "far" from the tropical boundary
    d = [true; diff(binary(:,i)) ~= 0]; % 1 when the binary switches from 0 to 1 or 1 to 0
    idx = find(d); % index where binary switches value
    lengths = diff([idx; numel(binary(:,i))+1]); % lengths of runs of 0s and 1s
    values = binary(idx,i); % value (0 or 1) corresponding to each of the lengths

    distance = part_lat(:,i)- break_lat(:,i);
    length_far_below = length(find(distance > 4));
    
    c = 1;
    if length(lengths) > 1
        if values(1) == 1
            for j = 1:2:length(lengths)-1
                length_far_below(c) = length(find(distance(idx(j):idx(j)+lengths(j)) > 4));
                lengths_ones(c) = lengths(j);
                lengths_zeros(c) = lengths(j+1);
                indices(c) = j;
                c = c + 1;
            end
            lengths_no_zeros = lengths;
            lengths_no_zeros(indices+1) = NaN;
        else
            if length(lengths) == 2
                lengths_ones(c) = lengths(1);
                lengths_zeros(c) = lengths(2);
                indices(c) = 2;
                c = c + 1;
            else
                for j = 2:2:length(lengths)-1
                    length_far_below(c) = length(find(distance(idx(j):idx(j)+lengths(j)) > 4));
                    lengths_ones(c) = lengths(j);
                    lengths_zeros(c) = lengths(j-1);
                    indices(c) = j;
                    c = c + 1;
                end
            end
            lengths_zeros(c) = lengths(end);

            lengths_no_zeros = lengths;
            lengths_no_zeros(indices-1) = NaN;
        end
    else
        lengths_ones = 0;
        lengths_zeros = lengths;
        lengths_no_zeros = [NaN, NaN];
    end

    if values(1) == 1
        for j = 1:length(lengths_zeros)-2
            if lengths_zeros(j) < 24 && lengths_ones(j) > limit && ...
                    lengths_ones(j+1) > limit
                binary(idx(j+1):idx(j+1)+lengths_zeros(j)-1,i) = 1;
            end
        end
    else
        for j = 1:length(lengths_zeros)-2
            if lengths_zeros(j) < 24 && lengths_ones(j) > limit && ...
                    lengths_ones(j+1) > limit
                binary(idx(j):idx(j)+lengths_zeros(j)-1,i) = 1;
            end
        end
    end

    if max(length_far_below) < 48 && length(lengths) > 8 %&& max(lengths) < 120
        if values(1) == 0
            binary(:,i) = zeros(height(binary),1);
        else
            bad_trajectory(a) = i;
            a = a + 1;
            binary(:,i) = zeros(height(binary),1);
        end
    elseif max(length_far_below) > limit
        % SEEMS TO BE WORKING
        position = find(lengths_ones > limit, 1, 'last');
        if position < length(lengths_ones)
            for k = position+1:length(lengths_ones)
                index = find(lengths_no_zeros == lengths_ones(k), 1, 'first');
                binary(idx(index):idx(index) + lengths_ones(k)-1,i) = ...
                    zeros(length(idx(index):idx(index) + lengths_ones(k)-1),1);
                lengths_no_zeros(index) = NaN;
            end
        end
    elseif max(length_far_below) < limit
        binary(:,i) = zeros(height(binary),1);
    elseif max(lengths_ones) < limit
        % SEEMS TO BE WORKING
        if (mean(distance(1:lengths(1)))>2 && distance(1) > 1 && lengths(1) > 84) || ...
            (mean(distance(1:lengths(1)))>2 && distance(1) > 3 && lengths(1) > 24)
            for k = 2:length(lengths_ones)
                index = find(lengths_no_zeros == lengths_ones(k), 1, 'first');
                binary(idx(index):idx(index) + lengths_ones(k)-1,i) = ...
                    zeros(length(idx(index):idx(index) + lengths_ones(k)-1),1);
                lengths_no_zeros(index) = NaN;
            end
            % DEFINE LAST FEW POINTS AS TROPOSPHERIC
        else
            % SEEMS TO BE WORKING (these are stratospheric?)
            binary(:,i) = zeros(height(binary),1);
            stratospheric_trajectory(s) = i;
            s = s + 1;
        end
    else
        if length(lengths) < 5 && ((mean(distance(1:lengths(1)))>2 && distance(1) > 1 && lengths(1) > 84) || ...
            (mean(distance(1:lengths(1)))>2 && distance(1) > 3 && lengths(1) > 24))
            for k = 2:length(lengths_ones)
                index = find(lengths_no_zeros == lengths_ones(k), 1, 'first');
                binary(idx(index):idx(index) + lengths_ones(k)-1,i) = ...
                    zeros(length(idx(index):idx(index) + lengths_ones(k)-1),1);
                lengths_no_zeros(index) = NaN;
            end
        elseif length(lengths_ones) > 1
            lengths_ones_for_elimination = lengths_ones;
            position = lengths_ones > limit;
            if position(end) == 1 && sum(position) < 2
                binary(:,i) = zeros(height(binary),1);
            else
                last_index = find(position == 1, 1 , 'last');
                if isempty(last_index)
                    binary(:,i) = zeros(height(binary),1);
                else
                    if last_index > length(lengths_ones)/2 && length(lengths) > 5 && lengths_ones(last_index-1) < limit
                        lengths_ones_for_elimination(last_index) = NaN;
                        position_new = find(lengths_ones_for_elimination > limit, 1, 'last');
        
                        if position_new < length(lengths_ones)
                            for k = position_new+1:length(lengths_ones)
                                index = find(lengths_no_zeros == lengths_ones(k), 1, 'first');
                                binary(idx(index):idx(index) + lengths_ones(k)-1,i) = ...
                                    zeros(length(idx(index):idx(index) + lengths_ones(k)-1),1);
                                lengths_no_zeros(index) = NaN;
                            end
                        end
                    else
                        if last_index < length(lengths_ones)
                            for k = last_index+1:length(lengths_ones)
                                index = find(lengths_no_zeros == lengths_ones(k), 1, 'first');
                                binary(idx(index):idx(index) + lengths_ones(k)-1,i) = ...
                                    zeros(length(idx(index):idx(index) + lengths_ones(k)-1),1);
                                lengths_no_zeros(index) = NaN;
                            end
                        end
                    end
                end
            end
        end
    end
    
    clear lengths_ones lengths_zeros lengths values indices
end

end

% CODE FOR CHECKING WITH PLOTS:
% for_plotting = binary(:,i);
% for_plotting(for_plotting==0) = NaN;
% clf
% hold on
% plot(trop_height(:,i), 'LineWidth', 2)
% plot(part_height(:,i), 'LineWidth', 2)
% plot(part_height(:,i).*for_plotting, 'k', 'LineWidth', 2)
% title(i + " max = " + max(lengths_ones))
% set(gcf, 'windowstate', 'fullscreen')
% drawnow
% pause(2)