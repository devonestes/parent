defmodule PeriodicTest do
  use ExUnit.Case, async: true

  describe "start_link/1" do
    test "sets the initial state correctly" do
      pid =
        start_test_scheduler(
          timeout: 500,
          log_level: :info,
          log_meta: [:thing],
          overlap?: false,
          every: 10
        )

      assert %{
               timeout: 500,
               log_level: :info,
               log_meta: [:thing],
               overlap?: false,
               every: 10
             } = :sys.get_state(pid)
    end

    test "starts a timer to execute a job" do
      start_test_scheduler(every: 9, apply_after_fun: test_apply_after())
      assert_receive {:apply_after, 9, Periodic, :run_job, [pid]}
      assert is_pid(pid)
    end
  end

  describe "child_spec/1" do
    test "returns a valid child spec" do
    end
  end

  describe "run_job/1" do
    test "ticking with initial delay" do
      scheduler_pid = start_test_scheduler(initial_delay: 1, every: 2)

      Periodic.run_job(scheduler_pid)
      assert_receive 1
      refute_received _

      Periodic.run_job(scheduler_pid)
      assert_receive 2
      refute_received _

      Periodic.run_job(scheduler_pid)
      assert_receive 2
      refute_received _
    end
  end
end
