# name: discourse-simple-unread
# about: Adds a tab which combines new/unread without complex tracking states
# version: 0.1
# authors: David Taylor
# url: https://github.com/davidtaylorhq/discourse-simple-unread

Discourse.top_menu_items.push(:unseen)
Discourse.filters.push(:unseen)

after_initialize do

  class ::TopicQuery

    def list_unseen
      create_list(:unseen) do |topics|
        col_name = @user&.staff? ? "highest_staff_post_number" : "highest_post_number"
        earliest_date = @user.first_seen_at

        # Bumped at after the user first logged in
        topics = topics.where("topics.bumped_at >= :bumped_at", bumped_at: earliest_date)

        # Unread
        topics = topics.where("tu.last_read_post_number IS NULL OR tu.last_read_post_number < topics.#{col_name}")

        topics
      end

    end

  end

end
