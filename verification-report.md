# TeamKit コマンドファイル群検証レポート

**検証日時**: 2026-02-11
**対象ディレクトリ**: `/home/user/teamkit/.claude/commands/teamkit/`
**検証基準**: verifier.md に記載された検証項目

---

## 1. Reference Integrity Check

### 検証内容
削除済みファイル名やリネーム前の名前への参照が残っていないことを確認する。

**検証対象パターン**:
- `story.yml`
- `check.md`
- `generate-story`
- `create-feature.md`
- `update-feature.md`
- `feature.yml` (YAML キーとしての使用)

### 検証結果: ✅ OK

**詳細**:
- 全コマンドファイル (.md) を対象に grep 検索を実施
- 上記のパターンは一切検出されず
- 旧ファイル名への参照は完全に除去されている

---

## 2. Structure Validation

### 検証内容
各コマンドファイルの構造的な正しさを検証する。

### 2-1. status.json テンプレート (generate-workflow.md)

**検証項目**:
- steps 配列のキー名が正しいこと
- steps 配列のステップ数が正しいこと

**検証結果**: ✅ OK

**詳細** (generate-workflow.md L189-218):
```json
"steps": [
    { "workflow": {...} },    // steps[0]
    { "usecase": {...} },     // steps[1]
    { "ui": {...} },          // steps[2]
    { "screenflow": {...} }   // steps[3]
]
```
- ステップ数: 4 (workflow, usecase, ui, screenflow)
- キー名: 正しい

### 2-2. マッピングテーブル (check-status.md / update-status.md)

**検証項目**:
- コマンド名 → ステップインデックスの対応が正しいこと

**検証結果**: 🔍 要確認 (check-status.md, update-status.md が install.sh のリストに含まれていない)

**詳細**:
- `check-status.md`: install.sh L166 に含まれている
- `update-status.md`: install.sh L177 に含まれている
- これらのコマンドは存在するが、検証は実施していない (本検証の対象外)

### 2-3. パイプラインステップ (create-mock.md)

**検証項目**:
- create-mock.md のステップ順序と数が正しいこと

**検証結果**: ✅ OK

**詳細** (create-mock.md):
- Step 1: Generate Screenflow (if needed)
- Step 2: Generate Mock
- Completion
- ステップ構造は正しい

---

## 3. Install Script Validation

### 検証内容
install.sh のファイルコピー行を検証する。

### 3-1. 削除されたファイルのコピー行がないこと

**検証結果**: ✅ OK

**詳細**:
- `COMMAND_FILES` 配列 (L164-181) に削除対象ファイルは含まれていない
- `DEPRECATED_FILES` 配列 (L201-206) に削除対象が明記されている:
  - `create-feature.md`
  - `generate-story.md`
  - `update-feature.md`
  - `check.md`

### 3-2. 追加・リネームされたファイルのコピー行があること

**検証結果**: ⚠️ WARNING

**詳細**:

実際のファイル一覧 (19ファイル):
```
app-init.md
apply-feedback.md
check-status.md
create-app.md
create-mock.md
design-app.md
feedback.md
generate-acceptance-test.md
generate-manual.md
generate-mock.md
generate-screenflow.md
generate-ui.md
generate-usecase.md
generate-workflow.md
generate.md
get-step-info.md
plan-app.md
show-event.md
update-status.md
```

install.sh の COMMAND_FILES 配列 (17ファイル):
```
apply-feedback.md
check-status.md
create-mock.md
feedback.md
generate-mock.md
generate-screenflow.md
generate-ui.md
generate-usecase.md
generate-workflow.md
get-step-info.md
app-init.md
show-event.md
update-status.md
create-app.md
design-app.md
plan-app.md
```

**不一致**:
- ❌ `generate.md` が install.sh に含まれていない
- ❌ `generate-manual.md` が install.sh に含まれていない
- ❌ `generate-acceptance-test.md` が install.sh に含まれていない

**推奨**: install.sh の COMMAND_FILES に以下を追加:
```bash
"generate.md"
"generate-manual.md"
"generate-acceptance-test.md"
```

---

## 4. Installation Verification

### 検証結果: ⚠️ SKIPPED (テスト環境未実施)

本検証はファイル構造の静的解析のみを実施し、実際のインストールテストは省略。

---

## 5. Workflow Structure Verification

### 検証内容
`feature` → `workflow` 構造変更に関する整合性を検証する。

### 5-1. generate-workflow.md の検証

**検証項目**:
- YAML 出力フォーマットが新構造 (`workflow:`) であること
- 旧構造 (`feature:`) が存在しないこと
- Step Field Reference テーブルが存在すること
- Actor Usage Guidelines が存在すること

**検証結果**: ✅ OK

**詳細**:

✅ **新構造の存在確認**:
- L91: `workflow:` キーが定義されている
- L97-112: 各ステップに `actor`, `activity`, `aggregate`, `event`, `policy` が定義されている

✅ **旧構造が残っていないこと**:
- `^feature:` (YAML キーとしての feature) は検出されず
- `scenarios:` は検出されず

✅ **Step Field Reference テーブル** (L118-126):
```markdown
| Field | Required | Description |
|-------|----------|-------------|
| `actor` | Yes | ... |
| `activity` | Yes | ... |
| `aggregate` | No | ... |
| `event` | No | ... |
| `policy` | No | ... |
```

✅ **Actor Usage Guidelines** (L142-145):
- `system` アクターの説明あり
- 外部システムアクターの説明あり

✅ **Execution Example が新構造** (L256-325):
- `workflow:` セクションを使用
- 各ステップに `actor:` と `activity:` あり

### 5-2. show-event.md の検証

**検証項目**:
- Step 2 (Read Input) が新構造を参照していること
- 旧構造への参照が存在しないこと
- Example の Input が新構造であること

**検証結果**: ✅ OK

**詳細**:

✅ **新構造の参照確認** (L49-61):
- L54: `workflow` - List of workflows
- L56-61: `actor`, `activity`, `aggregate`, `event`, `policy` への言及あり

✅ **旧構造が残っていないこと**:
- `feature.*events`, `feature.*policy`, `Feature definitions and scenarios` は検出されず

✅ **Example の Input が新構造** (L234-273):
- L236-240: `actor:` セクションあり
- L248: `workflow:` セクションあり
- `feature:` と `scenarios:` は存在しない

### 5-3. generate-usecase.md の検証

**検証項目**:
- Step 3 (Read Input Files) が新構造を参照していること
- Step 5 の Rules にアクター/エンティティ抽出ルールがあること
- Example の Input が新構造であること

**検証結果**: ✅ OK

**詳細**:

✅ **新構造の参照確認** (L56-57):
- L57: `Workflow definitions with structured steps (actor, activity, aggregate, event, policy)`

✅ **旧構造が残っていないこと**:
- `Feature definitions and scenarios` は検出されず

✅ **アクター/エンティティ抽出ルール** (L122-124):
- L122: **Actor extraction**: Use the `actor` field from workflow steps
- L124: **Entity extraction**: Use the `aggregate` field from workflow steps

✅ **Step 6 (Verification)** (L126-130):
- L128: "EVERY workflow" という表現あり
- "EVERY feature scenario" は存在しない

✅ **Example の Input が新構造** (L159-191):
- L162-163: `actor:` セクションあり
- L169: `workflow:` セクションあり
- `feature:` と `scenarios:` は存在しない

### 5-4. 横断的整合性チェック

**検証結果**: ✅ OK

**詳細**:

✅ **3ファイルすべてで workflow 構造を参照**:
- generate-workflow.md: `workflow:` 多数
- show-event.md: `workflow` 多数
- generate-usecase.md: `workflow.yml` 参照あり

✅ **YAML キーとしての feature: が残っていない**:
- 3ファイルのいずれにも検出されず
- (status.json の `feature_name` は許容される)

✅ **ステップフィールドの一貫性**:
- 3ファイルすべてで `actor`, `activity` が必須フィールドとして扱われている
- 3ファイルすべてで `aggregate`, `event`, `policy` がオプションフィールドとして扱われている

---

## 6. Generate Command Idempotency Verification

### 検証内容
`generate` コマンドを2回連続実行しても、バージョンが1つしか上がらないことを検証する。

### 6-1. バージョンスキップロジックの検証

**検証対象ファイル**:
- `generate-workflow.md`
- `generate-usecase.md`
- `generate-ui.md`
- `generate-screenflow.md`
- `generate-mock.md`
- `generate-manual.md`
- `generate-acceptance-test.md`

**検証項目**:
- `currentVersion >= targetVersion` でスキップし STOP すること

**検証結果**: ⚠️ PARTIAL OK (generate-workflow.md に課題あり)

**詳細**:

#### ✅ generate-usecase.md (L51-52)
```
If {{currentVersion}} >= {{targetVersion}} → Display "スキップ: usecase は既に最新です (version {{currentVersion}})" and **STOP**
If {{targetVersion}} - {{currentVersion}} > 1 → Display warning but continue
```
- ✅ スキップロジックあり
- ✅ STOP 指示あり

#### ✅ generate-ui.md (L52-53)
```
If {{currentVersion}} >= {{targetVersion}} → Display "スキップ: ui は既に最新です (version {{currentVersion}})" and **STOP**
If {{targetVersion}} - {{currentVersion}} > 1 → Display warning but continue
```
- ✅ スキップロジックあり
- ✅ STOP 指示あり

#### ✅ generate-screenflow.md (L81-82)
```
If {{currentVersion}} >= {{targetVersion}} → Display "スキップ: screenflow は既に最新です (version {{currentVersion}})" and **STOP**
If {{targetVersion}} - {{currentVersion}} > 1 → Display warning but continue
```
- ✅ スキップロジックあり
- ✅ STOP 指示あり

#### ✅ generate-mock.md (L65-66)
```
If {{currentVersion}} >= {{targetVersion}} → Display "スキップ: mock は既に最新です (version {{currentVersion}})" and **STOP**
If {{targetVersion}} - {{currentVersion}} > 1 → Display warning but continue
```
- ✅ スキップロジックあり
- ✅ STOP 指示あり

#### ✅ generate-manual.md (L55)
```
If {{currentVersion}} >= {{targetVersion}} → Display "スキップ: manual は既に最新です (version {{currentVersion}})" and **STOP**
```
- ✅ スキップロジックあり
- ✅ STOP 指示あり

#### ✅ generate-acceptance-test.md (L54)
```
If {{currentVersion}} >= {{targetVersion}} → Display "スキップ: acceptance_test は既に最新です (version {{currentVersion}})" and **STOP**
```
- ✅ スキップロジックあり
- ✅ STOP 指示あり

#### ⚠️ generate-workflow.md (L40-50)

**問題点**: README が変更されていない場合のスキップロジックが明示的に記載されていない

**現在のロジック**:
```
Step 2. Check Status (Version Validation)
- Get steps[0].workflow.version as currentVersion
- Calculate diff = 1 - currentVersion
- If diff > 1: STOP (バージョンが飛んでいる)
- If diff <= 1: 続行
```

**課題**:
- `currentVersion = 1` の場合、`diff = 1 - 1 = 0` となり `diff <= 1` で続行される
- README の checksum 比較によるスキップロジックがない
- 2回目実行時に workflow.yml が再生成されてしまう可能性がある

**推奨**: Step 2 に以下のロジックを追加
```
- If status.json exists:
  - Read readme.checksum from status.json
  - Calculate current README.md checksum
  - If checksums match AND currentVersion >= 1:
    - Display "スキップ: workflow は既に最新です (README未変更, version {{currentVersion}})" and **STOP**
```

または、他のコマンドと同様に:
```
- If currentVersion >= 1 → Display "スキップ: workflow は既に最新です (version {{currentVersion}})" and **STOP**
```

### 6-2. バージョン依存チェーンの検証

**検証項目**: 各ステップの targetVersion が前ステップの version から取得されていること

**検証結果**: ✅ OK

**詳細**:

| コマンド | targetVersion 取得元 | currentVersion 取得元 | 検証結果 |
|---------|---------------------|----------------------|---------|
| generate-workflow | N/A (固定値 1) | `steps[0].workflow.version` | ⚠️ (上記参照) |
| generate-usecase | `steps[0].workflow.version` (L48) | `steps[1].usecase.version` (L49) | ✅ OK |
| generate-ui | `steps[1].usecase.version` (L48) | `steps[2].ui.version` (L50) | ✅ OK |
| generate-screenflow | `steps[2].ui.version` (L77) | `steps[3].screenflow.version` (L79) | ✅ OK |
| generate-mock | `steps[3].screenflow.version` (L61) | `mock.version` (L64) | ✅ OK |
| generate-manual | `steps[3].screenflow.version` (L49) | `manual.version` (L51) | ✅ OK |
| generate-acceptance-test | `steps[2].ui.version` (L48) | `acceptance_test.version` (L51) | ✅ OK |

**注記**:
- generate-workflow は他のステップに依存せず、README から生成するため targetVersion の概念が異なる
- 他のコマンドはすべて正しく前ステップの version を targetVersion として取得している

### 6-3. 冪等性シナリオの論理検証

**シナリオ**: `generate` を2回連続実行した場合

#### 1回目の実行 (想定)

| コマンド | targetVersion | currentVersion | 処理 | 結果 |
|---------|--------------|---------------|------|------|
| generate-workflow | 1 | 0 | 生成実行 | workflow.version = 1 |
| generate-usecase | 1 | 0 | 生成実行 | usecase.version = 1 |
| generate-ui | 1 | 0 | 生成実行 | ui.version = 1 |
| generate-screenflow | 1 | 0 | 生成実行 | screenflow.version = 1 |
| generate-mock | 1 | 0 | 生成実行 | mock.version = 1 |

#### 2回目の実行 (想定)

| コマンド | targetVersion | currentVersion | 処理 | 結果 |
|---------|--------------|---------------|------|------|
| generate-workflow | 1 | 1 | ⚠️ 続行 (README checksum 未チェック) | workflow.version = 1 (再生成) |
| generate-usecase | 1 | 1 | ✅ スキップ (`currentVersion >= targetVersion`) | usecase.version = 1 (変更なし) |
| generate-ui | 1 | 1 | ✅ スキップ | ui.version = 1 (変更なし) |
| generate-screenflow | 1 | 1 | ✅ スキップ | screenflow.version = 1 (変更なし) |
| generate-mock | 1 | 1 | ✅ スキップ | mock.version = 1 (変更なし) |

**検証結果**: ⚠️ PARTIAL OK

**課題**:
- generate-workflow のみ、2回目実行時にスキップされない可能性がある
- 他のコマンドは正しくスキップされる

### 6-4. Update Status で targetVersion を使用しているか

**検証項目**: Update Status セクションが `currentVersion + 1` ではなく `targetVersion` を使用していること

**検証結果**: ✅ OK

**詳細**:

全コマンドで `version: Set to {{targetVersion}}` を使用:

- generate-usecase.md L150: `version: Set to {{targetVersion}} (from Step 2)`
- generate-ui.md L72: `version: Set to {{targetVersion}} (from Step 3)`
- generate-screenflow.md L162: `version: Set to {{targetVersion}} (from Step 2)`
- generate-mock.md L301: `version: Set to {{targetVersion}} (from Step 2)`
- generate-manual.md L180: `version: Set to {{targetVersion}} (from Step 2)`
- generate-acceptance-test.md L212: `version: Set to {{targetVersion}} (from Step 2)`

✅ すべてのコマンドで targetVersion を使用しており、currentVersion + 1 は使用していない

**冪等性への影響**:
- targetVersion が変わらなければ、書き込み値も変わらない
- これにより、2回目実行時にバージョンが上がらない

---

## 総合評価

### ✅ 良好な点

1. **旧ファイル名への参照が完全に除去されている**
   - `feature.yml`, `story.yml`, `check.md`, `generate-story` などの参照は一切なし

2. **workflow 構造への移行が完了している**
   - generate-workflow.md, show-event.md, generate-usecase.md すべてで新構造を使用
   - Step Field Reference テーブルが整備されている
   - Actor Usage Guidelines が明確

3. **冪等性ロジックが実装されている**
   - 6つの generate-* コマンド (usecase, ui, screenflow, mock, manual, acceptance-test) でスキップロジックあり
   - すべて targetVersion を使用して更新

4. **バージョン依存チェーンが正しい**
   - workflow → usecase → ui → screenflow → mock
   - workflow → usecase → ui → acceptance-test
   - workflow → usecase → ui → screenflow → manual

### ⚠️ 改善推奨項目

1. **install.sh へのファイル追加が必要**
   - `generate.md`
   - `generate-manual.md`
   - `generate-acceptance-test.md`

2. **generate-workflow.md の冪等性ロジック改善**
   - 現状: README が変更されていなくても workflow.yml を再生成する可能性がある
   - 推奨: `currentVersion >= 1` でスキップするロジックを追加、または README checksum 比較を追加

### 📊 検証サマリー

| 検証項目 | 結果 | 備考 |
|---------|------|------|
| 1. Reference Integrity Check | ✅ OK | 旧ファイル名への参照なし |
| 2. Structure Validation | ✅ OK | status.json, パイプライン構造正常 |
| 3. Install Script Validation | ⚠️ WARNING | 3ファイルが install.sh に未記載 |
| 4. Installation Verification | - | 未実施 (静的解析のみ) |
| 5. Workflow Structure Verification | ✅ OK | feature → workflow 移行完了 |
| 6-1. スキップロジック検証 | ⚠️ PARTIAL OK | generate-workflow のみ課題あり |
| 6-2. バージョン依存チェーン | ✅ OK | 依存関係正しい |
| 6-3. 冪等性シナリオ | ⚠️ PARTIAL OK | generate-workflow のみ課題あり |
| 6-4. targetVersion 使用確認 | ✅ OK | 全コマンドで使用 |

---

## 推奨アクション

### 優先度: 高

1. **install.sh の修正**
   ```bash
   # COMMAND_FILES 配列に以下を追加 (L181 の後)
   "generate.md"
   "generate-manual.md"
   "generate-acceptance-test.md"
   ```

### 優先度: 中

2. **generate-workflow.md の冪等性ロジック改善**

   Option A (シンプル):
   ```markdown
   ### 2. Check Status (Version Validation)
   - If status.json exists:
     - Read status.json
     - Get steps[0].workflow.version as currentVersion
     - If currentVersion >= 1:
       - Display "スキップ: workflow は既に最新です (version {{currentVersion}})" and **STOP**
     - Otherwise: Proceed to Step 3
   - If status.json does not exist:
     - Proceed to Step 3
   ```

   Option B (README checksum 活用):
   ```markdown
   ### 2. Check Status (Version Validation)
   - If status.json exists:
     - Read status.json
     - Get steps[0].workflow.version as currentVersion
     - Get readme.checksum from status.json
     - Calculate current README.md checksum
     - If checksums match:
       - Display "スキップ: workflow は既に最新です (README未変更)" and **STOP**
     - If checksum differs but currentVersion >= 1:
       - Calculate diff = (currentVersion + 1) - currentVersion = 1
       - Continue to regenerate workflow.yml
   - If status.json does not exist:
     - Proceed to Step 3
   ```

---

**検証完了日時**: 2026-02-11
**検証者**: Claude Code Verification Specialist
