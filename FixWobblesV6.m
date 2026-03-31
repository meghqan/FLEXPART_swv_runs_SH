function [binary, bad_trajectory, stratospheric_trajectory] = FixWobblesV6(binary, trop_height, part_height, num_days)

% figure()
a = 1;
s = 1;
limit = num_days * 24;
for i = 1:length(binary)

    if trop_height(end,i) - part_height(end,i) > 0
        bad_trajectory(a) = i;
        a = a + 1;
    else

    % finding the indexes where the particle is below the tropopause, and
    % where it is "far" below the tropopause
    d = [true; diff(binary(:,i)) ~= 0];
    idx = find(d);
    lengths = diff([idx; numel(binary(:,i))+1]); % length of span in trop or strat
    values = binary(idx,i); % state: either 0 or 1 for strat or trop

    distance = trop_height(:,i) - part_height(:,i);
    length_far_below = length(find(distance > 3));
    
    c = 1;
    if length(lengths) > 2
        if values(1) == 1
            for j = 1:2:length(lengths)-1
                length_far_below(c) = length(find(distance(idx(j):idx(j)+lengths(j)) > 3));
                lengths_ones(c) = lengths(j);
                lengths_zeros(c) = lengths(j+1);
                indices(c) = j;
                c = c + 1;
            end
            lengths_no_zeros = lengths;
            lengths_no_zeros(indices+1) = NaN;
        else
            for j = 2:2:length(lengths)-1
                length_far_below(c) = length(find(distance(idx(j):idx(j)+lengths(j)) > 3));
                lengths_ones(c) = lengths(j);
                lengths_zeros(c) = lengths(j-1);
                indices(c) = j;
                c = c + 1;
            end
            lengths_zeros(c) = lengths(end);

            lengths_no_zeros = lengths;
            lengths_no_zeros(indices-1) = NaN;
        end
    elseif length(lengths) == 2
        length_far_below = length(find(distance(1:idx(2)-1) > 3));
        lengths_ones = lengths(1);
        lengths_zeros = lengths(2);
        indices = 2;
        lengths_no_zeros = lengths;
        lengths_no_zeros(indices-1) = NaN;
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
        bad_trajectory(a) = i;
        a = a + 1;
        binary(:,i) = zeros(height(binary),1);
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
            % SEEMS TO BE WORKING (these are stratospheric)
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