/** This LWC has the purpose of reset flow transaction
 * It can be implemented in a screen flow
 * It shows a lightning spinner for 2 s
 * The screen makes the flow closes the last transaction and starts a new one
 */
import { LightningElement, api } from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationFinishEvent,FlowNavigationBackEvent  } from 'lightning/flowSupport';

export default class HdtResetTransaction extends LightningElement 
{
    /* Flow Variable for available actions (e.g. NEXT, FINISH, BACK, exc.) */
    @api availableActions = [];


    connectedCallback()
    {
        this.resetTransaction();
    }

    resetTransaction()
    {
        setTimeout(() => 
        {   
            this.handleGoNext();
        }, 2000);
    }


    handleGoNext() 
    {
        if(this.availableActions.find(action => action === 'NEXT')){
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        } else {
            const navigateFinish = new FlowNavigationFinishEvent();
            this.dispatchEvent(navigateFinish);
        }
    }


}