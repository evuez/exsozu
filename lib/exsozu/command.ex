defmodule ExSozu.Command do
  import ExSozu.Macros
  alias ExSozu.Command

  defstruct [:id, :type, :data, :proxy_id, version: 0]

  @id_length 16


  # State

  defcommand :status, :proxy, do: %{type: :status}
  defcommand :dump_state, :dump_state, do: nil
  defcommand :save_state, :save_state, [path], do: %{path: path}
  defcommand :load_state, :load_state, [path], do: %{path: path}

  # Lifecycle

  defcommand :soft_stop, :proxy, do: %{type: :soft_stop}
  defcommand :hard_stop, :proxy, do: %{type: :hard_stop}

  # Fronts

  defcommand :add_http_front, :proxy, [app_id, host, path_begin] do
    %{type: :add_http_front,
      data: %{app_id: app_id,
              hostname: host,
              path_begin: path_begin}}
  end
  defcommand :add_https_front, :proxy, [app_id, host, path_begin, fingerprint] do
    %{type: :add_https_front,
      data: %{app_id: app_id,
              hostname: host,
              path_begin: path_begin,
              fingerprint: fingerprint}}
  end
  defcommand :remove_http_front, :proxy, [app_id, host, path_begin] do
    %{type: :remove_http_front,
      data: %{app_id: app_id,
              hostname: host,
              path_begin: path_begin}}
  end
  defcommand :remove_https_front, :proxy, [app_id, host, path_begin, fingerprint] do
    %{type: :remove_https_front,
      data: %{app_id: app_id,
              hostname: host,
              path_begin: path_begin,
              fingerprint: fingerprint}}
  end

  # Workers

  defcommand :list_workers, :list_workers, do: nil

  # Instances

  defcommand :add_instance, :proxy, [app_id, ip_addr, port] do
    %{type: :add_instance,
      data: %{app_id: app_id,
              ip_address: ip_addr,
              port: port}}
  end
  defcommand :remove_instance, :proxy, [app_id, ip_addr, port] do
    %{type: :remove_instance,
      data: %{app_id: app_id,
              ip_address: ip_addr,
              port: port}}
  end

  # Certificates

  defcommand :add_certificate, :proxy, [cert, cert_chain, key] do
    %{type: :add_certificate,
      data: %{certificate: cert,
              certificate_chain: cert_chain,
              key: key}}
  end
  defcommand :remove_certificate, :proxy, [data],
    do: %{type: :remove_certificate, data: data}

  # Upgrade

  defcommand :upgrade_master, :upgrade_master, do: nil

  # Helpers

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
