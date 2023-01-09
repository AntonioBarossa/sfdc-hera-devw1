import { LightningElement, api, wire } from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationFinishEvent,FlowNavigationBackEvent  } from 'lightning/flowSupport';
import getAsyncJobByJobItem from '@salesforce/apex/HDT_UTL_HerokuPostSalesManager.getAsyncJobByJobItem';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { MessageContext, publish } from "lightning/messageService";
import BUTTONMC from "@salesforce/messageChannel/flowButton__c";

//Time out for callout in seconds
const timeOut = 30;

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
    @api disabledNavigationEvent;
    @api sessionid;
    @api stopNavigationEvent;

    @api availableActions = [];

    @wire(MessageContext)
	messageContext;


    connectedCallback(){

        if(this.loadingSpinner){    

            var startTime = this.getTime();
            var timeoutTime = startTime + timeOut;

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
                        this.showCustomToast('Errore','Comunicazione Fallita','error');
                        this.handleGoNext();
                    } else if(this.getTime() >= timeoutTime)
                    {
                        clearInterval(interval);
                        this.loadingSpinner = false;
                        this.showCustomToast('Richiesta Presa in Carico','La richiesta è stata presa in carico','info');
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

    getTime(){

        console.log('###### Inside getTime ######');

        const d = new Date();
        const seconds = d.getSeconds();
        const min = d.getMinutes();

        console.log('#StartSeconds -> '+seconds);  
        
        return seconds + min * 60;

    }

    showCustomToast(titleStr, messageStr, variantStr){

        this.dispatchEvent(
            new ShowToastEvent({
                title: titleStr,
                message: messageStr,
                variant: variantStr,
            }),
        );

    }

    handleClick(event){

        console.log('#StandAlone --> '+this.standAlone);

        console.log('#ButtonName --> '+event.target.name);

        console.log('AVAILABLE_ACTIONS --> ' +this.availableActions);

        if(this.sessionid){
            const payload = { message: event.target.name,  sessionid : this.sessionid};
            publish(this.messageContext, BUTTONMC, payload);
        }

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
        if(!this.disabledNavigationEvent){
            if(this.availableActions.find(action => action === 'NEXT')){

                const navigateNextEvent = new FlowNavigationNextEvent();

                this.dispatchEvent(navigateNextEvent);

            } else {

                const navigateFinish = new FlowNavigationFinishEvent();

                this.dispatchEvent(navigateFinish);
            }
        }
    }

    handlePrevious(){
        const navigateBackEvent = new FlowNavigationBackEvent();
        this.dispatchEvent(navigateBackEvent);
    }


}