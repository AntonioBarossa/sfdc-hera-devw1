import { LightningElement,api } from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationFinishEvent,FlowNavigationBackEvent  } from 'lightning/flowSupport';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class HdtAccountStatementPickerFlow extends LightningElement {
    @api contractAccount;
    @api billingProfileId;
    @api codiceCliente;
    @api caseId;
    @api processType;
    @api accountId;
    @api billingProblems;
    @api returnBillingProfileId;
    @api availableActions = [];
    @api saveButton;
    @api cancelButton;
    @api previousButton;
    @api draftButton;
	@api labelSaveButton;
    @api labelDraftButton;
    @api labelPreviousButton;

    handlePrevious(){
        const navigateBackEvent = new FlowNavigationBackEvent();
        this.dispatchEvent(navigateBackEvent);
    }
    handleNext() {
        console.log('BillingProblems --> ' + this.billingProblems);
        let returnValue = this.template.querySelector('c-hdt-account-statement-picker').checkBillingProblems();
        let billingProfileId = this.template.querySelector('c-hdt-account-statement-picker').getBillingProfileId();
        console.log('returnValue--> '+returnValue);
        this.returnBillingProfileId = billingProfileId;
        console.log('returnBillingProfileId--> '+billingProfileId);
        if(returnValue){

            return;

        }


        if(this.availableActions.find(action => action === 'NEXT')){    

            const navigateNextEvent = new FlowNavigationNextEvent();

            this.dispatchEvent(navigateNextEvent);

        } else {

            const navigateFinish = new FlowNavigationFinishEvent();

            this.dispatchEvent(navigateFinish);
        }

    }
}