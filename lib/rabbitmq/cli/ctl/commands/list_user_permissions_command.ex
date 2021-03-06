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
## The Initial Developer of the Original Code is GoPivotal, Inc.
## Copyright (c) 2007-2017 Pivotal Software, Inc.  All rights reserved.


defmodule RabbitMQ.CLI.Ctl.Commands.ListUserPermissionsCommand do
  @behaviour RabbitMQ.CLI.CommandBehaviour
  use RabbitMQ.CLI.DefaultOutput

  def formatter(), do: RabbitMQ.CLI.Formatters.Table

  def scopes(), do: [:ctl, :diagnostics]

  def merge_defaults(args, opts), do: {args, opts}

  def validate([], _), do: {:validation_failure, :not_enough_args}
  def validate([_|_] = args, _) when length(args) > 1, do: {:validation_failure, :too_many_args}
  def validate([_], _), do: :ok

  use RabbitMQ.CLI.Core.RequiresRabbitAppRunning

  def run([username], %{node: node_name, timeout: time_out}) do
    :rabbit_misc.rpc_call(node_name,
        :rabbit_auth_backend_internal,
        :list_user_permissions,
        [username],
        time_out
      )
  end

  def usage, do: "list_user_permissions <username>"

  def banner([username], _), do: "Listing permissions for user \"#{username}\" ..."
end
