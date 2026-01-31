function [detections, threshold, noise_level] = CFAR2D(sig, n_train, n_guard, pfa, method)
%--------------------------------------------------------------------------
%
% 输入参数：
%   sig      : 输入功率信号
%   n_train  : 每侧训练单元数量 [Tr Td]
%   n_guard  : 每侧保护单元数量 [Gr Gd]
%   pfa      : 期望虚警概率
%   method   : CFAR算法类型
%                'CA' - Cell Averaging CFAR
%                'GO' - Greatest Of CFAR
%                'SO' - Smallest Of CFAR
%
% 输出参数：
%   detections : 检测结果
%   threshold  : 每个单元的检测门限
%   noise_level: 估计的噪声平均功率
%--------------------------------------------------------------------------

    method = upper(method);

    switch method
        case 'CA'
            [detections, threshold, noise_level] = CA_CFAR(sig, n_train, n_guard, pfa);
        case 'GO'
            [detections, threshold, noise_level] = GO_CFAR(sig, n_train, n_guard, pfa);
        case 'SO'
            [detections, threshold, noise_level] = SO_CFAR(sig, n_train, n_guard, pfa);
        otherwise
            error('未知的 CFAR 方法类型。可选: CA, GO, SO');
    end
end

%% -------------------- CA-CFAR --------------------
function [detections, threshold, noise_level] = CA_CFAR(sig, n_train, n_guard, pfa)    
    % ---------------- 参数解析 ----------------
    Tr = n_train(1);   % 距离向训练
    Td = n_train(2);   % 多普勒向训练
    Gr = n_guard(1);   % 距离向保护
    Gd = n_guard(2);   % 多普勒向保护
    
    [Nd, Nr] = size(sig);
    
    % ---------------- Padding ----------------
    pad_d = Td + Gd;
    pad_r = Tr + Gr;
    
    sig_pad = padarray(sig, [pad_d, pad_r], 'replicate', 'both');
    
    % ---------------- 输出初始化 ----------------
    detections  = zeros(Nd, Nr);
    threshold   = zeros(Nd, Nr);
    noise_level = zeros(Nd, Nr);
    
    % ---------------- 训练单元数 ----------------
    Ntrain = (2*(Tr+Gr)+1)*(2*(Td+Gd)+1) - (2*Gr+1)*(2*Gd+1);
    
    alpha = Ntrain * (pfa^(-1/Ntrain) - 1);
    
    % ---------------- CFAR 主循环 ----------------
    for d = 1:Nd
        for r = 1:Nr
    
            dp = d + pad_d;
            rp = r + pad_r;
    
            % 训练窗口
            window = sig_pad(dp-Gd-Td:dp+Gd+Td, rp-Gr-Tr:rp+Gr+Tr);
    
            % 保护窗口
            guard = sig_pad(dp-Gd:dp+Gd, rp-Gr:rp+Gr);
    
            % 噪声估计
            noise_sum = sum(window(:)) - sum(guard(:));
            noise_level(d, r) = noise_sum / Ntrain;
    
            % 门限
            threshold(d, r) = alpha * noise_level(d, r);
    
            % 判决
            if sig(d, r) > threshold(d, r)
                detections(d, r) = 1;
            end
        end
    end
end

%% -------------------- GO-CFAR --------------------
function [detections, threshold, noise_level] = GO_CFAR(sig, n_train, n_guard, pfa)    
    % ---------------- 参数解析 ----------------
    Tr = n_train(1);   % 距离向训练
    Td = n_train(2);   % 多普勒向训练
    Gr = n_guard(1);   % 距离向保护
    Gd = n_guard(2);   % 多普勒向保护
    
    [Nd, Nr] = size(sig);
    
    % ---------------- Padding ----------------
    pad_d = Td + Gd;
    pad_r = Tr + Gr;
    
    sig_pad = padarray(sig, [pad_d, pad_r], 'replicate', 'both');
    
    % ---------------- 输出初始化 ----------------
    detections  = zeros(Nd, Nr);
    threshold   = zeros(Nd, Nr);
    noise_level = zeros(Nd, Nr);
    
    % ---------------- 训练单元数 ----------------
    Ntrain = Tr * (2*(Td + Gd) + 1);
    
    alpha = Ntrain * (pfa^(-1/Ntrain) - 1);
    
    % ---------------- CFAR 主循环 ----------------
    for d = 1:Nd
        for r = 1:Nr
    
            dp = d + pad_d;
            rp = r + pad_r;
    
            % 训练窗口
            left_win  = sig_pad(dp-Gd-Td:dp+Gd+Td, rp-Gr-Tr:rp-Gr);
            right_win = sig_pad(dp-Gd-Td:dp+Gd+Td, rp+Gr:rp+Gr+Tr);

            left_win_mean = mean(left_win(:));
            right_win_mean = mean(right_win(:));

            % 噪声估计
            noise_level(d, r) = max(left_win_mean, right_win_mean);
    
            % 门限
            threshold(d, r) = alpha * noise_level(d, r);
    
            % 判决
            if sig(d, r) > threshold(d, r)
                detections(d, r) = 1;
            end
        end
    end
end

%% -------------------- SO-CFAR --------------------
function [detections, threshold, noise_level] = SO_CFAR(sig, n_train, n_guard, pfa)    
    % ---------------- 参数解析 ----------------
    Tr = n_train(1);   % 距离向训练
    Td = n_train(2);   % 多普勒向训练
    Gr = n_guard(1);   % 距离向保护
    Gd = n_guard(2);   % 多普勒向保护
    
    [Nd, Nr] = size(sig);
    
    % ---------------- Padding ----------------
    pad_d = Td + Gd;
    pad_r = Tr + Gr;
    
    sig_pad = padarray(sig, [pad_d, pad_r], 'replicate', 'both');
    
    % ---------------- 输出初始化 ----------------
    detections  = zeros(Nd, Nr);
    threshold   = zeros(Nd, Nr);
    noise_level = zeros(Nd, Nr);
    
    % ---------------- 训练单元数 ----------------
    Ntrain = Tr * (2*(Td + Gd) + 1);
    
    alpha = Ntrain * (pfa^(-1/Ntrain) - 1);
    
    % ---------------- CFAR 主循环 ----------------
    for d = 1:Nd
        for r = 1:Nr
    
            dp = d + pad_d;
            rp = r + pad_r;
    
            % 训练窗口
            left_win  = sig_pad(dp-Gd-Td:dp+Gd+Td, rp-Gr-Tr:rp-Gr);
            right_win = sig_pad(dp-Gd-Td:dp+Gd+Td, rp+Gr:rp+Gr+Tr);

            left_win_mean = mean(left_win(:));
            right_win_mean = mean(right_win(:));

            % 噪声估计
            noise_level(d, r) = min(left_win_mean, right_win_mean);
    
            % 门限
            threshold(d, r) = alpha * noise_level(d, r);
    
            % 判决
            if sig(d, r) > threshold(d, r)
                detections(d, r) = 1;
            end
        end
    end
end
