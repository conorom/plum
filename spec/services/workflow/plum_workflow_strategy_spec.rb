require 'rails_helper'

RSpec.describe Workflow::PlumWorkflowStrategy, :no_clean, :admin_set do
  context 'when working with a scanned resource' do
    let(:work) { FactoryGirl.build(:scanned_resource) }
    let(:workflow_strategy) { described_class.new(work) }

    describe '#workflow_id' do
      subject { workflow_strategy.workflow }
      it { is_expected.to eq Sipity::Workflow.where(name: 'book_works').first! }
    end
  end

  context 'when working with a vector work' do
    let(:work) { FactoryGirl.build(:vector_work) }
    let(:workflow_strategy) { described_class.new(work) }

    describe '#workflow_name' do
      subject { workflow_strategy.workflow }
      it { is_expected.to eq Sipity::Workflow.where(name: 'geo_works').first! }
    end
  end
end
