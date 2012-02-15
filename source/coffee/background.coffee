# cache
count = null
contents = null
templates = {}


# underscore
_.templateSettings = 
  interpolate: /\{\{(.+?)\}\}/g
  evaluate: /\{%(.+?)%\}/g
  escape: /\{%-(.+?)%\}/g


class Cache
  # ttl: time to live
  constructor: (@ttl, @reflesh) ->
    @last = null
    @value = null

  get: ->
    if @last is null or Date.now() - @last > @ttl
      # update the value
      @last = Date.now()
      @reflesh()
    else
      @value


parseNotificationData = (notifications) ->
  parseRow = (row) ->
    content = _.template templates[row.action]
                        , names: (user.display_name for user in row.users).join ', '
    data = 
      action: row.action
      object: row.object
      created_at: row.created_at
      image_url: row.users[0].profile_image_url
      name: row.users[0].url_name
      seen: row.seen
      content: content
    _.template templates.notification, data
  (parseRow(row) for row in notifications).join('')


parseChunkData = (chunks) ->
  parseRow = (row) ->
    data = {}
    for own key, value of row
      data[key] = value
    _.template(templates.chunk, data)
  (parseRow(row) for row in chunks).join('')


checkCount = ->
  $.when(count.get())
    .done((data) ->
      chrome.browserAction.setBadgeText text: data.count.toString()
      color = if data.count is 0 then [100, 100, 100, 255] else [204, 60, 41, 255]
      chrome.browserAction.setBadgeBackgroundColor color: color
    )
    .fail(->
      chrome.browserAction.setBadgeText text: '-'
      chrome.browserAction.setBadgeBackgroundColor color: [100, 100, 100, 255]
    )


readAll = ->
  content.seen = true for content in contents.notifications.value


chrome.extension.onRequest.addListener (req, sender, res) ->
  if req.action is 'click'
    $.when(contents[req.menu].get())
      .done((data) ->
        if req.menu is 'notifications'
          chrome.browserAction.setBadgeText text: '0'
          chrome.browserAction.setBadgeBackgroundColor color: [100, 100, 100, 255]
          res(parseNotificationData(data))
          readAll()
          $.get 'http://qiita.com/api/notifications/read' # call read api
        else
          res(parseChunkData(data))
      )
      .fail(->
        res(templates.login_required)
      )


cacheFactory = (pathname, ttl) ->
  new Cache(
    ttl or 1000 * 60
    ->
      dfd = $.Deferred()
      $.ajax "http://qiita.com#{pathname}",
        success: (data, status, jqXHR) =>
          @value = data
          dfd.resolve(@value)
        error: ->
          dfd.reject()
        dataType: 'json'
      return dfd
  )


$ ->
  # initialize cache objects
  contents =
    notifications: cacheFactory('/api/notifications')
    following: cacheFactory('/following')
    'all-posts': cacheFactory('/public')
  count = cacheFactory('/api/notifications/count')
  templates.notification = $('#notification').html()
  templates.chunk = $('#chunk').html()
  templates.login_required = $('#login-required').html()
  for id in ['follow_user', 'update_posted_chunk', 'increment', 'stock']
    templates[id] = $("##{id}").html()

  checkCount()

  setInterval(
    -> checkCount()
    1000 * 150
  )
