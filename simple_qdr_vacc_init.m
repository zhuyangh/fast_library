function simple_qdr_vacc_init(blk, varargin)
% Initialize and configure a simple_qdr_vacc block.
%
% simple_qdr_vacc_init(blk, varargin)
%
% blk = The block to configure.
% varargin = {'varname', 'value', ...} pairs.
%
% Valid varnames for this block are:
% vec_len = 
% arith_type = 
% n_bits = 
% bin_pt = 
% qdr_slot =

% Declare any default values for arguments you might like.
defaults = {};
if same_state(blk, 'defaults', defaults, varargin{:}), return, end
check_mask_type(blk, 'simple_qdr_vacc');
munge_block(blk, varargin{:});

vec_len = get_var('vec_len', 'defaults', defaults, varargin{:});
arith_type = get_var('arith_type', 'defaults', defaults, varargin{:});
n_bits = get_var('n_bits', 'defaults', defaults, varargin{:});
bin_pt = get_var('bin_pt', 'defaults', defaults, varargin{:});
qdr_slot = get_var('qdr_slot', 'defaults', defaults, varargin{:});

% Validate input fields.

if vec_len < 14
	errordlg('simple_bram_vacc: Invalid vector length. Must be greater than 14.')
end

if n_bits < 1
	errordlg('simple_bram_vacc: Invalid bit width. Must be greater than 0.')
end

if bin_pt > n_bits
	errordlg('simple_bram_vacc: Invalid binary point. Cannot be greater than the bit width.')
end

% Adjust sub-block parameters.

set_param([blk, '/Constant'], 'arith_type', arith_type);
set_param([blk, '/Adder'], 'arith_type', arith_type);
set_param([blk, '/Reinterpret'], 'arith_type', arith_type);
set_param([blk, '/delay_qdr'], 'qdr_slot', qdr_slot);

save_state(blk, 'defaults', defaults, varargin{:});
