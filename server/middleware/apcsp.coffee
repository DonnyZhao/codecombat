wrap = require 'co-express'
errors = require '../commons/errors'
database = require '../commons/database'
config = require '../../server_config'
request = require 'request'
aws = require 'aws-sdk'

aws.config.update
  accessKeyId: 'AKIAIUJAS3Z7XUQWFKPA'
  secretAccessKey: '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'
  region: 'us-east-1'

getAPCSPFile = wrap (req, res) ->
  if not req.user
    throw new errors.Unauthorized('You must be logged in')

  unless req.user.isTeacher() or req.user.isAdmin()
    throw new errors.Forbidden('You cannot access this file')

  rest = req.params['0']
  
  url = "#{config.apcspFileUrl}#{rest}.md"
  [proxyRes] = yield request.getAsync({url})
  if proxyRes.statusCode is 404
    throw new errors.NotFound('Document could not be found.')
  else if proxyRes.statusCode >= 400
    throw new errors.BadGatewayError()
  res.send(proxyRes.body)

  
module.exports = {
  getAPCSPFile
}
