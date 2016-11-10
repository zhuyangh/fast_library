function [eof, dval, out_sel, fifo_re] = pktz_64to64_fsm(reset, fifo_count, pktlen_m1, pktlen_m2, idlecycles_m1)

persistent state, state = xl_state(0, {xlUnsigned, 3, 0});
persistent outcntr, outcntr = xl_state(0, {xlUnsigned, 11, 0});
persistent idlecntr,  idlecntr = xl_state(0, {xlUnsigned, 11, 0});
persistent outsel, outsel = xl_state(1, {xlUnsigned, 1, 0});
persistent dvalid, dvalid = xl_state(0, {xlBoolean});
persistent endofframe, endofframe = xl_state(0, {xlBoolean});
persistent fifore, fifore = xl_state(0, {xlBoolean});
persistent in_transmission, in_transmission = xl_state(0, {xlBoolean});


% constant values
xlTrue = xfix({xlBoolean}, 1);
xlFalse = xfix({xlBoolean}, 0);

dval = dvalid;
out_sel = outsel;
fifo_re = fifore;
eof = endofframe;

% synchronize reset
if reset
    state = 0;
    outcntr = 0;
    idlecntr = 0;
    outsel = 1;
    fifore = xlFalse;
    if in_transmission
        dvalid = xlTrue;
        endofframe = xlTrue;
    else
        dvalid = xlFalse;
        endofframe = xlFalse;
    end
    in_transmission = xlFalse;
else
    switch double(state)
        % wait for fifo fill
        case 0
            idlecntr = 0;
            dvalid = xlFalse;
            endofframe = xlFalse;
            if fifo_count > pktlen_m1
                state = 1;
            else
                state = 0;
            end
        % packet serial number
        case 1
            outsel = 0;
            dvalid = xlTrue;
            in_transmission = xlTrue;
            fifore = xlTrue;
            state = 2;
        % output fifo data
        case 2
            outsel = 1;
            if outcntr == pktlen_m2
                state = 3;
            else
                state = 2;
            end
            outcntr = outcntr + 1;
        % final word in packet
        case 3
            outcntr = 0;
            fifore = xlFalse;
            endofframe = xlTrue;
            in_transmission = xlFalse;
            state = 4;
        % idle loop, wait for eth block starting transfer
        case 4
            dvalid = xlFalse;
            endofframe = xlFalse;
            if idlecntr == idlecycles_m1
                state = 0;
            else
                state = 4;
            end
            idlecntr = idlecntr + 1;
    end %switch
end %if reset

end %function
