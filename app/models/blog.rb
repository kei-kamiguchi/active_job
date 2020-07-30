class Blog < ApplicationRecord
  def title_change
    sleep 5
    update(title: 'changed')
  end
end
