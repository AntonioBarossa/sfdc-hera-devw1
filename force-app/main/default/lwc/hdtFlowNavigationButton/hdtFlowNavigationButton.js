import { LightningElement, api } from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationFinishEvent,FlowNavigationBackEvent  } from 'lightning/flowSupport';
import getAsyncJobByJobItem from '@salesforce/apex/HDT_UTL_HerokuPostSalesManager.getAsyncJobByJobItem';
export default class HdtFlowNavigationButton extends LightningElement {


    @api nextLabel;
    @api nextVariant;
    @api isDraft;
    @api isCancel;
    @api isPrevious;
    @api standAlone
    @api cancelCase;
    @api saveDraft;
    @api loadingSpinner = false;
    @api recordId;

    @api availableActions = [];


    connectedCallback(){

        if(this.loadingSpinner){

            var interval = setInterval(() => {

                getAsyncJobByJobItem({recordId: this.recordId})
                .then(result => {

                    console.log('#Result --> '+result);

                    if(result === 'OK'){
                        clearInterval(interval);
                        this.loadingSpinner = false;
                        this.handleGoNext();
                    }


                }).catch(error => {

                    console.log('#Error --> ' +error);

                });

            }, 5000)

            /*setTimeout(() => {

                this.loadingSpinner = true;
                this.handleGoNext();

            }, 30000);*/

        }

    }


    handleClick(event){

        console.log('#StandAlone --> '+this.standAlone);

        console.log('#ButtonName --> '+event.target.name);

        if(this.standAlone){

            if(event.target.name === 'save'){

                this.saveDraft = false;
                this.cancelCase = false;

                this.handleGoNext();

            } else if(event.target.name === 'draft'){

                this.saveDraft = true;
                this.cancelCase = false;

                this.handleGoNext();

            } else if(event.target.name === 'cancel'){

                this.saveDraft = false;
                this.cancelCase = true;

                this.handleGoNext();

            } else if(event.target.name === 'previous'){

                this.cancelCase = false;
                this.saveDraft = false;

                this.handlePrevious();

            }


        }else{
            
            this.dispatchEvent(new CustomEvent('navigation', {detail: event.target.name}));
        
        }

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

    handlePrevious(){
        const navigateBackEvent = new FlowNavigationBackEvent();
        this.dispatchEvent(navigateBackEvent);
    }


}