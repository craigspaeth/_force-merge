_ = require 'underscore'
Backbone = require 'backbone'
Profile = require '../../models/profile.coffee'
{ Following, FollowButton } = require '../../components/follow_button/index.coffee'
CurrentUser = require '../../models/current_user.coffee'
ShowInquiryModal = require '../contact/show_inquiry_modal.coffee'

module.exports = class PartnerShowButtons extends Backbone.View

  initialize: (options) ->
    _.extend @, options
    @following = new Following(null, kind: 'profile')
    @following.syncFollows [@model.get('partner')?.default_profile_id]
    new FollowButton
      el: @$('.plus-follow-button')
      modelName: 'profile'
      model: new Profile(id: @model.get('partner')?.default_profile_id)
      following: @following
      context_module: 'Partner show module'

  events:
    'click .partner-buttons-contact': 'contactGallery'

  contactGallery: ->
    new ShowInquiryModal show: @model
