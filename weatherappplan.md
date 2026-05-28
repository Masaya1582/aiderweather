# 天気アプリ実装計画

## プロジェクト概要
SwiftUI と Swift Concurrency (async/await) を学ぶための実践的な天気アプリケーション。OpenWeather API を使用して、実際の天気データを取得・表示する。

## 学習目標
- SwiftUI によるモダンなUI構築
- Swift Concurrency (async/await) を用いた非同期データ取得
- 外部API (OpenWeather) との連携
- 状態管理（ObservableObject, @State, @Publishedなど）
- ユーザー設定の永続化（都市選択など）
- エラーハンドリングとユーザーへのフィードバック

## 実装機能

### 1. 基本機能
- **現在の天気表示**: 現在地または選択した都市の現在の天気（気温、天気状態、湿度、風速など）を表示
- **天気予報**: 5日間（3時間間隔）の天気予報をリストまたはグラフで表示
- **都市検索・選択**: ユーザーが都市名で検索し、お気に入り都市を登録できる
- **位置情報**: ユーザーの現在地を取得し、その地域の天気を自動表示（オプション）

### 2. UIコンポーネント
- **メイン画面**: 現在の天気を大きく表示、天気アイコン、気温、都市名
- **予報画面**: タブまたはページングで日別・時間別予報を切り替え
- **設定画面**: APIキー設定（デバッグ用）、温度単位（摂氏/華氏）、言語など
- **ローディング表示**: データ取得中のインジケータ
- **エラー表示**: ネットワークエラーやAPIエラー時のユーザー通知

### 3. 技術的実装項目
- **ネットワーク層**: `URLSession` を利用したAPIリクエスト、async/await でラップ
- **データモデル**: OpenWeather API のレスポンスに合わせた `Codable` 構造体
- **ViewModel**: `ObservableObject` を採用し、UI状態とビジネスロジックを管理
- **永続化**: `UserDefaults` または `@AppStorage` で選択都市や設定を保存
- **依存性注入**: テスト容易性のため、APIクライアントをプロトコルで抽象化
- **ユニットテスト**: ViewModelとネットワーク層のテスト（モックを使用）

## 実装フェーズ

### Phase 1: 基礎構築
1. OpenWeather API 登録とAPIキー取得
2. プロジェクト設定（必要な権限追加: 位置情報など）
3. 基本的なネットワークマネージャーの実装（async/await）
4. 天気データモデルの定義

### Phase 2: メインUI
1. 現在の天気を表示するシンプルなビュー作成
2. ViewModel でデータ取得と状態管理
3. ローディング・エラー状態のUI対応

### Phase 3: 機能拡張
1. 5日間予報データの取得と表示
2. 都市検索機能の追加
3. ユーザー設定（温度単位など）の実装

### Phase 4: 磨き上げ
1. UI/UXの改善（アニメーション、デザイン調整）
2. パフォーマンス最適化（画像キャッシュなど）
3. エラーハンドリングの強化
4. テストの追加

## 使用技術スタック
- **UI**: SwiftUI
- **非同期処理**: Swift Concurrency (async/await, Task, Actor)
- **アーキテクチャ**: MVVM (Model-View-ViewModel)
- **ネットワーク**: URLSession, Codable
- **永続化**: @AppStorage, UserDefaults
- **位置情報**: CoreLocation (必要に応じて)

## 参考リソース
- [OpenWeather API Documentation](https://openweathermap.org/api)
- [Apple Swift Concurrency](https://developer.apple.com/documentation/swift/concurrency)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)

## 備考
- APIキーは環境変数や設定ファイルで管理し、GitHubなどに公開しないよう注意
- 無料プランのAPI制限（1分間60回）を考慮した実装にする
- 国際化（i18n）対応はオプションとして後期に検討
