import { withPluginApi } from 'discourse/lib/plugin-api';
import showModal from 'discourse/lib/show-modal';
import { popupAjaxError } from 'discourse/lib/ajax-error';
import { ajax } from 'discourse/lib/ajax';

function initialize(api) {
  api.modifyClass('controller:discovery/topics', {
    showDismissRead: function(){
      var superVal = this._super();

      const isUnseenWithTopics = this.isFilterPage(this.get('model.filter'), 'unseen') && this.get('model.topics.length') > 0;

      return superVal || isUnseenWithTopics;
    }.property('model.filter', 'model.topics.length'),

    showDismissAtTop: function() {
      if(this.isFilterPage(this.get('model.filter'), 'unseen')){
        return this.get('model.topics.length') >= 30;
      }else{
        return this._super();
      }
    }.property('model.filter', 'model.topics.length'),

    actions: {
      dismissReadPosts(){
        if(this.isFilterPage(this.get('model.filter'),'unseen')){
          showModal('dismiss-unseen', { title: 'topics.dismiss_unseen.title' });
        }else{
          this._super();
        }
      },

      dismissUnseenTopics(){
        ajax("/simple-unread/dismiss", {
          type: "PUT",
          data: { category_id: this.get('category.id') }
        }).then(() => {
          this.send('closeModal');
          this.send('refresh');
        }).catch(popupAjaxError);
      }
    }

  });

  api.modifyClass('route:discovery', {
    actions: {
      dismissUnseenTopics(){
        this.controllerFor("discovery/topics").send('dismissUnseenTopics');
      }
    }
  });
}

export default {
  name: "extend-topics-controller",
  initialize() {
    withPluginApi('0.8.9', initialize);
  }
};

