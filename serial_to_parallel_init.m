% Create a serial to parallel block
%
% serial_to_parallel_init(blk, varargin)
%
% blk = The block to be configured.
% varargin = {'varname', 'value', ...} pairs
%
% Valid varnames for this block are:
% n_elems = No. of serial input elements which group to 1 parallel output

function serial_to_parallel_init(blk, varargin)

clog('entering serial_to_parallel_init', 'trace');
check_mask_type(blk, 'serial_to_parallel');

defaults = {'n_elems', 2};
if same_state(blk, 'defaults', defaults, varargin{:}), return, end
clog('serial_to_parallel_init: post same_state', 'trace');
munge_block(blk, varargin{:});

% set bit length based on parallel numbers
n_elems = get_var('n_elems', 'defaults', defaults, varargin{:});
if n_elems < 2 || n_elems > 100
    errordlg('Number of Parallel Elements must be within range 2~100', 'Parameter Error');
    return;
end
cntr_bits = nextpow2(n_elems + 1);
set_param([blk, '/Counter'], 'n_bits', num2str(cntr_bits));
set_param([blk, '/num_elems'], 'n_bits', num2str(cntr_bits));
set_param([blk, '/num_elems'], 'const', num2str(n_elems));
set_param([blk, '/const_1'], 'n_bits', num2str(cntr_bits));

% Remove unused registers
nblks = length(find_system(blk, 'LookUnderMasks', 'all', 'ReferenceBlock', 'xbsIndex_r4/Register'));
for n = n_elems+1:nblks
    reg = [blk, '/reg', num2str(n)];
    lines = get_param(reg, 'LineHandles');
    lhs = [lines.Inport, lines.Outport];
    for i = 1:length(lhs)
        if lhs(i) > 0, delete_line(lhs(i)), end;
    end
    delete_block(reg);
end

if n_elems < nblks
    nblks = n_elems;
end

% Create output registers
pos = get_param([blk, '/reg', num2str(nblks)], 'Position');
left = pos(1);
right = pos(3);
height = pos(4) - pos(2);
margin = 24;
top = pos(4) + margin;

reuse_block(blk, 'Concat', 'xbsIndex_r4/Concat', 'num_inputs', num2str(n_elems));

for n = nblks+1:n_elems
    reuse_block(blk, ['reg', num2str(n)], 'xbsIndex_r4/Register', ...
        'en', 'on', ...
        'Position', [left top right top+height]);
    add_line(blk, ['reg', num2str(n-1), '/1'], ['reg', num2str(n), '/1'], 'autorouting', 'on');
    add_line(blk, 'en_buf/1', ['reg', num2str(n), '/2'], 'autorouting', 'on');
    add_line(blk, ['reg', num2str(n), '/1'], ['Concat/', num2str(n)], 'autorouting', 'on');
    top = top + height + margin;
end

% Save and back-populate mask parameter values
save_state(blk, 'defaults', defaults, varargin{:});

end