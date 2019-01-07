Twitarr.LoadingRoute = Ember.Route.extend
  renderTemplate: ->
    @render 'loading'

Twitarr.ApplicationRoute = Ember.Route.extend
  actions:
    logout: ->
      $.getJSON("#{Twitarr.api_path}/user/logout").done (data) =>
        if data.status is 'ok'
          @controller.logout()
          @transitionTo 'stream.index'
    start_upload: ->
      @controller.incrementProperty 'uploads_pending'
    end_upload: ->
      @controller.decrementProperty 'uploads_pending'
    display_photo: (photo) ->
      @controllerFor('photo_view').set 'model', photo
      @render 'photo_view',
        into: 'application',
        outlet: 'modal'
    close_photo: ->
      @disconnectOutlet
        outlet: 'modal',
        parentView: 'application'
    display_seamail: (id) ->
      @transitionTo('seamail.detail', id)
    display_forum: (id, page) ->
      @transitionTo('forums.detail', id, page)
    display_tweet: (id) ->
      @transitionTo('stream.view', id)
    display_user: (username) ->
      @transitionTo('user.profile', username)
    display_event: (id) ->
      @transitionTo('schedule.detail', id)

Twitarr.IndexRoute = Ember.Route.extend
  redirect: ->
    @transitionTo 'stream.index'

Twitarr.AlertsRoute = Ember.Route.extend
  model: ->
    $.getJSON("#{Twitarr.api_path}/alerts").then (data) =>
      data.unread_seamail = Ember.A(Twitarr.SeamailMeta.create(seamail) for seamail in data.unread_seamail)
      data.tweet_mentions = Ember.A(Twitarr.StreamPost.create(post) for post in data.tweet_mentions)
      data.upcoming_events = Ember.A(Twitarr.EventMeta.create(event) for event in data.upcoming_events)
      data
  actions:
    reload: ->
      @refresh()

Twitarr.TagRoute = Ember.Route.extend
  model: (params) ->
    $.getJSON("#{Twitarr.api_path}/stream/h/#{params.tag_name}").then (data) ->
      data.tag_name = params.tag_name
      data

  setupController: (controller, model) ->
    controller.set 'tag_name', model.tag_name
    if model.status is 'ok'
      controller.set 'recent_tweets', model.posts
    else
      alert(model.status)

Twitarr.StarredRoute = Ember.Route.extend
  model: ->
    Twitarr.StarredMeta.get()

Twitarr.TimeRoute = Ember.Route.extend
  model: ->
    $.getJSON("#{Twitarr.api_path}/time").then (data) ->
      data

Twitarr.HelpRoute = Ember.Route.extend
  model: ->
    $.getJSON("#{Twitarr.api_path}/text/helptext").then (data) =>
      data
