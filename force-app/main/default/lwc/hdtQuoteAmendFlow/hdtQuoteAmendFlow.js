import { api } from 'lwc';
import HdtQuoteAmendContract from 'c/hdtQuoteAmendContract';
import { FlowNavigationNextEvent, FlowNavigationFinishEvent  } from 'lightning/flowSupport';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class HdtQuoteAmendFlow extends HdtQuoteAmendContract {
    @api contractId;
    @api isCommunity;
    @api availableActions = [];
    title="Rimozione Agevolazione";

    handleCloseModal(){
        if(this.availableActions.find(action => action === 'NEXT')){
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        } else {
            const navigateFinish = new FlowNavigationFinishEvent();
            this.dispatchEvent(navigateFinish);
        }
    }
}