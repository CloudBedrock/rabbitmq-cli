## The contents of this file are subject to the Mozilla Public License
## Version 1.1 (the "License"); you may not use this file except in
## compliance with the License. You may obtain a copy of the License
## at http://www.mozilla.org/MPL/
##
## Software distributed under the License is distributed on an "AS IS"
## basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
## the License for the specific language governing rights and
## limitations under the License.
##
## The Original Code is RabbitMQ.
##
## The Initial Developer of the Original Code is Pivotal Software, Inc.
## Copyright (c) 2016-2017 Pivotal Software, Inc.  All rights reserved.


defmodule ChangeClusterNodeTypeCommandTest do
  use ExUnit.Case, async: false
  import TestHelper

  @command RabbitMQ.CLI.Ctl.Commands.ChangeClusterNodeTypeCommand

  setup_all do
    RabbitMQ.CLI.Core.Distribution.start()


    start_rabbitmq_app()

    on_exit([], fn ->
      start_rabbitmq_app()


    end)

    :ok
  end

  setup do
    {:ok, opts: %{
      node: get_rabbit_hostname()
    }}
  end

  test "validate: node type of disc, disk, and ram pass validation", context do
    assert match?(
      {:validation_failure, {:bad_argument, _}},
      @command.validate(["foo"], context[:opts]))

    assert :ok == @command.validate(["ram"], context[:opts])
    assert :ok == @command.validate(["disc"], context[:opts])
    assert :ok == @command.validate(["disk"], context[:opts])
  end

  test "validate: providing no arguments fails validation", context do
    assert @command.validate([], context[:opts]) ==
      {:validation_failure, :not_enough_args}
  end
  test "validate: providingg too many arguments fails validation", context do
    assert @command.validate(["a", "b", "c"], context[:opts]) ==
      {:validation_failure, :too_many_args}
  end

  # TODO
  #test "run: change ram node to disc node", context do
  #end

  # TODO
  #test "run: change disk node to ram node", context do
  #end

  test "run: request to a node with running RabbitMQ app fails", context do
   assert match?(
     {:error, :mnesia_unexpectedly_running},
    @command.run(["ram"], context[:opts]))
  end

  test "run: request to an unreachable node returns nodedown", _context do
    target = :jake@thedog

    opts = %{
      node: target
    }
    # We use "self" node as the target. It's enough to trigger the error.
    assert match?(
      {:badrpc, :nodedown},
      @command.run(["ram"], opts))
  end

  test "banner", context do
    assert @command.banner(["ram"], context[:opts]) =~
      ~r/Turning #{get_rabbit_hostname()} into a ram node/
  end

  test "output mnesia is running error", context do
    exit_code = RabbitMQ.CLI.Core.ExitCodes.exit_software
    assert match?({:error, ^exit_code,
                   "Mnesia is still running on node " <> _},
                   @command.output({:error, :mnesia_unexpectedly_running}, context[:opts]))

  end
end
