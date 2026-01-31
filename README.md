# CFAR
Radar target detection

# USE METHOD

## [detections, threshold, noise_level] = CFAR1D(sig, n_train, n_guard, pfa, method)

### 输入参数：

- **sig:**  
  输入功率信号 (1 × N)

- **n_train:**  
  每侧训练单元数量

- **n_guard:**  
  每侧保护单元数量

- **pfa:**  
  期望虚警概率

- **method:**  
  CFAR 算法类型  
  - `'CA'` - Cell Averaging CFAR  
  - `'GO'` - Greatest Of CFAR  
  - `'SO'` - Smallest Of CFAR  

### 输出参数：

- **detections:**  
  检测结果

- **threshold:**  
  每个单元的检测门限

- **noise_level:**  
  估计的噪声平均功率


## [detections, threshold, noise_level] = CFAR2D(sig, n_train, n_guard, pfa, method)

### 输入参数：

- **sig:** 输入功率信号

- **n_train:**  
  每侧训练单元数量 `[Tr Td]`  
  快时间和慢时间方向训练单元

- **n_guard:**  
  每侧保护单元数量 `[Gr Gd]`  
  快时间和慢时间方向保护单元

- **pfa:**  
  期望虚警概率

- **method:**  
  CFAR 算法类型  
  - `'CA'` - Cell Averaging CFAR  
  - `'GO'` - Greatest Of CFAR  
  - `'SO'` - Smallest Of CFAR  

### 输出参数：

- **detections:**  
  检测结果

- **threshold:**  
  每个单元的检测门限

- **noise_level:**  
  估计的噪声平均功率


## [Pd, Pfa, stats] = CFARProb(det, mask)

### 输入参数：

- **det:**  
  检测结果 (0 / 1)

- **mask:**  
  真实掩码 (0 / 1)

### 输出参数：

- **Pd:**  
  检测概率
  
- **Pfa:**  
  虚警率
  
- **stats:**  
  混淆矩阵 (TP-正确检测、FN-漏检、FP-虚警、TN-正确拒绝)
  
