module ActiveAdminDatetimepicker
  module Base
    mattr_accessor :default_datetime_picker_options
    @@default_datetime_picker_options = {}
    mattr_accessor :format
    @@format = '%Y-%m-%d %H:%M'

    def html_class
      'date-time-picker'
    end

    def input_html_data
      {}
    end

    def input_html_options(input_name = nil, placeholder = nil)
      super().tap do |options|
        options[:class] = [self.options[:class], html_class].compact.join(' ')
        options[:data] ||= input_html_data
        options[:data].merge!(datepicker_options: datetime_picker_options)
        options[:value] = input_value(input_name)
        options[:maxlength] = 19
        options[:placeholder] = placeholder unless placeholder.nil?
      end
    end

    def input_value(input_name = nil)
      val = object.public_send(input_name || method)
      if val.is_a?(Date)
        val.strftime(format)
      elsif val.is_a?(DateTime) || val.is_a?(Time)
        format_datetime_with_timezone(val, format)
      else
        parse_datetime(val)
      end
    end

    def parse_datetime(val)
      DateTime.parse(val.to_s).in_time_zone.strftime(format)
    rescue ArgumentError
      nil
    end

    def datetime_picker_options
      @datetime_picker_options ||= begin
        # backport support both :datepicker_options AND :datetime_picker_options
        options = self.options.fetch(:datepicker_options, {})
        options = self.options.fetch(:datetime_picker_options, options)
        options = Hash[options.map { |k, v| [k.to_s.camelcase(:lower), v] }]
        _default_datetime_picker_options.merge(options)
      end
    end

    private

    def format_datetime_with_timezone(datetime, format)
      # Format the datetime but retain the timezone information
      timezone = datetime.time_zone
      datetime.strftime(format).in_time_zone(timezone)
    end

    protected

    def _default_datetime_picker_options
      res = default_datetime_picker_options.map do |k, v|
        if v.respond_to?(:call) || v.is_a?(Proc)
          [k, v.call]
        else
          [k, v]
        end
      end
      Hash[res]
    end
  end
end

