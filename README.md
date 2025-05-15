## アプリケーション名
"ProgressHub"（プログレスハブ）
→「Progress（進捗）」＋「Hub（ハブ・集約地点）」の組み合わせで、進捗を一元管理するイメージ

## アプリケーション概要
ProgressHubは、複数の部署がバラバラに管理している進捗や実績を、一つのシステムでまとめて管理できるアプリです。リアルタイムで情報を更新・共有できるため、報告の手間を削減し、業務の効率を向上させます。管理者はダッシュボードで全体の状況を一目で把握でき、担当者は簡単にデータを登録・編集できます。

## URL
https://◎◎◎◎.onrender.com
br※デプロイ済みのURLを記載。デプロイが済んでいない場合は、デプロイが完了次第記載すること。

## テスト用アカウント
テスト用Email：test@test.com
brテスト用Password：aaa123
br※ログイン機能等を実装した場合は、ログインに必要な情報を記載。
br※またBasic認証等を設けている場合は、そのID/Passも記載すること。

## 利用方法
1. URLにアクセスし、ヘッダー右上の「ログイン」ボタンからログイン画面に移動します。
2. テスト用アカウントを使用しログインします。
3. トップページのヘッダー右上の「投稿する」ボタンから新規呟きを投稿します。
4. 投稿内容には画像1枚と文章を含めることができます。
5. 他のユーザーの呟きを閲覧し、コメントを残すことも可能です。
6. 投稿した呟きはトップページから編集・削除できます。

## アプリケーションを作成した背景
PicTweetは、ユーザー同士が画像とテキストを使って簡単に感情やアイデアを共有できるプラットフォームです。
br視覚的なコンテンツを通じてコミュニケーションを楽しむことを目指し、共通の趣味や関心を持つ人々がつながる場所を提供します。

## 実装した機能についての画像やGIFおよびその説明
|ページ|説明|
|---|------------------|
|[トップページのGIF](URL_TO_GIF)|トップページ　　　　　　　　　　　　　　　　　　　　　　|
|[ユーザー機能のGIF](URL_TO_GIF)|ユーザー機能br・新規登録br・ログイン/ログアウトbr・マイページ|
|[ツイート機能のGIF](URL_TO_GIF)|ツイート（呟き）機能br・投稿機能br・一覧機能br・詳細機能br・編集・削除機能|
|[コメント機能のGIF](URL_TO_GIF)|コメント機能|
|[検索機能のGIF](URL_TO_GIF)|検索機能|

## 実装予定の機能
- リアルタイム通知機能
- ユーザー同士のフォロー機能
- お気に入りのツイートを保存する機能
- 高度な検索フィルター機能

## データベース設計
ER図を添付。
brAIで作る場合は、googleアカウントがあれば使用できる「Vercel v0」がオススメです。
img width="307" alt="Image" src="https://github.com/user-attachments/assets/f780ed7f-e22c-495f-ad7d-5add7f75e45f" /


## 画面遷移図
画面遷移図を添付。
brAIで作る場合は、googleアカウントがあれば使用できる「Vercel v0」がオススメです。
img width="509" alt="Image" src="https://github.com/user-attachments/assets/086ceb82-5286-4340-b4ff-014d621e4d26" /


## 開発環境
| 項目               | バージョン・サービス |
|------------------|-----------------|
| **言語**        | Ruby 3.2.0 |
| **フレームワーク** | Ruby on Rails 7.1.5.1 |
| **データベース**  | PostgreSQL 14.15（本番） / MySQL 8.0（開発） |
| **フロントエンド** | HTML / CSS / JavaScript |
| **認証機能**    | Devise |
| **デプロイ環境** | Render |
| **バージョン管理** | GitHub |

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

DB設計
users テーブル（社員情報）
| Column             | Type     | Options                   | 備考                       |
|--------------------|----------|---------------------------|----------------------------|
| id                 | integer  | primary_key               | 社員の一意識別子            | 
| employee_id        | string   | null: false, unique: true | 社員ID（一意の識別子）       | 
| email              | string   | null: false, unique: true | メールアドレス              | 
| encrypted_password | string   | null: false               | パスワード（ハッシュ化）     | 
| user_name          | string   | null: false               | 社員名                      | 
| department         | string   | null: false               | 所属部署                    | 
| role               | integer  | null: false, default: 0   | 権限（0:一般社員, 1:管理者） | 
| created_at         | datetime |                           | 作成日時                    | 
| updated_at         | datetime |                           | 更新日時                    | 

Association:
- has_many :projects, foreign_key: :employee_id, dependent: :destroy


projects テーブル
| Column                   | Type     | Options                        | 備考                                 |
|--------------------------|----------|--------------------------------|--------------------------------------|
| id                       | integer  | primary_key                    | 案件の一意識別子                       | 
| customer_name            | string   | null: false                    | 顧客名                                | 
| sales_office             | string   |                                | 営業拠点                              | 
| sales_representative     | string   |                                | 営業担当                              | 
| request_type             | integer  | null: false, default: 0        | ENUM管理（新規/修正/追加/バグ修正など） | 
| request_content          | integer  | null: false, default: 0        | ENUM管理（WEBアプリ制作など）          | 
| order_date               | date     |                                | 受注日（カレンダー機能）               | 
| due_date                 | date     |                                | 納期（カレンダー機能）                 | 
| revenue                  | integer  | default: 0                     | 売上（1000単位）                      | 
| cost                     | integer  | default: 0                     | コスト（1000単位）                    | 
| profit                   | integer  |                                | 売上 - コスト（自動計算）              | 
| remarks                  | text     |                                | 備考                                 | 
| attachments              | string   |                                | 添付資料（Excel, Word, PNG, PDFなど） | 
| user_id                  | integer  | null: false, foreign_key: true | 社員ID（usersテーブルの外部キー）      | 
| assigned_person          | string   |                                | 担当者（社員ID入力時に自動入力）       | 
| planning_start_date      | date     |                                | 企画部の作業開始日                    | 
| planning_end_date        | date     |                                | 企画部の作業完了日                    | 
| design_start_date        | date     |                                | 情報設計部の作業開始日                 | 
| design_end_date          | date     |                                | 情報設計部の作業完了日                 | 
| development_start_date   | date     |                                | 開発部の作業開始日                     | 
| development_end_date     | date     |                                | 開発部の作業完了日                     | 
| status                   | integer  | default: 0                     | 状態（0:未着手, 1:進行中, 2:完了）      | 
| created_at               | datetime |                                | 作成日時                              | 
| updated_at               | datetime |                                | 更新日時                              | 

Association:
class Project < ApplicationRecord
- belongs_to :user

- validates :customer_name, presence: true
- validates :request_type, presence: true
- validates :request_content, presence: true
- validates :revenue, numericality: { greater_than_or_equal_to: 0 }
- validates :cost, numericality: { greater_than_or_equal_to: 0 }

- before_save :calculate_profit

- enum status: { 未着手: 0, 進行中: 1, 完了: 2 }

- private

  def calculate_profit
    self.profit = self.revenue - self.cost
  end
