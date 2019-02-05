Ember.Handlebars.helper 'pretty_time', (timestamp) ->
  moment(timestamp).format('llll')

Ember.Handlebars.helper 'pretty_timestamp', (timestamp) ->
  new Ember.Handlebars.SafeString("<span class='timestamp' title='#{moment(timestamp).format('llll')}'>#{moment(timestamp).fromNow(true)} ago</span>")

Ember.Handlebars.helper 'pretty_timestamp_labeled', (timestamp, label) ->
  new Ember.Handlebars.SafeString("<span class='timestamp' title='#{moment(timestamp).format('llll')}'>#{label}: #{moment(timestamp).fromNow(true)} ago</span>")

Ember.Handlebars.helper 'pretty_timespan', (start_time, end_time) ->
  if end_time
    new Ember.Handlebars.SafeString("<span class='timestamp'>#{moment(start_time).format('LT')} - #{moment(end_time).format('LT')}</span>")
  else
    new Ember.Handlebars.SafeString("<span class='timestamp'>#{moment(start_time).format('LT')}</span>")
