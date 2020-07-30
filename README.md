# Active Job
- メール送信、大きなデータのダウンロードなどの逐次処理を行うとき
- 大量のデータベース更新、不要になったレコードの削除、定期的なデータ集計など、定期的で大きな処理を行うときは「Whenever」を使用すべき
- Active Jobだけでは非同期処理は実装できないので、いずれかのgem(Sidekiq、Resque、Delayed Jobなど)を入れる必要があります。
## 導入
1. gem`delayed_job_active_record`をインストール
2. Active Jobのアダプター(どのgem使うか)としてDelayed Jobを利用することを設定
[config/application.rb]
```
class Application < Rails::Application
  # 省略
  config.active_job.queue_adapter = :delayed_job
end
```
3. Job管理テーブルを作成(Job管理テーブルを確認し実行するワーカーを起動するbin/delayed_job実行ファイルも作成されます)
```
$ rails g delayed_job:active_record
```
4. マイグレーションを実行
```
$ rails db:migrate
```
5. Jobの設定ファイルを作成
```
$ rails g job sample
```
6. 非同期にしたい処理をコーディング
[app/jobs/sample_job.rb]
```
class SampleJob < ApplicationJob
  queue_as :default

  def perform(引数)
    # ここに非同期にしたい処理をコーディング
  end
end
```
7. Job管理テーブルにJobを登録(＝エンキュー)
<br>非同期処理を行いたい箇所に以下のようにメソッドを記述
```
# すぐに実行
SampleJob.perform_later(引数)
# 翌日の正午に実行
SampleJob.set(wait_until: Date.tomorrow.noon).perform_later(引数)
# 1週間後に実行
SampleJob.set(wait: 1.week).perform_later(引数)
```
8. ワーカー起動
<br>一方でrailsサーバーを起動し、もう一つ別のターミナルを開いてワーカーを起動
```
$ rails jobs:work
```
9. 本番環境でログを確認する設定
<br>以下の設定で[log/delayed_job.log]にログを記録することができます。

[config/initializers/delayed_job_config.rb]
```
Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', 'delayed_job.log'))
```
## テスト
Action Jobでテストすべき項目
- Jobがエンキューされたか
- Job実行後の処理が正常か

- Active Jobのテスト用のHelperを使えるようする設定
[spec/rails_helper.rb]
```
# 省略
RSpec.configure do |config|
  # 省略
  config.include ActiveJob::TestHelper
end
```
- テスト用のHelper(追記予定)
  - have_enqueued_jobmatcher：引数に持つクラス名とエンキューされているJobのクラス名とが一致するかを返します。
  - perform_enqueued_jobs：ブロック内のActive Jobを同期実行させることができます
- bin/rspec実行時に以下のようなエラーが発生する場合、以下のコマンドでテスト用のデータベースを作成してください
```
$ rails db:create db:migrate RAILS_ENV=test
```
## Action Mailerの非同期処理
- Action Mailerを呼び出す際の`.deliver`を`.deliver_later`に変更するだけで非同期処理が可能
