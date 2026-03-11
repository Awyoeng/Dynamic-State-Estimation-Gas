---

# Dynamic-State-Estimation-Gas  
**Gas Pipeline Dynamic State Estimation with Robust EKF and Adaptive Fading EKF**

---

## 📌 项目简介 | Project Overview

### 中文说明

本项目实现了一套用于**天然气管网动态状态估计（Dynamic State Estimation, DSE）**的仿真与评估框架。  
在存在 **模型失配（mismatch）**、**测量噪声不确定性**、**稀疏异常值（outliers）** 以及 **管道泄漏（leak）** 的复杂工况下，对多种 EKF 变体进行系统对比与分析。

项目重点评估并对比以下四种方法：

1. **Standard EKF**（标准扩展卡尔曼滤波）
2. **Chen Robust EKF**（基于创新协方差自适应）
3. **EKF‑LE**（结合三层检测器的泄漏估计）
4. **AFEKF / AFUKF**（自适应衰减 + 鲁棒统计）

---

### English Description

This repository provides a **Dynamic State Estimation (DSE) framework for gas pipeline networks**, designed to evaluate EKF‑based estimators under challenging conditions including:

- Model mismatch  
- Measurement noise uncertainty  
- Sparse sensor outliers  
- Pipeline leakage  

Four EKF‑based methods are implemented and compared:

1. Standard EKF  
2. Chen Robust EKF (innovation covariance adaptation)  
3. EKF‑LE (EKF with leak estimation and detector feedback)  
4. Adaptive Fading EKF (AFEKF / AFUKF)

---

## 🧠 方法概览 | Methods Overview

| 方法 / Method | 核心思想 | Key Features |
|---|---|---|
| Standard EKF | 经典 EKF | 对异常值与失配敏感 |
| Chen EKF | 创新协方差自适应 | 对噪声变化更鲁棒 |
| EKF‑LE | EKF + 泄漏检测 | 可估计泄漏流量 |
| **AFEKF (AFUKF)** | 自适应衰减 + 鲁棒统计 | 同时应对异常、失配与泄漏 |

---

## 📂 项目结构 | Repository Structure

```
.
├── dse_main_four_methods.m
├── dse_main_four_methods_monte_carlo.m
├── main_loop_for_Monte_Carlo.m
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

## 🔧 核心模块说明 | Core Modules

### 主仿真入口 | Main Simulation Entry

#### `dse_main_four_methods.m`
- 单次仿真运行（Single‑run simulation）
- 支持模型失配参数 `mismatch`
- 自动生成：
  - RMSE / MAE 统计
  - `.fig` 图像
  - `.csv` 与 `.xlsx` 结果文件

#### `dse_main_four_methods_monte_carlo.m`
- Monte Carlo 扩展版本
- 支持多噪声强度（10 dB / 20 dB）
- 用于统计稳定性与鲁棒性分析

#### `main_loop_for_Monte_Carlo.m`
- Monte Carlo 总控脚本
- 自动多次调用 `dse_main_four_methods`
- 汇总多轮仿真统计结果

---

## ⚙️ AFEKF / AFUKF 核心机制 | AFEKF Core Mechanisms

### 中文

`AFUKF.m` 实现了一个高度鲁棒的扩展卡尔曼滤波器，主要包括：

- 自适应衰减因子（α：状态，β：测量）在线估计  
- 基于 MAD（Median Absolute Deviation）的异常检测  
- Huber 型测量噪声自适应  
- 极端异常值的硬替换（measurement replacement）  
- 泄漏检测驱动的负载补偿机制  

---

### English

The `AFUKF.m` module implements a highly robust EKF featuring:

- Online adaptive fading factors (α for state, β for measurement)  
- MAD‑based outlier detection  
- Huber‑type adaptive measurement noise  
- Hard replacement for extreme outliers  
- Leak‑driven load compensation  

---

## 🧪 实验场景 | Test Scenarios

| Case | 描述 / Description |
|---|---|
| Case 1 | Clean data (no outliers, no leak) |
| Case 2 | Sparse outliers (6–12 h) |
| Case 3 | Outliers + leak |
| Case 4 | Pure leak |

---

## 🚀 运行说明 | How to Run

### 1️⃣ 单次仿真运行 | Single Run

用于快速验证算法效果与生成对比图像。

```matlab
dse_main_four_methods(a, 1)
```

**参数说明 / Parameters**

- `a`：模型与噪声的 **mismatch 系数**
  - `a = 1`：**无 mismatch（理想匹配情况）**
  - `a < 1`：过程噪声偏小 / 测量噪声偏大
  - `a > 1`：过程噪声偏大 / 测量噪声偏小
- `1`：开启绘图（`ifplot = 1`）

> 说明：`a = 1` 表示 **没有 mismatch 的基准情况**。

---

### 2️⃣ 蒙特卡洛仿真 | Monte Carlo Simulation

用于统计意义上的性能评估。

```matlab
main_loop_for_Monte_Carlo
```

说明：

- 自动进行多轮随机仿真
- 汇总统计结果（均值、方差、性能提升）
- 推荐用于论文实验与鲁棒性分析

---

## 📊 输出结果 | Outputs

- **Figures**：`./figures/*.fig`
- **CSV**：`./csv_results/`
- **Excel 汇总**：`Comprehensive_Results_4Methods.xlsx`

---

## 📌 适用场景 | Applications

- 天然气管网状态估计  
- 鲁棒滤波算法研究  
- 异常检测与泄漏定位  
- EKF / AFKF 方法对比实验  

---

## 📄 备注 | Notes

- 本代码为**研究用途实现**
- AFEKF 模块可独立复用于其他非线性系统
- 支持进一步扩展至分布式估计或多源数据融合

---
