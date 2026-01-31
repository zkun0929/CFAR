function [detections, threshold, noise_level] = CFAR1D(sig, n_train, n_guard, pfa, method)
%--------------------------------------------------------------------------
% 通用 CFAR 检测函数
%
% 输入参数：
%   sig      : 输入功率信号
%   n_train  : 每侧训练单元数量
%   n_guard  : 每侧保护单元数量
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
function [detections, threshold, noise_level] = CA_CFAR(signal, num_train, num_guard, pfa)
    N           = length(signal);
    detections  = zeros(1, N);
    threshold   = zeros(1, N);
    noise_level = zeros(1, N);
    
    % 计算门限因子
    alpha = num_train * (pfa^(-1/num_train) - 1);
    
    for i = 1:N
        start_train_left  = i - num_guard - num_train;
        end_train_left    = i - num_guard - 1;
        start_train_right = i + num_guard + 1;
        end_train_right   = i + num_guard + num_train;
    
        if start_train_left < 1 || end_train_right > N
            continue;
        end
    
        train_cells = [signal(start_train_left:end_train_left), ...
                       signal(start_train_right:end_train_right)];
        
        noise_level(i) = mean(train_cells);
        threshold(i) = noise_level(i) * alpha;
    
        if signal(i) > threshold(i)
            detections(i) = 1;
        end
    end
end


%% -------------------- GO-CFAR --------------------
function [detections, threshold, noise_level] = GO_CFAR(signal, num_train, num_guard, pfa)
    N = length(signal);
    detections = zeros(1, N);
    threshold  = zeros(1, N);
    noise_level = zeros(1, N);
    
    alpha = num_train * (pfa^(-1/num_train) - 1);
    
    for i = 1:N
        start_train_left  = i - num_guard - num_train;
        end_train_left    = i - num_guard - 1;
        start_train_right = i + num_guard + 1;
        end_train_right   = i + num_guard + num_train;
    
        if start_train_left < 1 || end_train_right > N
            continue;
        end
    
        left_train  = signal(start_train_left:end_train_left);
        right_train = signal(start_train_right:end_train_right);
    
        % GO-CFAR取左右平均噪声中较大者
        noise_level(i) = max(mean(left_train), mean(right_train));
        threshold(i) = noise_level(i) * alpha;
    
        if signal(i) > threshold(i)
            detections(i) = 1;
        end
    end
end


%% -------------------- SO-CFAR --------------------
function [detections, threshold, noise_level] = SO_CFAR(signal, num_train, num_guard, pfa)
    N = length(signal);
    detections = zeros(1, N);
    threshold  = zeros(1, N);
    noise_level = zeros(1, N);
    
    alpha = num_train * (pfa^(-1/num_train) - 1);
    
    for i = 1:N
        start_train_left  = i - num_guard - num_train;
        end_train_left    = i - num_guard - 1;
        start_train_right = i + num_guard + 1;
        end_train_right   = i + num_guard + num_train;
    
        if start_train_left < 1 || end_train_right > N
            continue;
        end
    
        left_train  = signal(start_train_left:end_train_left);
        right_train = signal(start_train_right:end_train_right);
    
        % SO-CFAR取左右平均噪声中较小者
        noise_level(i) = min(mean(left_train), mean(right_train));
        threshold(i) = noise_level(i) * alpha;
    
        if signal(i) > threshold(i)
            detections(i) = 1;
        end
    end
end
