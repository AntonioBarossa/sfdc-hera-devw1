({
    closeModal:function(component,event,helper){    
        var cmpTarget = component.find('modalbox');
        var cmpBack = component.find('modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
    },

    openModal:function(component,event,helper){    
        var cmpTarget = component.find('modalbox');
        var cmpBack = component.find('modalbackdrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open');
    }

})