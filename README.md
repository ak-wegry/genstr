# genstr - 文字列生成ツール

genstrは、指定されたルールやリストファイルに基づいて文字列を生成し、必要に応じてコマンドとして実行できるツールです。LinuxとWindowsの両方に対応しており、シェルスクリプトまたはバッチファイルを通じて利用できます。

## 📦 特徴

- 複数のリストを組み合わせて文字列を生成
- `%1`, `%2`, ... の形式でテンプレート文字列を置換
- リストファイル(CSV形式)を使ったコマンド展開
- ヘッダ付きファイルの項目名による置換
- コマンドの表示・実行モードを選択可能

## 🖥️ 対応環境

- Linux: `genstr` (シェルスクリプト + awk)
- Windows: `genstr.bat` + `genstr.awk`  
  ※ 実行には gawk for Windows（`gawk.exe`）が必要です。`PATH` の通ったディレクトリに配置してください。

## 🚀 インストール方法

### Linux

1. `genstr` を実行可能にします：

```bash
chmod +x genstr
```

2. `PATH` の通ったディレクトリに配置して使用してください。

### Windows

1. `genstr.bat` と `genstr.awk` を同じフォルダに配置します。
2. コマンドプロンプトで `genstr.bat` を実行します。

## 🛠️ 使い方

```bash
genstr [-e|-E] rule {cmd | -c filename}
genstr [-e|-E] [-F fs] -f filename [-l line] [-H] {cmd | -c filename}
```

### 🔧 引数

| 引数 | 説明 |
|------|------|
| `rule` | コロン区切りで複数のリストを指定。各リストは `1-3`(範囲)や `a,b,c`(CSV)などで記述。全組み合わせが展開される。 |
| `cmd` | 生成されたリスト値を `%1`, `%2`, ... の形式で埋め込むテンプレート文字列。コマンドとして実行可能。 |

### ⚙️ オプション

| オプション       | 説明 |
|------------------|------|
| `-e`             | 生成した文字列をコマンドとして実行 (コマンド表示なし) |
| `-E`             | 生成した文字列をコマンドとして実行 (コマンド表示あり) |
| `-F fs`          | リストファイルの区切り文字 (デフォルトはスペース) |
| `-f filename`    | リストファイルを指定 (CSV形式) |
| `-l line`        | 実行対象の行番号を指定 (例: `1-3,5`) |
| `-c filename`    | コマンドをファイルから読み込む |
| `-H`             | リストファイルの1行目をヘッダとして使用 (`%項目名` で参照) |

---

## 💡 使用例で理解する genstr の活用パターン

### 例1: ログファイル名の一括生成 (クリーニング処理の検証用)

```bash
genstr "01-30:00-23" "touch log_202511%1%2.txt"
```

**目的**:  
ログファイルのクリーニング処理を開発する際、1ヶ月分のログファイルを生成して、一定期間以前のファイルが削除されるかを検証。

**生成される文字列例**:
```
touch log_2025110100.txt
touch log_2025110101.txt
...
touch log_2025113023.txt
```

---

### 例2: サーバーへのSSH接続コマンドを生成 (複数ホストの疎通確認)

```bash
genstr -f hosts.csv "ssh %1@%2"
```

**hosts.csv**:
```
user1 server1.example.com
user2 server2.example.com
```

**目的**:  
複数のホストに対してSSH接続できるかを確認するためのコマンドを一括生成。

**生成される文字列例**:
```
ssh user1@server1.example.com
ssh user2@server2.example.com
```

---

### 例3: 特定行だけを対象にしたコマンド生成 (障害対応で一部サーバーのみ再起動)

```bash
genstr -f servers.csv -l 2,4 "systemctl restart %1"
```

**servers.csv**:
```
web01
web02
db01
db02
```

**目的**:  
障害が発生したサーバーのみを対象に、再起動コマンドを生成。

**生成される文字列例**:
```
systemctl restart web02
systemctl restart db02
```

---

### 例4: ヘッダ付きCSVで項目名を使った置換 (ユーザー情報の表示)

```bash
genstr -f users.csv -F , -H "echo 'User: %name, ID: %id'"
```

**users.csv**:
```
name,id
alice,1001
bob,1002
```

**目的**:  
CSVのヘッダを活用して、ユーザー情報を整形して表示。

**生成される文字列例**:
```
echo 'User: alice, ID: 1001'
echo 'User: bob, ID: 1002'
```

---

### 例5: コマンドテンプレートをファイルで指定 (設定ファイルの一括生成)

```bash
genstr "A,B" -c template.txt
```

**template.txt**:
```
echo "Processing %1"
mkdir /tmp/%1
```

**目的**:  
複数の設定対象に対して、同じ処理をテンプレート化して一括生成。

**生成される文字列例**:
```
echo "Processing A"
mkdir /tmp/A
echo "Processing B"
mkdir /tmp/B
```

---

### 例6: 実行モードの切り替え (表示だけで確認、後から実行)

```bash
genstr -E "1-3" "echo Hello %1"
```

**目的**:  
生成されるコマンドを確認しながら、順次実行する。

**生成される文字列と出力**:
```
echo Hello 1
Hello 1
echo Hello 2
Hello 2
echo Hello 3
Hello 3
```

---

## 🧮 ruleの指定方法 (From-To形式とゼロ埋め)

ruleは、複数のリストを「:」で区切って指定します。各リストは以下の形式で記述できます：

### From-To形式

- `1-10` → `1,2,3,...,10`
- `01-10` → `01,02,03,...,10` (2桁でゼロ埋め)
- `001-10` → `001,002,003,...,010` (3桁でゼロ埋め)

ゼロ埋めされた値は、コマンド内の `%1`, `%2` などにそのまま反映されます。

### CSV形式

- `a,b,c` → `a`, `b`, `c`
- `east,west,north,south` → 地域名などの任意の文字列

### 混在形式

- `1-3,5,7-9` → `1,2,3,5,7,8,9`

### 複数リストの組合せ

```bash
genstr "A,B:C,D" "echo %1-%2"
```

**生成される文字列例**:
```
echo A-C
echo A-D
echo B-C
echo B-D
```

このように、ruleを使えば膨大な組合せの文字列を簡単に生成できます。
