require 'rails_helper'
RSpec.describe TitlesChangeJob, type: :job do
  let(:blog){Blog.create(id: 1, title: 'タイトル', content: '内容')}
  it 'Jobがエンキューされたか' do
    expect {
      TitlesChangeJob.set(wait_until: Date.tomorrow.noon).perform_later(blog.id)
    }.to have_enqueued_job(TitlesChangeJob).at(Date.tomorrow.noon)
  end
  it 'Job実行後、タイトルが変更されているか' do
    perform_enqueued_jobs do
      TitlesChangeJob.set(wait_until: Date.tomorrow.noon).perform_later(blog.id)
    end
    expect(Blog.find(1).title).to eq 'changed'
  end
end
