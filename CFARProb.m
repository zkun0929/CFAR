function [Pd, Pfa, stats] = CFARProb(det, mask)
    TP = sum(det(:) == 1 & mask(:) == 1);  % 正确检测
    FN = sum(det(:) == 0 & mask(:) == 1);  % 漏检
    FP = sum(det(:) == 1 & mask(:) == 0);  % 虚警
    TN = sum(det(:) == 0 & mask(:) == 0);  % 正确拒绝
    
    if TP + FN > 0
        Pd = TP / (TP + FN);
    else
        Pd = NaN;
    end

    if FP + TN > 0
        Pfa = FP / (FP + TN);
    else
        Pfa = NaN;
    end

    stats.TP = TP;
    stats.FN = FN;
    stats.FP = FP;
    stats.TN = TN;
end
