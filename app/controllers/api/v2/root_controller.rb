# encoding: utf-8

class Api::V2::RootController < Api::V2Controller

  def index
    resp = {
      api: {
        version: 2,
        description:    "Welcome to the pony.io API version 2.0",
        copyright:      "© IOMUSE 2012 – 2013",
        website:        root_url(subdomain: "www"),
        terms_of_use:   page_url("terms-and-conditions",subdomain: "www"),
        privacy_policy: page_url("privacy-policy",subdomain: "www")
      },
      meta: {
        status: 200,
        errors: [],
        notice: ""
      }
    }

    respond_with resp, status: 200
  end

  def not_found
    resp = {
      meta: {
        status: 404,
        errors: [],
        notice: "Resource does not exist."
      }
    }
    respond_with resp, status: 200
  end

end
