({
   checkUserProfile : function(component)
   {
        var action = component.get("c.checkAdministratorProfile");
        action.setCallback(this, function(response)
            {
                console.log('HideGear: Response >>> ' + JSON.stringify(response.getReturnValue()));
                return response.getReturnValue();
            }
        );
        $A.enqueueAction(action);
   }
})