require 'rubygems'
require 'bundler'
require 'openssl'
require 'base64'

Bundler.require(:default)
require "./amazon_endpoint"
run AmazonEndpoint