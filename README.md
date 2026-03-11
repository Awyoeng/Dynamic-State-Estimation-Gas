# Dynamic-State-Estimation-Gas
Dynamic State Estimation (DSE) for gas networks using EKF, robust EKF, EKF-LE and Adaptive Fading EKF (AFEKF), with outlier and leak simulation.

---

# Dynamic State Estimation for Gas Pipeline Networks  
**Robust EKF / Chen EKF / EKF-LE / Adaptive Fading EKF (AFEKF)**

---

## 📌 项目简介

本项目实现了一套**天然气管网动态状态估计（Dynamic State Estimation, DSE）仿真框架**，用于在存在**模型失配、测量噪声、稀疏异常值（outliers）以及管道泄漏（leak）** 的复杂工况下，对管网状态进行鲁棒估计。

框架对比并评估了四种基于扩展卡尔曼滤波（EKF）的估计方法：

1. **Standard EKF**（基线方法）
2. **Chen Robust EKF**（基于创新协方差自适应）
3. **EKF-LE**（结合三层检测器的泄漏估计）
4. **AFEKF / AFUKF**（自适应衰减 + 鲁棒统计 + 泄漏补偿）

---

## 🧠 方法概览

| 方法 | 核心思想 | 主要特点 |
|----|----|----|
| Standard EKF | 经典 EKF | 对异常值和模型失配敏感 |
| Chen Robust EKF | 创新协方差自适应 | 对噪声统计变化更鲁棒 |
| EKF-LE | EKF + 泄漏检测反馈 | 可估计泄漏流量 |
| **AFEKF (AFUKF)** | 自适应衰减 + MAD + Huber | 同时应对异常值、模型失配和泄漏 |

---

## 📂 项目结构

```
.
├── dse_main_four_methods.m
├── dse_main_four_methods_monte_carlo.m
├── AFUKF.m
├── dse_normal_ekf.m
├── dse_chen_ekf.m
├── dse_4_estimator_leak.m
├── dse_leak_detector.m
├── dse_1_load_data.m
├── dse_2_build_model.m
├── dse_3_gen_data_leak.m
├── dse_steady_solver.m
├── inject_outlier_sparse.m
├── calc_stats_simple.m
├── calc_stats_with_leak_separation.m
├── gas_data.xlsx
├── leak.xlsx
├── figures/
└── csv_results/
```

---

## 🔧 核心模块说明

### 1️⃣ 主仿真入口

#### `dse_main_four_methods.m`
- 单次仿真对比四种方法
- 支持模型失配参数 `mismatch`
- 自动生成：
  - RMSE 统计
  - CSV / Excel 结果
  - 可视化图像

#### `dse_main_four_methods_monte_carlo.m`
- Monte Carlo 扩展版本
- 支持多噪声强度（10 dB / 20 dB）
- 用于统计稳定性分析

---

### 2️⃣ 卡尔曼滤波器实现（核心）

| 文件 | 功能 |
|----|----|
| `dse_normal_ekf.m` | 标准 EKF |
| `dse_chen_ekf.m` | Chen 鲁棒 EKF |
| `dse_4_estimator_leak.m` | EKF + 泄漏估计 |
| **`AFUKF.m`** | **自适应衰减 EKF（核心创新）** |

---

### 3️⃣ AFEKF（AFUKF）核心机制

`AFUKF.m` 实现了一个**高度鲁棒的扩展卡尔曼滤波器**，主要包含：

- **自适应衰减因子（Adaptive Fading）**
  - 在线估计状态衰减因子 `α`
  - 在线估计测量噪声放大因子 `β`
- **MAD（Median Absolute Deviation）异常检测**
- **Huber 型测量噪声自适应**
- **极端异常值硬替换（measurement replacement）**
- **泄漏检测驱动的负载补偿**

该方法在以下场景表现尤为稳定：
- 稀疏/持续异常值
- 模型失配（Q/R 不准确）
- 泄漏与异常值同时存在

---

### 4️⃣ 系统建模与数据生成

| 文件 | 功能 |
|----|----|
| `dse_1_load_data.m` | 读取管网拓扑与参数 |
| `dse_2_build_model.m` | 构建离散状态空间模型 |
| `dse_3_gen_data_leak.m` | 生成含泄漏的仿真数据 |
| `dse_steady_solver.m` | 计算稳态初值 |

---

### 5️⃣ 异常值与泄漏建模

#### `inject_outlier_sparse.m`
- 按 dB 定义异常值幅度
- 支持节点 / 管道异常
- 输出异常索引用于统计剔除

#### `dse_leak_detector.m`
- 三层检测器
- 为 EKF-LE 和 AFEKF 提供泄漏触发信号

---

### 6️⃣ 性能评估

| 文件 | 功能 |
|----|----|
| `calc_stats_simple.m` | 全时段 RMSE / MAE |
| `calc_stats_with_leak_separation.m` | 正常 / 泄漏阶段分离统计 |

---

## 🧪 实验场景

| Case | 描述 |
|----|----|
| Case 1 | 无异常、无泄漏 |
| Case 2 | 稀疏异常值（6–12h） |
| Case 3 | 异常值 + 泄漏 |
| Case 4 | 纯泄漏 |

---

## 📊 输出结果

- **Figures**：`./figures/*.fig`
- **CSV**：`./csv_results/`
- **Excel 汇总**：`Comprehensive_Results_4Methods.xlsx`

---

## 🚀 快速运行

### 运行方式说明

本项目支持 **单次仿真运行** 与 **蒙特卡洛批量仿真** 两种模式，请根据需求选择对应入口。

### 1️⃣ 单次仿真运行（Single Run）

用于快速验证算法效果、生成单次对比结果与图像。

在 MATLAB 命令行中直接运行：

```matlab
dse_main_four_methods(a, 1)
```

参数说明：

- `a`：模型与噪声的 **mismatch 系数**
  - `a = 1`：**无 mismatch（理想匹配情况）**
  - `a < 1`：过程噪声偏小 / 测量噪声偏大
  - `a > 1`：过程噪声偏大 / 测量噪声偏小
- `1`：开启绘图（`ifplot = 1`），会生成并保存所有对比图像  
  - 若不需要绘图，可设为 `0`

输出内容包括：

- 四种方法（Standard EKF / Chen EKF / EKF-LE / AFEKF）的状态估计结果
- 各 Case（Clean / Outlier / Outlier+Leak / Leak）的 RMSE 统计
- `.fig` 图像文件
- `.csv` 与 `.xlsx` 结果文件

---

### 2️⃣ 蒙特卡洛仿真（Monte Carlo Simulation）

用于统计意义上的性能评估（多次随机扰动、离群点注入等）。

在 MATLAB 中运行：

```matlab
main_loop_for_Monte_Carlo
```

说明：

- 该脚本会 **多次调用 `dse_main_four_methods`**
- 自动进行多轮随机仿真
- 汇总统计结果（均值、方差、对比指标等）
- 适合用于论文实验、算法鲁棒性分析

---

### ⚠️ 注意事项

- **单次仿真** 与 **蒙特卡洛仿真** 使用的是不同入口脚本，请勿混用
- 若只想快速看效果或调试算法，推荐使用 `dse_main_four_methods(a,1)`
- 若需要统计结论或对比性能提升，推荐使用 `main_loop_for_Monte_Carlo`

---


## 📌 适用场景

- 天然气管网状态估计
- 鲁棒滤波算法研究
- 异常检测与泄漏定位
- EKF / AFKF 方法对比实验

---

## 📄 备注

- 本代码为**研究用途实现**
- AFEKF 模块可独立复用至其他非线性系统
- 支持进一步扩展至分布式估计或 PMU/SCADA 融合
