defmodule ExSozu.Command do
  @moduledoc """
  Provides a set of helpers to prepare commands for Sōzu.

  If you can't find a command in this list, you can create one like this:

      %ExSozu.Command{
        type: <type (must be an atom)>,
        proxy_id: <the proxy id, if any>,
        data: <whatever needs to be send>
      }

  You can then send it using `ExSozu.command/1`.

  Checkout the [Sōzu documentation](https://github.com/sozu-proxy/sozu/tree/master/command)
  for more info.
  """

  @type t :: %__MODULE__{
    id: String.t,
    version: 0,
    type: atom,
    data: nil | map,
    proxy_id: nil | integer
  }
  @type options :: [proxy_id: nil | integer]

  @derive [Poison.Encoder]
  defstruct [:id, :type, :data, :proxy_id, version: 0]

  @doc false
  def to_json!(command = %__MODULE__{}) do
    command = Map.update!(command, :type, &upcase_atom/1)
    command = with %{data: %{type: type}} <- command,
                do: put_in(command.data.type, upcase_atom(type))

    command = with %{proxy_id: nil} <- command, do: Map.delete(command, :proxy_id)
    command = with %{data: nil} <- command, do: Map.delete(command, :data)

    Poison.encode!(command)
  end

  defp upcase_atom(atom), do: atom |> Atom.to_string |> String.upcase

  # State

  @spec status(options) :: t
  def status(opts \\ []) do
    config(:proxy, %{type: :status}, opts)
  end

  @spec dump_state(options) :: t
  def dump_state(opts \\ []) do
    config(:dump_state, opts)
  end

  @spec save_state(path :: String.t, options) :: t
  def save_state(path, opts \\ []) do
    config(:save_state, %{path: path}, opts)
  end

  @spec load_state(path :: String.t, options) :: t
  def load_state(path, opts \\ []) do
    config(:load_state, %{path: path}, opts)
  end

  # Lifecycle

  @spec soft_stop(options) :: t
  def soft_stop(opts \\ []) do
    config(:proxy, %{type: :soft_stop}, opts)
  end

  @spec hard_stop(options) :: t
  def hard_stop(opts \\ []) do
    config(:proxy, %{type: :hard_stop}, opts)
  end

  # Fronts

  @spec add_http_front(app_id :: String.t,
                       host :: String.t,
                       path_begin :: String.t,
                       options) :: t
  def add_http_front(app_id, host, path_begin, opts \\ []) do
    data = %{app_id: app_id, hostname: host, path_begin: path_begin}

    config(:proxy, %{type: :add_http_front, data: data}, opts)
  end

  @spec add_https_front(app_id :: String.t,
                        host :: String.t,
                        path_begin :: String.t,
                        fingerprint :: String.t,
                        options) :: t
  def add_https_front(app_id, host, path_begin, fingerprint, opts \\ []) do
    data = %{app_id: app_id,
            hostname: host,
            path_begin: path_begin,
            fingerprint: fingerprint}

    config(:proxy, %{type: :add_https_front, data: data}, opts)
  end

  @spec remove_http_front(app_id :: String.t,
                          host :: String.t,
                          path_begin :: String.t,
                          options) :: t
  def remove_http_front(app_id, host, path_begin, opts \\ []) do
    data = %{app_id: app_id, hostname: host, path_begin: path_begin}

    config(:proxy, %{type: :remove_http_front, data: data}, opts)
  end

  @spec remove_https_front(app_id :: String.t,
                           host :: String.t,
                           path_begin :: String.t,
                           fingerprint :: String.t,
                           options) :: t
  def remove_https_front(app_id, host, path_begin, fingerprint, opts \\ []) do
    data = %{app_id: app_id,
            hostname: host,
            path_begin: path_begin,
            fingerprint: fingerprint}

    config(:proxy, %{type: :remove_https_front, data: data}, opts)
  end

  # Workers

  @spec list_workers(options) :: t
  def list_workers(opts \\ []) do
    config(:list_workers, opts)
  end

  # Instances

  @spec add_instance(app_id :: String.t,
                     instance_id :: String.t,
                     ip_addr :: String.t,
                     port :: integer,
                     options) :: t
  def add_instance(app_id, instance_id, ip_addr, port, opts \\ []) do
    data = %{app_id: app_id, instance_id: instance_id, ip_address: ip_addr, port: port}

    config(:proxy, %{type: :add_instance, data: data}, opts)
  end

  @spec remove_instance(app_id :: String.t,
                        instance_id :: String.t,
                        ip_addr :: String.t,
                        port :: integer,
                        options) :: t
  def remove_instance(app_id, instance_id, ip_addr, port, opts \\ []) do
    data = %{app_id: app_id, instance_id: instance_id, ip_address: ip_addr, port: port}

    config(:proxy, %{type: :remove_instance, data: data}, opts)
  end

  # Certificates

  @spec add_certificate(cert :: String.t,
                        cert_chain :: [String.t],
                        key :: String.t,
                        options) :: t
  def add_certificate(cert, cert_chain, key, opts \\ []) do
    data = %{certificate: cert, certificate_chain: cert_chain, key: key}

    config(:proxy, %{type: :add_certificate, data: data}, opts)
  end

  @spec remove_certificate(data :: String.t, options) :: t
  def remove_certificate(data, opts \\ []) do
    config(:proxy, %{type: :remove_certificate, data: data}, opts)
  end

  # Upgrade

  @spec upgrade_master(options) :: t
  def upgrade_master(opts \\ []) do
    config(:upgrade_master, opts)
  end

  # Helpers

  defp config(type, data \\ nil, opts) do
    %__MODULE__{
      type: type,
      proxy_id: opts[:proxy_id],
      data: data
    }
  end
end
