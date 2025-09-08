# scRNA-seq 解析デモリポジトリ

このリポジトリは、**シングルセルRNAシーケンス（scRNA-seq）解析のデモ用パイプライン**を提供します。  
実データや機密情報は含まれておらず、GitHub 上で公開・共有できるように **合成データ（デモデータ）** を用いています。

⚠️ **注意**  
ここで扱うデータはすべて **合成デモデータ** です。  
**生物学的な意味を持ちません**。あくまで解析手順や可視化方法のデモンストレーション用です。

---

## リポジトリ構成

```
├── R/
│   ├── 00_setup.R                   # 必要パッケージの確認・インストール
│   ├── 01_generate_synthetic_data.R # 合成データの生成
│   ├── 02_run_pipeline.R            # 最小パイプラインの実行例
│
├── data/                            # 合成データ (sim_counts.rds)
├── results/                         # 解析結果（図・CSV）
├── notebooks/
│   ├── scRNA-seq_Analysis_Notebook (Demo-ready).Rmd
│   ├── Expression_Distribution_Analysis_on_Demo_Synthetic_scRNA-seq.Rmd
│   ├── GO_Enrichment_on_Demo_Synthetic_scRNA-seq.Rmd
│   └── ...
└── README.md
```

---

## デモワークフロー

### 1. 合成データの生成
- `R/01_generate_synthetic_data.R` によりランダムなカウント行列を作成。    
- 出力: `data/sim_counts.rds`

### 2. 発現分布解析
Notebook: **`Expression_Distribution_Analysis_on_Demo_Synthetic_scRNA-seq.Rmd`**

- QC 指標の可視化（`nFeature_RNA`, `nCount_RNA`, `percent.mt`）  
- バイオリンプロット、リッジプロット、FeaturePlot  
- FeatureScatter による QC 散布図  
- 結果は `results/` に保存

### 3. GO 解析
Notebook: **`GO_Enrichment_on_Demo_Synthetic_scRNA-seq.Rmd`**

- Seurat によるクラスタリングと差次的発現遺伝子抽出  
- 合成遺伝子名をヒト遺伝子シンボルに強制変換  
- GO:BP enrichment  
  - `clusterProfiler + org.Hs.eg.db` があれば利用  
  - なければ `msigdbr` + **独自 ORA (Fisher 検定)** にフォールバック  
  - デモ用に GO ヒットが必ず得られるよう「スパイク遺伝子」も追加  
- 出力: `results/go_ora_bar_cluster_*.png`, `results/go_enrichment_results.csv`

### 4. デモノートブック
Notebook: **`scRNA-seq_Analysis_Notebook (Demo-ready).Rmd`**

- 散布図生成・クラスタリングを実行

---

## 実行方法

### セットアップ
```r
# Rコンソールで
source("R/00_setup.R")
```

### デモデータ生成
```r
source("R/01_generate_synthetic_data.R")
```

### ノートブックの実行
RStudio から Knit するか、コマンドラインから実行します:
```bash
Rscript -e "rmarkdown::render('notebooks/Expression_Distribution_Analysis_on_Demo_Synthetic_scRNA-seq.Rmd')"
Rscript -e "rmarkdown::render('notebooks/GO_Enrichment_on_Demo_Synthetic_scRNA-seq.Rmd')"
```

出力は `results/` 以下に保存されます。

---

## サンプル結果
一部抜粋
- クラスター
<img width="700" height="432" alt="image" src="https://github.com/user-attachments/assets/54f948bb-5bc4-4d14-9e01-9555b70374fc" />

- 検出遺伝子数・カウント数・ミトコンドリア割合の分布
<img width="672" height="384" alt="image" src="https://github.com/user-attachments/assets/8606c84c-f06a-495f-83fe-1e056f166d46" />

- 各クラスターのRNAカウント分布:
<img width="672" height="384" alt="image" src="https://github.com/user-attachments/assets/4910af5f-62eb-4684-a810-9e3c0f39f616" />

- 個別遺伝子の発現量:
<img width="672" height="384" alt="image" src="https://github.com/user-attachments/assets/ab77de26-5d36-4dc4-a1dc-9fd479ccce13" />

- 各遺伝子の発現とクラスターの関係性
<img width="700" height="432" alt="image" src="https://github.com/user-attachments/assets/75645ce0-9118-4ec5-8e45-ed1ddfad2bd3" />

-各クラスターにおける個別遺伝子の発現分布
<img width="1800" height="1200" alt="image" src="https://github.com/user-attachments/assets/354e7875-ded2-4841-b869-2ff69836fab4" />

- GO解析
<img width="1500" height="900" alt="image" src="https://github.com/user-attachments/assets/76c57c4a-e7c6-4538-8d6c-d49634183073" />


---
## 制限事項
- 本リポジトリで使うデータは **完全に合成されたデモ用** です。  
- 出力される GO 用語や発現パターンは **生物学的な解釈には利用できません**。  
- 目的は以下です:
  - R/Seurat ワークフローの再現性デモ
  - 教育・コード共有
  - 機密データを含まない GitHub 公開
実データを解析する場合は、`data/sim_counts.rds` を実際の scRNA-seq データに差し替えてください。
---
