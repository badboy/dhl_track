require 'faraday'
require 'faraday_middleware'
require 'nokogiri'
require 'time'

require "dhl_track/version"

DHL_API_URI = "https://api-eu.dhl.com"

class Status
  attr_reader :time
  attr_reader :location
  attr_reader :status_code
  attr_reader :status
  attr_reader :description

  def self.from_api(status)
    time = Time.parse(status.timestamp)
    location = status.location&.address&.addressLocality || "unknown"
    self.new(time, location, status.status_code, status.status, status.description)
  end

  def to_s
    "#{time}: #{description} (in #{location})"
  end

  def inspect
    "Status([#{status_code}] #{self})"
  end

  def delivered?
    status_code == "delivered" || status == "SIGNATURE_RECORDED"
  end

  private
  def initialize(time, location, status_code, status, description)
    @time = time
    @location = location
    @status_code = status_code
    @status = status
    @description = Nokogiri::HTML(description).inner_text
  end
end


class DhlTrack
  class Error < StandardError;
    attr_reader :response
    def initialize(response)
      @response = response
    end
  end
  class UnknownPackageError < Error; end
  class RateLimitError < Error; end

  def initialize(apikey)
    headers = {
      "User-Agent": "package-tracking/#{DhlTrack::VERSION}",
      "DHL-API-Key": apikey
    }
    @conn = Faraday.new(url: DHL_API_URI, headers: headers) do |faraday|
      faraday.adapter Faraday.default_adapter

      if $DEBUG
        faraday.response :logger
      end

      faraday.response :rashify
      faraday.response :json, :content_type => /\bjson$/
    end
  end

  def shipment_status(tracking_number, language="de")
    resp = @conn.get("track/shipments", trackingNumber: tracking_number, language: language)
    if !resp.success?
      if resp.status == 429
        raise RateLimitError.new(resp)
      end

      if resp.status == 404
        raise UnknownPackageError.new(resp)
      end

      raise Error.new(resp)
    end

    shipments = resp.body.shipments
    return nil if shipments.nil?

    shipment = shipments.first
    Status.from_api(shipment.status)
  end
end
