({
	advancedRedirect : function(cmp, recordId) {
		var navService = cmp.find("navService");
    var pageReference = {    
       "type": "standard__recordPage", //example for opening a record page, see bottom for other supported types
       "attributes": {
       "recordId": recordId, //place your record id here that you wish to open
       "actionName": "view"
        }
    }

    navService.generateUrl(pageReference)
    .then($A.getCallback(function(url) {
      console.log('success: ' + url); //you can also set the url to an aura attribute if you wish
      window.open(url,'_blank'); //this opens your page in a seperate tab here
    }), 
    $A.getCallback(function(error) {
      console.log('error: ' + error);
    }));
	}
})