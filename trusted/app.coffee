https = require 'https'
fs    = require 'fs'

options = 
  host: 172.42.1.62
  port: 4242
  method: 'GET'
  path: '/containers/json'
  key: fs.readFileSync('ssl/client.key')
  cert: fs.readFileSync('ssl/client.crt')
  headers: { 'Accept': 'application/json'} # not required, but being semantic here!

req = https.request options, (res) ->
    console.log res

req.end()
