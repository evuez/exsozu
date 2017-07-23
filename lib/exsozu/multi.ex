defmodule ExSozu.Multi do
  alias __MODULE__
  alias ExSozu.Command

  @type t :: %__MODULE__{proxy_id: integer, actions: [], names: MapSet.t}
  defstruct [:proxy_id, actions: [], names: MapSet.new]

  @spec new :: t
  @spec new(proxy_id :: integer) :: t
  def new(proxy_id \\ nil) do
    %Multi{proxy_id: proxy_id}
  end

  # State

  def status(multi, name, opts \\ []) do
    add_action!(multi, name, Command.status(opts))
  end

  def dump_state(multi, name, opts \\ []) do
    add_action!(multi, name, Command.dump_state(opts))
  end

  def save_state(multi, name, path, opts \\ []) do
    add_action!(multi, name, Command.save_state(path, opts))
  end

  def load_state(multi, name, path, opts \\ []) do
    add_action!(multi, name, Command.load_state(path, opts))
  end

  # Lifecycle

  def soft_stop(multi, name, opts \\ []) do
    add_action!(multi, name, Command.soft_stop(opts))
  end

  def hard_stop(multi, name, opts \\ []) do
    add_action!(multi, name, Command.hard_stop(opts))
  end

  # Fronts

  def add_http_front(multi, name, app_id, host, path_begin, opts \\ []) do
    add_action!(multi, name, Command.add_http_front(app_id, host, path_begin, opts))
  end

  def add_https_front(multi, name, app_id, host, path_begin, fingerprint, opts \\ []) do
    add_action!(
      multi,
      name,
      Command.add_https_front(app_id, host, path_begin, fingerprint, opts)
    )
  end

  def remove_http_front(multi, name, app_id, host, path_begin, opts \\ []) do
    add_action!(multi, name, Command.remove_http_front(app_id, host, path_begin, opts))
  end

  def remove_https_front(multi, name, app_id, host, path_begin, fingerprint, opts \\ []) do
    add_action!(
      multi,
      name,
      Command.remove_https_front(app_id, host, path_begin, fingerprint, opts)
    )
  end

  # Workers

  def list_workers(multi, name, opts \\ []) do
    add_action!(multi, name, Command.list_workers(opts))
  end

  # Instances

  def add_instance(multi, name, app_id, ip_addr, port, opts \\ []) do
    add_action!(multi, name, Command.add_instance(app_id, ip_addr, port, opts))
  end

  def remove_instance(multi, name, app_id, ip_addr, port, opts \\ []) do
    add_action!(multi, name, Command.remove_instance(app_id, ip_addr, port, opts))
  end

  # Certificates

  def add_certificate(multi, name, cert, cert_chain, key, opts \\ []) do
    add_action!(multi, name, Command.add_certificate(cert, cert_chain, key, opts))
  end

  def remove_certificate(multi, name, data, opts \\ []) do
    add_action!(multi, name, Command.remove_certificate(data, opts))
  end

  # Upgrade

  def upgrade_master(multi, name, opts \\ []) do
    add_action!(multi, name, Command.upgrade_master(opts))
  end

  # Helpers

  defp add_action!(multi = %Multi{}, name, action) do
    %{actions: actions, names: names} = multi

    if MapSet.member?(names, name) do
      raise "An action #{inspect name} has already been set:\n#{inspect multi}"
    else
      %{multi | actions: [{name, action} | actions], names: MapSet.put(names, name)}
    end
  end
end
