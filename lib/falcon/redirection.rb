# Copyright, 2018, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'async/http/client'

module Falcon
	module NotFound
		def self.call(request)
			return Protocol::HTTP::Response[404, {}, []]
		end
		
		def self.close
		end
	end
	
	class Redirection < Protocol::HTTP::Middleware
		def initialize(app, hosts, endpoint)
			super(app)
			
			@hosts = hosts
			@endpoint = endpoint
		end
		
		def lookup(request)
			# Trailing dot and port is ignored/normalized.
			if authority = request.authority.sub(/(\.)?(:\d+)?$/, '')
				return @hosts[authority]
			end
		end
		
		def call(request)
			if host = lookup(request)
				if @endpoint.default_port?
					location = "#{@endpoint.scheme}://#{host.authority}#{request.path}"
				else
					location = "#{@endpoint.scheme}://#{host.authority}:#{@endpoint.port}#{request.path}"
				end
				
				return Protocol::HTTP::Response[301, [['location', location]], []]
			else
				super
			end
		end
	end
end
