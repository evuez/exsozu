defmodule ExSozu.Command do
  alias ExSozu.Command

  defstruct [:id, :type, :data, :proxy_id, version: 0]

  @id_length 16

  # State

  def status(commands, opts \\ []) do
    [config(:proxy, %{type: :status}, opts) | commands]
  end

  def dump_state(commands, opts \\ []) do
    [config(:dump_state, opts) | commands]
  end

  def save_state(commands, path, opts \\ []) do
    [config(:save_state, %{path: path}, opts) | commands]
  end

  def load_state(commands, path, opts \\ []) do
    [config(:load_state, %{path: path}, opts) | commands]
  end

  # Lifecycle

  def soft_stop(commands, opts \\ []) do
    [config(:proxy, %{type: :soft_stop}, opts) | commands]
  end

  def hard_stop(commands, opts \\ []) do
    [config(:proxy, %{type: :hard_stop}, opts) | commands]
  end

  # Fronts

  def add_http_front(commands, app_id, host, path_begin, opts \\ []) do
    [config(
      :proxy,
      %{type: :add_http_front,
        data:
          %{app_id: app_id,
            hostname: host,
            path_begin: path_begin}},
      opts) | commands]
  end

  def add_https_front(commands, app_id, host, path_begin, fingerprint, opts \\ []) do
    [config(
      :proxy,
      %{type: :add_https_front,
        data:
          %{app_id: app_id,
            hostname: host,
            path_begin: path_begin,
            fingerprint: fingerprint}},
      opts) | commands]
  end

  def remove_http_front(commands, app_id, host, path_begin, opts \\ []) do
    [config(
      :proxy,
      %{type: :remove_http_front,
        data:
          %{app_id: app_id,
            hostname: host,
            path_begin: path_begin}},
      opts) | commands]
  end

  def remove_https_front(commands, app_id, host, path_begin, fingerprint, opts \\ []) do
    [config(
      :proxy,
      %{type: :remove_https_front,
        data:
          %{app_id: app_id,
            hostname: host,
            path_begin: path_begin,
            fingerprint: fingerprint}},
      opts) | commands]
  end

  # Workers

  def list_workers(commands, opts \\ []) do
    [config(:list_workers, opts) | commands]
  end

  # Instances

  def add_instance(commands, app_id, ip_addr, port, opts \\ []) do
    [config(
      :proxy,
      %{type: :add_instance,
        data:
          %{app_id: app_id,
            ip_address: ip_addr,
            port: port}},
      opts) | commands]
  end

  def remove_instance(commands, app_id, ip_addr, port, opts \\ []) do
    [config(
      :proxy,
      %{type: :remove_instance,
        data:
          %{app_id: app_id,
            ip_address: ip_addr,
            port: port}},
      opts) | commands]
  end

  # Certificates

  def add_certificate(commands, cert, cert_chain, key, opts \\ []) do
    [config(
      :proxy,
      %{type: :add_certificate,
        data:
          %{certificate: cert,
            certificate_chain: cert_chain,
            key: key}},
      opts) | commands]
  end

  def remove_certificate(commands, data, opts \\ []) do
    [config(:proxy, %{type: :remove_certificate, data: data}, opts) | commands]
  end

  # Upgrade

  def upgrade_master(commands, opts \\ []) do
    [config(:upgrade_master, opts) | commands]
  end

  # Helpers

  defp config(type, opts), do: config(type, nil, opts)
  defp config(type, data, opts) do
    %Command{
      id: id(),
      type: type,
      proxy_id: opts[:proxy_id],
      data: data
    }
  end

  defp id do
    :crypto.strong_rand_bytes(@id_length)
    |> Base.encode64
    |> binary_part(0, @id_length)
  end
end
