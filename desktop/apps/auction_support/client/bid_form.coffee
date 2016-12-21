_ = require 'underscore'
Backbone = require 'backbone'
sd = require('sharify').data
analyticsHooks = require '../../../lib/analytics_hooks.coffee'
ModalPageView = require '../../../components/modal/page.coffee'
BidderPosition = require '../../../models/bidder_position.coffee'
CurrentUser = require '../../../models/current_user.coffee'
ErrorHandlingForm = require '../../../components/credit_card/client/error_handling_form.coffee'
{ SESSION_ID } = require('sharify').data

module.exports = class BidForm extends ErrorHandlingForm

  timesPolledForBidPlacement: 0
  maxTimesPolledForBidPlacement: sd.MAX_POLLS_FOR_MAX_BIDS
  errors:
    "Sale Closed to Bids": "Sorry, your bid wasn't received before the auction closed."
    connection: "Your bid didn't make it to us. Please check your network connectivity and try again."
    "Bidder not qualified to bid on this auction.": "Sorry, we could not process your bid. <br>Please contact <a href='#' class='js-contact-specialist'>Artsy staff</a> for support."

  events:
    'click .registration-form-content .avant-garde-button-black': 'placeBid'
    'click .bidding-question': 'showBiddingDialog'

  initialize: ({ @saleArtwork, @bidderPositions, @submitImmediately }) ->
    @user = CurrentUser.orNull()
    @$submit = @$('.registration-form-content .avant-garde-button-black')
    @placeBid() if @submitImmediately
    @$('.max-bid').focus() unless @submitImmediately

    # extend form's errors with our own
    @errors = _.defaults @errors, ErrorHandlingForm.prototype.errors

  showBiddingDialog: (e) ->
    e.preventDefault()
    new ModalPageView
      width: '700px'
      pageId: 'auction-info'

  getBidAmount: =>
    val = @$('.max-bid').val()
    @saleArtwork.cleanBidAmount val if val

  placeBid: =>
    @timesPolledForBidPlacement = 0
    @$submit.addClass('is-loading')
    @clearErrors()

    if @getBidAmount() >= @bidderPositions.minBidCents()
      bidderPosition = new BidderPosition
        sale_id: @model.get('id')
        artwork_id: @saleArtwork.get('artwork').id
        max_bid_amount_cents: @getBidAmount()
      bidderPosition.save null,
        timeout: 30000
        success: (model, response, options) =>
          _.delay =>
            @pollForBidderPositionProcessed(model)
          , 1000
        error: (model, response) =>
          @showError 'Error placing your bid', response
    else
      @showError "Your bid must be higher than #{@bidderPositions.minBid()}"

  pollForBidderPositionProcessed: (bidderPosition) ->
    bidderPosition.fetch
      success: (bidderPosition) =>
        if bidderPosition.has('processed_at')
          if bidderPosition.get('active')
            analyticsHooks.trigger 'confirm:bid:form:success', {
              bidder_position_id: bidderPosition.id
              bidder_id: bidderPosition.get('bidder')?.id
              max_bid_amount_cents: bidderPosition.get('max_bid_amount_cents')
            }
            @showSuccessfulBidMessage()
          else
            @showError "You've been outbid, increase your bid"
        else if @timesPolledForBidPlacement > @maxTimesPolledForBidPlacement
          @showError "Your bid result is not yet available. Please contact support@artsy.net."
        else
          @timesPolledForBidPlacement += 1
          _.delay =>
            @pollForBidderPositionProcessed bidderPosition
          , 1000

  showSuccessfulBidMessage: =>
    window.location = @saleArtwork.artwork().bidSuccessUrl()
