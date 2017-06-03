Puppet::Functions.create_function(:hiera_jenkins) do
  require 'uri'
  require 'puppet/util/lookup_httpx'

  dispatch :lookup_key do
    param 'Variant[String, Numeric]', :key
    param 'Hash', :options
    param 'Puppet::LookupContext', :context
  end

  def lookup_key(key, options, context)
    options['port'] = 8080 unless options['port']
    options['output'] = 'json' unless options['output']
    options['ignore_404'] = true unless options['ignore_404']
    options['auth_user'] = options['jenkins_user'] if options['jenkins_user']
    options['auth_pass'] = options['jenkins_user'] if options['jenkins_password']

    if confine_keys = options['confine_to_keys']
      raise ArgumentError, 'confine_to_keys must be an array' unless confine_keys.is_a?(Array)
      confine_keys.map! { |r| Regexp.new(r) }
      regex_key_match = Regexp.union(confine_keys)
      unless key[regex_key_match] == key
        context.explain { "Skipping hiera_jenkins backend because key does not match confine_to_keys" }
        context.not_found
      end
    end

    result = http_get(key, context, options)

    answer = result.is_a?(Hash) ? result[key] : result
    context.not_found if answer.nil?

    return answer
  end

  def http_get(key, context, options)
    scope = URI.parse(options['uri']).path.split('/').last

    if scope.nil?
      context.explain { "Skipping an empty scope" }
      context.not_found
    end

    uri = URI::HTTP.build({
      :host  => options['host'],
      :port  => options['port'],
      :query => URI.escape("scope=#{scope}&key=#{key}"),
      :path  => '/hiera/lookup'
    })

    if options[:use_ssl]
      uri.scheme = 'https'
    end

    if context.cache_has_key("#{scope}/#{key}")
      context.explain { "Returning cached value for #{scope}/#{key}" }
      return context.cached_value("#{scope}/#{key}")
    else
      context.explain { "Querying #{uri}" }
      lookup_params = {}
      options.each do |k,v|
        lookup_params[k.to_sym] = v if supported_params.include?(k.to_sym)
      end
      http_handler = LookupHttp.new(lookup_params.merge({:host => uri.host, :port => uri.port}))

      begin
        response = http_handler.get_parsed(uri)
        context.cache("#{scope}/#{key}", response)
        return response
      rescue LookupHttp::LookupError => e
        raise Puppet::DataBinding::LookupError, "lookup_http failed #{e.message}"
      end
    end
  end

  def supported_params
    [
      :output,
      :failure,
      :ignore_404,
      :headers,
      :http_connect_timeout,
      :http_read_timeout,
      :use_ssl,
      :ssl_ca_cert,
      :ssl_cert,
      :ssl_key,
      :ssl_verify,
      :auth_user,
      :auth_pass,
    ]
  end
end
