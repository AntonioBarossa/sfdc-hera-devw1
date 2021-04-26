({
    navigateToCommunityPage : function(params) {
        //Find the text value of the component with aura:id set to "address"
        var address = '/wizard-vendita?c__accountId='+params.accountId+'&c__saleId='+params.venditeId;
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": address,
          "isredirect": true
        });
        urlEvent.fire();
        location.reload();
      }
})
