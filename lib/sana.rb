require 'shioruby'

# Ukagaka SHIORI submodule 'Sana'
class Sana
  # the ghost/master path
  attr_reader :dirpath
  # events object
  attr_reader :events
  # default Charset header value
  attr_accessor :charset
  # default Sender header value
  attr_accessor :sender

  # initialize Sana
  # @param [Object] events event definitions
  def initialize(events = Kernel)
    @events = events
    @charset = 'UTF-8'
    @sender = 'Sana'
  end

  # SHIORI load()
  # @param [String] dirpath the ghost/master directory path
  def load(dirpath)
    @dirpath = dirpath
    events.public_send(:_load, dirpath)
  end

  # SHIORI unload()
  def unload
    events.public_send(:_unload)
  end

  # SHIORI request()
  # @param [String] request_str SHIORI Request
  # @return [String] SHIORI Response
  def request(request_str)
    request = Shioruby.parse_request(request_str)
    if request.version[0] == '2'
      return build_response Sana::ResponseHelper.bad_request
    end
    begin
      response = events.public_send(request.ID, request)
    rescue
      raise unless error.is_a?(NoMethodError) && error.name.to_s == request.ID
    end
    case response
    when OpenStruct
      build_response response
    else
      build_response Sana::ResponseHelper.ok response
    end
  rescue => error
    case error
    when Shioruby::ParseError
      build_response Sana::ResponseHelper.bad_request
    else
      build_response Sana::ResponseHelper.internal_server_error
    end
  end

  private
  def build_response(response)
    response.version ||= '3.0'
    response.Charset = response.Charset || charset
    response.Sender = response.Sender || sender
    Shioruby.build_response(response)
  end
end

class Sana
  # SHIORI Response struct build helper
  module ResponseHelper
    # empty response struct
    # @return [OpenStruct] empty SHIORI Response struct
    def response
      OpenStruct.new
    end

    # normal response (200 OK or 204 No Content)
    # @param [String] value Value header content
    # @param [String] to Reference0 header content (for communication)
    # @return [OpenStruct] SHIORI Response struct
    def ok(value = nil, to = nil)
      if value.to_s.size != 0
        response = OpenStruct.new({
          code: 200,
          Value: value.to_s,
        })
        if to
          response.Reference0 = to.to_s
        end
        response
      else
        no_content
      end
    end

    # 204 No Content
    # @return [OpenStruct] SHIORI Response struct
    def no_content
      OpenStruct.new({
        code: 204,
      })
    end

    # 400 Bad Request
    # @return [OpenStruct] SHIORI Response struct
    def bad_request
      OpenStruct.new({
        code: 400,
      })
    end

    # 500 Internal Server Error
    # @return [OpenStruct] SHIORI Response struct
    def internal_server_error
      OpenStruct.new({
        code: 500,
      })
    end

    module_function :response
    module_function :ok
    module_function :no_content
    module_function :bad_request
    module_function :internal_server_error
  end
end
