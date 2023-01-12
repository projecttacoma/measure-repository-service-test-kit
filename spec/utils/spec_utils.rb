# frozen_string_literal: true

def run(runnable, inputs = {})
  test_run_params = { test_session_id: test_session.id }.merge(runnable.reference_hash)
  test_run = Inferno::Repositories::TestRuns.new.create(test_run_params)
  inputs.each do |name, value|
    session_data_repo.save(test_session_id: test_session.id, name:, value:, type: 'text')
  end
  Inferno::TestRunner.new(test_session:, test_run:).run(runnable)
end
