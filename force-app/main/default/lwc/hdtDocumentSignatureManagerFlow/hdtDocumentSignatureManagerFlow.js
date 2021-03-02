import { LightningElement,track,api } from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationFinishEvent,FlowNavigationBackEvent  } from 'lightning/flowSupport';

export default class HdtDocumentSignatureManagerFlow extends LightningElement {
    @api processType;
    @api quoteType;
    @api outcome;
    @api availableActions = [];
    @api cancelCase;

    handleGoNext() {

        this.cancelCase = false;

        if(this.availableActions.find(action => action === 'NEXT')){

            const navigateNextEvent = new FlowNavigationNextEvent();

            this.dispatchEvent(navigateNextEvent);

        } else {

            const navigateFinish = new FlowNavigationFinishEvent();

            this.dispatchEvent(navigateFinish);
        }

    }

    handleCancel(){

        if(this.availableActions.find(action => action === 'NEXT')){

            this.cancelCase = true;

            const navigateNextEvent = new FlowNavigationNextEvent();

            this.dispatchEvent(navigateNextEvent);

        } else {

            const navigateFinish = new FlowNavigationFinishEvent();

            this.dispatchEvent(navigateFinish);
        }

    }

    handleGoBack(){

        const navigateBackEvent = new FlowNavigationBackEvent();

        this.dispatchEvent(navigateBackEvent);

    }

}