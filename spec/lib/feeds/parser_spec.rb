require 'spec_helper'

module Feeds
  describe Parser do

    context '#parse_submission' do
      it 'should return the feed id' do
        id = Parser.parse_submission(Responses.successful_submission)
        id.should eq "8253017998"
      end
    end
  end
end

