extend = require("lodash/extend")
isObject = require("lodash/isObject")
isString = require("lodash/isString")
isUndefined = require("lodash/isUndefined")

cloudinary_config = undefined

isNestedKey = (key)->
  key.match /\w+\[\w+\]/

###**
  * Assign a value to a nested object
  * @function putNestedValue
  * @param params the parent object - this argument will be modified!
  * @param key key in the form nested[innerkey]
  * @param value the value to assign
  * @return the modified params object
###
putNestedValue = (params, key, value)->
  chain = key.split(/[\[\]]+/).filter((i)=> i.length)
  outer = params
  lastKey = chain.pop()
  for innerKey in chain
    inner = outer[innerKey]
    unless inner?
      inner = {}
      outer[innerKey] = inner
    outer = inner

  outer[lastKey] = value

module.exports = (new_config, new_value) ->
  if !cloudinary_config? || new_config == true
    cloudinary_url = process.env.CLOUDINARY_URL
    if cloudinary_url?
      uri = require('url').parse(cloudinary_url, true)
      cloudinary_config =
        cloud_name: uri.host,
        api_key: uri.auth and uri.auth.split(":")[0],
        api_secret: uri.auth and uri.auth.split(":")[1],
        private_cdn: uri.pathname?,
        secure_distribution: uri.pathname and uri.pathname.substring(1)
      if uri.query?
        for k, v of uri.query
          if isNestedKey(k)
            putNestedValue cloudinary_config, k, v
          else
            cloudinary_config[k] = v
    else
      cloudinary_config = {}
  if not isUndefined(new_value)
    cloudinary_config[new_config] = new_value
  else if isString(new_config)
    return cloudinary_config[new_config]
  else if isObject(new_config)
    extend(cloudinary_config, new_config)
  cloudinary_config
