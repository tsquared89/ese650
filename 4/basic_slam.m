function [ pos_timeseries, map_timeseries ] = basic_slam( x0, raw_data, params )
% [ pos_timeseries, map_timeseries ] = basic_slam( x0, data, params )
%
%% initialization
data = clean_data( raw_data );

pos_timeseries = {};
map_timeseries = {};
%% step loop
for i=2:imax
    [output, slam_state] = step_slam( data{i}, slam_state{i-1}, output{i-1} );
    pos_timeseries{i} = output.pos;
    map_timeseries{i} = output.map;
end