({

    rerender : function(cmp, helper){
        this.superRerender();
        if (document.getElementsByClassName("setupGear") != null)
            if (document.getElementsByClassName("setupGear").length > 0)
                document.getElementsByClassName("setupGear")[0].style.visibility="hidden";
    },
    afterRender: function (component, helper) {
        this.superAfterRender();
        var action = component.get("c.checkAdministratorProfile");
        action.setCallback(this, function(response)
            {
                console.log('HideGear: Response >>> ' + JSON.stringify(response.getReturnValue()));
                var checkAdministratoProfile = response.getReturnValue();
                if (document.getElementsByClassName("setupGear") != null)
                {
                    if (document.getElementsByClassName("setupGear").length > 0)
                    {
                        console.log('HidGear: CheckAdministratorProfile >>> ' + checkAdministratoProfile);
                        if(checkAdministratoProfile === true)
                        {
                            console.log('HideGear: inside check true');
                            document.getElementsByClassName("setupGear")[0].style.visibility="visible";
                        }
                        else
                        {
                            console.log('HideGear: inside check false');
                            document.getElementsByClassName("setupGear")[0].style.visibility="hidden"; 
                        }
                    }
                }
            }
        );
        $A.enqueueAction(action);
    }, 
})