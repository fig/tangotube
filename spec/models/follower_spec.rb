require 'rails_helper'

RSpec.describe Follower, type: :model do
  it { is_expected.to have_many(:videos) }
end
