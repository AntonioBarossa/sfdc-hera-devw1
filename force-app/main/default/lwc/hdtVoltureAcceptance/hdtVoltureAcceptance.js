import { LightningElement,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getActivity  from '@salesforce/apex/HDT_LC_VoltureAcceptance.getActivity';
import updateOrder  from '@salesforce/apex/HDT_LC_VoltureAcceptance.updateOrder';

export default class HdtVoltureAcceptance extends LightningElement {
    @api recordId;
    showSpinner = true;

    connectedCallback(){
        console.log('@@@@@recordId ' + this.recordId);
        if (this.recordId){
            this.showSpinner = false;
        }
    }

    handleClick(event){
        this.showSpinner = true;
        this.start(event.currentTarget.name);
    }

    async start(btnName){
        try{    
            let response = await getActivity({activityId : this.recordId});
            console.log("@@@@Response " + response);
            let activity = JSON.parse(response);
            if (activity.isUserActivity__c === true || activity.isUserActivity__c ==="true"){
                this.next(btnName,this.recordId,activity.Order__c);
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Attenzione',
                        message: 'L\'attività può essere gestita solo dall\'assegnatario.',
                        variant: 'error',
                    }),
                );
                this.showSpinner = false;
            }
        }catch(error){
            console.error(error);
        }
         
    }

    async next(btnName,actId,ordId){
        try{
            let response = await updateOrder({
                activityId : actId, 
                orderId :  ordId, 
                operation : btnName
            });
            if (response !=='OK'){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Attenzione',
                        message: response,
                        variant: 'error',
                    }),
                );
                this.showSpinner = false;
            }else{
                window.location.reload();
            }
        }catch (error){
            console.error(error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Attenzione',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
            this.showSpinner = false;
        }
    }
}