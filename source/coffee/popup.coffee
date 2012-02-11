insertNotification = (action, object, created_at, seen, users) ->
  content = _.template templates[action]
                      , names: (user.display_name for user in users).join ', '
  data = 
    action: action
    object: object
    created_at: created_at
    image_url: users[0].profile_image_url
    name: users[0].url_name
    seen: seen
    content: content
  $ol.append($(_.template(list, data)))

$ ->
  $ol = $('ol#notification-list')

  $('body')
    .delegate 'a', 'click', (e) ->
      $a = if e.target.tagName is 'A' then $(e.target) else $(e.target).parents('a')
      chrome.tabs.create
        url: $a.attr('href')
        active: true

  chrome.extension.sendRequest 'click', (content) ->
    debugger
    $ol.html(content)
