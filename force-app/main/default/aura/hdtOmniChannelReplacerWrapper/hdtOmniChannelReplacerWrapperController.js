({
    doInit : function(component, event, helper) {
        setTimeout(function() {
            var utilityBarAPI = component.find("utilitybar");
            utilityBarAPI.onUtilityClick({eventHandler: function(response) {
                    utilityBarAPI.setUtilityHighlighted({highlighted: false});
                    utilityBarAPI.setUtilityIcon({icon: 'list'})
                }.bind(this)
            });
        }, 0);
    },
    doNotify : function (component, event, helper) {
        var utilityBarAPI = component.find("utilitybar");
        utilityBarAPI.setUtilityHighlighted({highlighted: true});
        utilityBarAPI.setUtilityIcon({icon: 'alert'});
    }
})
