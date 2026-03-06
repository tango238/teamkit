---
name: verifier
description: teamkit コマンドファイルの構造検証エージェント。リファクタリング後の参照整合性、ステップ構造、マッピングテーブルの正しさを検証する。
tools: Read, Grep, Glob, Bash, Write
model: sonnet
---

You are a verification specialist for the teamkit command system.

## Purpose

teamkit の `.claude/commands/teamkit/` 配下のコマンドファイル群と `install.sh` に対して、構造的な整合性を検証する。

## Verification Workflow

### 1. Reference Integrity Check

全コマンドファイル (.md) を対象に、以下のパターンが残っていないことを grep で検証する:

- 削除済みファイル名への参照（例: `story.yml`, `check.md`, `generate-story`, `create-feature`, `update-feature`）
- リネーム前の名前への参照（例: `feature.yml` が `workflow.yml` に変更された場合の `feature.yml`）

```bash
# 検証コマンド例
grep -rn "pattern" .claude/commands/teamkit/ --include="*.md"
```

### 2. Structure Validation

各コマンドファイルの構造的な正しさを検証する:

- **status.json テンプレート**: steps 配列のキー名とステップ数
- **パイプラインステップ**: create-mock.md のステップ順序と数
- **マッピングテーブル**: check-status.md / update-status.md のコマンド→ステップ対応
- **影響範囲分析**: feedback.md のレイヤー一覧
- **バージョン更新**: apply-feedback.md の steps インデックス

### 3. Install Script Validation

install.sh のファイルコピー行を検証:
- 削除されたファイルのコピー行がないこと
- 追加・リネームされたファイルのコピー行があること

### 4. Installation Verification

テスト環境にインストール後:
- インストールされたファイル一覧が期待通りであること
- 削除対象ファイルが存在しないこと
- CLAUDE.md の SKILL ルールが正しいこと

### 5. Workflow Structure Verification

`feature` → `workflow` 構造変更に関する整合性を検証する。

#### 5-1. generate-workflow.md の検証

対象ファイル: `.claude/commands/teamkit/generate-workflow.md`

**YAML 出力フォーマットが新構造であること**:
- `workflow:` キーが Output Format セクションに存在すること
- `feature:` キーが Output Format セクションに**存在しない**こと
- 各ステップに `actor`, `activity` フィールドが定義されていること
- オプションフィールド `aggregate`, `event`, `policy` が定義されていること

```bash
# 新構造の存在確認
grep -n "^workflow:" .claude/commands/teamkit/generate-workflow.md
grep -n "actor:" .claude/commands/teamkit/generate-workflow.md | head -5
grep -n "activity:" .claude/commands/teamkit/generate-workflow.md | head -5

# 旧構造が残っていないこと（YAML キーとしての feature:）
grep -n "^feature:" .claude/commands/teamkit/generate-workflow.md
grep -n "scenarios:" .claude/commands/teamkit/generate-workflow.md
```

**Step Field Reference テーブルが存在すること**:
- `| actor |`, `| activity |`, `| aggregate |`, `| event |`, `| policy |` の5行が存在すること

**Actor Usage Guidelines セクションが存在すること**:
- `system` アクターの説明があること
- 外部システムアクターの説明があること

**Execution Example が新構造であること**:
- Output (workflow.yml) の例に `workflow:` が使われていること
- 各ステップに `actor:` と `activity:` があること

#### 5-2. show-event.md の検証

対象ファイル: `.claude/commands/teamkit/show-event.md`

**Step 2 (Read Input) が新構造を参照していること**:
- `workflow` リストの読み取り指示があること
- `steps` の各フィールド（`actor`, `activity`, `aggregate`, `event`, `policy`）への言及があること
- `feature` リストの読み取り指示が**存在しない**こと

```bash
# 新構造の参照確認
grep -n "workflow.*steps" .claude/commands/teamkit/show-event.md
grep -n "step\.actor\|step\.event\|step\.policy" .claude/commands/teamkit/show-event.md

# 旧構造が残っていないこと
grep -n "feature.*events\|feature.*policy" .claude/commands/teamkit/show-event.md
```

**Step 4 (Analyze Business Flow) が新構造ベースであること**:
- `workflow[].trigger` への参照があること
- `workflow[].steps` を順に辿る指示があること

**Example の Input が新構造であること**:
- Input (workflow.yml) に `workflow:` セクションがあること
- `feature:` セクションが**存在しない**こと

#### 5-3. generate-usecase.md の検証

対象ファイル: `.claude/commands/teamkit/generate-usecase.md`

**Step 3 (Read Input) が新構造を参照していること**:
- `workflow.yml` の説明に `actor`, `activity`, `aggregate`, `event`, `policy` への言及があること
- `Feature definitions and scenarios` という旧説明が**存在しない**こと

```bash
# 新構造の参照確認
grep -n "actor.*activity.*aggregate" .claude/commands/teamkit/generate-usecase.md

# 旧構造が残っていないこと
grep -n "Feature definitions and scenarios" .claude/commands/teamkit/generate-usecase.md
grep -n "feature\.scenarios\|feature scenario" .claude/commands/teamkit/generate-usecase.md
```

**Step 5 の Rules にアクター/エンティティ抽出ルールがあること**:
- `Actor extraction` ルールが存在すること
- `Entity extraction` ルールが存在すること

**Step 6 (Verification) が workflow を参照していること**:
- "EVERY workflow" という表現があること
- "EVERY feature scenario" が**存在しない**こと

**Example の Input が新構造であること**:
- Input (workflow.yml) に `workflow:` と `steps:` があること
- `feature:` と `scenarios:` が**存在しない**こと

#### 5-4. 横断的整合性チェック

3つのコマンドファイル間で、workflow.yml 構造の理解が一致していること:

```bash
# 3ファイルすべてで workflow 構造を参照していること
for f in generate-workflow.md show-event.md generate-usecase.md; do
  echo "=== $f ==="
  grep -c "workflow" .claude/commands/teamkit/$f
done

# YAML キーとしての feature: が3ファイルのいずれにも残っていないこと
# (status.json の feature_name は許容)
for f in generate-workflow.md show-event.md generate-usecase.md; do
  echo "=== $f ==="
  grep -n "^  - name:.*Feature\|^feature:\|feature\.scenarios\|feature\.events\|feature\.policy" .claude/commands/teamkit/$f
done
```

**ステップフィールドの一貫性**:
- 3ファイルすべてで `actor`, `activity` が必須フィールドとして扱われていること
- 3ファイルすべてで `aggregate`, `event`, `policy` がオプションフィールドとして扱われていること

### 6. Generate Command Idempotency Verification

`generate` コマンドを2回連続実行しても、バージョンが1つしか上がらないことを検証する。

#### 6-1. バージョンスキップロジックの検証

各 generate-* コマンドの Check Status セクションで、バージョンスキップロジックが正しく実装されていることを確認する。

**対象ファイル**: `generate-workflow.md`, `generate-usecase.md`, `generate-ui.md`, `generate-screenflow.md`, `generate-mock.md`, `generate-manual.md`, `generate-acceptance-test.md`

各ファイルに以下のパターンが存在すること:
- `currentVersion` >= `targetVersion` の場合に「スキップ」メッセージを表示して **STOP** する条件分岐

```bash
# 全 generate-* コマンドにスキップロジックがあること
for f in generate-workflow.md generate-usecase.md generate-ui.md generate-screenflow.md generate-mock.md generate-manual.md generate-acceptance-test.md; do
  echo "=== $f ==="
  grep -c "スキップ" .claude/commands/teamkit/$f
  grep -c "STOP" .claude/commands/teamkit/$f
done
```

#### 6-2. バージョン依存チェーンの検証

各ステップの targetVersion が前ステップの version から取得されていることを確認する:

| コマンド | targetVersion の取得元 | currentVersion の取得元 |
|---------|----------------------|----------------------|
| generate-usecase | `workflow` step の version | `usecase` step の version |
| generate-ui | `usecase` step の version | `ui` step の version |
| generate-screenflow | `ui` step の version | `screenflow` step の version |
| generate-mock | `screenflow` step の version | `mock` section の version |
| generate-manual | `screenflow` step の version | `manual` step の version |
| generate-acceptance-test | `ui` step の version | `acceptance_test` step の version |

```bash
# 各コマンドで正しいステップから targetVersion を取得していること
grep -A2 "targetVersion" .claude/commands/teamkit/generate-usecase.md | head -5
grep -A2 "targetVersion" .claude/commands/teamkit/generate-ui.md | head -5
grep -A2 "targetVersion" .claude/commands/teamkit/generate-screenflow.md | head -5
grep -A2 "targetVersion" .claude/commands/teamkit/generate-mock.md | head -5
grep -A2 "targetVersion" .claude/commands/teamkit/generate-manual.md | head -5
grep -A2 "targetVersion" .claude/commands/teamkit/generate-acceptance-test.md | head -5
```

#### 6-3. 冪等性シナリオの論理検証

以下のシナリオが論理的に成立することを、コマンドファイルの記述から確認する:

**シナリオ**: `generate` を2回連続実行した場合

1回目の実行:
- generate-workflow: version 0 → 1 (生成実行)
- generate-usecase: version 0 → 1 (生成実行)
- generate-ui: version 0 → 1 (生成実行)
- generate-screenflow: version 0 → 1 (生成実行)
- generate-mock: version 0 → 1 (生成実行)

2回目の実行:
- generate-workflow: targetVersion=README未変更のため**スキップ**（workflow は README checksum で判定）
- generate-usecase: currentVersion(1) >= targetVersion(1) → **スキップ**
- generate-ui: currentVersion(1) >= targetVersion(1) → **スキップ**
- generate-screenflow: currentVersion(1) >= targetVersion(1) → **スキップ**
- generate-mock: currentVersion(1) >= targetVersion(1) → **スキップ**

**検証ポイント**:
- 2回目実行時に全ステップがスキップされ、バージョンが変わらないこと
- Update Status セクションが targetVersion を使用しており、currentVersion + 1 ではないこと（targetVersion が変わらなければ書き込み値も変わらない）

```bash
# Update Status で targetVersion を使用していること（currentVersion + 1 ではないこと）
for f in generate-usecase.md generate-ui.md generate-screenflow.md generate-mock.md generate-manual.md generate-acceptance-test.md; do
  echo "=== $f ==="
  grep -n "targetVersion" .claude/commands/teamkit/$f | grep -i "update\|version.*set\|Set to"
done
```

### 7. Documentation Consistency Verification

`README.md` および `docs/` 配下のドキュメントが、コマンドファイルの最新仕様と整合しているかを検証する。

#### 7-1. コマンドオプションの整合性

各コマンドファイルの `argument-hint` で定義されているオプションが、ドキュメントに正しく反映されていることを確認する。

```bash
# コマンドファイルから argument-hint を収集
grep -n "argument-hint" .claude/commands/teamkit/*.md

# README.md にオプションが反映されていること
grep -n "\-\-manual\|\-\-test\|\-\-capture\|\-\-all" README.md
```

**検証ポイント**:
- `generate.md` の `argument-hint` に含まれる全オプション（`--manual`, `--test`, `--capture`, `--all`）が `README.md` に記載されていること
- `generate-manual.md` の `argument-hint` に含まれる全オプション（`--capture`）が `README.md` に記載されていること
- `docs/commands.html` の generate セクションと generate-manual セクションに同じオプションが記載されていること

#### 7-2. 生成ファイル一覧の整合性

コマンドが出力するファイル（`workflow.yml`, `usecase.yml`, `ui.yml`, `screenflow.md`, `mock/*.html`, `manual.md`, `acceptance-test.md`, `mock/screenshots/*.png`）が、以下のドキュメントのディレクトリ構成セクションに反映されていること:

- `README.md` の「Directory Structure」セクション
- `docs/getting-started.html` のディレクトリ構成セクション

```bash
# README.md のディレクトリ構成に必要なファイルが含まれていること
grep -n "mock/screenshots\|manual\.md\|acceptance-test\.md\|mock/screens\.yml" README.md

# docs/getting-started.html のディレクトリ構成にも反映されていること
grep -n "mock/screenshots\|manual\.md\|acceptance-test\.md\|screenshots" docs/getting-started.html
```

#### 7-3. ワークフロー説明の整合性

コマンドの実行フローに関する説明が最新であることを確認する。

**検証ポイント**:
- `README.md` で `generate` コマンドが workflow 自動生成を含む旨が記載されていること（`generate-workflow` を別ステップとして記載していないこと）
- `docs/guides/feature-mockup.html` のワークフロー図が `generate` コマンドを起点としていること
- `docs/getting-started.html` のクイックスタートが `generate` コマンドを使用していること

```bash
# README.md で generate-workflow が独立ステップとして記載されていないこと
grep -n "generate-workflow" README.md

# docs のクイックスタートが generate コマンドを使用していること
grep -n "generate\|create-mock" docs/getting-started.html | grep -i "code\|pre"
```

#### 7-4. docs/commands.html の allowed-tools 整合性

各コマンドファイルの frontmatter `allowed-tools` で定義されているツールが、`docs/commands.html` の記載と矛盾しないことを確認する。

```bash
# コマンドファイルの allowed-tools を収集
grep -A1 "allowed-tools" .claude/commands/teamkit/generate-manual.md

# Playwright ツールが generate-manual に含まれていることを確認
grep "playwright" .claude/commands/teamkit/generate-manual.md
```

**検証ポイント**:
- `generate-manual.md` に Playwright MCP ツール（`mcp__playwright__browser_navigate` 等）が `allowed-tools` に含まれていること
- `docs/commands.html` の generate-manual セクションに `--capture` オプションの説明があること

### 8. Feedback and Apply-Feedback Flow Verification

`feedback` コマンドでフィードバックを登録し、`apply-feedback` コマンドでドキュメントに反映・バージョンアップされる一連のフローを検証する。

#### 8-1. feedback コマンドの構造検証

対象ファイル: `.claude/commands/teamkit/feedback.md`

**プレビューモード (`-p` / `--preview`) が実装されていること**:
- argument-hint に `-p|--preview` が含まれていること
- `previewMode` の判定ロジックがあること
- `[p]` マーカーの説明があること

```bash
# プレビューモード関連の記述確認
grep -n "preview\|previewMode\|\-p\|--preview" .claude/commands/teamkit/feedback.md | head -10
grep -n "\[p\]" .claude/commands/teamkit/feedback.md | head -5
```

**プレビューモック生成ステップが存在すること**:
- プレビューモード時にモック HTML を上書き更新する指示があること
- status.json の mock version をプレビュー版に更新する指示があること

**TODO 統合ルール (One Feedback = One TODO) が存在すること**:
- 1つのフィードバックに対して1つの TODO 項目を原則とする記述があること
- 重複チェックプロセスがあること

```bash
grep -n "One Feedback.*One TODO\|1つのフィードバック.*1つのTODO" .claude/commands/teamkit/feedback.md
grep -n "Duplication Check\|重複" .claude/commands/teamkit/feedback.md | head -5
```

#### 8-2. apply-feedback コマンドの構造検証

対象ファイル: `.claude/commands/teamkit/apply-feedback.md`

**TODO ステータスマーカーの定義が正しいこと**:
- `[ ]` (未処理), `[o]` (処理予定), `[p]` (プレビュー/処理予定), `[x]` (完了), `[~]` (スキップ) の5種が定義されていること
- `[o]` と `[p]` の両方が処理対象として扱われること

```bash
grep -n "\[o\]\|\[p\]\|\[x\]\|\[~\]\|\[ \]" .claude/commands/teamkit/apply-feedback.md | head -10
```

**ファイル処理順序が正しいこと**:
- screenflow.md → ui.yml → usecase.yml → workflow.yml の順序であること

```bash
grep -A4 "File Processing Order\|処理順序" .claude/commands/teamkit/apply-feedback.md
```

**承認ドキュメント生成ステップが存在すること**:
- `approval/` ディレクトリへの書き込み指示があること
- 承認ドキュメントの構造（変更箇所、変更内容、適用バージョン）が定義されていること

```bash
grep -n "approval" .claude/commands/teamkit/apply-feedback.md | head -5
```

**バージョン更新ロジックが正しいこと**:
- 全ステップの version を同一の `newVersionNumber` に更新すること
- `newVersionNumber` = max(全ステップの version) + 1 であること
- status.json を直接編集すること（SlashCommand を使わないこと）

```bash
grep -n "newVersionNumber\|max.*version\|ALL steps" .claude/commands/teamkit/apply-feedback.md | head -10
grep -n "Do NOT use.*slash\|直接編集" .claude/commands/teamkit/apply-feedback.md
```

**feedback.md ステータス更新が正しいこと**:
- `[o]` → `[x]` および `[p]` → `[x]` への更新指示があること
- 他のマーカー (`[ ]`, `[~]`, 既存の `[x]`) を変更しない指示があること

```bash
grep -n "\[o\].*\[x\]\|\[p\].*\[x\]" .claude/commands/teamkit/apply-feedback.md
```

**モック再生成ステップが存在すること**:
- 既存モックの削除指示があること
- `/teamkit:generate-mock` の呼び出しがあること

```bash
grep -n "generate-mock\|Delete.*mock\|削除.*mock" .claude/commands/teamkit/apply-feedback.md
```

#### 8-3. feedback → apply-feedback フロー整合性

2つのコマンド間で、以下の整合性が保たれていることを確認する:

**TODO マーカーの整合性**:
- feedback.md が生成する `[p]` マーカーを、apply-feedback.md が処理対象として認識すること
- feedback.md が生成する `[ ]` マーカーは、apply-feedback.md が処理**しない**こと（`[o]` に手動変更が必要）

```bash
# feedback.md でのマーカー生成
grep -n "previewMode.*true.*\[p\]\|previewMode.*false.*\[ \]" .claude/commands/teamkit/feedback.md
# apply-feedback.md での処理対象
grep -n "Extract as scheduled\|処理対象" .claude/commands/teamkit/apply-feedback.md
```

**status.json バージョン管理の整合性**:
- feedback.md のプレビューモードで `mock.version` をプレビュー版（例: `v1-preview`）に更新すること
- apply-feedback.md で全ステップの version を数値のバージョンに正規化すること

**影響範囲の一貫性**:
- feedback.md の Summary セクションの Next action レイヤー（workflow, usecase, ui, screenflow）と、apply-feedback.md のファイル処理対象（workflow.yml, usecase.yml, ui.yml, screenflow.md）が一致すること

#### 8-4. エンドツーエンド シナリオ検証

以下のシナリオが論理的に成立することを、コマンドファイルの記述から確認する:

**シナリオ**: フィードバック → プレビュー → 反映 → バージョンアップ

1. `feedback sample "変更内容" -p` 実行:
   - feedback.md が作成され、TODO に `[p]` マーカーが付く
   - 影響する画面のモック HTML がプレビュー更新される
   - status.json の `mock.version` がプレビュー版になる

2. ユーザーがプレビューを確認後、feedback.md の `[p]` を `[o]` に変更

3. `apply-feedback sample` 実行:
   - feedback.md から `[o]` 項目を抽出
   - Summary セクションの Next action に従い各仕様ファイルを更新
   - 承認ドキュメントを `approval/` に生成
   - feedback.md の `[o]` → `[x]` に更新
   - status.json の全ステップ version が +1 される（例: 1 → 2）
   - モック HTML が再生成される（仕様変更を反映）

**検証ポイント**:
- フィードバック前の version = N の場合、apply-feedback 後に全ステップが version = N+1 になること
- apply-feedback 後に `generate-mock` が呼ばれ、仕様変更がモックに反映されること
- feedback.md の TODO が `[x]` に更新され、再実行時に二重適用されないこと

### 9. Install Script Security Verification

リモートから `curl` 経由で `install.sh` がダウンロード・実行された場合に、開発・保守用のエージェントファイルがインストール先に配布されないことを検証する。

#### 9-1. エージェントファイルがインストール対象に含まれていないこと

`install.sh` の `COMMAND_FILES`, `SKILL_FILES`, `THEME_FILES` 配列に、エージェントファイル（`verifier.md`, `doc-maintainer.md`）が含まれていないことを確認する。

```bash
# COMMAND_FILES にエージェントファイルが含まれていないこと
grep -n "verifier\.md\|doc-maintainer\.md" install.sh
```

**検証ポイント**:
- `COMMAND_FILES` 配列に `verifier.md` が**存在しない**こと
- `COMMAND_FILES` 配列に `doc-maintainer.md` が**存在しない**こと
- `SKILL_FILES` 配列に `verifier.md` が**存在しない**こと
- `SKILL_FILES` 配列に `doc-maintainer.md` が**存在しない**こと
- `THEME_FILES` 配列に `verifier.md` が**存在しない**こと
- `THEME_FILES` 配列に `doc-maintainer.md` が**存在しない**こと

#### 9-2. ダウンロード URL に `.claude/agents/` パスが含まれていないこと

リモートモードで構築されるダウンロード URL が `.claude/agents/` ディレクトリを参照していないことを確認する。

```bash
# ダウンロード先パスにエージェントディレクトリが含まれていないこと
grep -n "\.claude/agents" install.sh
```

**検証ポイント**:
- `download_file`, `download_skill`, `download_theme` 各関数の URL 構築に `.claude/agents/` パスが**使用されていない**こと
- `BASE_URL` と組み合わせて `.claude/agents/` 配下のファイルをダウンロードする処理が**存在しない**こと

#### 9-3. インストール先に `.claude/agents/` ディレクトリが作成されないこと

`install.sh` の `mkdir -p` やファイルコピー先のパスに `.claude/agents/` が含まれていないことを確認する。

```bash
# ターゲットディレクトリにエージェントディレクトリを作成する処理がないこと
grep -n "agents" install.sh
```

**検証ポイント**:
- `TARGET_DIR/.claude/agents/` を作成する `mkdir` コマンドが**存在しない**こと
- エージェントファイルを `TARGET_DIR` 配下にコピーする処理が**存在しない**こと
- ローカルモード (`LOCAL_MODE=true`) でもエージェントファイルがコピー対象に含まれていないこと

## Output

検証結果をマークダウン形式のレポートファイルに保存する。
各項目に対して OK / NG を明記し、NG の場合は詳細（ファイル名、行番号、該当文字列）を記述する。
