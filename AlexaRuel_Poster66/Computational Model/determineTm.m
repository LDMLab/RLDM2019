function Tm = determineTm(t, subdata)

    pcommon = subdata.blockCondition(t)/100;
    if subdata.commontrans(t) == 1
        if (subdata.a(t,1) == 1 && subdata.s2(t) == 1) || (subdata.a(t,1) == 2 && subdata.s2(t) == 2)
            Tm = [pcommon 1-pcommon; 1-pcommon pcommon];        % transition matrix
        elseif (subdata.a(t,1) == 1 && subdata.s2(t) == 2) || (subdata.a(t,1) == 2 && subdata.s2(t) == 1)
            Tm = [1-pcommon pcommon; pcommon, 1-pcommon];
        else 
            error('Could not determine transition matrix for subject %s in trial %s', num2str(subdata.id), num2str(t)) 
        end
    elseif subdata.commontrans(t) == 0
        if (subdata.a(t,1) == 1 && subdata.s2(t) == 1) || (subdata.a(t,1) == 2 && subdata.s2(t) == 2)
            Tm = [1-pcommon pcommon; pcommon, 1-pcommon];
        elseif (subdata.a(t,1) == 1 && subdata.s2(t) == 2) || (subdata.a(t,1) == 2 && subdata.s2(t) == 1)
            Tm = [pcommon 1-pcommon; 1-pcommon pcommon]; 
        else
            error('Could not determine transition matrix for subject %s in trial %s', num2str(subdata.id), num2str(t)) 
        end
    else 
        error('Could not determine transition matrix for subject %s in trial %s', num2str(subdata.id), num2str(t)) 
    end
end