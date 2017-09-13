# name: discourse-simple-unread
# about: Adds a tab which combines new/unread without complex tracking states
# version: 0.1
# authors: David Taylor
# url: https://github.com/davidtaylorhq/discourse-simple-unread

Discourse.top_menu_items.push(:unseen)
Discourse.filters.push(:unseen)

PLUGIN_NAME ||= "discourse-simple-unread".freeze

after_initialize do

  module ::SimpleUnread
    class Engine < ::Rails::Engine
      engine_name PLUGIN_NAME
      isolate_namespace SimpleUnread
    end
  end

  class ::TopicQuery

    def self.unseen_filter(list, earliest_date, is_staff)
      col_name = is_staff ? "highest_staff_post_number" : "highest_post_number"

      # Bumped at after the user first logged in
      list = list.where("topics.bumped_at >= :bumped_at", bumped_at: earliest_date)

      # Unread
      list = list.where("tu.last_read_post_number IS NULL OR tu.last_read_post_number < topics.#{col_name}")

      list
    end

    def list_unseen
      create_list(:unseen) do |topics|
        is_staff = @user&.staff?
        earliest_date = @user.first_seen_at

        TopicQuery.unseen_filter(topics, earliest_date, is_staff)
      end

    end

  end

  class SimpleUnread::DismissController < ::ApplicationController
    before_filter :ensure_logged_in

    # This is based on topics_controller's "bulk" method
    def dismiss_unseen
      tq = TopicQuery.new(current_user)
      topics = TopicQuery.unseen_filter(tq.joined_topic_user, current_user.first_seen_at, current_user.staff?).listable_topics
      topics = topics.where('category_id = ?', params[:category_id]) if params[:category_id]
      topic_ids = topics.pluck(:id)
      operation = { type: 'dismiss_posts' }
      operator = TopicsBulkAction.new(current_user, topic_ids, operation)
      changed_topic_ids = operator.perform!
      render_json_dump topic_ids: changed_topic_ids
    end

  end

  SimpleUnread::Engine.routes.draw do
    put '/dismiss' => 'dismiss#dismiss_unseen'
  end

  Discourse::Application.routes.append do
    mount ::SimpleUnread::Engine, at: '/simple-unread'
  end

end
