import { LightningElement, api } from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationFinishEvent,FlowNavigationBackEvent  } from 'lightning/flowSupport';
import getAsyncJobByJobItem from '@salesforce/apex/HDT_UTL_HerokuPostSalesManager.getAsyncJobByJobItem';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class HdtSpinnerFlow extends LightningElement {

    @api recordId;
    @api availableActions = [];
    
    connectedCallback() {

        var interval = setInterval(() => {

            getAsyncJobByJobItem({recordId: this.recordId})
            .then(result => {

                console.log('#Result --> '+result);

                if(result === 'OK'){
                    clearInterval(interval);
                    this.loadingSpinner = false;
                    this.handleGoNext();
                } else if(result === 'Error'){
                    clearInterval(interval);
                    this.loadingSpinner = false;
                    this.showCustomToast();
                    this.handleGoNext();
                }

            }).catch(error => {

                console.log('#Error --> ' +error);

            });

        }, 5000)

    }


    handleGoNext() {
        if(this.availableActions.find(action => action === 'NEXT')){

            const navigateNextEvent = new FlowNavigationNextEvent();

            this.dispatchEvent(navigateNextEvent);

        } else {

            const navigateFinish = new FlowNavigationFinishEvent();

            this.dispatchEvent(navigateFinish);
        }

    }

    showCustomToast(){

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Errore',
                message: 'Invio della pratica non riuscito.',
                variant: 'error',
            }),
        );

    }

}