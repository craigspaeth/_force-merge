//
// Generic events around bidding for auctions
//

var AUCTION_ID = (
  sd.AUCTION && sd.AUCTION.id ||
  sd.SALE && sd.SALE.id ||
  sd.UPCOMING_AUCTIONS && sd.UPCOMING_AUCTIONS[0].id ||
  location.pathname.replace('/auction/', '').split('/')[0] ||
  location.search.replace('?auction_id=','') ||
  null
);
var USER_AUCTION = {};
if (sd.CURRENT_USER) USER_AUCTION.user_id = sd.CURRENT_USER.id;
if (AUCTION_ID) USER_AUCTION.auction_slug = AUCTION_ID;

// -----------------------------------------------------------------------------
// Events from https://trello.com/c/nqmq1yjL/264-web-send-data-to-segment
// -----------------------------------------------------------------------------

// Notify me auction form opened
$(".auction-preview-sidebar-email input").focus(function() {
  analytics.track('Notify me auction form opened', { nonInteraction: 1 });
});

// Notify me form submitted on the auction registration page
$(document).on('click', '.auction-preview-sidebar-email .avant-garde-box-button-black', function() {
  analytics.track(
    'Notify me form submitted on the auction registration page', USER_AUCTION);
});
analytics.trackLink(
  $('#auction-page [href*=sign_up]')[0],
  'Notify me form submitted on the auction registration page'
);

// Clicked “Register to bid” on the auction feature page
// There is no "Register" button on /auction/:id like Force

// Clicked "Register" in the Thank You / Auction modal
analytics.trackLink(
  $('.auction-subscribed-thank-you [href*=sign_up]')[0],
  'Clicked “Register to bid” on the auction feature page',
  USER_AUCTION
);

// Successful registration on auction feature page
analyticsHooks.on('auth:signup', function(data) {
  analytics.track(
    'Successful registration on auction feature page', USER_AUCTION);
});

// Registration submitted
analyticsHooks.on('registration:submitted', function(){
  analytics.track('Registration submitted', USER_AUCTION);
});

// Registration submit billing address
analyticsHooks.on('registration:submitted-address', function(options) {
  analytics.track('Registration submit billing address', USER_AUCTION);
});

// Registration card validated
analyticsHooks.on('registration:validated', function(options) {
  analytics.track('Registration card validated', USER_AUCTION);
});

// Clicked “Bid” on the artwork page
analytics.trackLink(
  $('.artwork-bid-button')[0],
  'Clicked “Bid” on the artwork page',
  USER_AUCTION
);

// Clicked “Bid” button on artwork item from auction feature page
// Does not exist in MG, just list item links

// Clicked “Confirm Bid” on bid page
$('#feature-bid-page-container .avant-garde-box-button-black').click(function() {
  analytics.track('Clicked “Confirm Bid” on bid page', USER_AUCTION);

  // Error placing your bid
  $(document).one('ajaxError', function(e, jqXHR, settings, error) {
    analytics.track('Error placing your bid', jqXHR.responseText);
  });
});

// Confirmed bid on bid page
analyticsHooks.on('confirm:bid', function(bidderPosition) {
  analytics.track('Confirmed bid on bid page', {
    user_id: USER_AUCTION.user_id,
    auction_slug: USER_AUCTION.auction_slug,
    bidder_position_id: bidderPosition.id
  });
});

// Auction Page Pageview
if (location.pathname.match(new RegExp('auction/.*')) &&
   !location.pathname.match(new RegExp('auction/.*/'))) {
  analytics.track("Auction Page Pageview", {
    slug: AUCTION_ID, preview: sd.AUCTION.auction_state, nonInteraction: 1
  });
}

// -----------------------------------------------------------------------------
// Misc Events
// -----------------------------------------------------------------------------

// Clicked "Register" in the Thank You / Auction modal
$(document).on('click', '.auction-subscribed-register', function() {
  analytics.track('Clicked "Register" in the Thank You / Auction modal');
});

// Clicked "Skip" in the Thank You / Auction modal
$(document).on('click', '.auction-subscribed-skip', function() {
  analytics.track('Clicked "Skip" in the Thank You / Auction modal');
});

// Showed ‘Confirm bid on artwork page’
if (location.pathname.match(/artwork\/.*\/bid/))
  analytics.track("Showed 'Confirm bid on artwork page'", { nonInteraction: 1 });

// Trigged login for bid registrations
if (location.pathname.includes('/log_in') && location.search.includes("?redirect_uri=/auction-registration/")) {
  analytics.track('Trigged login form via register to bid button')
}

// Criteo tracking
window.criteo_q = window.criteo_q || [];
var pathSplit = location.pathname.split('/')
if (pathSplit[1] == 'auctions') {
  criteo_q.push(
    { event: "setAccount", account: sd.CRITEO_ACCOUNT_NUMBER },
    { event: "setSiteType", type: "d" },
    { event: "viewHome" }
  )
} else if (pathSplit[1] == 'auction' && pathSplit[3] == null) {
  window.criteo_q.push(
    { event: "setAccount", account: sd.CRITEO_ACCOUNT_NUMBER },
    { event: "setSiteType", type: "d" },
    { event: "viewList", item: sd.ARTWORKS.map(function(a) { return a._id }) }
  )
} else if (pathSplit[1] == 'artwork' && pathSplit[3] == null) {
  window.criteo_q.push(
    { event: "setAccount", account: sd.CRITEO_ACCOUNT_NUMBER },
    { event: "setSiteType", type: "d" },
    { event: "viewItem", item: sd.AUCTION && sd.AUCTION.artwork_id }
  )
} else if (pathSplit[1] == 'auction' && pathSplit[3] == 'bid') {
  analyticsHooks.on('confirm:bid', function(bidderPosition) {
    price = bidderPosition.get('max_bid_amount_cents') ? bidderPosition.get('max_bid_amount_cents') / 100 : null;
    window.criteo_q.push(
      { event: "setAccount", account: sd.CRITEO_ACCOUNT_NUMBER },
      { event: "setSiteType", type: "d" },
      {
        event: "trackTransaction",
        id: bidderPosition.get('bidder').id,
        item: [
          {
            id: bidderPosition.get('sale_artwork').artwork.id,
            price: price,
            quantity: 1
          }
        ]
      }
    )
  });
}
