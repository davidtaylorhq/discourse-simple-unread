# name: discourse-simple-unread
# about: Adds a tab which combines new/unread without complex tracking states
# version: 0.1
# authors: David Taylor
# url: https://github.com/davidtaylorhq/discourse-simple-unread
# transpile_js: true

PLUGIN_NAME ||= "discourse-simple-unread".freeze

enabled_site_setting :simple_unread_enabled

after_initialize do
  module ::SimpleUnread
    class Engine < ::Rails::Engine
      engine_name PLUGIN_NAME
      isolate_namespace SimpleUnread
    end
  end

  TopicQuery.add_custom_filter(:unseen) do |results, topic_query|
    next results if !topic_query.user
    if topic_query.options[:unseen] == 'true'
      earliest_date = topic_query.user.first_seen_at

      results = results.where("topics.bumped_at >= :bumped_at", bumped_at: earliest_date)

      col_name = topic_query.user.staff? ? "highest_staff_post_number" : "highest_post_number"
      results = results.where("tu.last_read_post_number IS NULL OR tu.last_read_post_number < topics.#{col_name}")
    end
    results
  end
end
