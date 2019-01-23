Twitarr.SearchIndexController = Twitarr.Controller.extend()

Twitarr.SearchResultsController = Twitarr.ObjectController.extend
  error: ''

  actions:
    user_search: ->
      @transitionToRoute('search.user_results', @get('query'))
    tweet_search: ->
      @transitionToRoute('search.tweet_results', @get('query'))
    forum_search: ->
      @transitionToRoute('search.forum_results', @get('query'))
    event_search: ->
      @transitionToRoute('search.event_results', @get('query'))

Twitarr.SearchUserResultsController = Twitarr.ObjectController.extend
  error: ''

Twitarr.SearchTweetResultsController = Twitarr.ObjectController.extend
  error: ''

Twitarr.SearchForumResultsController = Twitarr.ObjectController.extend
  error: ''

Twitarr.SearchEventResultsController = Twitarr.ObjectController.extend
  error: ''

Twitarr.SearchUserPartialController = Twitarr.ObjectController.extend()
