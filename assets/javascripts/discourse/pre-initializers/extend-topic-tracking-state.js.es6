import { withPluginApi } from 'discourse/lib/plugin-api';

function initialize(api) {
  api.modifyClass('model:topic-tracking-state', {
    notify(data){
      this._super(data);
      const filter = this.get("filter");

      if (data.payload && data.payload.archetype === "private_message") { return; }

      if ((filter === "unseen") && (data.message_type === "new_topic" || data.message_type === "latest" )) {
        this.addIncoming(data.topic_id);
      }
    },

  });
}

export default {
  name: "extend-topic-tracking-state",
  before: "inject-discourse-objects",
  initialize() {
    withPluginApi('0.8.9', initialize);
  }
};