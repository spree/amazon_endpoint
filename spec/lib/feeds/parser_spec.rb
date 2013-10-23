require 'spec_helper'

module Feeds
  describe Parser do

    describe '#parse_submission' do
      it 'should return the feed id' do
        id = Parser.parse_submission(Responses.successful_submission)
        id.should eq "8253017998"
      end
    end

    describe '#parse_result' do
      it 'should raise error if feed failed' do
        # id = Parser.parse_result(Responses.successful_result)
        # id.should eq "8253017998"
      end
    end
  end
end

